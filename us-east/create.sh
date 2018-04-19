#!/bin/bash

source .env
set -eux

aws s3 mb s3://${US_EAST_BUCKET_NAME} --region ${US_EAST_REGION}

kops create cluster \
  --name=${US_EAST_CONTEXT} \
  --state=s3://${US_EAST_BUCKET_NAME} \
  --zones="${US_EAST_REGION}${ZONE}" \
  --master-size=${MASTER_SIZE} \
  --node-size=${NODE_SIZE} \
  --node-count=${NODE_COUNT} \
  --dns-zone=${DOMAIN_NAME}

kops update cluster ${US_EAST_CONTEXT} \
  --state=s3://${US_EAST_BUCKET_NAME} \
  --yes
