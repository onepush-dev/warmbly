# Warmbly admin panel (static SPA on nginx) for Railway: listens on 8080 (IPv4 + IPv6).
ARG WARMBLY_TAG=v0.6.72
FROM ghcr.io/warmbly/warmbly/admin:${WARMBLY_TAG}
RUN sed -i 's/listen 80;/listen 8080; listen [::]:8080;/' /etc/nginx/conf.d/default.conf && grep -q 'listen 8080' /etc/nginx/conf.d/default.conf && nginx -t
ENV PORT=8080 WARMBLY_ENV_LABEL=production WARMBLY_TURNSTILE_KEY=1x00000000000000000000AA
EXPOSE 8080
HEALTHCHECK NONE
