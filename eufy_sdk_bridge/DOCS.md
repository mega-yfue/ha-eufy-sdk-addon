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

## Configuration

| Option | Default | Description |
| --- | --- | --- |
| `email` | — | eufy account email |
| `password` | — | eufy account password |
| `country` | `GB` | Two-letter country code — routes the eufy region |
| `poll_ms` | `600000` | How often the bridge re-reads device state from the cloud (ms); `0` disables polling |
| `stream_idle_ms` | `300000` | Auto-off a camera's live feed after this long with no detection (ms); `0` disables. Saves battery |
| `rtsp_idle_off_ms` | `300000` | Turn a **battery** camera's native `rtspStream` OFF after this long idle (ms); `0` disables. Wired cameras untouched |
| `prewarm` | `false` | Speculatively open a camera's P2P on a high-intent event (doorbell/person/pet/package) so live view starts instantly. Holds a battery camera's radio ~28s per event |
| `event_log` | `true` | Log one line per push/semantic event (what it is, clients reached, image fetches) |
| `debug` | `false` | Verbose bridge logging (WS commands, control timing, P2P connect/close) |
| `debug_p2p` | `false` | Additionally route the raw per-frame P2P transport logs (very noisy) |

The tuning options mirror the bridge's own defaults, so leaving them unchanged behaves exactly as
before. The login token persists in the add-on's `/data`, so a restart does not re-authenticate (eufy
allows one active session per account; a session bumped elsewhere re-authenticates, escalating to 2FA).
