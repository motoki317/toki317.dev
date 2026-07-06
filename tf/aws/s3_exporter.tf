# IAM user for the Prometheus s3_exporter (monitor/s3-exporter). It hits /discovery
# (ListAllMyBuckets) then probes each bucket's object listing for metrics — read-only
# metadata across all buckets, no object access. Separate from the per-app users, which
# are scoped to one bucket with object read/write.

resource "aws_iam_user" "s3_exporter" {
  name = "s3-exporter"
}

resource "aws_iam_user_policy" "s3_exporter" {
  name = "s3-metrics-readonly"
  user = aws_iam_user.s3_exporter.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "s3:ListAllMyBuckets"
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = ["s3:ListBucket", "s3:GetBucketLocation"]
        Resource = "arn:aws:s3:::*"
      },
    ]
  })
}
