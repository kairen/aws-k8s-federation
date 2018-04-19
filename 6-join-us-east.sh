#!/bin/bash

source .env
set -eux

# Switch to the fed cluster context
kubectl config use-context ${FED_CONTEXT}

# Join the us-east clusters to the Federation
kubefed join us-east \
  --host-cluster-context=${US_WEST_CONTEXT} \
  --cluster-context=${US_EAST_CONTEXT}
