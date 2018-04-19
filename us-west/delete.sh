#!/bin/bash

source .env
set -eux

kops delete cluster \
 --name=${US_WEST_CONTEXT} \
 --state=s3://${US_WEST_BUCKET_NAME} --yes

aws s3 rb s3://${US_WEST_BUCKET_NAME} --force
