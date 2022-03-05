variable "my_instance_type" {
  description = "This is to dynamically set the instance type"
  type        = string
  default     = "t2.micro"
}

variable "env" {
  default     = ""
  description = ""
}

variable "region" {
  default = "us-east-1"
}

variable "private_key_path" {
  default = "aws_key"
}

variable "public_key_path" {
  default = "aws_key.pub"
}

#variable "aws_access_key" {}
#variable "aws_secret_key" {}
#variable "private_key_path" {}
#variable "key_name" {}
#variable "region" {
#  default = "eu-west-2"
#}

