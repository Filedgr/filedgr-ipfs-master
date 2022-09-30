#!/bin/sh
terraform apply -var="privSubnetId=${PRIV_SUBNETID}" \
-var="pubSubnetId=${PRIV_SUBNETID}" \
-var="vpcId=${VPCID}" \
-var="securityGroupId=${SGID}" \
-var="ecr_ipfs-image=${IMAGE_ID}" \
--auto-approve
