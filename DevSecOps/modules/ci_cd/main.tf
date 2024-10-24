# CI/CD Module (modules/ci_cd/main.tf):

resource "aws_codepipeline" "pipeline" {
  name = "example-pipeline"

  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    type     = "S3"
    location = aws_s3_bucket.codepipeline_bucket.bucket
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      action_type_id {
        category = "Source"
        owner    = "AWS"
        provider = "S3"
        version  = "1"
      }
      output_artifacts = ["source_output"]
    }
  }

  tags = var.tags
}
