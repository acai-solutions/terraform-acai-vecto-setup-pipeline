terraform {
  backend "s3" {
    key      = "acai-vecto-setup.tfstate"
    encrypt  = true
  }
}
