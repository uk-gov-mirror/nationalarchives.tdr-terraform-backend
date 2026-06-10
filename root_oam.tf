# TDRD-1323/1542 OAM (Share CW Logs and Metrics with a monitoring account x-region)
module "oam_sink" {
  source                 = "./da-terraform-modules/oam_sink"
  source_oam_account_ids = [data.aws_ssm_parameter.dev_account_number.value, data.aws_ssm_parameter.intg_account_number.value, data.aws_ssm_parameter.staging_account_number.value, data.aws_ssm_parameter.prod_account_number.value]
  region                 = "eu-west-2"
}

module "oam_sink_us_east_1" {
  source                 = "./da-terraform-modules/oam_sink"
  source_oam_account_ids = [data.aws_ssm_parameter.dev_account_number.value, data.aws_ssm_parameter.intg_account_number.value, data.aws_ssm_parameter.staging_account_number.value, data.aws_ssm_parameter.prod_account_number.value]
  region                 = "us-east-1"
}

module "oam_sources_dev" {
  source              = "./da-terraform-modules/oam_sources"
  aws_oam_sink_arn    = module.oam_sink.aws_oam_sink.arn
  aws_account_id_sink = data.aws_ssm_parameter.mgmt_account_number.value
  region              = "eu-west-2"
  providers = {
    aws = aws.dev
  }
}

module "oam_sources_dev_us_east_1" {
  source                        = "./da-terraform-modules/oam_sources"
  aws_oam_sink_arn              = module.oam_sink_us_east_1.aws_oam_sink.arn
  aws_account_id_sink           = data.aws_ssm_parameter.mgmt_account_number.value
  service_role_managed_policies = []
  region                        = "us-east-1"
  providers = {
    aws = aws.dev
  }
}

module "oam_sources_intg" {
  source              = "./da-terraform-modules/oam_sources"
  aws_oam_sink_arn    = module.oam_sink.aws_oam_sink.arn
  aws_account_id_sink = data.aws_ssm_parameter.mgmt_account_number.value
  region              = "eu-west-2"
  providers = {
    aws = aws.intg
  }
}

module "oam_sources_intg_us_east_1" {
  source                        = "./da-terraform-modules/oam_sources"
  aws_oam_sink_arn              = module.oam_sink_us_east_1.aws_oam_sink.arn
  aws_account_id_sink           = data.aws_ssm_parameter.mgmt_account_number.value
  service_role_managed_policies = []
  region                        = "us-east-1"
  providers = {
    aws = aws.intg
  }
}

module "oam_sources_staging" {
  source              = "./da-terraform-modules/oam_sources"
  aws_oam_sink_arn    = module.oam_sink.aws_oam_sink.arn
  aws_account_id_sink = data.aws_ssm_parameter.mgmt_account_number.value
  region              = "eu-west-2"
  providers = {
    aws = aws.staging
  }
}

module "oam_sources_staging_us_east_1" {
  source                        = "./da-terraform-modules/oam_sources"
  aws_oam_sink_arn              = module.oam_sink_us_east_1.aws_oam_sink.arn
  aws_account_id_sink           = data.aws_ssm_parameter.mgmt_account_number.value
  service_role_managed_policies = []
  region                        = "us-east-1"
  providers = {
    aws = aws.staging
  }
}

module "oam_sources_prod" {
  source              = "./da-terraform-modules/oam_sources"
  aws_oam_sink_arn    = module.oam_sink.aws_oam_sink.arn
  aws_account_id_sink = data.aws_ssm_parameter.mgmt_account_number.value
  region              = "eu-west-2"
  providers = {
    aws = aws.prod
  }
}

module "oam_sources_prod_us_east_1" {
  source                        = "./da-terraform-modules/oam_sources"
  aws_oam_sink_arn              = module.oam_sink_us_east_1.aws_oam_sink.arn
  aws_account_id_sink           = data.aws_ssm_parameter.mgmt_account_number.value
  service_role_managed_policies = []
  region                        = "us-east-1"
  providers = {
    aws = aws.prod
  }
}
