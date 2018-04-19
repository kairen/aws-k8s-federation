#!/bin/bash

source .env
set -eux

# Switch to master cluster
kubectl config use-context ${US_WEST_CONTEXT}

# Deploy the Federation control plane to the host cluster
kubefed init ${FED_CONTEXT} \
  --image=kairen/fcp-amd64:v1.10.0-alpha \
  --host-cluster-context=${US_WEST_CONTEXT} \
  --dns-provider=aws-route53 \
  --dns-zone-name=${DOMAIN_NAME}
