output "address" {
  value = "${aws_elb.webserver.*.dns_name}"
}
