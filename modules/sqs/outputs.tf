####################
# SQS Queue Outputs
####################
 
output "sqs_queue_id" {
    value           = aws_sqs_queue.queue.id
    description     = "sqs queue id"
}

output "sqs_queue_arn" {
    value           = aws_sqs_queue.queue.arn
    description     = "Sqs queue ARN"
}

