#!/bin/bash

source .env
set -eux

# Switch to the fed cluster context
kubectl config use-context ${FED_CONTEXT}

# Create a nginx2 deployment
cat <<EOF | kubectl --context=${FED_CONTEXT} apply -f -
apiVersion: types.federation.k8s.io/v1alpha1
kind: FederatedDeployment
metadata:
  name: nginx2
  namespace: test
spec:
  template:
    metadata:
      labels:
        app: nginx2
    spec:
      replicas: 1
      selector:
        matchLabels:
          app: nginx2
      template:
        metadata:
          labels:
            app: nginx2
        spec:
          containers:
          - image: nginx
            name: nginx
  placement:
    clusterNames:
    - ap-northeast
    - us-east
    - us-west
EOF

