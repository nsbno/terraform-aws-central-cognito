terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0.0"
    }
  }
}

/*
 * == Dependencies
 *
 * Various static data that is useful for the rest of the module
 */
locals {
  cognito_environments = {
    dev = {
      name         = "dev"
      account_id   = "834626710667"
      user_pool_id = "eu-west-1_0AvVv5Wyk"
    }
    test = {
      name         = "test"
      account_id   = "231176028624"
      user_pool_id = "eu-west-1_Z53b9AbeT"
    }
    stage = {
      name         = "stage"
      account_id   = "214014793664"
      user_pool_id = "eu-west-1_AUYQ679zW"
    }
    prod = {
      name         = "prod"
      account_id   = "387958190215"
      user_pool_id = "eu-west-1_e6o46c1oE"
    }
  }

  environment = cognito_environments[var.environment]
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

/*
 * == Configure Resource Server and User Pool Client
 */
locals {
  resource_server = {
    resource_server = {
      name_prefix = "${var.name_prefix}-${var.application_name}"
      identifier  = "https://${var.resource_server_base_url}/${var.application_name}"

      scopes = [
        for key, value in var.resource_server_scopes : {
          scope_name        = value.name
          scope_description = value.description
        }
      ]
    }
  }

  user_pool_client = {
    user_pool_client = {
      name_prefix     = "${var.name_prefix}-${var.application_name}"
      generate_secret = true

      explicit_auth_flows                  = ["ADMIN_NO_SRP_AUTH"]
      allowed_oauth_flows                  = ["client_credentials"]
      allowed_oauth_scopes                 = var.user_pool_client_scopes
      allowed_oauth_flows_user_pool_client = true
    }
  }


  # Don't use the config if the user didn't supply any scopes.
  cognito_config = jsonencode(merge(
    length(var.resource_server_scopes) == 0 ? {} : local.resource_server,
    length(var.user_pool_client_scopes) == 0 ? {} : local.user_pool_client
  ))
}

resource "aws_s3_bucket_object" "delegated-cognito-config" {
  bucket = var.bucket
  acl    = "bucket-owner-full-control"

  key = "${local.environment.name}/${data.aws_caller_identity.current.account_id}/${var.name_prefix}-${var.application_name}.json"

  content      = local.cognito_config
  content_type = "application/json"
}


/*
 * == Get the values back from Cognito
 *
 * The Central Cognito is set up in such a way that we can't get this back in a pure declarative way.
 * Because of this we need to do some small hacks with sleeping to make it work.
 *
 * Central Cognito will dump our values back into a secretsmanager variable, that we can read.
 */
resource "time_sleep" "wait_for_credentials" {
  create_duration = "300s"

  triggers = {
    config_hash = sha1(aws_s3_bucket_object.delegated-cognito-config[0].content)
  }
}

data "aws_secretsmanager_secret_version" "microservice_client_credentials" {
  depends_on = [aws_s3_bucket_object.delegated-cognito-config[0], time_sleep.wait_for_credentials[0]]

  secret_id  = "arn:aws:secretsmanager:eu-west-1:${local.environment.account_id}:secret:${data.aws_caller_identity.current.account_id}-${var.name_prefix}-${var.application_name}-id"
}
