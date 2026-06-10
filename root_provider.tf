// Because this is a bootstrap stack, local role config is used
provider "aws" {
  region  = "eu-west-2"
  profile = "tdr_admin_management"
}

provider "aws" {
  alias   = "dev"
  region  = "eu-west-2"
  profile = "tdr_admin_development"
}

provider "aws" {
  alias   = "intg"
  region  = "eu-west-2"
  profile = "tdr_admin_integration"
}

provider "aws" {
  alias   = "staging"
  region  = "eu-west-2"
  profile = "tdr_admin_staging"

}

provider "aws" {
  alias   = "prod"
  region  = "eu-west-2"
  profile = "tdr_admin_production"
}
