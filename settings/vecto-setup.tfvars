# VECTO Setup settings, shared by all environments.
# Placeholders in names: {env} = environment key (e.g. prod), {Env} = environments[<key>].name (e.g. Prod)
# Each environment run (its own state) owns its AWS side, its <ENV>_ variables in the VECTO variable group and environments/<env>/ files;
# the primary_environment run additionally owns the VECTO repository, pipeline and files outside environments/.
# Keep the environment keys in sync with the values of the run parameter environment in azure-pipelines.yml.

# VECTO module version: source of the Setup module and module ref of the bootstrapped VECTO code
vecto_version = "3.0.0"

vecto_setup_settings = {
  # promotion path, in order; handed down to VECTO (settings/environments.tfvars), approvals per tier are defined in VECTO
  # state_bucket_name: Setup and VECTO state bucket of the environment, read by the pipeline before terraform init
  environments = {
    dev  = { order = 10, name = "Dev", display_name = "Dev", tier = "nonprod", state_bucket_name = "vecto-setup-tf-state-<DEV_VECTO_ACCOUNT_ID>" }
    test = { order = 20, name = "Test", display_name = "Test", tier = "preprod", state_bucket_name = "vecto-setup-tf-state-<TEST_VECTO_ACCOUNT_ID>" }
    prod = { order = 30, name = "Prod", display_name = "Prod", tier = "prod", state_bucket_name = "vecto-setup-tf-state-<PROD_VECTO_ACCOUNT_ID>" }
  }

  # also owns the VECTO repository, pipeline and files outside environments/; run it first
  primary_environment = "prod"

  aws_settings = {
    oidc_provider_deployed = false   # true if an OIDC provider for Azure DevOps already exists (parallel VECTO installation)
    state_file_prefix      = ""      # optional {segregation_id} for parallel VECTO installations
    vecto_state_name       = "vecto" # VECTO state keys <state_file_prefix><vecto_state_name>-aws-side.tfstate / -ado-side.tfstate
    target_region          = "eu-central-1"
    resource_prefix        = "" # optional {segregation_id} for parallel VECTO installations
  }

  ado_settings = {
    agent_pool_name            = "Azure Pipelines"
    oidc_service_endpoint_name = "acai-vecto-oidc-connection-to-aws-lz-{env}"
    vecto_pipeline_repo = {
      repo_name           = "AWS-LZ-VECTO"
      release_branch_name = "main"
    }
    vecto_pipeline = {
      path          = "/AWS-LZ-VECTO"
      pipeline_name = "AWS-LZ-VECTO"
      # PATs (manual) and per environment <ENV>_VECTO_PROVISIONER_ROLE_ARN / <ENV>_AWS_CICD_PROVISIONING_ROLE_EXTERNAL_ID
      variable_group_name = "VECTO_ACCESS_TOKEN"
    }
  }

  # where the VECTO Terraform module is hosted; replace in case you host VECTO in your own repository
  vecto_repo_settings = {
    git_url   = "github.com/acai-solutions/"
    repo_name = "terraform-aws-acai-vecto.git"
  }
}
