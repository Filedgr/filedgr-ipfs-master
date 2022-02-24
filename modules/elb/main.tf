resource "aws_lb_target_group" "filedgr-ipfs-gateway-web" {
  target_type = "ip"
  name        = "filedgr-ipfs-gateway-web"
  port        = 8080
  protocol    = "TCP"
  vpc_id      = var.vpcId
}

resource "aws_lb_target_group" "filedgr-ipfs-gateway-ipfs" {
  target_type = "ip"
  name        = "filedgr-ipfs-gateway-ipfs"
  port        = 4001
  protocol    = "TCP_UDP"
  vpc_id      = var.vpcId
}

resource "aws_lb" "ipfs-gateway-lb" {
  name               = "ipfs-gateway-lb"
  internal           = false
  load_balancer_type = "network"

  subnets = [var.pubSubnetId]
}

resource "aws_lb_listener" "web" {
  load_balancer_arn = aws_lb.ipfs-gateway-lb.arn
  port              = 8080
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.filedgr-ipfs-gateway-web.arn
  }
}

resource "aws_lb_listener" "ipfs" {
  load_balancer_arn = aws_lb.ipfs-gateway-lb.arn
  port              = 4001
  protocol          = "TCP_UDP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.filedgr-ipfs-gateway-ipfs.arn
  }
}

