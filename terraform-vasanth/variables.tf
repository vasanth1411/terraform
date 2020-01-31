
variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "us-west-1"
}

variable "key_name" {
  description = "Desired name of AWS key pair"
}

variable "public_key_path" {
  description = "path for AWS key"
  default     = "/Users/vmurali/Downloads/vmurali.pem.pub"
}

variable "private_key_path" {
  description = "path for AWS key"
  default     = "/Users/vmurali/Downloads/vmurali.pem"
}

variable "name" {
  description = "Name to be used on all resources as prefix"
  type        = string
}

variable "use_num_suffix" {
  description = "Always append numerical suffix to instance name, even if instance_count is 1"
  type        = bool
  default     = false
}

# CentOs Images
variable "aws_amis" {
  default = {
    us-east-1 = "ami-014b38e758721be30"
    us-east-2 = "ami-0a4e0492247630fe1"
    us-west-1 = "ami-1093b355"
    us-west-2 = "ami-0362922178e02e9f3"
  }
}

variable "instance_count" {
  description = "Number of instances to launch"
  type        = number
  default     = 2
}

variable "instance_type" {
  description = "Number of instances to launch"
  type        = string
  default     = "m3.medium"
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
