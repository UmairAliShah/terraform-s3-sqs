
#####################################
# S3 Resources along with properties
#####################################
resource "aws_s3_bucket" "bucket" {
  bucket            = "${var.bucket_name}-${terraform.workspace}"
  acl               = var.bucket_acl

  tags = merge(
    var.common_tags,
    {
      Name          = "${var.bucket_name}-${terraform.workspace}"
    }
  )
}

##########################################
# S3 Bucket Notification on Object Upload
##########################################
resource "aws_s3_bucket_notification" "bucket_notif" {
  bucket           = aws_s3_bucket.bucket.id

  queue {
    queue_arn      = var.sqs_queue_arn
    events         = ["s3:ObjectCreated:*"]
  }
}