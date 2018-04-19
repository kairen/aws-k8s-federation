#!/bin/bash

source .env
set -eux

# Switch to the fed cluster context
kubectl config use-context ${FED_CONTEXT}

# Join the ap-northeast clusters to the Federation
kubefed join ap-northeast \
  --host-cluster-context=${US_WEST_CONTEXT} \
  --cluster-context=${AP_NORTHEAST_CONTEXT}
