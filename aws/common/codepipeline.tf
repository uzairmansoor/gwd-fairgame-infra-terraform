# code build role
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
  name               = "${var.project}-${terraform.workspace}--codebuild-role"
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
  name               = "${var.project}-${terraform.workspace}--codepipeline-role"
  tags = {
    project= var.project
    Environment = "${terraform.workspace}"
  }
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
  name        = "${var.project}-codepipeline-policy"
  description = "Policy to allow codepipeline to execute"
  tags = {
    project= var.project
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
        "s3:PutObject"
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
  build_timeout = "30"
  service_role  = aws_iam_role.codebuild_project_role.arn
  artifacts {
    type = "CODEPIPELINE"
  }
  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
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
        ConnectionArn    = aws_codestarconnections_connection.bitbucket.arn #var.bitbucketArn # aws_codestarconnections_connection.codestar_connection_example.arn
        FullRepositoryId = var.bitbucketRepo   
        BranchName       = "main"
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
  stage {
    name = "Deploy"
    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "S3"
      input_artifacts = ["build_output"]
      version         = "1"
      configuration = {
        BucketName = aws_s3_bucket.artifacts_s3_bucket.id
        Extract    = "true"
      }
    }
  }
}