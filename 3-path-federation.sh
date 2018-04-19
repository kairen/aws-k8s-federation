#!/bin/bash

source .env
set -eu

# Switch to master cluster
kubectl config use-context ${US_WEST_CONTEXT}

# Create the patch file 
ACCESS_KEY=$(cat ~/.aws/credentials | awk '/aws_access_key_id/ {print $3}')
SECRET_KEY=$(cat ~/.aws/credentials | awk '/aws_secret_access_key/ {print $3}')
cat <<EOF > fed-controller-patch.yml
spec:
  template:
    spec:
      containers:
      - name: controller-manager
        env:
        - name: AWS_ACCESS_KEY_ID
          value: ${ACCESS_KEY}
        - name: AWS_SECRET_ACCESS_KEY
          value: ${SECRET_KEY}
EOF

# Patch the file into controller manager
kubectl -n federation-system patch deployment controller-manager --patch "$(cat fed-controller-patch.yml)"
rm -rf fed-controller-patch.yml
