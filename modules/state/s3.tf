resource "aws_s3_bucket" "tdr_terraform_state" {
  bucket = "tdr-terraform-state"
  acl    = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  versioning {
    enabled = true
  }

  tags = merge(
    var.common_tags,
    tomap(
      { "Name" = "TDR Terraform State" }
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

resource "aws_s3_bucket" "tdr_terraform_state_grafana" {
  bucket = "tdr-terraform-state-grafana"
  acl    = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  versioning {
    enabled = true
  }

  tags = merge(
    var.common_tags,
    tomap(
      { "Name" = "TDR Grafana Terraform State" }
    )
  )
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
  acl    = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  versioning {
    enabled = true
  }

  tags = merge(
    var.common_tags,
    tomap(
      { "Name" = "TDR Scripts Terraform State" }
    )
  )
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

  acl = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  versioning {
    enabled = true
  }

  tags = merge(
    var.common_tags,
    tomap(
      { "Name" = "TDR Github Terraform State" }
    )
  )
}

resource "aws_s3_bucket_public_access_block" "public_access_block_github" {
  bucket = aws_s3_bucket.tdr_terraform_state_github.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
