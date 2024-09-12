resource "aws_secretsmanager_secret" "app_secrets" {
  name = "${var.project}-${terraform.workspace}-app-secrets"
  tags = {
    name        = "${var.project}-${terraform.workspace}-app-secrets"
    project     = var.project
    Environment = "${terraform.workspace}"
  }
}