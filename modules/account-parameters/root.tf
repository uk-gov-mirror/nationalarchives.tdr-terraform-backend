resource "aws_ssm_parameter" "cost_centre" {
  name  = "/mgmt/cost_centre"
  type  = "String"
  value = var.cost_centre

  tags = var.common_tags
}
