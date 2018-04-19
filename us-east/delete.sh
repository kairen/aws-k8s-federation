#!/bin/bash

source .env
set -eux

kops delete cluster \
 --name=${US_EAST_CONTEXT} \
 --state=s3://${US_EAST_BUCKET_NAME} --yes

aws s3 rb s3://${US_EAST_BUCKET_NAME} --force
