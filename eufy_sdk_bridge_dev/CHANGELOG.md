# Changelog

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
