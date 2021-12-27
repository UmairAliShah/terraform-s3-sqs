
########################################
# Common Tags for Upload bucket and SQS
########################################
locals {
  common_tags = {
      environment           = terraform.workspace 
      team                  = var.team 
      project               = var.project 
      created_by            = var.created_by
      organization          = var.organization 
  }
}