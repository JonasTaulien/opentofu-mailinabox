#!/usr/bin/env bash
DIGITALOCEAN_TOKEN="${1}"

curl --silent --request GET \
  -H 'Content-Type: application/json' \
  -H "Authorization: Bearer $DIGITALOCEAN_TOKEN" \
  'https://api.digitalocean.com/v2/sizes' \
  | jq '[.sizes[] |  {description,slug,memory,vcpus,disk,price_monthly,available}] | sort_by(.price_monthly)'
