########################
# Upload Bucket Outputs
######################## 
output "upload_bucket_name" {
  value             = module.upload_bucket.bucket_name
  description       = "Upload Bucket name"
}

output "upload_bucket_arn" {
  value             = module.upload_bucket.bucket_arn
  description       = "Upload Bucket ARN"
}


#######################
# Upload Queue Outputs
####################### 
output "upload_sqs_queue_id" {
    value           = module.upload_queue.sqs_queue_id
    description     = "Upload sqs queue id"
}

output "upload_sqs_queue_arn" {
    value           = module.upload_queue.sqs_queue_arn
    description     = "Upload Sqs queue ARN"
}

