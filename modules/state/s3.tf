resource "aws_s3_bucket" "tdr_terraform_state" {
  bucket = "tdr-terraform-state"
  acl    = "private"

  tags = merge(
    var.common_tags,
    map(
      "Name", "TDR Terraform State",
    )
  )
}

resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket = aws_s3_bucket.tdr_terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket" "tdr_terraform_state_jenkins" {
  bucket = "tdr-terraform-state-jenkins"
  acl    = "private"

  tags = merge(
    var.common_tags,
    map(
      "Name", "TDR Jekins Terraform State",
    )
  )
}

resource "aws_s3_bucket_public_access_block" "public_access_block_jenkins" {
  bucket = aws_s3_bucket.tdr_terraform_state_jenkins.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


resource "aws_s3_bucket" "tdr_database_migrations" {
  bucket = "tdr-database-migrations"
  acl    = "private"
  policy = file("${path.module}/policy.json.tpl")
  tags = merge(
  var.common_tags,
  map(
  "Name", "TDR Jekins Terraform State",
  )
  )
}