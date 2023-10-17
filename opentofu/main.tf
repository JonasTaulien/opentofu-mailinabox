terraform {
  required_version = "~> 1.6.0"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

variable "aws_access_key" {
  type = string
  sensitive = true
}

variable "aws_secret_key" {
  type = string
  sensitive = true
}

variable "aws_region" {
  type = string
}

provider "aws" {
  region = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

resource "aws_s3_bucket" "mail_in_a_box_backups" {
  bucket = "miab-backups"
 // force_destroy = true
}

resource "aws_iam_user" "mail_in_a_box" {
  name = "mail-in-a-box"
}

resource "aws_iam_access_key" "mail_in_a_box" {
  user = aws_iam_user.mail_in_a_box.name
}

// See : https://docs.aws.amazon.com/AmazonS3/latest/userguide/example-policies-s3.html#iam-policy-ex0
data "aws_iam_policy_document" "allow_miab_backups_bucket" {
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
    resources = ["arn:aws:s3:::${aws_s3_bucket.mail_in_a_box_backups.bucket}"]
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
    resources = ["arn:aws:s3:::${aws_s3_bucket.mail_in_a_box_backups.bucket}/*"]
  }
}

resource "aws_iam_user_policy" "mail_in_a_box_policy" {
  name   = "allow_miab_backups_bucket"
  user   = aws_iam_user.mail_in_a_box.name
  policy = data.aws_iam_policy_document.allow_miab_backups_bucket.json
}


output "s3-region" {
  value = var.aws_region
}

output "s3-host" {
  value = "s3.${aws_s3_bucket.mail_in_a_box_backups.region}.amazonaws.com"
}

output "s3-path" {
  value = "${aws_s3_bucket.mail_in_a_box_backups.bucket}/"
}

output "s3-access-key" {
  value = aws_iam_access_key.mail_in_a_box.id
  sensitive = true
}

output "s3-secret-key" {
  value = aws_iam_access_key.mail_in_a_box.secret
  sensitive = true
}
