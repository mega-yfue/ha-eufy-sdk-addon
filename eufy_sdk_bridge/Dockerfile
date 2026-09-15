# https://developers.home-assistant.io/docs/add-ons/configuration#add-on-dockerfile
#
# This add-on is a THIN WRAPPER over ha-eufy-sdk-bridge: it builds FROM the bridge image and adds only
# the glue that turns Home Assistant add-on options into the env the bridge reads. `BUILD_FROM` is set
# per-arch in build.yaml to the published bridge image.
ARG BUILD_FROM=ghcr.io/mega-yfue/ha-eufy-sdk-bridge:0.2.0
FROM ${BUILD_FROM}

# The bridge base is node:alpine (no s6/bashio). `jq` reads /data/options.json and `curl` registers
# Supervisor discovery with the effective add-on network mapping.
RUN apk add --no-cache curl jq

COPY run.sh /run.sh
RUN chmod +x /run.sh

LABEL \
    org.opencontainers.image.title="Home Assistant Add-on: eufy-sdk bridge" \
    org.opencontainers.image.description="Runs the ha-eufy-sdk bridge for the eufy-sdk HACS integration." \
    org.opencontainers.image.source="https://github.com/mega-yfue/ha-eufy-sdk-addon" \
    org.opencontainers.image.licenses="MIT"

CMD [ "/run.sh" ]
