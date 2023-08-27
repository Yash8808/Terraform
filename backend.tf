terraform {
  backend "s3" {
    bucket         = "sosuke-terraform-state"
    key            = "assesment"
    region         = "eu-west-2"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
