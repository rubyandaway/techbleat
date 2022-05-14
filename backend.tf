terraform {
  backend "s3" {
    bucket = "bucket4state54"
    key    = "dev/terraform.tfstate"
    region = "us-east-1"
    acl    = "private"
  }

}
