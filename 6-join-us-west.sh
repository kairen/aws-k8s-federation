#!/bin/bash

source .env
set -eux

# Switch to the fed cluster context
kubectl config use-context ${FED_CONTEXT}

# Join the us-west cluster to the Federation
kubefed2 join us-west \
  --host-cluster-context=${AP_NORTHEAST_CONTEXT} \
  --cluster-context=${US_WEST_CONTEXT} \
  --add-to-registry \
  --v=2 

# Check cluster by kubectl
kubectl -n federation-system describe federatedclusters us-west