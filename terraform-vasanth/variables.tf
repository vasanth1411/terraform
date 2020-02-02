
variable "aws_region" {
  description = "AWS region to launch servers."
}

variable "key_name" {
  description = "Desired name of AWS key pair"
}

variable "public_key_path" {
  description = "path for AWS key"
}

variable "private_key_path" {
  description = "path for AWS key"
  default     = "/Users/vmurali/Downloads/vmurali.pem"
}

variable "name" {
  description = "Name to be used on all resources as prefix for Tags"
  type        = string
}

variable "use_num_suffix" {
  description = "Always append numerical suffix to instance name, even if instance_count is 1"
  type        = bool
}


# CentOs aws_amis
variable "aws_amis" {
  default = {
    us-east-1 = "ami-973db5fe"
    us-east-2 = "ami-973db5fe"
    us-west-1 = "ami-1093b355"
    us-west-2 = "ami-a861ea98"
  }
}

variable "instance_count" {
  description = "Number of instances to launch"
  type        = number
}

variable "instance_type" {
  description = "Number of instances to launch"
  type        = string
}

variable "subnet_count" {
  description = "Number of subnets to launch"
  type        = number
}

variable "subnet_cidrs" {
  type = list
}

variable "ip_whitelist" {
}

variable "dest_cidrs" {
}

variable "vpc_cidrs" {
}

variable "sg_dest_cidrs" {
}

variable "sg_vpc_cidrs" {
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

variable "volume_tags" {
  description = "A mapping of tags to assign to the devices created by the instance at launch time"
  type        = map(string)
  default     = {}
}
