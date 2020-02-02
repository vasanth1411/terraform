
# Network configs
subnet_cidrs     = [ "10.0.1.0/25", "10.0.5.0/24" ]
vpc_cidrs        = "10.0.0.0/16"
dest_cidrs       = "0.0.0.0/0"
sg_vpc_cidrs     = [ "10.0.0.0/16" ]
sg_dest_cidrs    = [ "0.0.0.0/0" ]
ip_whitelist     = [ "122.180.159.134/32" ]

# IAM
key_name         = "vmurali.pem"
public_key_path  = "/Users/vmurali/Downloads/vmurali.pem.pub"
private_key_path = "/Users/vmurali/Downloads/vmurali.pem"

#Instance configs
aws_region       = "us-west-1"
use_num_suffix   =  false
instance_type    = "m3.medium"

#Count Variables for multiAZ deployments
instance_count   = 4
#subnet count cannot be more than 2, becasue usuable AZ for us-west-1 is 2.
subnet_count     = 2
