output "arn" {
  value = aws_elasticsearch_domain.this.arn
}

output "domain_id" {
  value = aws_elasticsearch_domain.this.domain_id
}

output "domain_name" {
  value = aws_elasticsearch_domain.this.domain_name
}

output "endpoint" {
  value = aws_elasticsearch_domain.this.endpoint
}

output "kibana_endpoint" {
  value = aws_elasticsearch_domain.this.kibana_endpoint
}