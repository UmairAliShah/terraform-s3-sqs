variable "region" {
  description   = "AWS region name for provider"
  default       = "us-east-1"
  type = string
}

########################################
# Common Tags for Upload Bucket and SQS 
########################################
variable "team" {
  description = "The name of the team"
  default = "DevOps"
  type = string
}

variable "project" {
  description = "The name of the project"
  default = "Terraform"
  type = string
}

variable "created_by" {
  description = "Resources created by"
  default = "Syed Umair Ali"
  type = string
}

variable "organization" {
  description = "The name of the organization"
  default = "terraform"
  type = string
}


##########################
# Upload Bucket Variables
##########################
variable "upload_bucket_name" {
  description = <<EOF
                    The name of the upload bucket. If omitted, Terraform will assign a random, 
                    unique name. Must be less than or equal to 63 characters in length.
                EOF
  type        = string
  default     = "upload-bucket"
}

variable "upload_bucket_acl" {
  description = "Bucket ACL"
  type        = string
  default     = "private"
}

#############################
# Upload SQS Queue Variables 
#############################
variable "upload_sqs_name" {
  description = <<EOF
                    This is the human-readable name of the queue. If omitted, Terraform will assign a random name.
                EOF
  type        = string
  default     = "upload-queue"
}

variable "upload_sqs_delay_sec" {
  description = <<EOF
                    The time in seconds that the delivery of all messages in the queue will be delayed. 
                    An integer from 0 to 900 (15 minutes). The default for this attribute is 0 seconds.
                EOF
  type        = number
  default     = 60
}

variable "upload_sqs_max_message_size" {
  description = <<EOF
                    The limit of how many bytes a message can contain before Amazon SQS rejects it. 
                    An integer from 1024 bytes (1 KiB) up to 262144 bytes (256 KiB). 
                    The default for this attribute is 262144 (256 KiB).
                EOF
  type        = number
  default     = 200000
}

variable "upload_sqs_retention_period" {
  description = <<EOF
                    The number of seconds Amazon SQS retains a message. Integer representing seconds, 
                    from 60 (1 minute) to 1209600 (14 days). 
                    The default for this attribute is 345600 (4 days).
                EOF
  type        = number
  default     = 172800
}

variable "upload_sqs_receive_wait_time" {
  description = <<EOF
                    The time for which a ReceiveMessage call will wait for a message to arrive 
                    (long polling) before returning. An integer from 0 to 20 (seconds). 
                    The default for this attribute is 0, meaning that the call will return immediately.
                EOF
  type        = number  
  default     = 20 
}
