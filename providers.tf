#can find this on the terraform documentation.

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}


provider "aws" {
  region                  = "ap-south-1"
  shared_credentials_file = "/home/kenny/.aws/credentials"
  profile                 = "terraform-1st"
}
