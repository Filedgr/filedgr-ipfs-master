#!/bin/sh
terraform apply -var="privSubnetId=subnet-0baa60163f5fb38d7" \
-var="pubSubnetId=subnet-069f3b85f5328bbc2" \
-var="vpcId=vpc-041189264a99a503c" \
-var="securityGroupId=sg-0db74a76f9b42afeb" \
-var="ecr_ipfs-image=867912683733.dkr.ecr.eu-central-1.amazonaws.com/filedgr-ipfs:manual" \
--auto-approve