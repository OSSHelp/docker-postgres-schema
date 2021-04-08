# postgres-schema

[![Build Status](https://drone.osshelp.ru/api/badges/docker/postgres-schema/status.svg)](https://drone.osshelp.ru/docker/postgres-schema)

## Description

One-shot container for init PostgreSQL users, databases, extensions.

## Deploy examples

### Docker Compose

``` yaml
  postgres-schema:
    image: osshelp/postgres-schema:stable
    restart: "no"
    environment:
      POSTGRES_PASSWORD: $POSTGRES_PASSWORD
      POSTGRES_DBS: "DB1_NAME:$USER1_PASSWORD, DB2_NAME:$USER2_PASSWORD"
    networks:
      - net
```

### Docker swarm

``` yaml
  postgres-schema:
    image: osshelp/postgres-schema:stable
    deploy:
      restart_policy:
        condition: none
    environment:
      POSTGRES_PASSWORD: $POSTGRES_PASSWORD
      POSTGRES_DBS: "DB1_NAME:$USER1_PASSWORD, DB2_NAME:$USER2_PASSWORD"
    networks:
      - net
```

### Alternative mode

Creates one user and multiple bases:

``` yaml
  postgres-schema:
    image: osshelp/postgres-schema:stable
    deploy:
      restart_policy:
        condition: none
    environment:
      POSTGRES_PASSWORD: $POSTGRES_PASSWORD
      POSTGRES_CREATE_USER: "user:pass@db1,db2,db3"
    networks:
      - net
```

## Parameters

Setting|Default|Description
---|---|---
`POSTGRES_HOST`|`postgres`|PostgreSQL host
`POSTGRES_PORT`|`5432`|PostgreSQL port
`POSTGRES_USER`|`postgres`|PostgreSQL superuser
`POSTGRES_PASSWORD`|`postgres`|PostgreSQL superuser password
`POSTGRES_TIMEOUT`|`60`|Timeout in seconds for wating PostgreSQL host connection
`POSTGRES_DBS`|-|List of DB_NAME:PASSWORD (delimiter: space or comma. USERNAME is equal to DBNAME)
`POSTGRES_CREATE_USER`|-|A user string with DB list. Format: `user:pass@db1,db2,db3`
`POSTGRES_EXTENSIONS`|-|List of PostgreSQL extensions (delimiter: space or comma)
`SKIP_DBS_CREATION`|-|The variable for POSTGRES_CREATE_USER mode only. If defined then no databases will be created

### Internal usage

For internal purposes and OSSHelp customers we have an alternative image url:

``` yaml
  image: oss.help/pub/postgres-schema:stable
```

There is no difference between the DockerHub image and the oss.help/pub image.

## Links

- [PostgreSQL Documentation](https://www.postgresql.org/docs/)

## TODO

- Add fixture dumps support (restore from dump if DB doesn't exits)
- Add GRANT tests
