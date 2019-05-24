#!/bin/bash

source .env
set -eux

# Switch to the fed cluster context
kubectl config use-context ${FED_CONTEXT}

# Create a domain and service dns record
cat <<EOF | kubectl apply -f -
apiVersion: multiclusterdns.kubefed.k8s.io/v1alpha1
kind: Domain
metadata:
  name: test-domain
  namespace: kube-federation-system
domain: ${DOMAIN_NAME}
EOF

# Create a service dns record
cat <<EOF | kubectl apply -f -
apiVersion: multiclusterdns.kubefed.k8s.io/v1alpha1
kind: ServiceDNSRecord
metadata:
  name: nginx
  namespace: test
spec:
  domainRef: test-domain
  recordTTL: 300
EOF
