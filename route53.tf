resource "aws_route53_zone" "private_docudb" {
  name    = "fastmongo.com"
  comment = "Hopefully this will serve private endpoints"

  vpc {
    vpc_id = aws_vpc.main.id
  }
}

resource "aws_route53_record" "private-docu-endpoint" {
  zone_id = aws_route53_zone.private_docudb.zone_id
  name    = "db"
  type    = "CNAME"
  ttl     = 5

  weighted_routing_policy {
    weight = 10
  }

  set_identifier = "dev"
  records        = ["db endpoint"]
}