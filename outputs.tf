output "client_id" {
  value     = jsondecode(data.aws_secretsmanager_secret_version.microservice_client_credentials[0].secret_string)["client_id"]
  sensitive = true
}

output "client_secret" {
  value     = jsondecode(data.aws_secretsmanager_secret_version.microservice_client_credentials[0].secret_string)["client_secret"]
  sensitive = true
}

output "cognito_auth_url" {
  value = "https://auth.${local.environment.name == "prod" ? "" : "${local.environment.name}."}cognito.vydev.io"
}

output "jwks_url" {
  value     = "https://cognito-idp.${data.aws_region.current.name}.amazonaws.com/${local.environment.user_pool_id}/.well-known/jwks.json"
}

output "open_id_url" {
  value     = "https://cognito-idp.${data.aws_region.current.name}.amazonaws.com/${local.environment.user_pool_id}/.well-known/openid-configuration"
}
