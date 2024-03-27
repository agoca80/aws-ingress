data "aws_acm_certificate" "this" {
  domain   = var.zone_name
  statuses = ["ISSUED"]
}

data "aws_vpc" "this" {
  filter {
    name   = "tag:Environment"
    values = [var.environment]
  }
}

data "aws_subnets" "private" {
  tags = {
    Environment = var.environment
    Private     = "true"
  }
}

data "aws_subnets" "public" {
  tags = {
    Environment = var.environment
    Public      = "true"
  }
}

resource "aws_security_group" "this" {
  name   = var.name
  tags   = var.tags
  vpc_id = data.aws_vpc.this.id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_alb" "this" {
  enable_deletion_protection = false
  idle_timeout               = 600
  name                       = var.name
  internal                   = false
  security_groups            = [aws_security_group.this.id]
  subnets                    = data.aws_subnets.public.ids
}

resource "aws_alb_listener" "this" {
  load_balancer_arn = aws_alb.this.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_acm_certificate.this.arn
  tags              = var.tags

  default_action {
    type  = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "OK"
      status_code  = "200"
    }
  }
}

