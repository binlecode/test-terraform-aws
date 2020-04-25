
resource "aws_instance" "bl-test-vm" {
#   ami           = "ami-2757f631"  # ubuntu 16.04LTS
#   ami           = "ami-b374d5a5"  # ubuntu 16.10
  ami           = "${var.amis["ubt-1604"]}"
  instance_type = "t2.nano"
  subnet_id = "${aws_subnet.bl-test-subnet.id}"
  vpc_security_group_ids = ["${aws_security_group.bl-test-sg.id}"]

#   provisioner "local-exec" {
#     command = "echo ${aws_instance.bl-test-vm.public_ip} > ip_address.txt"
#   }
}

output "vm_id" {
    value = "${aws_instance.bl-test-vm.id}"
}

output "public_ip" {
    value = "${aws_instance.bl-test-vm.public_ip}"
}
