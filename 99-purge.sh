#!/bin/bash

source .env
set -eux

# Delete clusters
./ap-northeast/delete.sh
./us-east/delete.sh
./us-west/delete.sh

ID=$(echo ${HOSTED_ZONE_ID} | sed 's/\/hostedzone\///')

# Delete hosted domain name
aws route53 list-resource-record-sets \
  --hosted-zone-id ${ID} |
jq -c '.ResourceRecordSets[]' |
while read -r resourcerecordset; do
  read -r name type <<<$(echo $(jq -r '.Name,.Type' <<<"$resourcerecordset"))
  if [ $type != "NS" -a $type != "SOA" ]; then
    aws route53 change-resource-record-sets \
      --hosted-zone-id ${ID} \
      --change-batch '{"Changes":[{"Action":"DELETE","ResourceRecordSet":
          '"$resourcerecordset"'
        }]}' \
      --output text --query 'ChangeInfo.Id'
  fi
done

aws route53 delete-hosted-zone --id ${ID}
