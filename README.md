# Terraform

Terraform runbook to create MultiAZ infra in AWS and run an HTTPD Webserver.

## Terraform version

Terraform 0.12.

### Prerequisites
* [Terraform 0.12](https://releases.hashicorp.com/terraform/0.12/)


# Terraform commands

Run the following after you set the path for terraform 0.12

- terraform init
- terraform plan
- terraform apply

# Terraform Plan

When you run "terraform plan" you will be prompted for key name and tag value name, which would be used as Tag value for all instances.
since we can create n instances with setting the count no : <value> which means Tag value also increments by n+1

Services created using Terraform are:
1 -> VPC (with routable ip)
2 -> Internet Gateway
3 -> Subnets(Public) in MultiAz
4 -> Security Groups (Open to ssh--> locked down to source public IP, HTTP and HTTPs locked down to VPC)
4 -> Instances (CentOs Ami) in MultiAZ
5 -> ELB with HTTP and HTTPs

> :warning: **Output:**
> The Output of ELB will be displayed after the terraform is applied and all the instances
> will be added automatically to the ELB created.
> eg. <http://webserverelb-2067134482.us-west-1.elb.amazonaws.com/>

> :warning: **Input:**
> All these inputs are preassigned using .tfvars as input variables.

<!-- BEGINNING OF TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| ami | ID of AMI to use for the instance | string | n/a | no |
| aws_region | Default AWS region | string | us-west-1 | no |
| instance\_count | Number of instances to launch | number | `"2"` | no |
| public_key_path | Public key for your created key pair | string | `""` | no |
| private_key_path | Private key for your created key pair | string | `""` | no |
| key\_name | The key name to use for the instance | string | `""` | no |
| subnets\_count | Number of subnets to launch | number | `"2"` | no |
| instance\_type | The type of instance to start | string | n/a | no |
| name | Name to be used on all resources as prefix | string | n/a | yes |
| subnet_cidrs | Subnet CIDR values | string | `""` | no |
| ip_whitelist | Whitelist Ip on SG level | string | `""` | no |
| dest_cidrs  | Outbound rules | string | `""` | no |
| vpc_cidrs | VPC CIDR values | string | `""` | no |
| tags | A mapping of tags to assign to the resource | map(string) | `{}` | no |
| volume\_tags | A mapping of tags to assign to the devices created by the instance at launch time | map(string) | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| Webserver | Output of Webserver used to connect httpd |

<!-- END OF TERRAFORM DOCS HOOK -->

## Authors

Module managed by [Vasanth Murali]

