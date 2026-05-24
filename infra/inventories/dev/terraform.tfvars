environment = "dev"
api_name   = "api-tech-challenge-v1"
vpc_id = "vpc-05f6d4d40bf2a3f50"
destroy = false

#API Gateway
throttle_burst_limit = 500
throttle_rate_limit  = 100
require_api_key      = false
log_retention_days = 1