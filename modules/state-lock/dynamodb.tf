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

resource "aws_dynamodb_table" "terraform_state_lock_jenkins" {
  name           = "tdr-terraform-state-lock-jenkins"
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
      { "Name" = "TDR Jenkins Terraform State Lock Table" }
    )
  )
}

resource "aws_dynamodb_table" "terraform_state_lock_grafana" {
  name           = "tdr-terraform-state-lock-grafana"
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
      { "Name" = "TDR Grafana Terraform State Lock Table" }
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

resource "aws_dynamodb_table" "terraform_github_state_lock" {
  name           = "tdr-terraform-github-state-lock"
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
      { "Name" = "TDR Terraform Github State Lock Table" }
    )
  )
}
