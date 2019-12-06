variable "workspace_to_environment_map" {
  type = map(string)

  //Maps the Terraform workspace to the AWS environment.
  default = {
    intg   = "intg"
    staging = "staging"
    prod = "prod"
  }
}

//variable "workspace_environment_account_map" {
//  type = map(string)
//
//  //Maps the Terraform workspace to the AWS environment account number.
//  default = {
//    ci   = "229554778675"
//    test = "846822818902"
//    prod = "846822818902"
//  }
//}

variable "workspace_aws_profile_map" {
  type = map(string)

  default = {
    intg   = "intgaccess"
    staging = "prodaccess"
    prod = "prodaccess"
  }
}