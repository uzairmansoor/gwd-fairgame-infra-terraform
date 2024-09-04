resource "aws_codestarconnections_connection" "bitbucket" {
  name          = "${var.project}-${terraform.workspace}-bitbucket-connection"
  provider_type = "Bitbucket"
}