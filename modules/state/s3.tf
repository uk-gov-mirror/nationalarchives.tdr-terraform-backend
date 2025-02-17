resource "aws_s3_bucket" "tdr_terraform_state" {
  bucket = "tdr-terraform-state"

  tags = merge(
    var.common_tags,
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
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
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

resource "aws_s3_bucket" "tdr_terraform_state_jenkins" {
  bucket = "tdr-terraform-state-jenkins"

  tags = merge(
    var.common_tags,
    tomap(
      { "Name" = "TDR Jekins Terraform State" }
    )
  )
}

resource "aws_s3_bucket_acl" "tdr_terraform_state_jenkins_acl" {
  bucket = aws_s3_bucket.tdr_terraform_state_jenkins.id
  acl    = "private"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tdr_terraform_state_jenkins_encryption" {
  bucket = aws_s3_bucket.tdr_terraform_state_jenkins.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "tdr_terraform_state_jenkins_versioning" {
  bucket = aws_s3_bucket.tdr_terraform_state_jenkins.id

  versioning_configuration {
    status = "Enabled"
  }
}


resource "aws_s3_bucket_public_access_block" "public_access_block_jenkins" {
  bucket = aws_s3_bucket.tdr_terraform_state_jenkins.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket" "tdr_terraform_state_grafana" {
  bucket = "tdr-terraform-state-grafana"

  tags = merge(
    var.common_tags,
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
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
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
    var.common_tags,
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
    var.common_tags,
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
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
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
