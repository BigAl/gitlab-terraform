data "aws_iam_policy_document" "ec2-allow-assume-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# once we have a certificate_domain enable this
data "aws_acm_certificate" "ssl_certificate_id" {
  domain = "${var.certificate_domain}"
}
