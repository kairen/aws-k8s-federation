#!/bin/bash

source .env
set -eux

# Switch to the fed cluster context
kubectl config use-context ${FED_CONTEXT}

# Join the ap-northeast cluster to the Federation
kubefed2 join ap-northeast \
  --host-cluster-context=${AP_NORTHEAST_CONTEXT} \
  --cluster-context=${AP_NORTHEAST_CONTEXT} \
  --add-to-registry \
  --v=2 

# Check cluster by kubectl
kubectl -n federation-system describe federatedclusters ap-northeast