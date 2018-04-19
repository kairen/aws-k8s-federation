#!/bin/bash

source .env
set -eux

kubectl --context=${FED_CONTEXT} scale deploy nginx \
  --replicas=10
