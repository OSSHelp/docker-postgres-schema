FROM postgres:13-alpine

LABEL maintainer="OSSHelp Team, https://oss.help"
LABEL description="One shot container which creates dbs, users and extensions"

COPY entrypoint.sh /usr/local/bin/
USER nobody

ENV POSTGRES_HOST=postgres \
    POSTGRES_PORT=5432 \
    POSTGRES_USER=postgres \
    POSTGRES_PASSWORD=postgres \
    POSTGRES_TIMEOUT=60

ENTRYPOINT ["entrypoint.sh"]
