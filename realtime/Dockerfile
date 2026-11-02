# Warmbly realtime (Phoenix websocket fan-out) for Railway: upstream image + baked defaults.
ARG WARMBLY_TAG=v0.6.72
FROM ghcr.io/warmbly/warmbly/realtime:${WARMBLY_TAG}
ENV PORT=8080 APP_ENV=prod DATABASE_SSL=false DATABASE_POOL_SIZE=10 PUBSUB_ENABLED=false
EXPOSE 8080
HEALTHCHECK NONE
