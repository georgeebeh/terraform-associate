# terraform settings block with required provider details
terraform {
    backend "remote" {
    hostname = "app.terraform.io"
    organization = "insight-catalyst"

    workspaces {
      name = "Getting_started"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "eu-west-2"
}

locals {
    project_name = "Prod"
}