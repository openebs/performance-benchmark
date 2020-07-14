output "public_subnet_id_one" {
  value = "${aws_subnet.public_subnet_one.id}"
}

output "public_subnet_id_two" {
  value = "${aws_subnet.public_subnet_two.id}"
}

output "private_subnet_id_one" {
  value = "${aws_subnet.private_subnet_one.id}"
}

output "private_subnet_id_two" {
  value = "${aws_subnet.private_subnet_two.id}"
}
