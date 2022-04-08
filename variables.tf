variable "name_prefix" {
  description = "Prefix for all resources. Typically team name"
  type        = string
}

variable "application_name" {
  description = "The name of the application that owns this resource server and/or app client"
  type        = string
}

variable "environment" {
  description = "The environment this configuration belongs to."
  type = string
}

variable "bucket" {
  description = "The bucket owned by central cognito. This is where the config will be uploaded to."
  type        = string

  # The name may deceive.
  # This bucket is used by the central account to verify the config before applying it.
  default = "vydev-delegated-cognito-staging"
}


variable "resource_server_base_url" {
  description = "The base URL for the resource server and/or user pool client"
  type = string

  default = ""
}

variable "resource_server_scopes" {
  description = "Scopes to use for your resource server. Leaving it empty will drop creating a resource server."
  type        = map(object({
    name        = string
    description = string
  }))

  default = {}
}

variable "user_pool_client_scopes" {
  description = "Scopes to use for your user pool client. Leaving it empty will drop creating an user pool client."
  type        = list(string)

  default = []
}

variable "generate_secret" {
  description = "Should an application secret be generated."
  type = bool

  default = true
}

variable "allowed_oauth_flows" {
  description = "List of allowed OAuth flows (code, implicit, client_credentials)."
  type        = list(string)

  default = ["client_credentials"]
  validation {
    condition = alltrue([
      for flow in var.allowed_oauth_flows
        : contains(["client_credentials", "code", "implicit"], flow)
    ])
    error_message = "Items in allowed_oauth_flows can only be'client_credentials', 'code' or 'implicit'."
  }
}

variable "explicit_auth_flows" {
  description = "List of excplicit auth flows this client can initate"
  type        = list(string)

  default = [ "ADMIN_NO_SRP_AUTH" ]

  validation {
    condition = alltrue([
      for flow in var.explicit_auth_flows 
        : contains(
           [
             "ADMIN_NO_SRP_AUTH",
             "CUSTOM_AUTH_FLOW_ONLY",
             "USER_PASSWORD_AUTH",
             "ALLOW_ADMIN_USER_PASSWORD_AUTH",
             "ALLOW_CUSTOM_AUTH",
             "ALLOW_USER_PASSWORD_AUTH",
             "ALLOW_USER_SRP_AUTH",
             "ALLOW_REFRESH_TOKEN_AUTH"
            ],
            flow
          )
    ])
    error_message = "The list contains an invalid explicit auth flow indentifier."
  }

}


variable "callback_urls" {
  description = "List of allowed callback URLs for the identity providers."
  type        = list(string)

  default = null
}

variable "logout_urls" {
  description = "List of allowed logout URLs for the identity providers."
  type        = list(string)

  default = null
}

variable "supported_identity_providers" {
  description = "List of provider names for the identity providers that are supported on this client. Uses the provider_name attribute of aws_cognito_identity_provider resource(s), or the equivalent string(s)."
  type        = list(string)

  default = null
}
