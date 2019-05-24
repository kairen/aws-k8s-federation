#!/bin/bash

source .env
set -eux

# Switch to the fed cluster context
kubectl config use-context ${FED_CONTEXT}

# Create a nginx2 rsp
cat <<EOF | kubectl apply -f -
apiVersion: scheduling.kubefed.k8s.io/v1alpha1
kind: ReplicaSchedulingPreference
metadata:
  name: nginx2
  namespace: test
spec:
  targetKind: FederatedDeployment
  totalReplicas: 15
  clusters:
    "*":
      weight: 2
    ap-northeast:
      minReplicas: 1
      maxReplicas: 3
      weight: 1
EOF

