resource "aws_s3_bucket" "tdr_terraform_state" {
  bucket = "tdr-terraform-state"

  tags = merge(
    local.common_tags,
    tomap(
      { "Name" = "TDR Terraform State" }
    )
  )
}

resource "aws_s3_bucket_acl" "tdr_terraform_state_acl" {
  bucket = aws_s3_bucket.tdr_terraform_state.id
  acl    = "private"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tdr_terraform_state_encryption" {
  bucket = aws_s3_bucket.tdr_terraform_state.id

  rule {
    bucket_key_enabled = true

    apply_server_side_encryption_by_default {
      kms_master_key_id = var.terraform_state_bucket_kms_key_arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_versioning" "tdr_terraform_state_versioning" {
  bucket = aws_s3_bucket.tdr_terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket = aws_s3_bucket.tdr_terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket" "tdr_terraform_state_grafana" {
  bucket = "tdr-terraform-state-grafana"

  tags = merge(
    local.common_tags,
    tomap(
      { "Name" = "TDR Grafana Terraform State" }
    )
  )
}

resource "aws_s3_bucket_acl" "tdr_terraform_state_grafana_acl" {
  bucket = aws_s3_bucket.tdr_terraform_state_grafana.id
  acl    = "private"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tdr_terraform_state_grafana_encryption" {
  bucket = aws_s3_bucket.tdr_terraform_state_grafana.id

  rule {
    bucket_key_enabled = true

    apply_server_side_encryption_by_default {
      kms_master_key_id = var.terraform_state_bucket_kms_key_arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_versioning" "tdr_terraform_state_grafana_versioning" {
  bucket = aws_s3_bucket.tdr_terraform_state_grafana.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "public_access_block_grafana" {
  bucket = aws_s3_bucket.tdr_terraform_state_grafana.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


resource "aws_s3_bucket" "tdr_terraform_state_scripts" {
  bucket = "tdr-terraform-state-scripts"

  tags = merge(
    local.common_tags,
    tomap(
      { "Name" = "TDR Scripts Terraform State" }
    )
  )
}

resource "aws_s3_bucket_acl" "tdr_terraform_state_scripts_acl" {
  bucket = aws_s3_bucket.tdr_terraform_state_scripts.id
  acl    = "private"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tdr_terraform_state_scripts_encryption" {
  bucket = aws_s3_bucket.tdr_terraform_state_scripts.id

  rule {
    bucket_key_enabled = true

    apply_server_side_encryption_by_default {
      kms_master_key_id = var.terraform_state_bucket_kms_key_arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_versioning" "tdr_terraform_state_scripts_versioning" {
  bucket = aws_s3_bucket.tdr_terraform_state_scripts.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "public_access_block_scripts" {
  bucket = aws_s3_bucket.tdr_terraform_state_scripts.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket" "tdr_terraform_state_github" {
  bucket = "tdr-terraform-state-github"

  tags = merge(
    local.common_tags,
    tomap(
      { "Name" = "TDR Github Terraform State" }
    )
  )
}

resource "aws_s3_bucket_acl" "tdr_terraform_state_github_acl" {
  bucket = aws_s3_bucket.tdr_terraform_state_github.id
  acl    = "private"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tdr_terraform_state_github_encryption" {
  bucket = aws_s3_bucket.tdr_terraform_state_github.id

  rule {
    bucket_key_enabled = true

    apply_server_side_encryption_by_default {
      kms_master_key_id = var.terraform_state_bucket_kms_key_arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_versioning" "tdr_terraform_state_github_versioning" {
  bucket = aws_s3_bucket.tdr_terraform_state_github.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "public_access_block_github" {
  bucket = aws_s3_bucket.tdr_terraform_state_github.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "terraform_state_bucket_policy" {
  for_each = { for idx, bucket in local.state_buckets : idx => bucket }

  bucket = each.value.id
  policy = templatefile("${path.module}/templates/terraform_state_bucket_policy.json.tpl",
    {
      bucket_name       = each.value.id,
      aws_back_role_arn = var.aws_backup_role_arn
  })
}
