locals {
  tags = {
    Owner       = "Chuck Norris"
    Environment = "test"
    Application = "DataLake"
  }

  eks_cluster_name = "eks-dlk-cluster"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "vpc-dlk-k8s-cluster"

  cidr = "10.11.0.0/16"

  azs             = ["${var.region}a", "${var.region}b", "${var.region}c"]
  public_subnets  = ["10.11.101.0/24", "10.11.102.0/24", "10.11.103.0/24"]
  private_subnets = ["10.11.1.0/24", "10.11.2.0/24", "10.11.3.0/24"]

  enable_dns_hostnames             = true
  enable_dns_support               = true
  default_vpc_enable_dns_hostnames = true

  tags = "${merge(local.tags, var.tags)}"

  vpc_tags = {
    Name = "vpc-dlk-k8s-cluster"
  }

  public_subnet_tags = {
    "tags.kubernetes.io/cluster/eks-dlk-cluster" = "shared"
  }
}

module "eks_dlk" {
  source       = "terraform-aws-modules/eks/aws"
  cluster_name = "${local.eks_cluster_name}"
  subnets      = "${module.vpc.public_subnets}"
  vpc_id       = "${module.vpc.vpc_id}"

  #write_kubeconfig = false
  kubeconfig_name = "kubeconfig.yml"

  worker_groups = [
    {
      instance_type      = "t2.small"
      asg_max_size       = 9
      worker_group_count = 3
    },
  ]

  tags = "${merge(local.tags, var.tags)}"
}

module "k8s_sns_topic" {
  source = "modules/sns-dlk"

  sns_topic_name      = "sns-k8s-lambda-topic"
  attached_lambda_arn = "${module.lambda_api_k8s_interact.function_arn}"
}

# resource "aws_lambda_event_source_mapping" "k8s_sns_topic" {
#   event_source_arn = "${module.k8s_sns_topic.sns_topic_arn}"
#   function_name    = "${module.lambda_api_k8s_interact.function_arn}"
# }

module "lambda_api_k8s_interact" {
  source = "github.com/markthebault/terraform-aws-lambda"

  function_name = "lambda-${local.name}-apigw-k8s-interactions"
  runtime       = "python3.6"
  handler       = "main.handler"

  source_path = "${path.module}/lambdas/lambda_eks2"

  environment {
    variables {
      DEBUG_ENABLED = "true"
      CLUSTER_NAME  = "${module.eks_dlk.cluster_id}"

      #DYNAMO_LANDING_TABLE_NAME = "${module.dynamodb_table_dataset_landing.table_name}"
      #DYNAMO_DLK_TABLE_NAME     = "${module.dynamodb_table_datalake.table_name}"
      #S3_LANDING_BUCKET         = "${local.landing_bucket_name}"
    }
  }

  attach_policy = true

  policy = <<JSON
{
    "Version": "2012-10-17",
    "Statement": [
      {
          "Effect": "Allow",
          "Action": "sts:AssumeRole",
          "Resource": "*"
      },
      {
        "Action": [
            "dynamodb:*"
          ],
        "Effect": "Allow",
        "Resource": [
          "${module.dynamodb_table_dataset_landing.table_arn}",
          "${module.dynamodb_table_datalake.table_arn}",
          "${module.dynamodb_table_dataset_landing.table_arn}/*",
          "${module.dynamodb_table_datalake.table_arn}/*"
        ]
      },
      {
        "Action": [
            "sns:*"
          ],
        "Effect": "Allow",
        "Resource": [
          "${module.k8s_sns_topic.sns_topic_arn}"
        ]
      },
      {
        "Effect": "Allow",
        "Action": [
          "eks:*"
        ],
        "Resource": [
          "*"
        ]
      },
      {
        "Effect": "Allow",
        "Action": [
          "sts:GetCallerIdentity"
        ],
        "Resource": "*"
      }
    ]
}
JSON
}
