resource "aws_s3_bucket" "sor" {
  bucket = "sor-bucket"
  acl    = "private"
  
  server_side_encryption_configuration {
    rule{
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    } 
  }

  tags = {
    Name = "fidel-sor-${var.env}-${var.region}-${data.aws_caller_identity.current.account_id}"    
  }
}

resource "aws_s3_bucket" "sot" {
  bucket = "sor-bucket"
  acl    = "private"
  
  server_side_encryption_configuration {
    rule{
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    } 
  }

  tags = {
    Name = "fidel-sot-${var.env}-${var.region}-${data.aws_caller_identity.current.account_id}"    
  }
}

resource "aws_s3_bucket" "spec" {
  bucket = "sor-bucket"
  acl    = "private"
  
  server_side_encryption_configuration {
    rule{
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    } 
  }

  tags = {
    Name = "fidel-spec-${var.env}-${var.region}-${data.aws_caller_identity.current.account_id}"    
  }
}