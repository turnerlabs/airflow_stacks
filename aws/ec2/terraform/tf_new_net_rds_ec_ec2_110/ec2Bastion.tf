resource "aws_instance" "instance_bastion" {
  ami                         = "ami-0ac019f4fcb7cb7e6"
  instance_type               = "t2.micro"
  key_name                    = "${var.airflow_keypair_name}"
  vpc_security_group_ids      = ["${aws_security_group.bastion_instance.id}"]
  subnet_id                   = "${aws_subnet.airflow_subnet_public_1c.id}"

  tags {
    Name            = "${var.prefix}_airflow_bastion"
    application     = "${var.tag_application}"
    contact-email   = "${var.tag_contact_email}"
    customer        = "${var.tag_customer}"
    team            = "${var.tag_team}"
    environment     = "${var.tag_environment}"
  }
}