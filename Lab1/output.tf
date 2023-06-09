output "FortiGate-1_Public_IP" {
  value = aws_instance.fortigate-1.public_ip
}

output "FortiGate-1_Password" {
  value = aws_instance.fortigate-1.id
}

output "FortiGate-2_Public_IP" {
  value = aws_instance.fortigate-2.public_ip
}

output "FortiGate-2_Password" {
  value = aws_instance.fortigate-2.id
}

output "Linux1_Public_IP" {
  value = aws_instance.linux1.public_ip
}

output "Linux2_Public_IP" {
  value = aws_instance.linux2.public_ip
}
