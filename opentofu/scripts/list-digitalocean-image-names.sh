#!/usr/bin/env bash
DIGITALOCEAN_TOKEN="${1}"

# e.g. "Ubuntu" or "Debian"
DISTRIBUTION="${2}"

curl --silent --request GET \
  -H 'Content-Type: application/json' \
  -H "Authorization: Bearer $DIGITALOCEAN_TOKEN" \
  'https://api.digitalocean.com/v2/images?page=1&per_page=200' \
  | jq ".images[] | select(.distribution == \"${DISTRIBUTION}\") | {name,slug,regions}"
