#!/bin/bash

source .env
set -eux

aws s3 mb s3://${AP_NORTHEAST_BUCKET_NAME} --region ${AP_NORTHEAST_REGION}

kops create cluster \
  --name=${AP_NORTHEAST_CONTEXT} \
  --state=s3://${AP_NORTHEAST_BUCKET_NAME} \
  --zones="${AP_NORTHEAST_REGION}${ZONE}" \
  --master-size=${MASTER_SIZE} \
  --node-size=${NODE_SIZE} \
  --node-count=${NODE_COUNT} \
  --dns-zone=${DOMAIN_NAME}

kops update cluster ${AP_NORTHEAST_CONTEXT} \
  --state=s3://${AP_NORTHEAST_BUCKET_NAME} \
  --yes
