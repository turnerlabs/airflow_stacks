output "circleci_access_key_id" {
  value = "${aws_iam_access_key.iam_access_key.id}"
}

output "circleci_access_key_secret" {
  value = "${aws_iam_access_key.iam_access_key.secret}"
}
