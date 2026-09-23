#!/bin/sh
# Add-on entrypoint: translate Home Assistant add-on options → the env the bridge reads, then hand off.
#
# HA writes the user's options to /data/options.json (not env), so this is the one glue step the thin
# wrapper adds on top of the bridge image. /data is the add-on's persistent volume, so the login token
# survives restarts (eufy allows ONE session per account — re-auth escalates to 2FA).
set -e

OPTS=/data/options.json
SUPERVISOR_API="${SUPERVISOR:-http://supervisor}"

export EUFY_EMAIL="$(jq -r '.email // ""' "$OPTS")"
export EUFY_PASSWORD="$(jq -r '.password // ""' "$OPTS")"
export EUFY_COUNTRY="$(jq -r '.country // "GB"' "$OPTS")"
export EUFY_SESSION="/data/.eufy-session.json"
# Reachable through ingress + the hosted go2rtc ports (not just localhost).
export BRIDGE_HOST="0.0.0.0"

# Optional tuning → bridge env. Defaults in config.yaml mirror the bridge's own, so these are a no-op
# unless the user changes them. debug is a bool option; map it to the truthy string the bridge expects.
export EUFY_POLL_MS="$(jq -r '.poll_ms // 600000' "$OPTS")"
export STREAM_IDLE_MS="$(jq -r '.stream_idle_ms // 300000' "$OPTS")"
export RTSP_IDLE_OFF_MS="$(jq -r '.rtsp_idle_off_ms // 300000' "$OPTS")"
# Feature toggle: speculative P2P prewarm on high-intent events (off by default).
[ "$(jq -r '.prewarm // false' "$OPTS")" = "true" ] && export BRIDGE_PREWARM=1
# Per-event log line is on by default in the bridge; only override when the user turns it off.
[ "$(jq -r '.event_log // true' "$OPTS")" = "false" ] && export BRIDGE_EVENT_LOG=0
[ "$(jq -r '.debug // false' "$OPTS")" = "true" ] && export BRIDGE_DEBUG=1
[ "$(jq -r '.debug_p2p // false' "$OPTS")" = "true" ] && export BRIDGE_DEBUG_P2P=1
# Bundled go2rtc is on by default; only pass the override when the user turns it off.
[ "$(jq -r '.go2rtc_enable // true' "$OPTS")" = "false" ] && export GO2RTC_ENABLE=0

# Optional Anker Solix (a SEPARATE Anker account from eufy). Empty email/password ⇒ Solix stays off
# (the bridge enables it only when BOTH are set). Empty country ⇒ the bridge falls back to EUFY_COUNTRY.
# Its session persists on /data so the Solix login token survives restarts, like the eufy one.
export SOLIX_EMAIL="$(jq -r '.solix_email // ""' "$OPTS")"
export SOLIX_PASSWORD="$(jq -r '.solix_password // ""' "$OPTS")"
export SOLIX_COUNTRY="$(jq -r '.solix_country // ""' "$OPTS")"
export SOLIX_SESSION="/data/.solix-session.json"
export SOLIX_SCENE_POLL_MS="$(jq -r '.solix_scene_poll_ms // 90000' "$OPTS")"
export SOLIX_RETRY_BASE_MS="$(jq -r '.solix_retry_base_ms // 900000' "$OPTS")"
export SOLIX_RETRY_MAX_MS="$(jq -r '.solix_retry_max_ms // 3600000' "$OPTS")"

register_discovery() {
  if [ -z "${SUPERVISOR_TOKEN:-}" ]; then
    echo "[addon] SUPERVISOR_TOKEN is unavailable; skipping eufy_sdk discovery"
    return
  fi

  addon_info="$(curl -fsS -H "Authorization: Bearer ${SUPERVISOR_TOKEN}" "${SUPERVISOR_API}/addons/self/info")" || {
    echo "[addon] could not read Supervisor add-on info; skipping eufy_sdk discovery"
    return
  }
  network_info="$(curl -fsS -H "Authorization: Bearer ${SUPERVISOR_TOKEN}" "${SUPERVISOR_API}/network/info")" || network_info='{"data":{}}'

  addon_host="$(printf '%s' "$addon_info" | jq -r '.data.hostname // "eufy-sdk-bridge"')"
  gateway="$(printf '%s' "$network_info" | jq -r '.data.docker.gateway // empty')"

  port_value() {
    key="$1"
    internal="$2"
    mapped="$(printf '%s' "$addon_info" | jq -r --arg key "$key" '.data.network[$key] // empty')"
    if [ -n "$mapped" ] && [ -n "$gateway" ]; then
      printf '%s\n' "$mapped"
    else
      printf '%s\n' "$internal"
    fi
  }

  if [ -n "$gateway" ]; then
    bridge_host="$gateway"
  else
    bridge_host="$addon_host"
  fi
  bridge_port="$(port_value "3000/tcp" 3000)"
  rtsp_port="$(port_value "8554/tcp" 8554)"

  discovery_payload="$(
    jq -cn \
      --arg host "$bridge_host" \
      --argjson port "$bridge_port" \
      --argjson rtsp_port "$rtsp_port" \
      '{
        service: "eufy_sdk",
        config: {
          host: $host,
          port: $port,
          go2rtc_rtsp_port: $rtsp_port
        }
      }'
  )"

  if curl -fsS -X POST -H "Authorization: Bearer ${SUPERVISOR_TOKEN}" -H "Content-Type: application/json" \
    -d "$discovery_payload" "${SUPERVISOR_API}/discovery" >/dev/null; then
    echo "[addon] registered eufy_sdk discovery: bridge ${bridge_host}:${bridge_port}, rtsp ${bridge_host}:${rtsp_port}"
  else
    echo "[addon] could not register eufy_sdk discovery"
  fi
}

wait_for_bridge() {
  health_url="http://127.0.0.1:${BRIDGE_PORT:-3000}/healthz"
  ready_timeout_sec=30
  attempt=1

  echo "[addon] waiting for bridge health at ${health_url} before registering discovery"
  until curl -fsS "$health_url" >/dev/null; do
    if ! kill -0 "$bridge_pid" 2>/dev/null; then
      echo "[addon] bridge exited before discovery could be registered"
      return 1
    fi
    if [ "$attempt" -ge "$ready_timeout_sec" ]; then
      echo "[addon] bridge did not become healthy within ${ready_timeout_sec}s; skipping eufy_sdk discovery"
      return 1
    fi
    attempt=$((attempt + 1))
    sleep 1
  done
}

# Contract with ha-eufy-sdk-bridge: the bridge image provides this launcher, which starts the daemon
# AND go2rtc. Start it first so HA's discovery flow can immediately validate the WebSocket.
/usr/local/bin/eufy-sdk-bridge &
bridge_pid="$!"

stop_bridge() {
  kill -TERM "$bridge_pid" 2>/dev/null || true
  wait "$bridge_pid"
}
trap stop_bridge TERM INT

(
  wait_for_bridge && register_discovery
) &

wait "$bridge_pid"
