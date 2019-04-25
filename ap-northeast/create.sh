#!/bin/bash

source .env
set -eux

aws s3 mb s3://${AP_NORTHEAST_BUCKET_NAME} --region ${AP_NORTHEAST_REGION}

cat <<EOF | kops create --state=s3://${AP_NORTHEAST_BUCKET_NAME} -f -
apiVersion: kops/v1alpha2
kind: Cluster
metadata:
  name: ${AP_NORTHEAST_CONTEXT}
spec:
  additionalPolicies:
    master: |
      [
        {
            "Action": "elasticloadbalancing:*",
            "Resource": "*",
            "Effect": "Allow"
        }
      ]
    node: |
      [
        {
          "Effect": "Allow",
          "Action": [
            "route53:ChangeResourceRecordSets",
            "route53:ListResourceRecordSets",
            "route53:GetHostedZone"
          ],
          "Resource": [
            "arn:aws:route53:::hostedzone/*"
          ]
        },
        {
          "Effect": "Allow",
          "Action": [
            "route53:GetChange"
          ],
          "Resource": [
            "arn:aws:route53:::change/*"
          ]
        },
        {
          "Effect": "Allow",
          "Action": [
            "route53:ListHostedZones"
          ],
          "Resource": [
            "*"
          ]
        },
        {
            "Effect": "Allow",
            "Action": "*",
            "Resource": "*"
        }
      ]
  api:
    dns: {}
  authorization:
    rbac: {}
  channel: stable
  cloudProvider: aws
  configBase: s3://${AP_NORTHEAST_BUCKET_NAME}/${AP_NORTHEAST_CONTEXT}
  dnsZone: ${DOMAIN_NAME}
  etcdClusters:
  - cpuRequest: 200m
    etcdMembers:
    - instanceGroup: master-ap-northeast-1a
      name: a
    memoryRequest: 100Mi
    name: main
  - cpuRequest: 100m
    etcdMembers:
    - instanceGroup: master-ap-northeast-1a
      name: a
    memoryRequest: 100Mi
    name: events
  iam:
    allowContainerRegistry: true
    legacy: false
  kubelet:
    anonymousAuth: false
  kubernetesApiAccess:
  - 0.0.0.0/0
  kubernetesVersion: ${KUBERNETES_VERSION}
  masterPublicName: api.${AP_NORTHEAST_CONTEXT}
  networkCIDR: 172.20.0.0/16
  networking:
    kubenet: {}
  nonMasqueradeCIDR: 100.64.0.0/10
  sshAccess:
  - 0.0.0.0/0
  subnets:
  - cidr: 172.20.32.0/19
    name: ap-northeast-1a
    type: Public
    zone: ap-northeast-1a
  topology:
    dns:
      type: Public
    masters: public
    nodes: public
---
apiVersion: kops/v1alpha2
kind: InstanceGroup
metadata:
  labels:
    kops.k8s.io/cluster: ${AP_NORTHEAST_CONTEXT}
  name: master-ap-northeast-1a
spec:
  image: kope.io/k8s-1.11-debian-stretch-amd64-hvm-ebs-2018-08-17
  machineType: ${MASTER_FLAVOR}
  maxSize: ${MASTER_COUNT}
  minSize: ${MASTER_COUNT}
  nodeLabels:
    kops.k8s.io/instancegroup: master-ap-northeast-1a
  role: Master
  subnets:
  - ap-northeast-1a
---
apiVersion: kops/v1alpha2
kind: InstanceGroup
metadata:
  labels:
    kops.k8s.io/cluster: ${AP_NORTHEAST_CONTEXT}
  name: nodes
spec:
  image: kope.io/k8s-1.11-debian-stretch-amd64-hvm-ebs-2018-08-17
  machineType: ${NODE_FLAVOR}
  maxSize: ${NODE_COUNT}
  minSize: ${NODE_COUNT}
  nodeLabels:
    kops.k8s.io/instancegroup: nodes
  role: Node
  subnets:
  - ap-northeast-1a
EOF

kops create secret --name ${AP_NORTHEAST_CONTEXT} \
  --state=s3://${AP_NORTHEAST_BUCKET_NAME} \
  sshpublickey admin -i ~/.ssh/id_rsa.pub

# kops create cluster \
#   --name=${AP_NORTHEAST_CONTEXT} \
#   --state=s3://${AP_NORTHEAST_BUCKET_NAME} \
#   --zones="${AP_NORTHEAST_REGION}${ZONE}" \
#   --master-size=${MASTER_FLAVOR} \
#   --node-size=${NODE_FLAVOR} \
#   --node-count=${NODE_COUNT} \
#   --dns-zone=${DOMAIN_NAME}

kops update cluster ${AP_NORTHEAST_CONTEXT} \
  --state=s3://${AP_NORTHEAST_BUCKET_NAME} \
  --yes
