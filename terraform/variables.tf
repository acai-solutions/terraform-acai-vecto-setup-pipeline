variable "vecto_setup_settings" {
  description = "Info to setup the VECTO CI/CD resources."
  type = object({
    aws_settings = object({
      state_bucket_name = string
      target_region     = string
      resource_prefix   = optional(string, "")
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
