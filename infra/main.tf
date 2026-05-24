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

