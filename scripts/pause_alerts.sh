#!/bin/bash

grafana_username=""
grafana_password=""
grafana_url=""

curl -u $grafana_username:$grafana_password -H "Content-Type:application/json" --data-binary '{"paused": true}' ${grafana_url}/api/admin/pause-all-alerts