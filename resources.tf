####################################
# Upload S3 Bucket Terraform Module 
####################################
module "upload_bucket" {
  source                    = "./modules/s3"
  bucket_name               = var.upload_bucket_name
  bucket_acl                = var.upload_bucket_acl
  sqs_queue_arn             = module.upload_queue.sqs_queue_arn
  common_tags               = local.common_tags
}

##############################
# Upload SQS Terraform Module 
##############################
module "upload_queue" {
  source                    = "./modules/sqs"
  sqs_name                  = var.upload_sqs_name
  sqs_delay_sec             = var.upload_sqs_delay_sec
  sqs_max_message_size      = var.upload_sqs_max_message_size
  sqs_retention_period      = var.upload_sqs_retention_period
  sqs_receive_wait_time     = var.upload_sqs_receive_wait_time
  s3_bucket_name            = var.upload_bucket_name
  common_tags               = local.common_tags
}