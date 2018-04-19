#!/bin/bash

source .env
set -eux

# Update DNS record func
function update_dns_record() {
  sed -i -e 's|"Name": ".*|"Name": "'"${DNS_RECORD_PREFIX}.${DOMAIN_NAME}"'",|g' dns-record.json
  sed -i -e 's|"Region": ".*|"Region": "'"${AWS_REGION}"'",|g' dns-record.json
  sed -i -e 's|"SetIdentifier": ".*|"SetIdentifier": "'"${AWS_REGION}"'",|g' dns-record.json
  sed -i -e 's|"Value": ".*|"Value": "'"${NGINX_LB}"'"|g' dns-record.json

  aws route53 change-resource-record-sets \
    --hosted-zone-id ${HOSTED_ZONE_ID} \
    --change-batch file://dns-record.json
}

# Set DNS prefix & the Service name and then retrieve ELB URL for the us-west cluster
AWS_REGION="${US_WEST_REGION}"
NGINX_LB=$(kubectl --context=${US_WEST_CONTEXT} get svc/${SERVICE_NAME} \
  --template="{{range .status.loadBalancer.ingress}} {{.hostname}} {{end}}")
update_dns_record
sleep 1

# Set DNS prefix & the Service name and then retrieve ELB URL for the us-east cluster
AWS_REGION="${US_EAST_REGION}"
NGINX_LB=$(kubectl --context=${US_EAST_CONTEXT} get svc/${SERVICE_NAME} \
  --template="{{range .status.loadBalancer.ingress}} {{.hostname}} {{end}}")
update_dns_record
sleep 1

# Set DNS prefix & the Service name and then retrieve ELB URL for the ap-northeast cluster
AWS_REGION="${AP_NORTHEAST_REGION}"
NGINX_LB=$(kubectl --context=${AP_NORTHEAST_CONTEXT} get svc/${SERVICE_NAME} \
  --template="{{range .status.loadBalancer.ingress}} {{.hostname}} {{end}}")
update_dns_record
sleep 1

rm -rf dns-record.json-e
