output "subnet_1" {
  value = aws_subnet.story_gen_subnet_1.id
}

output "subnet_2" {
  value = aws_subnet.story_gen_subnet_2.id
}

output "rds_subnet_group_name" {
  description = "The ID of the RDS Subnet Group"
  value       = aws_db_subnet_group.story_gen_rds_subnet_group.name
}

output "ids" {
  value = [aws_subnet.story_gen_subnet_1.id, aws_subnet.story_gen_subnet_2.id]
}