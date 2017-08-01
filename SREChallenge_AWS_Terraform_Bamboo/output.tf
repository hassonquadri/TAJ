output "bamboo-ip" {
  value = "${aws_instance.bamboo-instance.public_ip}"
}
output "app-ip" {
  value = "${aws_instance.app-instance.public_ip}"
}
