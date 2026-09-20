terraform {
  backend "s3" {
    bucket       = "tfstate-597936860210-eu-north-1-an"
    key          = "aca-voting-app/terraform.tfstate"
    region       = "eu-north-1"
    encrypt      = true
    use_lockfile = true
  }
}
