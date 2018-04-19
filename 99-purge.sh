#!/bin/bash

source .env
set -eux

# Delete federation resources
kubectl --context=${FED_CONTEXT} delete deploy nginx
kubectl --context=${FED_CONTEXT} delete svc nginx

# Delete clusters
./ap-northeast/delete.sh
./us-east/delete.sh
./us-west/delete.sh

# Delete hosted domain name
aws route53 list-resource-record-sets \
  --hosted-zone-id ${HOSTED_ZONE_ID} |
jq -c '.ResourceRecordSets[]' |
while read -r resourcerecordset; do
  read -r name type <<<$(echo $(jq -r '.Name,.Type' <<<"$resourcerecordset"))
  if [ $type != "NS" -a $type != "SOA" ]; then
    aws route53 change-resource-record-sets \
      --hosted-zone-id ${HOSTED_ZONE_ID} \
      --change-batch '{"Changes":[{"Action":"DELETE","ResourceRecordSet":
          '"$resourcerecordset"'
        }]}' \
      --output text --query 'ChangeInfo.Id'
  fi
done

aws route53 delete-hosted-zone --id ${HOSTED_ZONE_ID}
