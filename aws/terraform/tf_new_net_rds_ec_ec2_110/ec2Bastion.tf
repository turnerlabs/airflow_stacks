data "aws_ami" "ubuntu" {
  most_recent = true
  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "instance_bastion" {
  ami               = "${data.aws_ami.ubuntu.id}"
  instance_type     = "t2.micro"
  name              = "${var.prefix}_airflow_bastion"
  key_name          = "${var.airflow_keypair_name}"
  security_groups   = ["${aws_security_group.bastion_instance.id}"]

  tags {
    Name            = "${var.prefix}_airflow_bastion"
    application     = "${var.tag_application}"
    contact-email   = "${var.tag_contact_email}"
    customer        = "${var.tag_customer}"
    team            = "${var.tag_team}"
    environment     = "${var.tag_environment}"
  }
}