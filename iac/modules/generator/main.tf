# Create role for lambda
resource "aws_iam_role" "iam_for_lambda" {
  name = "fidel-lambda-role"
  
  inline_policy {
    name = "eventbridge-access"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {          
          Effect   = "Allow",
          Action   = "events:*",
          Resource = "arn:aws:events:*:${data.aws_caller_identity.current.account_id}:event-bus/${var.event_bus_name}"          
        },
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
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

# Create zip file for lambda
data "archive_file" "zipit" {
  type        = "zip"
  source_file = "../lambdas/fidel_transaction_generator.py"
  output_path = "./fidel_transaction_generator.zip"
}


# Create the lambda function
resource "aws_lambda_function" "lamda_generator" {  
  function_name    = "fidel_transaction_generator"
  role             = aws_iam_role.iam_for_lambda.arn
  handler          = "fidel_transaction_generator.lambda_handler"
  filename         = "./fidel_transaction_generator.zip"
  source_code_hash = "${data.archive_file.zipit.output_base64sha256}"
  runtime          = "python3.9"
  timeout          = "60"
}

# Create lambda destination
resource "aws_lambda_function_event_invoke_config" "lambda_destination" {
  function_name = aws_lambda_function.lamda_generator.function_name

  destination_config {
    on_success {
      destination = var.event_bus_arn
    }
  }
}

# Create role for event bridge rule for lambda caller
resource "aws_iam_role" "iam_for_event_rule" {
  name = "fidel-event-bridge-role"
  
  inline_policy {
    name = "lambda-access"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {          
          Effect   = "Allow",
          Action   = "lambda:InvokeFunction",
          Resource = "arn:aws:lambda:*:${data.aws_caller_identity.current.account_id}:function/${aws_lambda_function.lamda_generator.function_name}"          
        },
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

# Create event bridge rule for generating data over time
resource "aws_cloudwatch_event_rule" "lambda" {
    name = "fidel-lambda-caller"
    schedule_expression = "rate(1 minute)"
}

/* 
  Create event bridge rule target for lambda

  As rule is only by minutes, created 4 targets
  for calling lambda more times to generate data
*/
resource "aws_cloudwatch_event_target" "lambda_rule_1" {
    rule      = aws_cloudwatch_event_rule.lambda.name
    target_id = "lambda-generator-caller-1"
    arn       = aws_lambda_function.lamda_generator.arn    
}

resource "aws_cloudwatch_event_target" "lambda_rule_2" {
    rule      = aws_cloudwatch_event_rule.lambda.name
    target_id = "lambda-generator-caller-2"
    arn       = aws_lambda_function.lamda_generator.arn    
}

resource "aws_cloudwatch_event_target" "lambda_rule_3" {
    rule      = aws_cloudwatch_event_rule.lambda.name
    target_id = "lambda-generator-caller-3"
    arn       = aws_lambda_function.lamda_generator.arn    
}

resource "aws_cloudwatch_event_target" "lambda_rule_4" {
    rule      = aws_cloudwatch_event_rule.lambda.name
    target_id = "lambda-generator-caller-4"
    arn       = aws_lambda_function.lamda_generator.arn    
}

resource "aws_cloudwatch_event_target" "lambda_rule_5" {
    rule      = aws_cloudwatch_event_rule.lambda.name
    target_id = "lambda-generator-caller-5"
    arn       = aws_lambda_function.lamda_generator.arn    
}

# Create lambda permission for trigger
resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lamda_generator.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.lambda.arn  
}