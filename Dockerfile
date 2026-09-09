# syntax=docker/dockerfile:1
ARG RCLONE_IMAGE=rclone/rclone:latest

FROM node:22-alpine AS crontab-ui
ARG CRONTAB_UI_REF=master
RUN apk add --no-cache git \
    && git clone https://github.com/alseambusher/crontab-ui.git /crontab-ui \
    && cd /crontab-ui \
    && git checkout "${CRONTAB_UI_REF}" \
    && npm ci --omit=dev \
    && npm cache clean --force

FROM ${RCLONE_IMAGE}
RUN apk add --no-cache curl nodejs supervisor tini tzdata \
    && mkdir -p /etc/crontabs /var/log/rcron /rcron-data \
    && touch /etc/crontabs/root
COPY --from=crontab-ui /crontab-ui /crontab-ui
COPY docker/supervisord.conf /etc/supervisord.conf
ENV HOST=0.0.0.0 PORT=8000 CRON_IN_DOCKER=true CRON_PATH=/etc/crontabs CRON_DB_PATH=/rcron-data
EXPOSE 8000
VOLUME ["/config", "/rcron-data"]
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 CMD curl --fail http://localhost:${PORT}/ || exit 1
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
