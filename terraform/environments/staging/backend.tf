terraform {
  backend "s3" {
    bucket       = "my-terraform-state-bucket-mb"
    key          = "staging/terraform.tfstate"
    region       = "ap-south-1"
    use_lockfile = true
    encrypt      = true
  }
}