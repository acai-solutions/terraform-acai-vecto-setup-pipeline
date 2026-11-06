# ACAI Solutions
# Copyright (c) 2026 ACAI GmbH
#
# This file is part of ACAI VECTO. Visit https://www.acai.gmbh or https://docs.acai.gmbh for more information.
# 
# Proprietary and Confidential - Licensed under ACAI Rahmen-Lizenzvertrag + Order Form (Subscription required)
# For full license text, see LICENSE file in repository root.
#
# For commercial licensing, contact: contact@acai.gmbh

# Migration of the per-environment setup states (module vecto_setup, 10-setup/ado-oidc) to the environment setup.
# AWS side and OIDC access keep their resources. The old ADO side (repository, environment branches, per-environment
# pipelines, bootstrap files) leaves the state without being destroyed: the repository is adopted by the primary
# environment's run, the per-environment pipelines are deleted manually after the cutover.
# No-ops in new environments; remove after all environment states are migrated.

moved {
  from = module.vecto_setup.module.setup_oidc
  to   = module.vecto_environment.module.oidc
}

moved {
  from = module.vecto_setup.module.setup_aws_side
  to   = module.vecto_environment.module.aws_side
}

removed {
  from = module.vecto_setup.module.setup_ado_side

  lifecycle {
    destroy = false
  }
}
