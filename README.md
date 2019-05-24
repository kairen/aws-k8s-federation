# Setup Kubernetes Federation `V2` on AWS
In this lab, we will deploy the Kubernetes cluster in three different AWS regions, and then setup Federation between clusters. When federation has been created we will create a federated deployment and service for NGINX. And finally, we will create latency-based DNS records in Route 53, one for each cluster region.

![](/img/fed-cluster.png)

## Prerequisites
* We need to deploy Kubernetes cluster in different AWS regions. e.g.:
  * US West: **Oregon(us-west-2)**
  * US East: **Ohio(us-east-2)**
  * Asia: **Tokyo(ap-northeast-1)**
* Install the following tools on the host:
  * [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/): Using kubectl, you can inspect cluster resources; create, delete, and update components.
  * [helm](https://helm.sh/docs/using_helm/#installing-helm): Using helm to install federation-v2 components by the [chart](https://github.com/kubernetes-sigs/kubefed/tree/master/charts/kubefed).
  * [kubefedctl](https://github.com/kubernetes-sigs/kubefed): Helps you to join/unjon clusters from an existing federation control plane.
  * [kops](https://github.com/kubernetes/kops): Production Grade K8s Installation, Upgrades, and Management.
  
  > Federation v2 can be deployed to and manage clusters running Kubernetes `v1.11` or greater.

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
