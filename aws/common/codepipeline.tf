##########################################
# Frontend Pipeline
##########################################

##########################################
# IAM Roles
##########################################

data "aws_iam_policy_document" "codebuild_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "codebuild_project_role" {
  name               = "${var.project}-${terraform.workspace}-codebuild-role"
  assume_role_policy = data.aws_iam_policy_document.codebuild_policy.json
}

resource "aws_iam_policy" "codebuild_write_cloudwatch_policy" {
  name        = "${var.project}-${terraform.workspace}-codebuild-policy"
  description = "A policy for codebuild to write to cloudwatch"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "cloudwatch:*",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:CreateLogGroup",
          "logs:DescribeLogStreams"
        ],
        "Resource": "*",
        "Effect": "Allow"
      },
      {
        "Action": ["s3:*"],
        "Resource": "*",
        "Effect": "Allow"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_codebuild_write_cloudwatch_policy" {
  role       = aws_iam_role.codebuild_project_role.name
  policy_arn = aws_iam_policy.codebuild_write_cloudwatch_policy.arn
}


resource "aws_iam_role" "codepipeline_role" {
  name               = "${var.project}-${terraform.workspace}-codepipeline-role"
  # tags = {
  #   name        = "${var.project}-${terraform.workspace}-codepipeline-role"
  #   project     = var.project
  #   Environment = "${terraform.workspace}"
  # }
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Effect": "Allow"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
path               = "/"
}

resource "aws_iam_policy" "codepipeline_policy" {
  name        = "${var.project}-${terraform.workspace}-codepipeline-policy"
  description = "Policy to allow codepipeline to execute"
  tags = {
    name        = "${var.project}-${terraform.workspace}-codepipeline-policy"
    project     = var.project
    Environment = "${terraform.workspace}"
  }
  policy = jsonencode({
  #policy      = <<EOF
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect":"Allow",
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:PutObjectAcl",
        "s3:PutObject",
        "s3:*"
      ],
      "Resource": "*"
    },
    {
        Effect = "Allow"
        Action = [
          "codestar-connections:UseConnection",
          "codestar-connections:*"
        ]
        Resource = "*"
      },
    {
      "Effect":"Allow",
      "Action": [
        "s3:GetBucketVersioning"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "codebuild:BatchGetBuilds",
        "codebuild:StartBuild",
        "codebuild:BatchGetProjects"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "codebuild:CreateReportGroup",
        "codebuild:CreateReport",
        "codebuild:UpdateReport",
        "codebuild:BatchPutTestCases"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    }
  ]
}
)
}

resource "aws_iam_role_policy_attachment" "codepipeline_role_attach" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = aws_iam_policy.codepipeline_policy.arn
}

##########################################
# Code Build
##########################################

resource "aws_codebuild_project" "aws_codebuild_project" {
  name          = "${var.project}-${terraform.workspace}-codebuild"
  description   = "Codebuild for ${var.project}"
  build_timeout = "40"
  service_role  = aws_iam_role.codebuild_project_role.arn
  artifacts {
    type = "CODEPIPELINE"
  }
  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:6.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    environment_variable {
      name  = "S3_BUCKET_NAME"
      type  = "PLAINTEXT"
      value = aws_s3_bucket.frontend_s3_bucket.id
  }
  environment_variable {
      name  = "PROJECT_NAME"
      type  = "PLAINTEXT"
      value = "${var.bitbucketRepo}"
  }
  }
  logs_config {
    cloudwatch_logs {
      group_name  = "${var.project}-${terraform.workspace}-codebuild-log-group"
      stream_name = "${var.project}-${terraform.workspace}-codebuild-log-stream"
    }
  }
  source {
    type = "CODEPIPELINE"
    buildspec = "buildspec.yml"
  }
}

##########################################
# Code Pipeline
##########################################

resource "aws_codepipeline" "pipeline" {
  name     = "${var.project}-${terraform.workspace}-codepipeline"
  pipeline_type   = "V2"
  execution_mode  = "QUEUED"
  role_arn = aws_iam_role.codepipeline_role.arn
  artifact_store {
    location = aws_s3_bucket.artifacts_s3_bucket.id
    type     = "S3"
  }
  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]
      configuration = {
        ConnectionArn    = "${var.sourceConnectionArn}"
        FullRepositoryId = "${var.bitbucketAccount}/${var.bitbucketRepo}"   
        BranchName       = "${var.repoBranchName}"
      }
    }
  }
  stage {
    name = "Build"
    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"
      configuration = {
        ProjectName = aws_codebuild_project.aws_codebuild_project.name
      }
    }
  }
}


##########################################
# Backend Pipeline
##########################################

data "aws_iam_policy_document" "backend_codebuild_policy_doc" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "backend_codebuild_project_role" {
  name               = "${var.project}-${terraform.workspace}-backend-codebuild-role"
  assume_role_policy = data.aws_iam_policy_document.backend_codebuild_policy_doc.json
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/SecretsManagerReadWrite",
    "arn:aws:iam::aws:policy/CloudWatchFullAccess",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/AdministratorAccess"
  ]
}

