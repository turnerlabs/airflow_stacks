# VPC 

resource "aws_vpc" "airflow_vpc" {
  cidr_block            = "172.16.0.0/16"
  instance_tenancy      = "default"
  enable_dns_support    = true
  enable_dns_hostnames  = true
  enable_classiclink    = false

  tags {
    Name            = "${var.prefix}_vpc"
    application     = "${var.tag_application}"
    contact-email   = "${var.tag_contact_email}"
    customer        = "${var.tag_customer}"
    team            = "${var.tag_team}"
    environment     = "${var.tag_environment}"
  }
}

# Private Subnets

resource "aws_subnet" "airflow_subnet_private_1c" {
  depends_on                      = ["aws_vpc.airflow_vpc"]
  vpc_id                          = "${aws_vpc.airflow_vpc.id}"
  cidr_block                      = "172.16.1.0/24"
  availability_zone               = "${var.availability_zone_1}"
  map_public_ip_on_launch         = false
  assign_ipv6_address_on_creation = false

  tags {
    Name            = "${var.prefix}_subnet_private_1c"
    application     = "${var.tag_application}"
    contact-email   = "${var.tag_contact_email}"
    customer        = "${var.tag_customer}"
    team            = "${var.tag_team}"
    environment     = "${var.tag_environment}"
  }
}

resource "aws_subnet" "airflow_subnet_private_1d" {
  depends_on                      = ["aws_vpc.airflow_vpc"]
  vpc_id                          = "${aws_vpc.airflow_vpc.id}"
  cidr_block                      = "172.16.2.0/24"
  availability_zone               = "${var.availability_zone_2}"
  map_public_ip_on_launch         = false
  assign_ipv6_address_on_creation = false

  tags {
    Name            = "${var.prefix}_subnet_private_1d"
    application     = "${var.tag_application}"
    contact-email   = "${var.tag_contact_email}"
    customer        = "${var.tag_customer}"
    team            = "${var.tag_team}"
    environment     = "${var.tag_environment}"
  }
}

# Public Subnets

resource "aws_subnet" "airflow_subnet_public_1c" {
  depends_on                      = ["aws_vpc.airflow_vpc"]
  vpc_id                          = "${aws_vpc.airflow_vpc.id}"
  cidr_block                      = "172.16.3.0/24"
  availability_zone               = "${var.availability_zone_1}"
  map_public_ip_on_launch         = true
  assign_ipv6_address_on_creation = false

tags {
    Name            = "${var.prefix}_subnet_public_1c"
    application     = "${var.tag_application}"
    contact-email   = "${var.tag_contact_email}"
    customer        = "${var.tag_customer}"
    team            = "${var.tag_team}"
    environment     = "${var.tag_environment}"
  }
}

resource "aws_subnet" "airflow_subnet_public_1d" {
  depends_on                      = ["aws_vpc.airflow_vpc"]
  vpc_id                          = "${aws_vpc.airflow_vpc.id}"
  cidr_block                      = "172.16.4.0/24"
  availability_zone               = "${var.availability_zone_2}"
  map_public_ip_on_launch         = true
  assign_ipv6_address_on_creation = false

  tags {
    Name            = "${var.prefix}_subnet_public_1d"
    application     = "${var.tag_application}"
    contact-email   = "${var.tag_contact_email}"
    customer        = "${var.tag_customer}"
    team            = "${var.tag_team}"
    environment     = "${var.tag_environment}"
  }
}

# Internet Gateway

resource "aws_internet_gateway" "airflow_igw" {
  depends_on  = ["aws_vpc.airflow_vpc"]
  vpc_id      = "${aws_vpc.airflow_vpc.id}"

  tags {
    Name            = "${var.prefix}_igw"
    application     = "${var.tag_application}"
    contact-email   = "${var.tag_contact_email}"
    customer        = "${var.tag_customer}"
    team            = "${var.tag_team}"
    environment     = "${var.tag_environment}"
  }
}

