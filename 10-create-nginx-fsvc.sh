#!/bin/bash

source .env
set -eux

# Switch to the fed cluster context
kubectl config use-context ${FED_CONTEXT}

# Create a service for NGINX deployment
cat <<EOF | kubectl apply -f -
apiVersion: types.kubefed.k8s.io/v1beta1
kind: FederatedService
metadata:
  name: nginx
  namespace: test
spec:
  template:
    spec:
      selector:
        app: nginx
      type: LoadBalancer
      ports:
        - name: http
          port: 80
  placement:
    clusters:
    - name: ap-northeast
    - name: us-east
    - name: us-west
EOF
