# WAF

resource "aws_wafregional_ipset" "airflow_waf_ipset" {
  name = "${var.prefix}_airflow_waf_ipset"

  ip_set_descriptor {
    type  = "IPV4"
    value = "${var.waf_ip}"
  }
}

resource "aws_wafregional_rule" "airflow_waf_rule" {
  name        = "${var.prefix}_waf_rule"
  metric_name = "${var.prefix}wafrule"

  predicate {
    data_id = "${aws_wafregional_ipset.airflow_waf_ipset.id}"
    negated = false
    type    = "IPMatch"
  }
}

resource "aws_wafregional_web_acl" "airflow_waf_web_acl" {
  name = "${var.prefix}_airflow_waf_web_acl"
  metric_name = "${var.prefix}airflowwafwebacl"
  default_action {
    type = "BLOCK"
  }
  rule {
    action {
      type = "ALLOW"
    }
    priority = 1
    rule_id = "${aws_wafregional_rule.airflow_waf_rule.id}"
  }
}

resource "aws_wafregional_web_acl_association" "airflow_waf_web_acl_assoc" {
  depends_on    = ["aws_lb.airflow_lb"]
  
  resource_arn  = "${aws_lb.airflow_lb.arn}"
  web_acl_id    = "${aws_wafregional_web_acl.airflow_waf_web_acl.id}"
}
