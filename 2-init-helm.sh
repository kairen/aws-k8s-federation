#!/bin/bash

source .env
set -eux

# Switch to master cluster
kubectl config use-context ${FED_CONTEXT}

# Create RBAC for Helm
kubectl -n kube-system create sa tiller
kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller
helm init --service-account tiller
