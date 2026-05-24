output "api_gateway_id" {
  description = "REST API ID"
  value       = aws_api_gateway_rest_api.this.id
}

output "api_key" {
  description = "Generated API key value (empty when require_api_key = false)"
  value       = var.require_api_key ? aws_api_gateway_api_key.this[0].value : ""
  sensitive   = true
}