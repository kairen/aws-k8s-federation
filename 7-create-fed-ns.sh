#!/bin/bash

source .env
set -eux

# Create the default federated namespace
kubectl --context=${FED_CONTEXT} create namespace default

kubectl --context=${FED_CONTEXT} get clusters
