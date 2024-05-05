output "websiteurl" {
  value = "http://${aws_route53_record.phonebook-record.name}"
}

output "dns-name" {
  value = "http://${aws_lb.pb-lb.dns_name}"
}

output "db-addr" {
  value = aws_db_instance.db-server.address
}

output "db-endpoint" {
  value = aws_db_instance.db-server.endpoint
}