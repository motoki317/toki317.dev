# GitHub Actions OIDC federation for the CI roles (gmo-media/tofu-actions `aws-oidc` mode).
# Created once by a local admin apply — CI cannot assume these roles until they exist.

resource "aws_iam_openid_connect_provider" "github_actions" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
  # No thumbprint_list: AWS validates the GitHub OIDC IdP via its own CA store.
}

# Plan role: any branch, read-only.
resource "aws_iam_role" "tofu_plan" {
  name               = "tofu-plan"
  assume_role_policy = data.aws_iam_policy_document.tofu_plan_trust.json
}

data "aws_iam_policy_document" "tofu_plan_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github_actions.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${local.repository}:*"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "tofu_plan_readonly" {
  role       = aws_iam_role.tofu_plan.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

# `terraform plan` acquires the state lock (the tofu-actions plan step runs with
# -lock-timeout, not -lock=false), so this read-only role also needs write access
# to the S3 lock object. Without it, every CI plan fails with AccessDenied.
resource "aws_iam_role_policy" "tofu_plan_lock" {
  name = "tfstate-lock"
  role = aws_iam_role.tofu_plan.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["s3:PutObject", "s3:DeleteObject"]
      Resource = "arn:aws:s3:::${local.tfstate_bucket}/${local.tfstate_key}.tflock"
    }]
  })
}

# Apply role: main branch only.
resource "aws_iam_role" "tofu_apply" {
  name               = "tofu-apply"
  assume_role_policy = data.aws_iam_policy_document.tofu_apply_trust.json
}

data "aws_iam_policy_document" "tofu_apply_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github_actions.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${local.repository}:ref:refs/heads/${local.main_branch}"]
    }
  }
}

# PowerUserAccess covers everything except IAM; IAMFullAccess is added because
# this repo manages IAM users (e.g. the per-app S3 users for the k8s migration).
resource "aws_iam_role_policy_attachment" "tofu_apply_poweruser" {
  role       = aws_iam_role.tofu_apply.name
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}

resource "aws_iam_role_policy_attachment" "tofu_apply_iam" {
  role       = aws_iam_role.tofu_apply.name
  policy_arn = "arn:aws:iam::aws:policy/IAMFullAccess"
}

# ARNs to paste into .github/tofu-actions-config.js after the bootstrap apply.
output "tofu_plan_role_arn" {
  value = aws_iam_role.tofu_plan.arn
}

output "tofu_apply_role_arn" {
  value = aws_iam_role.tofu_apply.arn
}
