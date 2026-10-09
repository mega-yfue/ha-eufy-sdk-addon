# Home Assistant Add-on: eufy-sdk bridge

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

## Use a dedicated eufy account (recommended)

eufy allows **one active session per account**. When the eufy app or another client logs in with the
same account, it can bump the bridge's session. The bridge then has to log in again, and eufy may ask
for a new **2FA code**, so Home Assistant shows a re-authentication prompt (and you get code emails).

To avoid that, give the bridge an account of its own:

1. Create a second eufy account.
2. In the eufy app, on your main account, share your home/devices with it, with **admin** rights.
3. Log in to the eufy app once with the second account to accept the invitation, then log out.
4. Use the second account's email and password in this add-on's options.

Your main account stays free for the eufy app on your phone.

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
| `stream_fail_backoff_ms` | *(empty)* | Battery-saver: after a live-stream open **fails**, refuse to reopen that camera for this long (ms), doubling per consecutive failure up to 5 min, so go2rtc's retries get a fast error instead of waking the camera. Empty keeps the bridge default (`30000`); `0` disables |
| `snapshot_live` | *(empty = `auto`)* | How the still on a camera tile is taken. `auto`: **mains** cameras get a fresh live still; **battery** cameras are not woken and answer from their last-event thumbnail or last streamed frame. `on`: always take a live still (wakes battery cameras). `off`: never |
| `clip_settle_ms` | *(empty)* | How long after a detection the latest-recording clip waits before downloading it from a HomeBase 2 (ms), so the station has finished writing it. Set it at least to the camera's clip length. Empty keeps the bridge default (`30000`) |
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
