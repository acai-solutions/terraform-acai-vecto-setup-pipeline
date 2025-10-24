output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "vecto_setup" {
  value = module.vecto_setup
}

output "vecto_setup_settings" {
  value = var.vecto_setup_settings
}
