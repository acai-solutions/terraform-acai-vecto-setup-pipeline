# ---------------------------------------------------------------------------------------------------------------------
# ¦ REQUIREMENTS
# ---------------------------------------------------------------------------------------------------------------------
terraform {
  required_version = "= 1.5.7"

  required_providers {
    aws = {
      source                = "hashicorp/aws"
      configuration_aliases = []
    }
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = ">= 0.9.0"
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ LOCALS
# ---------------------------------------------------------------------------------------------------------------------
# Build the Azure DevOps organization service URL from the organization name
locals {
  ado_org_service_url = "https://dev.azure.com/${var.vecto_setup_settings.ado_settings.organization_name}/"
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ PROVIDER
# ---------------------------------------------------------------------------------------------------------------------
provider "aws" {
  region = var.vecto_setup_settings.aws_settings.target_region
}

provider "azuredevops" {
  org_service_url = local.ado_org_service_url
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ DATA
# ---------------------------------------------------------------------------------------------------------------------
data "aws_caller_identity" "current" {}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ VECTO_SETUP
# ---------------------------------------------------------------------------------------------------------------------
module "vecto_setup" {
  # replace with your source URL in case you host VECTO in your own repository
  source = "git::https://github.com/acai-solutions/terraform-aws-acai-vecto.git//10-setup/ado-oidc?ref=main"

  aws_settings        = var.vecto_setup_settings.aws_settings
  ado_settings        = var.vecto_setup_settings.ado_settings
  vecto_repo_settings = var.vecto_setup_settings.vecto_repo_settings

  resource_tags = {}
  providers = {
    aws = aws
    azuredevops = azuredevops
  }
}

