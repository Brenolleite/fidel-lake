# Create role for kinesis firehose
resource "aws_iam_role" "firehose_role" {
  name = "fidel-firehose-role"
  
  inline_policy {
    name = "firehose-policy"

    policy = jsonencode({
        Version = "2012-10-17",  
        Statement = [    
            {      
                Effect = "Allow",      
                Action = [
                    "s3:AbortMultipartUpload",
                    "s3:GetBucketLocation",
                    "s3:GetObject",
                    "s3:ListBucket",
                    "s3:ListBucketMultipartUploads",
                    "s3:PutObject"
                ],      
                Resource = [        
                    "arn:aws:s3:::${var.sor_bucket_name}",
                    "arn:aws:s3:::${var.sor_bucket_name}/*"		    
                ]     
            },
            {
              Effect = "Allow",
              Action = [
                  "kms:Decrypt",
                  "kms:GenerateDataKey"
              ],
              Resource = [
                  "arn:aws:kms:*:${data.aws_caller_identity.current.account_id}:key/*"           
              ],
              Condition = {
                  StringEquals = {
                      "kms:ViaService": "s3.*.amazonaws.com"
                  },
                  StringLike = {
                      "kms:EncryptionContext:aws:s3:arn": "arn:aws:s3:::${var.sor_bucket_name}/*"
                  }
              }
            },
            {
              Effect = "Allow",
              Action = [
                  "logs:PutLogEvents"
              ],
              Resource = [
                  "arn:aws:logs:*:${data.aws_caller_identity.current.account_id}:log-group:*:log-stream:*"
              ]
            }
        ]
    })
  }

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "firehose.amazonaws.com"
        }
      },
    ]
  })
}

# Create Kinesis Firehose for ingesting transation data
resource "aws_kinesis_firehose_delivery_stream" "firehose_transaction" {
  name        = "fidel-transactions-ingestion"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn            = aws_iam_role.firehose_role.arn
    bucket_arn          = var.sor_bucket_arn
    buffer_size         = 128
    buffer_interval     = 600
    compression_format  = "Snappy"
    prefix              = "transaction_events/"
    error_output_prefix = "error/"
  }

  server_side_encryption {
    enabled = true

  }
}

# Create role for kinesis firehose
resource "aws_iam_role" "event_bridge_firehose" {
  name = "fidel-eventbridge-firehose-role"
  
  inline_policy {
    name = "firehose-access"

    policy = jsonencode({
      Version = "2012-10-17",
      Statement = [
          {
              Effect = "Allow",
              Action = [
                  "firehose:PutRecord",
                  "firehose:PutRecordBatch"
              ],
              Resource = [
                  "arn:aws:firehose:*:${data.aws_caller_identity.current.account_id}:deliverystream/*"
              ]
          }
      ]
    })
  }

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "events.amazonaws.com"
        }
      },
    ]
  })
}

# Create a custom event bus for analytics porpuses
resource "aws_cloudwatch_event_bus" "analytics_bus" {
    name = "fidel-analytics"
}

# Create event bridge rule for ingesting transactions
resource "aws_cloudwatch_event_rule" "transactions_ingestion" {
    name = "fidel-transactions-ingestion"  
    event_bus_name = aws_cloudwatch_event_bus.analytics_bus.name

    event_pattern = jsonencode({
        source      = ["lambda"],
        detail-type = ["Lambda Function Invocation Result - Success"],
        detail = {
            responsePayload = {
                ingestion = ["transactions"]
            }
        }
    })
}

# Create event bridge rule target for transactions
resource "aws_cloudwatch_event_target" "firehose_rule" {
    rule      = aws_cloudwatch_event_rule.transactions_ingestion.name
    event_bus_name = aws_cloudwatch_event_bus.analytics_bus.name
    target_id = "transaction-ingestion-firehose"
    arn       = aws_kinesis_firehose_delivery_stream.firehose_transaction.arn
    role_arn  = aws_iam_role.event_bridge_firehose.arn
}