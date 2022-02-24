output "webTargetGroupArn" {
  value = aws_lb_target_group.filedgr-ipfs-gateway-web.arn
}

output "ipfsTargetGroupArn" {
  value = aws_lb_target_group.filedgr-ipfs-gateway-ipfs.arn
}
