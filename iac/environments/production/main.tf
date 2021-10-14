module "storage"{
  source = "../../modules/storage"  
  env    = "prod"
  region = "${var.region}"
}

module "network"{
  source = "../../modules/network"  
  env    = "prod"  
}