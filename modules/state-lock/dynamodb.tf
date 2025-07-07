resource "aws_dynamodb_table" "terraform_state_lock" {
  name           = "tdr-terraform-state-lock"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = merge(
    var.common_tags,
    tomap(
      { "Name" = "TDR Terraform State Lock Table" }
    )
  )
}

resource "aws_dynamodb_table" "terraform_state_lock_scripts" {
  name           = "tdr-terraform-state-lock-scripts"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = merge(
    var.common_tags,
    tomap(
      { "Name" = "TDR Scripts Terraform State Lock Table" }
    )
  )
}
