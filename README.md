
### Description
You and your team are working on a project in AWS. At the very beginning, you just created resources by clicking in the Developer Console, but as your project grew, you found it problematic to remember all the steps needed every time. You decided to start from scratch and use an automation tool so that you can easily create multiple environments, or recreate them if something bad happens.

You and your team have decided to go with Terraform. 
* The first elements that need to be created are the `S3 bucket` and the `SQS queue`. 
* These elements are connected together because the queue should be notified when someone uploads any file to S3.

You have prepared the requirements and now you're ready to implement them in Terraform.


#### Objectives

* There should be an S3 bucket referenced in Terraform as `bucket` and named `upload-bucket`. The ACL should be **private**.
* There should be an SQS queue referenced in Terraform as `queue` and named `upload-queue`.
* The above queue should have a delay specified as `60 seconds`, a max message size of `200B`, should discard messages after `48 hours` and should wait for up to `30 seconds` for messages to be received.
* There should be an IAM policy document created as Terraform data, referenced as `iam_notif_policy_doc`, which should describe the policy that will be used by the bucket notification hook to post messages to the queue, or you can use EOF expression in policy and omit this step.
* The above document should contain one `statement` with id equal to `1`.
* The above statement should work only for upload-bucket and it should be tested by checking if the `source ARN` matches.
* The above statement should work only on upload-queue and it should allow messages to be sent to it.
* The above statement should use the AWS type of principal with identifiers set to *.
* The above document should be used to create the upload-queue policy referenced in Terraform as `notif_policy`. You may as well use inline policy implementing the same thing instead of using policy document.
* Finally, bucket notification should be enabled (referenced in Terraform as bucket_notif) to send a message to upload-queue when an object is created in upload-bucket.
* All references to other resources should be specified as **Terraform identifiers**, not as text.

#### Versions
* AWS Provider version is **3.30.0**
* Terraform **0.14.7**


## Getting Started

### Folder Structure

    terraform-s3-sqs
    ├── environments                # .tfvars file for all environments
    |   └── dev.tfvars              # variables initialization file for dev environment workspace
    ├── modules                     # Terraform generic resources   
    │   ├── s3                      # S3 along with bucket notification resource
    |   |   ├── outputs.tf          # S3 resource outputs file
    |   |   ├── resource.tf         # S3 resource file
    |   |   └── variables.tf        # S3 variables declartion file
    │   ├── sqs                     # SQS resource along with policy resource
    |   |   ├── outputs.tf          # SQS resource outputs fil
    |   |   ├── resource.tf         # SQS resource file
    |   |   └── variables.tf        # SQS variables declartion file
    ├── outputs.tf                  # All resoruces outputs to export during provisioning 
    ├── provider.tf                 # Terraform aws provider information
    ├── README.md                   # README.md file of whole infrastructure
    ├── resources.tf                # Terraform dynamic modules file
    ├── tags.tf                     # Common tags for all resources
    └── variables.tf                # All terraform modules variables


### Export AWS Credentials to run terraform code
The AWS provider offers a flexible means of providing credentials for authentication. The following methods are supported, in this order, and explained below:

* Static credentials
* Environment variables
* Shared credentials/configuration file
* CodeBuild, ECS, and EKS Roles
* EC2 Instance Metadata Service

I used exporting Environment variables
so replace ***** with original credentials
> export AWS_ACCESS_KEY_ID="*****"

> export AWS_SECRET_ACCESS_KEY="******"

### Create Terraform workspace for dev environment
#### Workspace benefits:
* Workspace is used to create same resources for multiple environments
* Code reuseability for all enviroments so no code repetition


Create terraform workspace
> terraform workspace new dev            # create new workspace

>  terraform workspace list              # to see workspaces

>  terraform workspace select dev        # to select workspace

### Configure AWS Provide
Add this snippet in `provider.tf`

```bash
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 3.30.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.region
}
```

### Create S3 generic resource
In path `terraform-s3-sqs/modules/s3/` 
declare variables for s3
In `variables.tf`
```bash
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
```

In `resource.tf` 

```bash
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
```

In `outputs.tf`
To reference the values of resource in other module export the outputs
```bash
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
```

### Create SQS generic resource
In path `terraform-s3-sqs/modules/sqs/` 
declare variables for sqs
In `variables.tf`
```bash
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
```

In `resource.tf`
```bash
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
```

In `outputs.tf`
To reference the values of resource in other module export the outputs
```bash
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
```

### Terraform Modules
In `resources.tf` file create terraform s3 and sqs modules
**Modules are used to avoid code repetition**

```bash
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
```
### variables for all modules
In `variables.tf` file of root dir, add these variables
```bash
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
```

### Common Tags for all resources
Use locals for common variable and tags in `tags.tf`

```bash
locals {
  common_tags = {
      environment           = terraform.workspace 
      team                  = var.team 
      project               = var.project 
      created_by            = var.created_by
      organization          = var.organization 
  }
}
```
### Export modules outputs 
```bash
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
```

### Initialize variables for all modules of dev enviromment workspace
In `terraform-s3-sqs/environments/dev.tfvars` file initialize varibales
```bash
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
```

### Execute Terraform code
Terraform init command to initialize the aws resources modules, provider plugin installation and workspace configuration
> terraform init

Validate the syntax and code warnings
> terraform validate

Execute the plan to see expected resources provisioning
> terraform plan -var-file=environments/dev.tfvars

Provision resources if everything looks fine
> terraform apply -var-file=environments/dev.tfvars

### Note
* If you want to create resources for other environments too, just create new workspace and select it. Then create new environment_name.tfvars file.
* We can use S3 bucket to save the remote state file for the collaboration and syncing of the resources if multiple persons are working on the terraform.





