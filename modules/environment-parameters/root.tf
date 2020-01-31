resource "aws_ssm_parameter" "cost_centre" {
  name  = "/${var.tdr_environment}/cost_centre"
  type  = "String"
  value = var.cost_centre

  tags = var.common_tags
}
