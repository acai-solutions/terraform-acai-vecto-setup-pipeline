# ACAI Solutions
# Copyright (c) 2026 ACAI GmbH
#
# This file is part of ACAI VECTO. Visit https://www.acai.gmbh or https://docs.acai.gmbh for more information.
# 
# Proprietary and Confidential - Licensed under ACAI Rahmen-Lizenzvertrag + Order Form (Subscription required)
# For full license text, see LICENSE file in repository root.
#
# For commercial licensing, contact: contact@acai.gmbh


terraform {
  backend "s3" {
    # set at init from ../settings/vecto-setup.tfvars (variables are not allowed here): bucket (state_bucket_name of the
    # environment), region and key (<state_file_prefix>acai-vecto-setup.tfstate)
    encrypt = true
  }
}
