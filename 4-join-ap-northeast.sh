#!/bin/bash

source .env
set -eux

# Switch to the fed cluster context
kubectl config use-context ${FED_CONTEXT}

# Join the ap-northeast cluster to the Federation
kubefedctl join ap-northeast \
  --host-cluster-context=${AP_NORTHEAST_CONTEXT} \
  --cluster-context=${AP_NORTHEAST_CONTEXT} \
  --v=2 

# Check cluster by kubectl
kubectl -n kube-federation-system describe kubefedclusters ap-northeast