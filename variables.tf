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
