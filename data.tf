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

data "aws_acm_certificate" "this" {
  domain   = data.aws_route53_zone.this.name
  statuses = ["ISSUED"]
}

data "aws_ssm_parameter" "zone_id" {
  name = format("/environment/%s/route53/zone_id", var.environment)
}

data "aws_ssm_parameter" "zone_name" {
  name = format("/environment/%s/route53/zone_name", var.environment)
}

data "aws_route53_zone" "this" {
  name = data.aws_ssm_parameter.zone_name.value
  tags = {
    Environment = var.environment
    Public      = "true"
  }
}
