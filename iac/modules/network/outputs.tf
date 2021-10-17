output "vpc_id" {  
    value = aws_vpc.main.id 
}

output "private_subnets_ids" {  
    value = aws_subnet.private_subnet.*.id 
}