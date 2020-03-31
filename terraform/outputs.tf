output "website_endpoint" {
  value = aws_s3_bucket.site.website_endpoint
}

output "name_servers" {
  value = aws_route53_zone.bash_template_com.name_servers
}
