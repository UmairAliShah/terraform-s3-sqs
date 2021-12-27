########################################
############# AWS Region ###############
########################################
region              = "us-east-1"

########################################
###### Common Tags for resources #######
########################################
team                = "DevOps"
project             = "Terraform"
created_by          = "Syed Umair Ali"
organization        = "terraform"

########################################
# Upload Bucket Parameter Values
########################################
upload_bucket_name  = "upload-bucket-01"
upload_bucket_acl   = "private"


####################################
# Upload SQS QUEUE Parameter Values 
####################################
upload_sqs_name                 = "upload-queue"
upload_sqs_delay_sec            = 60
upload_sqs_max_message_size     = 200000
upload_sqs_retention_period     = 172800
upload_sqs_receive_wait_time    = 20
