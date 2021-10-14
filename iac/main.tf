terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}


/*
module "development" {
  source = "env/dev"
}

module "stagging" {
  source = "env/hom"
}
*/

module "production" {
  source = "./environments/production"
  region = "${var.region}"
}