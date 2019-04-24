#!/bin/bash

source .env
set -eux

aws route53 create-hosted-zone \
  --name ${DOMAIN_NAME} \
  --caller-reference $(date '+%Y-%m-%d-%H:%M')
