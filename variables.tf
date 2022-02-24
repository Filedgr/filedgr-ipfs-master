variable "ecr_ipfs-image" {
  type = string
  description = "The image ID to use for the container. To be specified as a cli parameter."
}

variable "privSubnetId" {
  type = string
  description = "The Subnet to place the task in. To be provided as cli parameter."
}

variable "pubSubnetId" {
  type = string
  description = "The Subnet to place the load balancer in. To be provided as cli parameter."
}

variable "vpcId" {
  type = string
  description = "The ID of the VPC to place the infra in."
}

variable "securityGroupId" {
  type = string
}