terraform {
  backend "s3" {
    bucket = "terraform-state-ecs"
    key    = "prod/terraform.tfstate"
    region = "us-east-1"
  }
}