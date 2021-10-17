# Create bucket for source of record layer
resource "aws_s3_bucket" "sor" {
  bucket = "fidel-sor-${var.env}-${var.region}-${data.aws_caller_identity.current.account_id}"
  acl    = "private"

  server_side_encryption_configuration {
    rule{
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    } 
  }
}

# Block public access for source of record layer
resource "aws_s3_bucket_public_access_block" "sor_block" {
  bucket = aws_s3_bucket.sor.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Create bucket for specialized layer
resource "aws_s3_bucket" "spec" {
  bucket = "fidel-spec-${var.env}-${var.region}-${data.aws_caller_identity.current.account_id}"
  acl    = "private"

  server_side_encryption_configuration {
    rule{
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    } 
  }
}

# Block public access for specialized layer
resource "aws_s3_bucket_public_access_block" "spec_block" {
  bucket = aws_s3_bucket.spec.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}