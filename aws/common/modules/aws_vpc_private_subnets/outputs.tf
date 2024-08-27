output "subnet_1" {
  value = aws_subnet.story_gen_private_subnet_1.id
}

output "subnet_2" {
  value = aws_subnet.story_gen_private_subnet_2.id
}

output "ids" {
  value = [aws_subnet.story_gen_private_subnet_1.id, aws_subnet.story_gen_private_subnet_2.id]
}