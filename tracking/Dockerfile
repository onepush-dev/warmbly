# Warmbly tracking (open/click pixels) for Railway: upstream image + baked defaults.
ARG WARMBLY_TAG=v0.6.72
FROM ghcr.io/warmbly/warmbly/tracking:${WARMBLY_TAG}
ENV PORT=8080 APP_ENV=prod AWS_CONFIG_ENABLED=false TRACKING_HOST=[::] TRACKING_PORT=8080 \
    EVENTBUS_PROVIDER=nats CODEC_PROVIDER=json
EXPOSE 8080
HEALTHCHECK NONE
