############################
# S3 Bucket Resource Output 
############################

output "bucket_name" {
  value             = aws_s3_bucket.bucket.id
  description       = "Export Bucket name"
}

output "bucket_arn" {
  value             = aws_s3_bucket.bucket.arn
  description       = "Export Bucket ARN"
}