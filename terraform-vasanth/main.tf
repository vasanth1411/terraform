# Specify the provider and access details
provider "aws" {
  region = "${var.aws_region}"
}

# Create a VPC to launch our instances into
resource "aws_vpc" "vasanth-test" {
  cidr_block = "10.0.0.0/16"
  
  tags = {
    Name = "Apps-VPC",
    Owner = "Vasanth"
  }
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "vasanth-test" {
  vpc_id = "${aws_vpc.vasanth-test.id}"

  tags = {
    Name = "Apps-IGW",
    Owner = "Vasanth"
  }
}


# Grant the VPC internet access on its main route table
resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.vasanth-test.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.vasanth-test.id}"
}

# Create a subnet to launch our instances into
resource "aws_subnet" "vasanth-test" {
  vpc_id                  = "${aws_vpc.vasanth-test.id}"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "Apps-Subnet01",
    Owner = "Vasanth"
  }
}

# A security group for the ELB so it is accessible via the webserver
resource "aws_security_group" "elb" {
  name        = "vasanth-test_elb"
  description = "Used in the terraform"
  vpc_id      = "${aws_vpc.vasanth-test.id}"

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from anywhere
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
   tags = {
    Name = "Apps-ELB-SG",
    Owner = "Vasanth"
  } 
}

# Our vasanth-test security group to access
# the instances over SSH and HTTP
resource "aws_security_group" "vasanth-test" {
  name        = "vasanth-test"
  description = "Used in the terraform"
  vpc_id      = "${aws_vpc.vasanth-test.id}"

  # SSH access from anywhere, terraform was created from local machine and on entire new AWS account
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from the VPC
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
  
  # HTTP access from anywhere
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Apps-Instance-SG",
    Owner = "Vasanth"
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
  subnet_id = "${aws_subnet.vasanth-test.id}"
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
  name =  "webserverelb"
#  count = var.instance_count
  subnets         = ["${aws_subnet.vasanth-test.id}"]
  security_groups = ["${aws_security_group.elb.id}"]
  instances       = "${aws_instance.webserver.*.id}"

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }  
#  listener {
#    instance_port     = 443
#    instance_protocol = "https"
#    lb_port           = 443
#   lb_protocol       = "ssl"
#  }
  tags = {
    Name = "Apps-ELB",
    Owner = "Vasanth"
  }
}
