#!/bin/bash

source .env
set -eux

# Switch to the fed cluster context
kubectl config use-context ${FED_CONTEXT}

# Join the us-east cluster to the Federation
kubefed2 join us-east \
  --host-cluster-context=${AP_NORTHEAST_CONTEXT} \
  --cluster-context=${US_EAST_CONTEXT} \
  --add-to-registry \
  --v=2 

# Check cluster by kubectl
kubectl -n federation-system describe federatedclusters us-east