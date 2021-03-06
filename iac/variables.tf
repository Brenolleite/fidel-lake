variable "access_key" {
    type = string
    description = "AWS Access Key"    
}

variable "secret_key" {
    type = string
    description = "AWS Secret Key"    
}

variable "region" {
    type = string
    description = "AWS Region"    
}

variable "env" {
    type = string
    description = "Environment: dev | stag | prod"  
}