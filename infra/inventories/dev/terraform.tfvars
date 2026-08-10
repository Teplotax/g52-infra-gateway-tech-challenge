environment = "dev"
api_name   = "api-g52-tech-challenge-v1"
vpc_id = "vpc-04055fee4b29e6c48"
destroy = false

#API Gateway
throttle_burst_limit = 500
throttle_rate_limit  = 100
require_api_key      = false
log_retention_days = 1