resource "aws_iam_policy" "backend_codebuild_policy" {
  name        = "${var.project}-${terraform.workspace}-backend-codebuild-policy"
  description = "A policy for codebuild to write to cloudwatch"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:CreateLogGroup",
          "logs:DescribeLogStreams"
        ],
        "Resource": ["*"],
        "Effect": "Allow"
      },
      {
        "Action": [
          "s3:PutObject",
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetBucketAcl",
          "s3:GetBucketLocation"
          ],
        "Resource": "*",
        "Effect": "Allow"
      },
      {
        "Action": [
          "codebuild:CreateReportGroup",
          "codebuild:CreateReport",
          "codebuild:UpdateReport",
          "codebuild:BatchPutTestCases",
          "codebuild:BatchPutCodeCoverages"
          ],
        "Resource": [
          "arn:aws:codebuild:${var.location}:${var.account_id}:report-group/*"
        ],
        "Effect": "Allow"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_backend_codebuild_policy" {
  role       = aws_iam_role.backend_codebuild_project_role.name
  policy_arn = aws_iam_policy.backend_codebuild_policy.arn
}

resource "aws_iam_role" "backend_codepipeline_role" {
  name               = "${var.project}-${terraform.workspace}-backend-codepipeline-role"
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AWSCodeDeployFullAccess",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  ]
  # tags = {
  #   name        = "${var.project}-${terraform.workspace}-backend-codepipeline-role"
  #   project     = var.project
  #   Environment = "${terraform.workspace}"
  # }
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Effect": "Allow"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
path               = "/"
}
resource "aws_iam_policy" "backend_codepipeline_policy" {
  name        = "${var.project}-${terraform.workspace}-backend-codepipeline-policy"
  description = "Policy to allow codepipeline to execute"
  tags = {
    name        = "${var.project}-${terraform.workspace}-backend-codepipeline-policy"
    project     = var.project
    Environment = "${terraform.workspace}"
  }
  policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect":"Allow",
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:PutObjectAcl",
        "s3:PutObject",
        "s3:*"
      ],
      "Resource": "*"
    },
    {
        Effect = "Allow"
        Action = [
          "codestar-connections:UseConnection"
        ]
        Resource = "*"
      },
    {
      "Effect":"Allow",
      "Action": [
        "s3:GetBucketVersioning"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "codebuild:BatchGetBuilds",
        "codebuild:StartBuild",
        "codebuild:BatchGetProjects"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "codebuild:CreateReportGroup",
        "codebuild:CreateReport",
        "codebuild:UpdateReport",
        "codebuild:BatchPutTestCases"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    }
  ]
}
)
}

resource "aws_iam_role_policy_attachment" "backend_codepipeline_role_attach" {
  role       = aws_iam_role.backend_codepipeline_role.name
  policy_arn = aws_iam_policy.backend_codepipeline_policy.arn
}

##########################################
# Code Build
##########################################

resource "aws_codebuild_project" "backend_aws_codebuild_project" {
  name          = "${var.project}-${terraform.workspace}-backend-codebuild"
  description   = "Codebuild for ${var.project}"
  build_timeout = "40"
  service_role  = aws_iam_role.backend_codebuild_project_role.arn
  artifacts {
    type = "CODEPIPELINE"
  }
  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:6.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    environment_variable {
      name  = "PROJECT"
      type  = "PLAINTEXT"
      value = "${var.project}"
  }
    environment_variable {
      name  = "ENV"
      type  = "PLAINTEXT"
      value = "${terraform.workspace}"
  }
    environment_variable {
      name  = "APP_SECRET_ID"
      type  = "SECRETS_MANAGER"
      value = "${var.project}/${terraform.workspace}/config" #Make sure that the secret name and this value remain same
  }
  }
  logs_config {
    cloudwatch_logs {
      group_name  = "${var.project}-${terraform.workspace}-codebuild-backend-log-group"
      stream_name = "${var.project}-${terraform.workspace}-codebuild-backend-log-stream"
    }
  }
  source {
    type = "CODEPIPELINE"
    buildspec = "buildspec.yml"
  }
}

##########################################
# Code Pipeline
##########################################

resource "aws_codepipeline" "backend_pipeline" {
  name     = "${var.project}-${terraform.workspace}-backend-codepipeline"
  pipeline_type   = "V2"
  execution_mode  = "QUEUED"
  role_arn = aws_iam_role.backend_codepipeline_role.arn
  artifact_store {
    location = aws_s3_bucket.backend_artifacts_s3_bucket.id
    type     = "S3"
  }
  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]
      configuration = {
        ConnectionArn    = "${var.sourceConnectionArn}"
        FullRepositoryId = "${var.bitbucketAccount}/${var.bitbucketBackendRepo}"   
        BranchName       = "${var.repoBranchBackendName}"
      }
    }
  }
  stage {
    name = "Build"
    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"
      configuration = {
        ProjectName = aws_codebuild_project.backend_aws_codebuild_project.name
      }
    }
  }
  stage {
    name = "Deploy"
    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeploy"
      input_artifacts = ["build_output"]
      version         = "1"
      configuration = {
        ApplicationName     = aws_codedeploy_app.backend_codedeploy.name
        DeploymentGroupName = aws_codedeploy_deployment_group.backend_codedeploy_group.deployment_group_name
      }
    }
  }
}