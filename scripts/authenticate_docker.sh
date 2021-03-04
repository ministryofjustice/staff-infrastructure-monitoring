#!/bin/bash

set -euo pipefail

aws ecr get-login-password --region eu-west-2 | docker login --username AWS --password-stdin ${SHARED_SERVICES_ACCOUNT_ID}.dkr.ecr.eu-west-2.amazonaws.com
