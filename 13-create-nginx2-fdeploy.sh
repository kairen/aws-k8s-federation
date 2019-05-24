#!/bin/bash

source .env
set -eux

# Switch to the fed cluster context
kubectl config use-context ${FED_CONTEXT}

# Create a nginx2 deployment
cat <<EOF | kubectl apply -f -
apiVersion: types.kubefed.k8s.io/v1beta1
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
    clusters:
    - name: ap-northeast
    - name: us-east
    - name: us-west
EOF

