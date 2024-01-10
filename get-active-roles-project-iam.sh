#!/usr/bin/env bash
# do not allow unset variables
set -u
# exit script on any error
set -e

function check_program() {
	set +e # next command may fail - allow failure
	PRG="$(command -v "$1" 2>/dev/null)"
	set -e # exit script on any error again
	if [ -z "$PRG" ]; then
		echo "ERROR - \"$1\" not found" >&2
		exit 1
	fi
}

check_program jq
check_program curl

eval "$(jq -r '@sh "PROJECT_ID=\(.project_id) ACCESS_TOKEN=\(.access_token)"')"

curl -H "Authorization: Bearer ${ACCESS_TOKEN}" -s -X POST \
	"https://cloudresourcemanager.googleapis.com/v3/projects/${PROJECT_ID}:getIamPolicy" -d "" |
	jq -c '{roles: [.bindings[].role] | join(",")}'
