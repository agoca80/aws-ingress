data "aws_security_group" "this" {
  for_each = var.listeners

  name   = each.key
  vpc_id = data.aws_vpc.this.id

  tags = {
    Environment = var.environment
  }
}

resource "aws_security_group_rule" "this" {
  for_each = var.listeners

  from_port                = each.value
  protocol                 = "tcp"
  to_port                  = each.value
  type                     = "ingress"
  security_group_id        = data.aws_security_group.this[each.key].id
  source_security_group_id = aws_security_group.this.id
}

data "aws_alb_target_group" "this" {
  for_each = var.listeners

  name = each.key

  tags = {
    Name        = each.key
    Environment = var.environment
  }
}

resource "aws_alb_listener_rule" "this" {
  for_each = var.listeners

  listener_arn = aws_alb_listener.this.arn
  priority     = 1

  action {
    type             = "forward"
    target_group_arn = data.aws_alb_target_group.this[each.key].arn
  }

  condition {
    host_header {
      values = [format("%s.%s", each.key, var.zone_name)]
    }
  }

  tags = merge(local.tags, {
    Name = each.key
  })
}

resource "aws_route53_record" "this" {
  for_each = var.listeners

  zone_id = data.aws_route53_zone.this.id
  name    = each.key
  type    = "A"

  alias {
    name                   = aws_alb.this.dns_name
    zone_id                = aws_alb.this.zone_id
    evaluate_target_health = true
  }
}
