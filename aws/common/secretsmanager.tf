resource "aws_secretsmanager_secret" "app_secrets" {
  name = "${var.project}/${terraform.workspace}/config"
  tags = {
    name        = "${var.project}-${terraform.workspace}-app-secret"
    project     = var.project
    Environment = "${terraform.workspace}"
  }
}