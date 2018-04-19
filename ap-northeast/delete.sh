#!/bin/bash

source .env
set -eux

kops delete cluster \
 --name=${AP_NORTHEAST_CONTEXT} \
 --state=s3://${AP_NORTHEAST_BUCKET_NAME} --yes

aws s3 rb s3://${AP_NORTHEAST_BUCKET_NAME} --force
