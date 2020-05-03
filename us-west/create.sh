#!/bin/bash

source .env
set -eux

aws s3 mb s3://${US_WEST_BUCKET_NAME} --region ${US_WEST_REGION}

cat <<EOF | kops create --state=s3://${US_WEST_BUCKET_NAME} -f -
apiVersion: kops/v1alpha2
kind: Cluster
metadata:
  name: ${US_WEST_CONTEXT}
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
  api:
    dns: {}
  authorization:
    rbac: {}
  channel: stable
  cloudProvider: aws
  configBase: s3://${US_WEST_BUCKET_NAME}/${US_WEST_CONTEXT}
  dnsZone: ${DOMAIN_NAME}
  etcdClusters:
  - cpuRequest: 200m
    etcdMembers:
    - instanceGroup: master-${US_WEST_ZONE}
      name: a
    memoryRequest: 100Mi
    name: main
  - cpuRequest: 100m
    etcdMembers:
    - instanceGroup: master-${US_WEST_ZONE}
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
  masterPublicName: api.${US_WEST_CONTEXT}
  networkCIDR: 172.20.0.0/16
  networking:
    kubenet: {}
  nonMasqueradeCIDR: 100.64.0.0/10
  sshAccess:
  - 0.0.0.0/0
  subnets:
  - cidr: 172.20.32.0/19
    name: ${US_WEST_ZONE}
    type: Public
    zone: ${US_WEST_ZONE}
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
    kops.k8s.io/cluster: ${US_WEST_CONTEXT}
  name: master-${US_WEST_ZONE}
spec:
  image: kope.io/k8s-1.11-debian-stretch-amd64-hvm-ebs-2018-08-17
  machineType: ${MASTER_FLAVOR}
  maxSize: ${MASTER_COUNT}
  minSize: ${MASTER_COUNT}
  nodeLabels:
    kops.k8s.io/instancegroup: master-${US_WEST_ZONE}
  role: Master
  subnets:
  - ${US_WEST_ZONE}
---
apiVersion: kops/v1alpha2
kind: InstanceGroup
metadata:
  labels:
    kops.k8s.io/cluster: ${US_WEST_CONTEXT}
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
  - ${US_WEST_ZONE}
EOF

kops create secret --name ${US_WEST_CONTEXT} \
  --state=s3://${US_WEST_BUCKET_NAME} \
  sshpublickey admin -i ~/.ssh/id_rsa.pub

# kops create cluster \
#   --name=${US_WEST_CONTEXT} \
#   --state=s3://${US_WEST_BUCKET_NAME} \
#   --zones="${US_WEST_ZONE}" \
#   --master-size=${MASTER_FLAVOR} \
#   --node-size=${NODE_FLAVOR} \
#   --node-count=${NODE_COUNT} \
#   --dns-zone=${DOMAIN_NAME}

kops update cluster ${US_WEST_CONTEXT} \
  --state=s3://${US_WEST_BUCKET_NAME} \
  --yes
