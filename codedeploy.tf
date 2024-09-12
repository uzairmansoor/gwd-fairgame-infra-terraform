##########################################
# CodeDeploy
##########################################

resource "aws_codedeploy_app" "backend_codedeploy" {
  compute_platform = "Server"
  name             = "${var.project}-${terraform.workspace}-backend-codedeploy"
}

resource "aws_codedeploy_deployment_config" "backend_codedeploy_config" {
  deployment_config_name = "backend-codedeploy-config"
  minimum_healthy_hosts {
    type  = "HOST_COUNT"
    value = 1
  }
}

resource "aws_codedeploy_deployment_group" "backend_codedeploy_group" {
  app_name               = aws_codedeploy_app.backend_codedeploy.name
  deployment_group_name  = "${var.project}-${terraform.workspace}-deployment-group"
  service_role_arn       = aws_iam_role.foo_role.arn
  deployment_config_name = aws_codedeploy_deployment_config.foo.id
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