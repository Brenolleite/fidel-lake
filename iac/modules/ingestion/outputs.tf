output "event_bus_name" {  
    value = aws_cloudwatch_event_bus.analytics_bus.name
}

output "event_bus_arn" {  
    value = aws_cloudwatch_event_bus.analytics_bus.arn
}