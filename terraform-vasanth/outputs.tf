output "address" {
  description = "Webserver can we accessed using below URL://"
  value = "${aws_elb.webserver.*.dns_name}"
}
