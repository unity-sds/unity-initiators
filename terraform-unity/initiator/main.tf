resource "null_resource" "build_lambda_package" {
  triggers = { always_run = timestamp() }
  provisioner "local-exec" {
    command = <<EOF
      set -ex
      docker run --rm -v ${path.module}/../..:/var/task mlupin/docker-lambda:python3.9-build ./scripts/build_lambda_package.sh
    EOF
  }
}

resource "aws_s3_object" "lambda_package" {
  depends_on = [null_resource.build_lambda_package]
  bucket     = var.code_bucket
  key        = "unity_initiator-${jsondecode(data.local_file.version.content).version}-lambda.zip"
  source     = "${path.module}/../../dist/unity_initiator-${jsondecode(data.local_file.version.content).version}-lambda.zip"
  etag       = filemd5("${path.module}/../../dist/unity_initiator-${jsondecode(data.local_file.version.content).version}-lambda.zip")
}

resource "aws_s3_object" "router_config" {
  bucket = var.config_bucket
  key    = basename(var.router_config)
  source = var.router_config
  etag   = filemd5(var.router_config)
}

resource "aws_lambda_function" "initiator_lambda" {
  depends_on    = [aws_s3_object.lambda_package, aws_s3_object.router_config]
  function_name = "${var.project}-${var.venue}-${var.deployment_name}-initiator"
  s3_bucket     = var.code_bucket
  s3_key        = "unity_initiator-${jsondecode(data.local_file.version.content).version}-lambda.zip"
  handler       = "unity_initiator.cloud.lambda_handler.lambda_handler_initiator"
  runtime       = "python3.11"
  role          = aws_iam_role.initiator_lambda_iam_role.arn
  timeout       = 900

  environment {
    variables = {
      ROUTER_CFG_URL = "s3://${aws_s3_object.router_config.bucket}/${aws_s3_object.router_config.key}"
    }
  }
  tags = var.tags
}

resource "aws_iam_role" "initiator_lambda_iam_role" {
  name = "${var.project}-${var.venue}-${var.deployment_name}-initiator_lambda_iam_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
      },
    ],
  })
  permissions_boundary = data.aws_iam_policy.mcp_operator_policy.arn
}

resource "aws_iam_policy" "initiator_lambda_policy" {
  name        = "${var.project}-${var.venue}-${var.deployment_name}-initiator_lambda_policy"
  description = "A policy for the initiator lambda function to access S3 and SQS"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "ListObjectsInBucket",
        "Effect" : "Allow",
        "Action" : ["s3:ListBucket"],
        "Resource" : ["arn:aws:s3:::*"]
      },
      {
        "Sid" : "AllObjectActions",
        "Effect" : "Allow",
        "Action" : "s3:*Object",
        "Resource" : ["arn:aws:s3:::*"]
      },
      {
        "Sid" : "AccessInitiatorSQS",
        "Effect" = "Allow"
        "Action" = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ],
        "Resource" = [aws_sqs_queue.initiator_queue.arn]
      }
    ]
  })

}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.initiator_lambda_iam_role.name
  policy_arn = aws_iam_policy.initiator_lambda_policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda_base_policy_attachment" {
  role       = aws_iam_role.initiator_lambda_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_ssm_parameter" "initiator_lambda_function_name" {
  name  = "/unity/${var.project}/${var.venue}/od/initiator/${var.deployment_name}"
  type  = "String"
  value = aws_lambda_function.initiator_lambda.function_name
}


resource "aws_sqs_queue" "initiator_dead_letter_queue" {
  name                       = "${var.project}-${var.venue}-${var.deployment_name}-initiator_dead_letter_queue"
  delay_seconds              = 0
  max_message_size           = 2048
  message_retention_seconds  = 1209600
  receive_wait_time_seconds  = 0
  visibility_timeout_seconds = 900
}

resource "aws_sqs_queue" "initiator_queue" {
  name                       = "${var.project}-${var.venue}-${var.deployment_name}-initiator_queue"
  delay_seconds              = 0
  max_message_size           = 2048
  message_retention_seconds  = 1209600
  receive_wait_time_seconds  = 10
  visibility_timeout_seconds = 900
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.initiator_dead_letter_queue.arn
    maxReceiveCount     = 2
  })
}

resource "aws_sns_topic" "initiator_topic" {
  name = "${var.project}-${var.venue}-${var.deployment_name}-initiator_topic"
}

resource "aws_sqs_queue_policy" "initiator_queue_policy" {
  queue_url = aws_sqs_queue.initiator_queue.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "sqs:SendMessage"
        Resource  = aws_sqs_queue.initiator_queue.arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_sns_topic.initiator_topic.arn
          }
        }
      },
    ]
  })
}

resource "aws_sns_topic_subscription" "initiator_subscription" {
  topic_arn = aws_sns_topic.initiator_topic.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.initiator_queue.arn
}

resource "aws_lambda_event_source_mapping" "initiator_queue_event_source_mapping" {
  batch_size       = 10
  enabled          = true
  event_source_arn = aws_sqs_queue.initiator_queue.arn
  function_name    = aws_lambda_function.initiator_lambda.arn
}
