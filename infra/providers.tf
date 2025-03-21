# Setting and locking the Dependencies
terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "4.2"
    }
  }

  # Setting the Terraform version
  required_version = ">= 1.0.0"
}

# Feeding the aws provider the data it needs
provider "aws" {
    # Set the default region
    region = var.region
  
}
