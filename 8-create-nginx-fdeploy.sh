#!/bin/bash

source .env
set -eux

# Switch to the fed cluster context
kubectl config use-context ${FED_CONTEXT}

# Create a nginx deployment
cat <<EOF | kubectl --context=${FED_CONTEXT} apply -f -
apiVersion: types.kubefed.k8s.io/v1beta1
kind: FederatedDeployment
metadata:
  name: nginx
  namespace: test
spec:
  template:
    metadata:
      labels:
        app: nginx
    spec:
      replicas: 1
      selector:
        matchLabels:
          app: nginx
      template:
        metadata:
          labels:
            app: nginx
        spec:
          containers:
          - image: nginx
            name: nginx
  placement:
    clusters:
    - name: ap-northeast
    - name: us-east
    - name: us-west
  overrides:
  - clusterName: us-east
    clusterOverrides:
    - path: spec.replicas
      value: 2
    - path: spec.template.spec.containers[0].image
      value: kairen/nginx:magic
  - clusterName: us-west
    clusterOverrides:
    - path: spec.replicas
      value: 3
EOF

