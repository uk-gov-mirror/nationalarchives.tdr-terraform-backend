// Because this is a bootstrap stack, local role config is used
provider "aws" {
  region  = "eu-west-2"
  profile = "<Profile configured for account in management>"
}

provider "aws" {
  alias   = "dev"
  region  = "eu-west-2"
  profile = "<Profile configured for account in dev>"
}

provider "aws" {
  alias   = "intg"
  region  = "eu-west-2"
  profile = "<Profile configured for account in intg>"
}

provider "aws" {
  alias   = "staging"
  region  = "eu-west-2"
  profile = "<Profile configured for account in staging>"

}

provider "aws" {
  alias   = "prod"
  region  = "eu-west-2"
  profile = "<Profile configured for account in prod>"
}
