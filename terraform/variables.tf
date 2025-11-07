# ACAI Solutions
# Copyright (C) 2025 ACAI GmbH
#
# This file is part of ACAI VECTO. Visit https://www.acai.gmbh or https://docs.acai.gmbh for more information.
# 
# Proprietary and Confidential - Licensed under ACAI Rahmen-Lizenzvertrag + Order Form (Subscription required)
# For full license text, see LICENSE file in repository root.
#
# For commercial licensing, contact: contact@acai.gmbh


variable "vecto_setup_settings" {
  description = "Info to setup the VECTO CI/CD resources."
  type = object({
    aws_settings = object({
      oidc_provider_deployed = bool
      state_bucket_name      = string
      target_region          = string
      resource_prefix        = optional(string, "")
    })
    ado_settings = object({
      organization_id            = string
      organization_name          = string
      project_name               = string
      agent_pool_name            = string
      oidc_service_endpoint_name = optional(string, "acai-vecto-oidc-connection-to-aws")
      vecto_pipeline_repo = object({
        repo_name           = optional(string, "pipeline--vecto") # Name of existing or new ADO Repo
        release_branch_name = optional(string, "main")            # for an existing repo, this must be a new branch name
      })
      vecto_pipeline = object({
        pipeline_name       = optional(string, "pipeline--vecto")
        variable_group_name = optional(string, "VECTO_ACCESS_TOKEN")
      })
    })
    vecto_repo_settings = object({
      git_url     = optional(string, "github.com/acai-solutions/")
      repo_name   = optional(string, "terraform-aws-acai-vecto.git")
      repo_branch = optional(string, "main")
    })
  })
}
