# Gitlab-CE HA on AWS with Terraform

Infrastructure code for building [Gitlab-ce](https://about.gitlab.com/) system as [High Availability](https://about.gitlab.com/high-availability/) using [Amazon Web Services](https://aws.amazon.com/). Ths setup is based on this [Gitlab university : HA on AWS](https://docs.gitlab.com/ce/university/high-availability/aws/) document.

# Requirements
- AWS Account
- VPC and subnets configure
- Route 53 DNS Domain
- Gitlab-CE AWS AMI in your region

# Usage

`terraform apply`
