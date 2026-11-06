# ACAI Solutions
# Copyright (c) 2026 ACAI GmbH
#
# This file is part of ACAI VECTO. Visit https://www.acai.gmbh or https://docs.acai.gmbh for more information.
# 
# Proprietary and Confidential - Licensed under ACAI Rahmen-Lizenzvertrag + Order Form (Subscription required)
# For full license text, see LICENSE file in repository root.
#
# For commercial licensing, contact: contact@acai.gmbh


output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "vecto_setup_shared" {
  value = one(module.vecto_shared)
}

output "vecto_setup_environment" {
  value = module.vecto_environment
}

output "vecto_setup_settings" {
  value = var.vecto_setup_settings
}