# NAT Gateway

resource "aws_eip" "airflow_nat_eip" {
  vpc         = true
  depends_on  = ["aws_internet_gateway.airflow_igw"]
}

resource "aws_nat_gateway" "airflow_natgw" {
  depends_on    = ["aws_vpc.airflow_vpc", "aws_internet_gateway.airflow_igw", "aws_subnet.airflow_subnet_public_1c"]
  allocation_id = "${aws_eip.airflow_nat_eip.id}"
  subnet_id     = "${aws_subnet.airflow_subnet_public_1c.id}"

  tags {
      Name            = "${var.prefix}_natgw"
      application     = "${var.tag_application}"
      contact-email   = "${var.tag_contact_email}"
      customer        = "${var.tag_customer}"
      team            = "${var.tag_team}"
      environment     = "${var.tag_environment}"
  }
}

# Main Route Table

resource "aws_route_table" "airflow_rt_main" {
  depends_on  = ["aws_vpc.airflow_vpc"]
  vpc_id      = "${aws_vpc.airflow_vpc.id}"

  tags {
    Name            = "${var.prefix}_rt_main"
    application     = "${var.tag_application}"
    contact-email   = "${var.tag_contact_email}"
    customer        = "${var.tag_customer}"
    team            = "${var.tag_team}"
    environment     = "${var.tag_environment}"
  }
}

resource "aws_route_table_association" "aws_route_table_association_private_1c" {
  depends_on      = ["aws_subnet.airflow_subnet_private_1c"]
  subnet_id       = "${aws_subnet.airflow_subnet_private_1c.id}"
  route_table_id  = "${aws_route_table.airflow_rt_main.id}"
}

resource "aws_route_table_association" "aws_route_table_association_private_1d" {
  depends_on      = ["aws_subnet.airflow_subnet_private_1d"]
  subnet_id       = "${aws_subnet.airflow_subnet_private_1d.id}"
  route_table_id  = "${aws_route_table.airflow_rt_main.id}"
}

resource "aws_route" "route_ngw" { 
  depends_on              = ["aws_nat_gateway.airflow_natgw"]  
  route_table_id          = "${aws_route_table.airflow_rt_main.id}"
  destination_cidr_block  = "0.0.0.0/0"
  nat_gateway_id          = "${aws_nat_gateway.airflow_natgw.id}"
}

# Custom Route Table

resource "aws_route_table" "airflow_rt_custom" {
  depends_on  = ["aws_vpc.airflow_vpc"]
  vpc_id      = "${aws_vpc.airflow_vpc.id}"

  tags {
    Name            = "${var.prefix}_rt_custom"
    application     = "${var.tag_application}"
    contact-email   = "${var.tag_contact_email}"
    customer        = "${var.tag_customer}"
    team            = "${var.tag_team}"
    environment     = "${var.tag_environment}"
  }
}

resource "aws_route_table_association" "aws_route_table_association_public_1c" {
  depends_on      = ["aws_subnet.airflow_subnet_public_1c"]
  subnet_id       = "${aws_subnet.airflow_subnet_public_1c.id}"
  route_table_id  = "${aws_route_table.airflow_rt_custom.id}"
}

resource "aws_route_table_association" "aws_route_table_association_public_1d" {
  depends_on      = ["aws_subnet.airflow_subnet_public_1d"]
  subnet_id       = "${aws_subnet.airflow_subnet_public_1d.id}"
  route_table_id  = "${aws_route_table.airflow_rt_custom.id}"
}

resource "aws_route" "route_igw" { 
  depends_on              = ["aws_internet_gateway.airflow_igw"]  
  route_table_id          = "${aws_route_table.airflow_rt_custom.id}"
  destination_cidr_block  = "0.0.0.0/0"
  gateway_id              = "${aws_internet_gateway.airflow_igw.id}"
}
