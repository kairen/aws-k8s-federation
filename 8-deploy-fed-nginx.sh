#!/bin/bash

source .env
set -eux

cat <<EOF | kubectl --context=${FED_CONTEXT} apply -f -
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: nginx
  annotations:
    federation.kubernetes.io/deployment-preferences: >
     {
       "rebalance": true,
       "clusters": {
         "us-west": {
           "minReplicas": 2,
           "maxReplicas": 10,
           "weight": 200
         },
         "us-east": {
           "minReplicas": 0,
           "maxReplicas": 2,
           "weight": 150
         },
         "ap-northeast": {
           "minReplicas": 1,
           "maxReplicas": 5,
           "weight": 150
         }
       }
     }
spec:
  replicas: 3
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx
        ports:
        - containerPort: 80
EOF

cat <<EOF | kubectl --context=${FED_CONTEXT} apply -f -
apiVersion: v1
kind: Service
metadata:
  name: nginx
  labels:
    app: nginx
spec:
  type: LoadBalancer
  ports:
  - port: 80
    targetPort: 80
    protocol: TCP
  selector:
    app: nginx
EOF
