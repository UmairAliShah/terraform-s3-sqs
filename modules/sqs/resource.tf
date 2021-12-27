#####################################
# SQS Resource along with properties
#####################################

resource "aws_sqs_queue" "queue" {
  name                      = "${var.sqs_name}-${terraform.workspace}"
  delay_seconds             = var.sqs_delay_sec
  max_message_size          = var.sqs_max_message_size
  message_retention_seconds = var.sqs_retention_period
  receive_wait_time_seconds = var.sqs_receive_wait_time
  tags = merge(
    var.common_tags,
    {
      Name = "${var.sqs_name}-${terraform.workspace}"
    }
  )
}

####################
# SQS Access Policy 
####################

resource "aws_sqs_queue_policy" "iam_notif_policy_doc" {
  queue_url = aws_sqs_queue.queue.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "sqspolicy",
  "Statement": [
    {
      "Sid": "1",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "sqs:SendMessage",
      "Resource": "${aws_sqs_queue.queue.arn}",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "arn:aws:s3:*:*:${var.s3_bucket_name}-${terraform.workspace}"
        }
      }
    }
  ]
}
POLICY
}