#!/bin/bash
# shellcheck disable=SC2086

export PGPASSWORD="$POSTGRES_PASSWORD"
psql_params="--host=$POSTGRES_HOST --port=$POSTGRES_PORT --username=$POSTGRES_USER"

check_postgres_is_available() {
	pg_isready $psql_params
}

create_db() {
	local db_name="$1"
	psql $psql_params --command="SELECT FROM pg_database WHERE datname = '$db_name'" | grep -q 0 \
	&& { psql $psql_params --command="CREATE DATABASE $db_name"; return 0; }
	echo "The db $db_name exists. Skipping"
}

create_role() {
	local db_name="$1"; local user_pass="$2"
	psql $psql_params --command="SELECT FROM pg_roles WHERE rolname='$db_name'" | grep -q 0 \
	&& {
		psql $psql_params --command="CREATE USER $db_name WITH password '$user_pass'"
		psql $psql_params --command="GRANT ALL privileges ON DATABASE $db_name TO $db_name"
		return 0
	}
	echo "The role $db_name exists. Skipping"
}

create_extensions() {
	for extension in ${POSTGRES_EXTENSIONS//,/ }; do
		psql $psql_params --command="CREATE EXTENSION IF NOT EXISTS $extension"
	done
}

create_dbs_and_roles() {
	for db in ${POSTGRES_DBS//,/ }; do
		create_db "${db%%:*}"
		create_role "${db%%:*}" "${db#*:}"
	done
}

until check_postgres_is_available; do
	sleep 1
	(( POSTGRES_TIMEOUT-- ))
	test $POSTGRES_TIMEOUT -eq 0 && { echo "ERROR. Postgres is unavailable $POSTGRES_HOST:$POSTGRES_PORT"; exit 1;}
done

create_dbs_and_roles
create_extensions
