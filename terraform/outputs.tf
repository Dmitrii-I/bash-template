output "website_endpoint" {
  value = aws_s3_bucket.site.website_endpoint
}

output "name_servers" {
  value = aws_route53_zone.bash_template_com.name_servers
}

output cloudfront_domain_name {
  value = aws_cloudfront_distribution.bash-template.domain_name
}

output "cloudfront_distribution_id" {
  value = aws_cloudfront_distribution.bash-template.id
}
