#!/bin/bash

source .env
set -eux

# Start to create k8s cluster on aws
./ap-northeast/create.sh
./us-east/create.sh
./us-west/create.sh
