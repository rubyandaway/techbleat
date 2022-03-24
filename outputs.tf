output "aws_instance_public_dns" {
  value = aws_instance.httpd-webserver.public_dns
}