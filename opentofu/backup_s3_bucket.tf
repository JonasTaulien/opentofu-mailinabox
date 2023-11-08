resource "aws_s3_bucket" "backup_bucket" {
  bucket = "miab-backups"
  // DO NOT ACTIVATE IF ACTUAL BACKUPS WILL BE PRESENT ON THE BUCKET
  // force_destroy = true
}

resource "aws_iam_user" "backup_user" {
  name = "mail-in-a-box"
}

resource "aws_iam_access_key" "backup_user_access_key" {
  user = aws_iam_user.backup_user.name
}

// See : https://docs.aws.amazon.com/AmazonS3/latest/userguide/example-policies-s3.html#iam-policy-ex0
data "aws_iam_policy_document" "backup_user_policy" {
  statement {
    effect    = "Allow"
    actions   = [
      "s3:ListAllMyBuckets"
    ]
    resources = ["*"]
  }

  statement {
    effect    = "Allow"
    actions   = [
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]
    resources = [aws_s3_bucket.backup_bucket.arn]
  }

  statement {
    effect    = "Allow"
    actions   = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:DeleteObject",
      "s3:DeleteObjectVersion"
    ]
    resources = ["${aws_s3_bucket.backup_bucket.arn}/*"]
  }
}

resource "aws_iam_user_policy" "backup_user_policy_assignment" {
  name   = "mail-in-a-box-policy"
  user   = aws_iam_user.backup_user.name
  policy = data.aws_iam_policy_document.backup_user_policy.json
}

resource "aws_s3_object" "backups_directory" {
  bucket = aws_s3_bucket.backup_bucket.bucket
  key = "backups/"
}
