resource "aws_security_group" "external_rfc_6598_lb" {
  name        = "external-rfc-6598-lb"
  description = "Allow http inbound traffic"
  vpc_id      = module.vpc.vpc_id

  tags = merge(var.common_tags, {
    Name = "external-rfc-6598-lb"
  })
}

resource "aws_security_group_rule" "external_ingress_http" {
  type              = "ingress"
  description       = "Allows HTTP inbound"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.external_rfc_6598_lb.id
}

resource "aws_security_group_rule" "external_egress_http" {
  type        = "egress"
  description = "Allows HTTP outbound to any 100.64"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["100.64.0.0/10"]

  security_group_id = aws_security_group.external_rfc_6598_lb.id
}

resource "aws_security_group" "internal_rfc_6598_lb" {
  name        = "internal-rfc-6598-lb"
  description = "Allow http inbound traffic"
  vpc_id      = module.vpc.vpc_id

  tags = merge(var.common_tags, {
    Name = "internal-rfc-6598-lb"
  })
}

resource "aws_security_group_rule" "internal_ingress_http" {
  type              = "ingress"
  description       = "Allows HTTP inbound"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["10.0.0.0/8"]
  security_group_id = aws_security_group.internal_rfc_6598_lb.id
}

resource "aws_security_group_rule" "internal_egress_http" {
  type        = "egress"
  description = "Allows HTTP outbound to any 100.64"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["100.64.0.0/10"]

  security_group_id = aws_security_group.internal_rfc_6598_lb.id
}

resource "aws_lb" "external_rfc_6598" {
  name               = "external-rfc-6598"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.external_rfc_6598_lb.id]
  subnets            = slice(module.vpc.public_subnets, 0, 3)

  enable_deletion_protection = false

  #   access_logs {
  #     bucket  = aws_s3_bucket.lb_logs.bucket
  #     prefix  = "test-lb"
  #     enabled = true
  #   }

  tags = merge(var.common_tags, {
    Name = "external-rfc-6598"
  })
}

resource "aws_lb" "internal_rfc_6598" {
  name               = "rfc-6598"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.internal_rfc_6598_lb.id]
  subnets            = slice(module.vpc.public_subnets, 3, 6)

  enable_deletion_protection = false

  #   access_logs {
  #     bucket  = aws_s3_bucket.lb_logs.bucket
  #     prefix  = "test-lb"
  #     enabled = true
  #   }

  tags = merge(var.common_tags, {
    Name = "internal-rfc-6598"
  })
}
