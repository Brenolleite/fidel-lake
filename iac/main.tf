terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

module "storage"{
  source = "./modules/storage"
  env    = "${var.env}"
  region = "${var.region}"
}

module "network"{
  source = "./modules/network"
  env    = "${var.env}"   
}

module "ingestion"{
  source     = "./modules/ingestion"
  sor_bucket_arn  = module.storage.sor_bucket_arn
  sor_bucket_name = module.storage.sor_bucket_name
}

module "generator"{
  source = "./modules/generator"
  event_bus_name = module.ingestion.event_bus_name
  event_bus_arn  = module.ingestion.event_bus_arn
}