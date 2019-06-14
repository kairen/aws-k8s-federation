#!/bin/bash

source .env
set -eux

# Switch to the us-east cluster context
kubectl config use-context ${US_EAST_CONTEXT}

# Patch the us-east  pods
PODS=$(kubectl -n test get po --no-headers "-o=custom-columns=NAME:.metadata.name")

for POD in ${PODS}; do
  kubectl -n test patch pod ${POD} --patch "$(cat patches/us-east-pod.yml)"
done

# Switch to the us-west cluster context
kubectl config use-context ${US_WEST_CONTEXT}

# Patch the us-west pods
PODS=$(kubectl -n test get po --no-headers "-o=custom-columns=NAME:.metadata.name")

for POD in ${PODS}; do
  kubectl -n test patch pod ${POD} --patch "$(cat patches/us-west-pod.yml)"
done