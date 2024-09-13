##########################################
# CodeDeploy
##########################################

data "aws_iam_policy_document" "backend_codedeploy_policy_doc" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["codedeploy.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "backend_codedeploy_role" {
  name               = "${var.project}-${terraform.workspace}-backend-codedeploy-role"
  assume_role_policy = data.aws_iam_policy_document.backend_codedeploy_policy_doc.json
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEC2FullAccess",
    "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS",
    "arn:aws:iam::aws:policy/AWSCodeDeployFullAccess"  
  ]
}
resource "aws_iam_policy" "backend_codedeploy_policy" {
  name        = "${var.project}-${terraform.workspace}-backend-codedeploy-policy"
  description = "A policy for codedeploy to write to cloudwatch"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "codedeploy:CreateDeployment"
        ],
        "Resource": [
          "*"
          # "arn:aws:codedeploy:${var.location}:${var.account_id}:deploymentgroup:*/*"
        ],
        "Effect": "Allow"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_backend_codedeploy_policy" {
  role       = aws_iam_role.backend_codedeploy_role.name
  policy_arn = aws_iam_policy.backend_codedeploy_policy.arn
}

resource "aws_codedeploy_app" "backend_codedeploy" {
  compute_platform = "Server"
  name             = "${var.project}-${terraform.workspace}-backend-codedeploy"
}

# resource "aws_codedeploy_deployment_config" "backend_codedeploy_config" {
#   deployment_config_name = "CodeDeployDefault.AllAtOnce"
#   minimum_healthy_hosts {
#     type  = "HOST_COUNT"
#     value = 1
#   }
# }

resource "aws_codedeploy_deployment_group" "backend_codedeploy_group" {
  app_name               = aws_codedeploy_app.backend_codedeploy.name
  deployment_group_name  = "${var.project}-${terraform.workspace}-deployment-group"
  service_role_arn       = aws_iam_role.backend_codedeploy_role.arn
  deployment_config_name = "CodeDeployDefault.AllAtOnce" #aws_codedeploy_deployment_config.backend_codedeploy_config.id
  ec2_tag_filter {
    key   = "Name"
    type  = "KEY_AND_VALUE"
    value = "${var.project}-${terraform.workspace}-backend"
  }
#   trigger_configuration {
#     trigger_events     = ["DeploymentFailure"]
#     trigger_name       = "foo-trigger"
#     trigger_target_arn = "foo-topic-arn"
#   }
  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }
}