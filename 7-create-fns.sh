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

# Create a federated namespace
cat <<EOF | kubectl apply -f -
apiVersion: types.kubefed.k8s.io/v1beta1
kind: FederatedNamespace
metadata:
  name: test
  namespace: test
spec:
  placement:
    clusters:
    - name: ap-northeast
    - name: us-east
    - name: us-west
EOF
