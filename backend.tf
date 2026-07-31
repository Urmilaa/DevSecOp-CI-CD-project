terraform {

  backend "s3" {

    bucket = "devsecops-ci-cd-terraform-state-bucket"

    key = "eks/terraform.tfstate"

    region = "us-east-1"

    use_lockfile = true

    encrypt = true

  }

}
