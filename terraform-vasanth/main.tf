terraform {
  required_version = ">= 0.12"
}

data "aws_availability_zones" "available" {
  state = "available"
}

# Specify the provider and access details
provider "aws" {
  region = "${var.aws_region}"
}

# Create a VPC to launch our instances into
resource "aws_vpc" "vasanth-test" {
  cidr_block = "${var.vpc_cidrs}"

  tags = {
    "Name" = format("%s-%s", var.name, "vpc")
    Owner = var.name
  }
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "vasanth-test" {
  vpc_id = "${aws_vpc.vasanth-test.id}"

  tags = {
    "Name" = format("%s-%s", var.name, "igw")
    Owner = var.name
  }
}

# Grant the VPC internet access on its main route table
resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.vasanth-test.main_route_table_id}"
  destination_cidr_block = var.dest_cidrs
  gateway_id             = "${aws_internet_gateway.vasanth-test.id}"
}

# Create a subnet to launch our instances into
resource "aws_subnet" "vasanth-test" {
  count = var.subnet_count
  availability_zone 	  = data.aws_availability_zones.available.names[count.index]
  vpc_id                  = "${aws_vpc.vasanth-test.id}"
  cidr_block              = "${var.subnet_cidrs[count.index]}"
  map_public_ip_on_launch = true

  tags = {
    "Name" = format("%s-%s-%d", var.name, "subnet", count.index + 1 )
    Owner = var.name
  }
}

# A security group for the ELB so it is accessible via the webserver
resource "aws_security_group" "elb" {
  name        = "webserver_elb_sg"
  description = "terraform security group"
  vpc_id      = "${aws_vpc.vasanth-test.id}"

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = "${var.ip_whitelist}"
  }

  # HTTP access from anywhere
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = "${var.ip_whitelist}"
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = "${var.sg_dest_cidrs}"
  }

 tags = {
    "Name" = format("%s-%s", var.name, "elb-sg")
    Owner = var.name
  }
}

# Our vasanth-test security group to access
# the instances over SSH and HTTP
resource "aws_security_group" "vasanth-test" {
  name        = "webserver_sg"
  description = "terraform security group"
  vpc_id      = "${aws_vpc.vasanth-test.id}"

  # SSH access from anywhere, terraform was created from local machine and on entire new AWS account
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = "${var.ip_whitelist}"
  }

  # HTTP access from the VPC
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = "${var.sg_vpc_cidrs}"
  }

  # HTTP access from anywhere
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = "${var.sg_vpc_cidrs}"
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = "${var.sg_dest_cidrs}"
  }

  tags = {
    "Name" = format("%s-%s", var.name, "webserver_sg")
    Owner = var.name
  }
}


resource "aws_key_pair" "auth" {
  key_name   = "${var.key_name}"
  public_key = "${file(var.public_key_path)}"
}

resource "aws_instance" "webserver" {
  count = var.instance_count
  instance_type = var.instance_type
  ami = "${lookup(var.aws_amis, var.aws_region)}"
  key_name = "${aws_key_pair.auth.id}"
  vpc_security_group_ids = ["${aws_security_group.vasanth-test.id}"]
  subnet_id = "${element("${aws_subnet.vasanth-test.*.id}", count.index)}"
  tags = merge(
  {
    "Name" = var.instance_count > 1 || var.use_num_suffix ? format("%s-%d", var.name, count.index + 1) : var.name
  },
  var.tags,
  )

  provisioner "remote-exec" {
    inline = [
      "sudo yum -y install httpd",
      "sudo touch /var/www/html/index.html && sudo chown -R ec2-user:ec2-user /var/www/html/index.html && sudo echo 'Hello Vasanth, Welcome!!! ' >> /var/www/html/index.html",
      "sudo service httpd start"
    ]
  }
  connection {
    user     = "ec2-user"
    host     = self.public_ip
    private_key = "${file(var.private_key_path)}"
  }
}

resource "aws_elb" "webserver" {
  name =  "webserver-elb"
  subnets         = "${aws_subnet.vasanth-test.*.id}"
  security_groups = ["${aws_security_group.elb.id}"]
  instances       = "${aws_instance.webserver.*.id}"

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
# Commenting due to free cert generation on certificate Manager
#  listener {
#    instance_port     = 443
#    instance_protocol = "https"
#    lb_port           = 443
#    lb_protocol       = "ssl"
#  }

   tags = {
    "Name" = format("%s-%s", var.name, "elb_sg")
     Owner = var.name
  }
}


# Create Router53 entry from the webserver endpoint created
#resource "aws_route53_record" "node" {
#  zone_id = "ZSxxxxxxx"
#  name    = "www.example.com"
#  type    = "A"
#  alias {
#    name                   = "${aws_elb.webserver.*.dns_name}"
#    zone_id                = "${aws_elb.webserver.*.zone_id}"
#    evaluate_target_health = true
#  }
#}
