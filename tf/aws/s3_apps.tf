# S3 buckets and per-app IAM users for the OCI → AWS storage migration.
# Each app runs on self-hosted k8s (not AWS), so it authenticates with a static
# access key created here and copied into the app's SOPS-encrypted secret.

locals {
  # Bucket names are globally unique; keep the `toki317-` prefix the state bucket uses.
  app_buckets = {
    neoshowcase = "toki317-neoshowcase"
  }
}

resource "aws_s3_bucket" "app" {
  for_each = local.app_buckets
  bucket   = each.value
}

# Private data (build artifacts, registry blobs) — never expose publicly.
resource "aws_s3_bucket_public_access_block" "app" {
  for_each = aws_s3_bucket.app
  bucket   = each.value.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_iam_user" "app" {
  for_each = local.app_buckets
  name     = "s3-${each.key}"
}

# Scoped to the app's own bucket. Multipart actions are required by the S3 storage
# drivers (NeoShowcase transfermanager, Harbor registry) for large objects.
resource "aws_iam_user_policy" "app" {
  for_each = local.app_buckets
  name     = "s3-access"
  user     = aws_iam_user.app[each.key].name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:ListBucket", "s3:GetBucketLocation", "s3:ListBucketMultipartUploads"]
        Resource = aws_s3_bucket.app[each.key].arn
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:AbortMultipartUpload",
          "s3:ListMultipartUploadParts",
        ]
        Resource = "${aws_s3_bucket.app[each.key].arn}/*"
      },
    ]
  })
}

resource "aws_iam_access_key" "app" {
  for_each = local.app_buckets
  user     = aws_iam_user.app[each.key].name
}

output "app_s3_access_key_ids" {
  value = { for k, v in aws_iam_access_key.app : k => v.id }
}

# `terraform output -json app_s3_secret_access_keys` to copy into each app's SOPS secret.
output "app_s3_secret_access_keys" {
  value     = { for k, v in aws_iam_access_key.app : k => v.secret }
  sensitive = true
}
