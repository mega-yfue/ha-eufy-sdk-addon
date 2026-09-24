# Changelog

## 0.4.0-dev.1

- Rebuild from the current bridge `:dev`. The previous dev image still ran bridge 0.1.60 on eufy-sdk
  `0.2.0-beta.18`; this one is **bridge 0.3.0 on eufy-sdk `0.3.0-beta.0`** (the same code as the stable
  eufy-sdk 0.2.0 release), picking up:
  - **Anker Solix**, complete: Solarbank 4 telemetry and controls, battery health, grid limits, backup
    reserve, expansion packs, and the Smart Meter.
  - **Several cameras on one HomeBase streaming at the same time.**
  - The **`gtoken not equal userid`** login fix.
  - A camera whose channel on its HomeBase is missing or shared is **refused with a clear error** instead of
    streaming the wrong camera.
  - Station database reads (face roster, "Last event" covers) no longer run on per-camera media sessions.

## 0.3.0-dev.2

- Rebuild from the current bridge `:dev`, picking up:
  - **Last event auto-heal** — a stale "Last event" image now re-fetches the cover in the background
    on the next request, so a late-written HomeBase crop self-heals without the *Refresh Last Event*
    button (bridge #54).
  - **Stream-consumer logging** — `/stream` now logs its immediate requester and asks go2rtc who is
    actually consuming the stream, to trace a stream that keeps opening "by itself" (bridge #55).
  - Smart-lock lock/unlock action routing (bridge #49).

## 0.3.0-dev.1

- Initial **dev / edge** channel of the eufy-sdk bridge add-on. Same wrapper as the stable
  `eufy_sdk_bridge`, but it builds FROM the bridge's rolling `:dev` image so testers get changes
  before a stable release. Marked `stage: experimental` (hidden unless HA Advanced Mode is on).
- Distinct slug/image (`eufy_sdk_bridge_dev` / `ghcr.io/mega-yfue/addon-eufy-sdk-bridge-dev`); shares
  the stable add-on's ports and options. Run only ONE bridge per eufy account (a second displaces the
  first's session).
