# ACAI Solutions
# Copyright (c) 2026 ACAI GmbH
#
# This file is part of ACAI VECTO. Visit https://www.acai.gmbh or https://docs.acai.gmbh for more information.
# 
# Proprietary and Confidential - Licensed under ACAI Rahmen-Lizenzvertrag + Order Form (Subscription required)
# For full license text, see LICENSE file in repository root.
#
# For commercial licensing, contact: contact@acai.gmbh


variable "vecto_version" {
  description = "VECTO module version (git ref). const: used in the module source, pass it to terraform init too."
  type        = string
  const       = true
}

variable "vecto_setup_settings" {
  description = "VECTO Setup settings shared by all environments (settings/vecto-setup.tfvars), {env}/{Env} are replaced per environment"
  type = object({
    environments = map(object({
      order             = number
      name              = string           # {Env}
      display_name      = optional(string) # pipeline stage names, default: name
      tier              = string           # nonprod | preprod | prod, VECTO maps it to an approval class
      state_bucket_name = string           # setup and VECTO state bucket of the environment
    }))
    primary_environment = string # its setup run and state also own the VECTO repository and pipeline
    aws_settings = object({
      oidc_provider_deployed = optional(bool, false)
      state_file_prefix      = optional(string, "")
      vecto_state_name       = optional(string, "vecto") # VECTO state keys <state_file_prefix><vecto_state_name>-aws-side.tfstate / -ado-side.tfstate
      target_region          = string
      resource_prefix        = optional(string, "")
    })
    ado_settings = object({
      agent_pool_name            = string
      oidc_service_endpoint_name = optional(string, "vecto-oidc-connection-to-aws")
      vecto_pipeline_repo = object({
        repo_name           = optional(string, "pipeline--vecto")
        release_branch_name = optional(string, "main") # single branch of the VECTO repository, bootstrap branch: <name>-bootstrap
      })
      vecto_pipeline = object({
        path                             = optional(string, "\\")
        pipeline_name                    = optional(string, "pipeline--vecto")
        variable_group_name              = optional(string, "VECTO_ACCESS_TOKEN")
        variable_name_ado_management_pat = optional(string, "PAT-VECTO_ADO_MANAGEMENT_ACCESS")
        variable_name_vecto_repo_pat     = optional(string, "PAT-VECTO_REPO_ACCESS")
      })
    })
    vecto_repo_settings = object({
      git_url   = optional(string, "github.com/acai-solutions/")
      repo_name = optional(string, "terraform-aws-acai-vecto.git")
    })
  })

  validation {
    condition     = length(distinct([for env in values(var.vecto_setup_settings.environments) : env.order])) == length(var.vecto_setup_settings.environments)
    error_message = "environments[*].order must be unique."
  }

  validation {
    condition     = contains(keys(var.vecto_setup_settings.environments), var.vecto_setup_settings.primary_environment)
    error_message = "primary_environment must be a key of environments."
  }

  validation {
    condition     = alltrue([for env in values(var.vecto_setup_settings.environments) : contains(["nonprod", "preprod", "prod"], env.tier)])
    error_message = "environments[*].tier must be one of: nonprod, preprod, prod."
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ PROVIDED BY THE PIPELINE
# ---------------------------------------------------------------------------------------------------------------------
variable "environment" {
  description = "Key of vecto_setup_settings.environments of this run; the primary environment also owns the VECTO repository and pipeline."
  type        = string

  validation {
    condition     = contains(keys(var.vecto_setup_settings.environments), var.environment)
    error_message = "environment must be a key of vecto_setup_settings.environments."
  }
}

variable "ado_organization" {
  description = "Azure DevOps organization and project of the pipeline run."
  type = object({
    organization_id   = string
    organization_name = string
    project_name      = string
  })
}
