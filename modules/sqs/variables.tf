########################
# SQS Reource Variables 
########################

variable "sqs_name" {
  description = <<EOF
                    This is the human-readable name of the queue. If omitted, Terraform will assign a random name.
                EOF
  type        = string
}

variable "sqs_delay_sec" {
  description = <<EOF
                    The time in seconds that the delivery of all messages in the queue will be delayed. 
                    An integer from 0 to 900 (15 minutes). The default for this attribute is 0 seconds.
                EOF
  type        = number
}

variable "sqs_max_message_size" {
  description = <<EOF
                    The limit of how many bytes a message can contain before Amazon SQS rejects it. 
                    An integer from 1024 bytes (1 KiB) up to 262144 bytes (256 KiB). 
                    The default for this attribute is 262144 (256 KiB).
                EOF
  type        = number
}

variable "sqs_retention_period" {
  description = <<EOF
                    The number of seconds Amazon SQS retains a message. Integer representing seconds, 
                    from 60 (1 minute) to 1209600 (14 days). 
                    The default for this attribute is 345600 (4 days).
                EOF
  type        = number
}

variable "sqs_receive_wait_time" {
  description = <<EOF
                    The time for which a ReceiveMessage call will wait for a message to arrive 
                    (long polling) before returning. An integer from 0 to 20 (seconds). 
                    The default for this attribute is 0, meaning that the call will return immediately.
                EOF
  type        = number  
}


variable "s3_bucket_name" {
  description = "S3 bucket name to send message to SQS"
  type        = string
}

variable "common_tags" {
  description       = "Common tags for resources"
  type              = map(string)
}