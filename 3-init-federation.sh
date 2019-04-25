#!/bin/bash

source .env
set -eux

# Switch to master cluster
kubectl config use-context ${FED_CONTEXT}

# First you'll need to create the reserved namespace for registering clusters with the cluster registry:
kubectl create ns kube-multicluster-public

# Deploy the Federation control plane to the host cluster
git clone https://github.com/kubernetes-sigs/federation-v2.git -b v0.0.8
cd federation-v2

helm install charts/federation-v2 \
  --name federation-v2 \
  --namespace federation-system \
  --set clusterregistry.enabled=true

# Remove unnecessary files
cd ../
rm -rf federation-v2

kubectl -n federation-system get po -o wide