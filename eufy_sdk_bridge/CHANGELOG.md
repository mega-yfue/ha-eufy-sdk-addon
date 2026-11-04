# Changelog

## 0.8.0

- Built on **bridge 0.7.0** (now **eufy-sdk 0.5.0**, up from 0.4.0). For the add-on, this means:
  - **Video Doorbell Dual (T8213) now gets a doorbell button entity.** Its press was reaching the
    bridge but wasn't surfaced; the SDK now types it from the doorbell tables.
  - **T8210C** is recognised as a Video Doorbell.
  - **Siren** works on a camera behind a **HomeBase S1 Pro**.
  - **"Last event" thumbnails in the newer `v2_` format now decode**, including covers whose colour
    tables are encrypted.
  - **Lock** actuation fixes (HomeBase 3 route) and more reliable push delivery.
  - **Broader device support**: PTZ for the T8E00 and the T8354 Baby Monitor E21; the E330 Pro (T8600)
    spotlight switch.
- No new options.

## 0.7.0

- Built on **bridge 0.6.0** (still eufy-sdk 0.4.0). For the add-on, this means:
  - **HomeBase S1 Pro (T9000) can start its WebRTC connection.** The image now ships `node-datachannel`,
    prebuilt for amd64 and arm64 (Raspberry Pi). Some accounts still hit an RTC sign refusal (HTTP 401)
    first; that's an SDK fix in progress.
  - **No more auth tokens in logs or error messages**: a token eufy echoes back is redacted.
  - **Battery cameras stop draining from Home Assistant's stream worker** together with **integration
    0.6.0**: the bridge now tells the integration which cameras are on battery, so mains cameras keep HLS.
  - **Clearer logs**: a failed stream says why, startup reports whether the WebRTC library loads, and a
    "Last event" cover in a format the SDK can't decode yet is logged instead of looking like no reply.
- No new options. Pair it with **integration 0.6.0**.

## 0.6.0

- Built on **bridge 0.5.0** (still eufy-sdk 0.4.0). For the add-on, this means:
  - **No more duplicate bridges in Home Assistant.** The bridge now has a stable ID, so with integration
    0.5.1 a bridge you already added (e.g. by IP) is no longer offered again when it's discovered at
    `172.30.32.1`. If you already have two eufy-sdk entries for this add-on, delete the newer one.
  - **"Last event" images on a HomeBase 2** come from the HomeBase again (a new query the HomeBase 2
    answers). Covers stored in the newer `v2_` format also need a later SDK release.
  - **"Refresh Last Event"** no longer times out; it answers within 10 s and finishes in the background.
  - **The newest "Last event" image wins**: an older push thumbnail no longer replaces a newer HomeBase
    cover on local-storage accounts.
  - **Mains-powered cameras keep streaming** to a continuous viewer (an NVR, say) instead of being
    idle-suspended after 5 minutes. The idle auto-off now applies to battery cameras only.
- No new options. Pair it with **integration 0.5.1**.

## 0.5.0

- Built on **bridge 0.4.0**, which uses **eufy-sdk 0.4.0**. For the add-on, this means:
  - **Property changes reach Home Assistant as they happen**, instead of waiting for the next poll.
  - **Station face roster**: faces known to a HomeBase are available to the integration.
  - **Latest recording as a clip**: a HomeBase 2 camera's most recent recording can be served as an mp4.
  - **More readable values and settings**: the device manifest carries decoded readings, and write-only
    settings are exposed so Home Assistant can show them.
  - The "Last event" image waits for the detection's own thumbnail instead of showing the previous one.
  - Steadier streams: idle streams are closed reliably, one stream client is shared per camera while it
    logs in, and a stream ends cleanly with its feed.
  - The watchdog no longer restarts the poll because a device was quiet.
- New optional options (empty keeps the bridge default):
  - **`snapshot_live`** (`auto` / `on` / `off`): whether a camera tile's still wakes the camera. `auto` wakes
    only mains cameras; battery cameras answer from their last thumbnail or frame.
  - **`stream_fail_backoff_ms`**: after a stream fails to open, how long to wait before waking that camera
    again (default 30 s, doubling per failure up to 5 min; `0` disables).
  - **`clip_settle_ms`**: how long the HomeBase 2 clip waits for the station to finish writing the
    recording (default 30 s).
- Pair it with **integration 0.4.0**.

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
