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

data "aws_route53_zone" "this" {
  name = var.zone_name
  tags = {
    Environment = var.environment
    Public      = "true"
  }
}

data "aws_acm_certificate" "this" {
  domain   = data.aws_route53_zone.this.name
  statuses = ["ISSUED"]
}
