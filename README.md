# Setup Kubernetes Federation on AWS
In this lab, we will deploy Kubernetes clusters in three different AWS regions, and then setup Kubernetes Federation between clusters. When federation has been created we will create a federated deployment and service for nginx. And finally, we will create latency-based DNS records in Route 53, one for each cluster region.

![](/img/fed-clusters.png)

## Prerequisites
* We will deploy clusters in different AWS regions:
  * US West: **Oregon(us-west-2)**
  * US East: **Ohio(us-east-2)**
  * Asia: **Tokyo(ap-northeast-1)**
* Install the following tools on the host:
  * [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/): Using kubectl, you can inspect cluster resources; create, delete, and update components.
  * [kubefed](https://kubernetes.io/docs/tasks/federation/set-up-cluster-federation-kubefed/): Helps you to deploy a new Kubernetes cluster federation control plane, and to add clusters to or remove clusters from an existing federation control plane.
  > if OS is OS X, you need build from [Federation](https://github.com/kubernetes/federation) source code.

  * [kops](https://github.com/kubernetes/kops): Production Grade K8s Installation, Upgrades, and Management.
  * [aws](https://aws.amazon.com/cli/?nc1=h_ls): The AWS Command Line Interface (CLI) is a unified tool to manage your AWS services.
* We will be using Amazon AWS as the IaaS provider:
  * IAM: Provide identity and access management.
  * EC2: The Kubernetes cluster instances.
  * ELB: Kubernetes service load balancer.
  * Route53: Public domain for Kubernetes API, Service, ..., etc.
  * S3: Store Kops state.
  * VPC: Provide cluster network.
* Godaddy domain name or register from Route53

## Quick Start
For the execution of the labs, you need set your env in `.env` file：
```sh
$ cp .env.sample .env
$ vim .env
```

First create a hostedzone using `0-create-hosted-domain.sh`:
```sh
$ ./0-create-hosted-domain.sh
# output like this
{
    "HostedZone": {
        "ResourceRecordSetCount": 2,
        "CallerReference": "2018-04-19-11:24",
        "Config": {
            "PrivateZone": false
        },
        "Id": "/hostedzone/Z363YQ27EUQU4S",
        "Name": "k8s.xxxx.com."
    },
    "DelegationSet": {
        "NameServers": [
            "ns-431.awsdns-49.org",
            "ns-1341.awsdns-00.com",
            "ns-134.awsdns-42.co.uk",
            "ns-1131.awsdns-62.net"
        ]
    },
    "Location": "https://route53.amazonaws.com/2013-04-01/hostedzone/Z363YQ27EUQU4S",
    "ChangeInfo": {
        "Status": "PENDING",
        "SubmittedAt": "2018-04-19T03:24:17.638Z",
        "Id": "/change/CTCT89X4F01LM"
    }
}

$ aws route53 list-hosted-zones
```

Add `NameServers` into Godaddy, like this:

![](/img/godday-ns.png)

Now follow the scripts to setup your federation cluster.
