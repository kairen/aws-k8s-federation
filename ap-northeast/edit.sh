#!/bin/bash

source .env
set -eux

kops edit cluster \
  --name=${AP_NORTHEAST_CONTEXT} \
  --state=s3://${AP_NORTHEAST_BUCKET_NAME} \

kops update cluster ${AP_NORTHEAST_CONTEXT} \
  --state=s3://${AP_NORTHEAST_BUCKET_NAME} \
  --yes