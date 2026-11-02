# Warmbly core for Railway: backend (API) + consumer + worker in ONE container.
# They share /data/blobs (message bodies, BLOB_PROVIDER=filesystem) and the worker
# state dir; Railway volumes cannot be shared between services, so they run together.
ARG WARMBLY_TAG=v0.6.72
FROM ghcr.io/warmbly/warmbly/consumer:${WARMBLY_TAG} AS consumer
FROM ghcr.io/warmbly/warmbly/worker:${WARMBLY_TAG} AS worker
FROM ghcr.io/warmbly/warmbly/backend:${WARMBLY_TAG}
USER root
RUN apk add --no-cache tini su-exec xxd
COPY --from=consumer /app/consumer /app/consumer
COPY --from=worker /app/worker /app/worker
COPY start.sh /usr/local/bin/warmbly-railway-start
RUN chmod +x /usr/local/bin/warmbly-railway-start && mkdir -p /data/blobs /data/state && chown -R warmbly:warmbly /data
# Plain defaults (Railway template generation drops plain values, so they live here).
ENV PORT=8080 \
    APP_ENV=prod AWS_CONFIG_ENABLED=false DEPLOYMENT_MODE=self_hosted GIN_MODE=release \
    EVENTBUS_PROVIDER=nats CODEC_PROVIDER=json KMS_PROVIDER=local \
    BLOB_PROVIDER=filesystem BLOB_FS_ROOT=/data/blobs TASKS_PROVIDER=local PUBSUB_ENABLED=false \
    BILLING_PROVIDER=none CAPTCHA_PROVIDER=none ENCRYPTED_KEYS_PROVIDER=postgres \
    UPDATER_URL=none MAIL_TRANSPORT=log EMAIL_NAME=Warmbly EMAIL_ADDRESS=noreply@example.com \
    SMTP_AUTH=auto AUTH_LOGIN_CODE=off REQUIRE_EMAIL_VERIFICATION=false DISABLE_REGISTRATION=invite_only \
    GEODB_PATH=/data/blobs/geo/GeoLite2-City.mmdb WORKER_STATE_DIR=/data/state MAIL_TLS_INSECURE=false \
    WARMBLY_BOOTSTRAP_ORG=Warmbly
EXPOSE 8080
HEALTHCHECK NONE
ENTRYPOINT ["/sbin/tini","--"]
CMD ["warmbly-railway-start"]
