# Terraform

Terraform runbook to create a Infra in AWS and run an HTTPD Webserver.

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
since we can create n instances with setting the count no : <value> which means Tag value alos increaments by n+1

Services created using Terraform are:
1 -> VPC (with routable ip)
2 -> Internet Gateway
3 -> Subnets(Public)
4 -> Security Groups (Open to ssh--> locked down to source public IP, HTTP and HTTPs locked down to VPC)
4 -> Instances (CentOs Ami)
5 -> ELB with HTTP and HTTPs

> :warning: **Output:**
> The Output of ELB will be displayed after the terraform is applied and all the instances 
> will be added automatically to the ELB created.
> eg. <http://webserverelb-2067134482.us-west-1.elb.amazonaws.com/>


<!-- BEGINNING OF TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| ami | ID of AMI to use for the instance | string | n/a | yes |
| instance\_count | Number of instances to launch | number | `"1"` | no |
| instance\_type | The type of instance to start | string | n/a | yes |
| key\_name | The key name to use for the instance | string | `""` | no |
| name | Name to be used on all resources as prefix | string | n/a | yes |
| tags | A mapping of tags to assign to the resource | map(string) | `{}` | no |
| volume\_tags | A mapping of tags to assign to the devices created by the instance at launch time | map(string) | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| Webserver | Output of Webserver used to connect httpd |

<!-- END OF TERRAFORM DOCS HOOK -->

## Authors

Module managed by [Vasanth Murali]

