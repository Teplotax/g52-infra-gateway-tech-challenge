# API Gateway

resource "aws_api_gateway_rest_api" "this" {
  name        = var.api_name
  description = "REST API for ${var.api_name} (${var.environment})"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = local.gateway_tags
}

# ── Optional: API Key + Usage Plan ────────────────────────────
resource "aws_api_gateway_api_key" "this" {
  count   = var.require_api_key ? 1 : 0
  name    = "${var.api_name}-api-key"
  enabled = true
  tags    = var.tags
}

resource "aws_api_gateway_usage_plan" "this" {
  count = var.require_api_key ? 1 : 0
  name  = "${var.api_name}-usage-plan"

  throttle_settings {
    burst_limit = var.throttle_burst_limit
    rate_limit  = var.throttle_rate_limit
  }

  quota_settings {
    limit  = var.quota_limit
    period = "MONTH"
  }

  tags = var.tags
}

resource "aws_api_gateway_usage_plan_key" "this" {
  count         = var.require_api_key ? 1 : 0
  key_id        = aws_api_gateway_api_key.this[0].id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.this[0].id
}

data "aws_vpc" "this" {
  id = var.vpc_id
}


# role de log do api gateway é config da conta, vale pros 3 stages (dev/hom/prod);
# fica aqui porque esse repo não é destruído junto com os ambientes
resource "aws_iam_role" "apigw_cloudwatch" {
  name = "role-apigateway-cloudwatch"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "apigateway.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = local.gateway_tags
}

resource "aws_iam_role_policy_attachment" "apigw_cloudwatch" {
  role       = aws_iam_role.apigw_cloudwatch.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

resource "aws_api_gateway_account" "this" {
  cloudwatch_role_arn = aws_iam_role.apigw_cloudwatch.arn

  depends_on = [aws_iam_role_policy_attachment.apigw_cloudwatch]
}
