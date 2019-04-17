locals {
  etl_role_name = "k8s-spark-etl"
}

resource "aws_iam_role" "etl_role" {
  name = "role-${local.etl_role_name}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "${module.eks_dlk.worker_iam_role_arn}"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}

EOF

  tags = "${merge(var.tags)}"
}

resource "aws_iam_policy" "etl_policy" {
  name = "policy-${local.etl_role_name}"
  path = "/"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": ${jsonencode(module.s3-buckets.s3_bucket_arn)}
        
    },
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": ${jsonencode(formatlist("%s/*",module.s3-buckets.s3_bucket_arn))}
        
    },
    {
    "Action": [
        "sns:*"
        ],
    "Effect": "Allow",
    "Resource": [
        "${module.k8s_sns_topic.sns_topic_arn}",
        "${module.dlk_sns_topic.sns_topic_arn}"
        ]
        
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "etl_attach" {
  name       = "attachment-${local.etl_role_name}-role"
  roles      = ["${aws_iam_role.etl_role.name}"]
  policy_arn = "${aws_iam_policy.etl_policy.arn}"
}
