#!/bin/bash
function apply() {
	local dbname="$1"
	local script_name="$2"
	local error_n=0

	if [[ ! -f "$script_name" ]]; then
		echo "$script_name: No such file or directory"
		return 1
	fi

	run_sql="mariadb $dbname"
	run_sql_verbose="$run_sql -v"

	n="$(sed -r -e "s/'/@@@/g; s/@@@/''/g" <<< "$script_name")"

	if $run_sql -e "select '@@FOUND@@' as Status from migrations where name='$n' limit 1" | grep -q '@@FOUND@@'; then
		echo "migration already applied."
		return 0
	fi

	$run_sql_verbose < "$script_name"
	error_n=$?

	if [[ $error_n -eq 0 ]]; then
		$run_sql -e "INSERT INTO migrations (name) VALUES ('$n');" && echo "OK" || return 1
	else
		return 1
	fi

	return 0
}

if [[ -z "$1" ]]; then
	echo "Especifique el nombre de la base de datos!"
	exit 1
fi

for f in *.sql
do
	echo "$f:"
	apply "$1" "$f"
	echo "status=${error_n}"
	if [[ $error_n -gt 0 ]]; then
		echo "MIGRATION FAILED: $f!"
		break
	fi
done
