#!/bin/bash

source .env
set -eux

# Switch to the fed cluster context
kubectl config use-context ${FED_CONTEXT}

# Create a namespace called `test`
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: test
EOF

# Create a federated namespace called `test-fns`
cat <<EOF | kubectl apply -f -
apiVersion: types.federation.k8s.io/v1alpha1
kind: FederatedNamespace
metadata:
  name: test
  namespace: test
spec:
  placement:
    clusterNames:
    - ap-northeast
    - us-east
    - us-west
EOF
