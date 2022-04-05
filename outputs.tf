output "account_id" {
  value = local.environment.account_id
}

output "user_pool_id" {
  value = local.environment.user_pool_id
}

output "client_id" {
  value     = length(var.user_pool_client_scopes) != 0 ? jsondecode(data.aws_secretsmanager_secret_version.microservice_client_credentials[0].secret_string)["client_id"] : null
  sensitive = true
}

output "client_secret" {
  value     = var.generate_secret && length(var.user_pool_client_scopes) != 0 ? jsondecode(data.aws_secretsmanager_secret_version.microservice_client_credentials[0].secret_string)["client_secret"] : null
  sensitive = true
}

output "auth_url" {
  value = "https://auth.${local.environment.name == "prod" ? "" : "${local.environment.name}."}cognito.vydev.io"
}

output "jwks_url" {
  value     = "https://cognito-idp.${data.aws_region.current.name}.amazonaws.com/${local.environment.user_pool_id}/.well-known/jwks.json"
}

output "open_id_url" {
  value     = "https://cognito-idp.${data.aws_region.current.name}.amazonaws.com/${local.environment.user_pool_id}/.well-known/openid-configuration"
}
