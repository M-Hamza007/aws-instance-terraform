output "aws_instance" {
    value = aws_instance.demo_instance.id
}

output "keyname" {
    # value = "${aws_key_pair.key-tf.key_name}"
    value = "${data.aws_key_pair.keypair.key_name}"
}

output securityGroupDetails {
    value = aws_security_group.demoSG1.id
}