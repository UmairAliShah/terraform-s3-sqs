#######################
# S3 Resource Variable
####################### 

variable "bucket_name" {
  description = <<EOF
                    The name of the bucket. If omitted, Terraform will assign a random, 
                    unique name. Must be less than or equal to 63 characters in length.
                EOF
  type        = string
}

variable "bucket_acl" {
  description = "Bucket ACL"
  type        = string
}

variable "sqs_queue_arn" {
  description = "SQS queue arn where messages would be posted"
  type        = string
}

variable "common_tags" {
  description       = "Common tags for resources"
  type              = map(string)
}