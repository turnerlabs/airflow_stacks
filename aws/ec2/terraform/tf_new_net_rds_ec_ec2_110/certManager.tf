# Certificate Manager Stuff

resource "aws_acm_certificate" "airflow_acm_cert" {
  domain_name       = "${var.subdomain}"
  validation_method = "DNS"
}

resource "aws_route53_record" "airflow_r53_cert_record" {
  name    = "${aws_acm_certificate.airflow_acm_cert.domain_validation_options.0.resource_record_name}"
  type    = "${aws_acm_certificate.airflow_acm_cert.domain_validation_options.0.resource_record_type}"
  zone_id = "${data.aws_route53_zone.airflow_r53_zone.id}"
  records = ["${aws_acm_certificate.airflow_acm_cert.domain_validation_options.0.resource_record_value}"]
  ttl     = 30
}

resource "aws_acm_certificate_validation" "cert" {
  depends_on              = ["aws_acm_certificate.airflow_acm_cert", "aws_route53_record.airflow_r53_cert_record"]

  certificate_arn         = "${aws_acm_certificate.airflow_acm_cert.arn}"
  validation_record_fqdns = ["${aws_route53_record.airflow_r53_cert_record.fqdn}"]
}
