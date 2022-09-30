terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
  required_version = ">= 0.14.9"

  backend "s3" {
    bucket = "terraform-20220210205113858700000002"
    key    = "a393884d-5d16-410c-bdf0-db62964b6945"
    region = "eu-central-1"
  }
}

provider "aws" {
  region  = "eu-central-1"
}

module "elb" {
  source = "./modules/elb"
  pubSubnetId = var.pubSubnetId
  vpcId = var.vpcId
}

module "ecs" {
  depends_on = [module.elb]

  ecr_ipfs_image = var.ecr_ipfs-image
  ipfs_subnet    = var.privSubnetId

  webTargetGroup = module.elb.webTargetGroupArn
#  apiTargetGroup = module.elb.apiTargetGroupArn
  ipfsTargetGroup = module.elb.ipfsTargetGroupArn
  securityGroupId = var.securityGroupId

  source = "./modules/ecs"
}

#module "cloudfront" {
#  depends_on = [module.ecs, module.elb]
#  elbDomain  = module.elb.elbDomain
#  source = "./modules/cloudfront"
#}

