#!/bin/bash

source .env
set -eux

aws s3 mb s3://${US_WEST_BUCKET_NAME} --region ${US_WEST_REGION}

kops create cluster \
  --name=${US_WEST_CONTEXT} \
  --state=s3://${US_WEST_BUCKET_NAME} \
  --zones="${US_WEST_REGION}${ZONE}" \
  --master-size=${MASTER_SIZE} \
  --node-size=${NODE_SIZE} \
  --node-count=${NODE_COUNT} \
  --dns-zone=${DOMAIN_NAME}

kops update cluster ${US_WEST_CONTEXT} \
  --state=s3://${US_WEST_BUCKET_NAME} \
  --yes
