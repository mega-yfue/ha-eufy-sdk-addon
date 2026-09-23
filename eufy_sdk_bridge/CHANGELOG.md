# Changelog

## 0.4.0

- Built on **bridge 0.3.0**, which uses **eufy-sdk 0.2.0**. For the add-on, this means:
  - **Anker Solix now works on the stable add-on.** Fill in the `solix_*` options (a SEPARATE Anker
    account) to get Solarbank / smart-meter entities. Leaving them empty keeps Solix off.
  - **Several cameras on one HomeBase can stream at the same time.** A second camera no longer waits for
    the first to stop.
  - Accounts that failed every request with `gtoken not equal userid` can now log in.
  - A camera whose channel on its HomeBase is missing or shared with another device is refused with a
    clear error, instead of streaming whichever camera sits on that channel.
- New option **`go2rtc_enable`** (default on). Turn it off if Home Assistant's own go2rtc should serve the
  streams instead of the bundled one.
- New option **`stream_battery_budget_ms`**: how long a **battery** camera may stream continuously. Left
  empty, it keeps the SDK default, which drops a watched stream about every 55 s; raise it (e.g.
  `180000`) to keep the stream up. Mains cameras ignore it.

## 0.3.0

- Surface the bridge's **Anker Solix** settings as add-on options: `solix_email` / `solix_password` /
  `solix_country` (a SEPARATE Anker account — adds Solarbank / smart-meter entities), plus
  `solix_scene_poll_ms`, `solix_retry_base_ms`, `solix_retry_max_ms`. All optional; empty email/password
  keeps Solix off, so eufy-only setups are unaffected. (Solix runs today on the **dev** add-on, which
  tracks the bridge `:dev` image; the stable image gains it when its pinned bridge release catches up.)
- New **dev / edge** add-on — `eufy-sdk bridge (dev)`, `stage: experimental` (hidden unless HA Advanced
  Mode is on), branded with a red "DEV" ribbon. It builds from the bridge's rolling `:dev` image so
  testers can try changes before a stable release; a GitHub **pre-release** publishes it.
- Register Supervisor **discovery**, so the `eufy-sdk` integration auto-fills the bridge host + ports.
- Bump `home-assistant/builder` to 2026.09.0.

## 0.2.1

- Publish the bridge control port `3000/tcp` so the `eufy-sdk` integration can reach the bridge directly
  (ingress is an HA-frontend-authenticated proxy the raw-WS client can't traverse).
- Real add-on icon + logo (replaced the EXAMPLE placeholders).

## 0.2.0

- First public add-on: thin wrapper over `ha-eufy-sdk-bridge` published as release-driven prebuilt
  multi-arch images (amd64 + aarch64), options → env, ingress, and the go2rtc media ports.

## 0.1.36

- Track bridge `0.1.36`; pin `build_from` to the versioned ghcr tag (was floating `:latest`).
- Expose the bridge's tuning knobs as add-on options: `poll_ms`, `stream_idle_ms`, `rtsp_idle_off_ms`,
  and `debug` — each mirrors the bridge default, so existing setups are unaffected.

## 0.1.0

- Initial scaffold: thin add-on wrapper over `ha-eufy-sdk-bridge` (options → env, ingress, go2rtc ports).
