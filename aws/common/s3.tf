##########################################
# Frontend S3 Bucket
##########################################

resource "aws_s3_bucket" "frontend_s3_bucket" {
  bucket  = "${var.project}-${terraform.workspace}-frontend-${var.location}-${var.account_id}"
  tags    = {
  project        = var.project
  environment    = "${terraform.workspace}"
  }
}
resource "aws_s3_bucket_public_access_block" "frontend_public_access" {
  bucket = aws_s3_bucket.frontend_s3_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_versioning" "frontend_versioning" {
  bucket = aws_s3_bucket.frontend_s3_bucket.id
  versioning_configuration {
    status = var.bucket_versioning
  }
}

resource "aws_s3_bucket_ownership_controls" "frontend_bucket_ownership" {
  bucket = aws_s3_bucket.frontend_s3_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "frontend_bucket_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.frontend_bucket_ownership]

  bucket = aws_s3_bucket.frontend_s3_bucket.id
  acl    = var.bucket_acl 
}

resource "aws_s3_bucket_website_configuration" "frontend_website_configuration" {
  bucket = aws_s3_bucket.frontend_s3_bucket.id
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "error.html"
  }
}

##########################################
# Artifacts S3 Bucket
##########################################

resource "aws_s3_bucket" "artifacts_s3_bucket" {
  bucket  = "${var.project}-${terraform.workspace}-artifacts-${var.location}-${var.account_id}"
  tags    = {
  project        = var.project
  environment    = "${terraform.workspace}"
  }
}
resource "aws_s3_bucket_public_access_block" "artifacts_public_access" {
  bucket = aws_s3_bucket.artifacts_s3_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_versioning" "artifacts_versioning" {
  bucket = aws_s3_bucket.artifacts_s3_bucket.id
  versioning_configuration {
    status = var.bucket_versioning
  }
}

resource "aws_s3_bucket_ownership_controls" "artifacts_bucket_ownership" {
  bucket = aws_s3_bucket.artifacts_s3_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "artifacts_bucket_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.artifacts_bucket_ownership]

  bucket = aws_s3_bucket.artifacts_s3_bucket.id
  acl    = var.bucket_acl 
}

resource "aws_s3_bucket_website_configuration" "artifacts_website_configuration" {
  bucket = aws_s3_bucket.artifacts_s3_bucket.id
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "error.html"
  }
}