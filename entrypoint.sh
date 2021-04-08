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
	&& { psql $psql_params --command="CREATE DATABASE $db_name"; return "$?"; }
	echo "The db $db_name exists. Skipping"
}

create_role() {
	local user_name="$1"; local user_pass="$2"
	psql $psql_params --command="SELECT FROM pg_roles WHERE rolname='$user_name'" | grep -q 0 \
	&& { psql $psql_params --command="CREATE USER $user_name WITH password '$user_pass'"; return "$?"; }
	echo "The role $user_name exists. Skipping"
}

grant_privileges_to_db() {
	local db_name="$1"; local user_name="$2"
	psql $psql_params --command="GRANT ALL privileges ON DATABASE $db_name TO $user_name"
}

create_extensions() {
	for extension in ${POSTGRES_EXTENSIONS//,/ }; do
		psql $psql_params --command="CREATE EXTENSION IF NOT EXISTS $extension"
	done
}

create_dbs_and_roles() {
	test -n "$POSTGRES_DBS" && {
		for db in ${POSTGRES_DBS//,/ }; do
			create_db "${db%%:*}"
			create_role "${db%%:*}" "${db#*:}"
			grant_privileges_to_db "${db%%:*}" "${db%%:*}"
		done
		return 0;
	}

	test -n "$POSTGRES_CREATE_USER" && {
		user="${POSTGRES_CREATE_USER%%@*}"
		dbs="${POSTGRES_CREATE_USER#*@}"
		create_role "${user%%:*}" "${user#*:}"
		for db in ${dbs//,/ }; do
			test -z "$SKIP_DBS_CREATION" && create_db "$db"
			grant_privileges_to_db "$db" "${user%%:*}"
		done
		return 0;
	}

	echo "No POSTGRES_DBS or POSTGRES_CREATE_USER variables exist. Skipping"
}

until check_postgres_is_available; do
	sleep 1
	(( POSTGRES_TIMEOUT-- ))
	test $POSTGRES_TIMEOUT -eq 0 && { echo "ERROR. Postgres is unavailable $POSTGRES_HOST:$POSTGRES_PORT"; exit 1;}
done

create_dbs_and_roles
create_extensions
