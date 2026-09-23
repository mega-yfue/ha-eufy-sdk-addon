# Home Assistant Add-on: eufy-sdk bridge (dev)

> ⚠️ **Development / edge channel.** Identical to the stable **eufy-sdk bridge**, but it builds from the
> bridge's rolling `:dev` image — it gets new features and fixes first, at the cost of being less tested.
> Install the stable add-on for everyday use. Don't run both at once: they share one eufy account, which
> allows a single session, so a second bridge displaces the first.

Runs the [`ha-eufy-sdk-bridge`](https://github.com/mega-yfue/ha-eufy-sdk-bridge) daemon inside Home
Assistant, so the [`eufy-sdk`](https://github.com/mega-yfue/ha-eufy-sdk) HACS integration has a bridge
to talk to without you running Docker yourself.

## How it works

The add-on builds `FROM` the bridge image and adds one thing: it reads your add-on options and passes
them to the bridge as the env it expects. The daemon + its bundled go2rtc then start automatically.
The add-on publishes and registers Supervisor discovery for only the ports the integration consumes:
the bridge control port and go2rtc RTSP port. The integration uses the same host for both bridge
control and RTSP; only the ports differ.

## Connecting the eufy-sdk integration

After the add-on is **started**, Home Assistant should discover the
[`eufy-sdk`](https://github.com/mega-yfue/ha-eufy-sdk) integration. Confirm the discovered bridge in
Settings → Devices & Services.

If you add the integration manually, point it at the bridge:

- **Host:** `homeassistant.local` (or your Home Assistant host's IP address)
- **Port:** `3000`
- **RTSP port:** `8554` unless you changed the add-on's RTSP host port in the **Network** panel

> **Not `localhost`.** The integration runs in the Home Assistant container, so `localhost` is HA
> itself, not the add-on. Use the host name/IP above with the published ports from the add-on's
> **Network** panel.

You can change the published host ports in the add-on's **Network** panel if the defaults conflict
with another service. On first login eufy may ask for **2FA / a captcha** — the integration's config
flow walks you through it.

## Configuration

| Option | Default | Description |
| --- | --- | --- |
| `email` | — | eufy account email |
| `password` | — | eufy account password |
| `country` | `GB` | Two-letter country code — routes the eufy region |
| `poll_ms` | `600000` | How often the bridge re-reads device state from the cloud (ms); `0` disables polling |
| `stream_idle_ms` | `300000` | Auto-off a camera's live feed after this long with no detection (ms); `0` disables. Saves battery |
| `rtsp_idle_off_ms` | `300000` | Turn a **battery** camera's native `rtspStream` OFF after this long idle (ms); `0` disables. Wired cameras untouched |
| `stream_battery_budget_ms` | *(empty)* | How long a **battery** camera may stream continuously (ms). Empty keeps the SDK default (45 s + 10 s grace), so a watched stream drops every ~55 s. Raise it (e.g. `180000`) to keep it up. Mains cameras ignore it |
| `prewarm` | `false` | Speculatively open a camera's P2P on a high-intent event (doorbell/person/pet/package) so live view starts instantly. Holds a battery camera's radio ~28s per event |
| `event_log` | `true` | Log one line per push/semantic event (what it is, clients reached, image fetches) |
| `debug` | `false` | Verbose bridge logging (WS commands, control timing, P2P connect/close) |
| `debug_p2p` | `false` | Additionally route the raw per-frame P2P transport logs (very noisy) |
| `solix_email` | — | Anker **Solix** account email (a **separate** account from eufy). Fill this **and** `solix_password` to add the Solarbank / smart-meter entities; leave empty to keep Solix off |
| `solix_password` | — | Solix account password |
| `solix_country` | — | Two-letter Solix account country (e.g. `GB`, `DE`); empty reuses `country` |
| `solix_scene_poll_ms` | `90000` | Solix scene backstop poll cadence (ms) — the slow authed read that fills battery temperature + a SOC cross-check the realtime push doesn't carry |
| `solix_retry_base_ms` | `900000` | Solix login self-heal backoff: starting delay after a failed login (ms), doubling up to the cap. Anker throttles frequent logins |
| `solix_retry_max_ms` | `3600000` | Cap for the escalating Solix login-retry backoff (ms) |

The tuning options mirror the bridge's own defaults, so leaving them unchanged behaves exactly as
before. The login token persists in the add-on's `/data`, so a restart does not re-authenticate (eufy
allows one active session per account; a session bumped elsewhere re-authenticates, escalating to 2FA).
