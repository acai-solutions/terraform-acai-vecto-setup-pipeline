# ACAI Solutions
# Copyright (c) 2026 ACAI GmbH
#
# This file is part of ACAI VECTO. Visit https://www.acai.gmbh or https://docs.acai.gmbh for more information.
# 
# Proprietary and Confidential - Licensed under ACAI Rahmen-Lizenzvertrag + Order Form (Subscription required)
# For full license text, see LICENSE file in repository root.
#
# For commercial licensing, contact: contact@acai.gmbh


# ---------------------------------------------------------------------------------------------------------------------
# ¦ REQUIREMENTS
# ---------------------------------------------------------------------------------------------------------------------
terraform {
  required_version = "= 1.16.6"

  required_providers {
    aws = {
      source                = "hashicorp/aws"
      configuration_aliases = []
    }
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = ">= 1.14.0"
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ LOCALS
# ---------------------------------------------------------------------------------------------------------------------
# Build the Azure DevOps organization service URL from the organization name
locals {
  ado_org_service_url = "https://dev.azure.com/${var.ado_organization.organization_name}/"
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ SETUP SETTINGS OF THIS RUN
# ---------------------------------------------------------------------------------------------------------------------
locals {
  environment = var.environment
  is_primary  = var.environment == var.vecto_setup_settings.primary_environment
  ado         = var.vecto_setup_settings.ado_settings

  environments = {
    for key, env in var.vecto_setup_settings.environments : key => {
      order                      = env.order
      name                       = env.name
      display_name               = coalesce(env.display_name, env.name)
      tier                       = env.tier
      oidc_service_endpoint_name = replace(replace(local.ado.oidc_service_endpoint_name, "{env}", key), "{Env}", env.name)
    }
  }

  vecto_pipeline_repo = {
    repo_name             = local.ado.vecto_pipeline_repo.repo_name
    main_branch_name      = local.ado.vecto_pipeline_repo.release_branch_name
    bootstrap_branch_name = "${local.ado.vecto_pipeline_repo.release_branch_name}-bootstrap"
  }
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
# ¦ VECTO SETUP - SHARED (primary environment only)
# ---------------------------------------------------------------------------------------------------------------------
# replace the source URLs in case you host VECTO in your own repository
module "vecto_shared" {
  count  = local.is_primary ? 1 : 0
  source = "git::https://github.com/acai-solutions/terraform-aws-acai-vecto.git//10-setup/multi-env/shared?ref=${var.vecto_version}"

  environments = local.environments
  aws_settings = {
    target_region = var.vecto_setup_settings.aws_settings.target_region
  }
  ado_settings = {
    organization_name          = var.ado_organization.organization_name
    project_name               = var.ado_organization.project_name
    agent_pool_name            = local.ado.agent_pool_name
    oidc_service_endpoint_name = local.ado.oidc_service_endpoint_name
    vecto_pipeline_repo        = local.vecto_pipeline_repo
    vecto_pipeline             = local.ado.vecto_pipeline
  }
  vecto_repo_settings = merge(var.vecto_setup_settings.vecto_repo_settings, {
    repo_branch = var.vecto_version
  })

  providers = {
    azuredevops = azuredevops
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ VECTO SETUP - ENVIRONMENT
# ---------------------------------------------------------------------------------------------------------------------
module "vecto_environment" {
  source = "git::https://github.com/acai-solutions/terraform-aws-acai-vecto.git//10-setup/multi-env/environment?ref=${var.vecto_version}"

  environment = local.environment
  aws_settings = merge(var.vecto_setup_settings.aws_settings, {
    state_bucket_name = var.vecto_setup_settings.environments[local.environment].state_bucket_name
  })
  ado_settings = {
    organization_id            = var.ado_organization.organization_id
    organization_name          = var.ado_organization.organization_name
    project_name               = var.ado_organization.project_name
    agent_pool_name            = local.ado.agent_pool_name
    oidc_service_endpoint_name = local.environments[local.environment].oidc_service_endpoint_name
    variable_group_name        = local.ado.vecto_pipeline.variable_group_name
    vecto_pipeline_repo        = local.vecto_pipeline_repo
    vecto_pipeline             = local.ado.vecto_pipeline
  }
  # primary run: repository and pipeline are created in this run, other environments look them up by name
  shared_resources = one(module.vecto_shared[*].vecto_pipeline)

  resource_tags = {}
  providers = {
    aws         = aws
    azuredevops = azuredevops
  }
}

