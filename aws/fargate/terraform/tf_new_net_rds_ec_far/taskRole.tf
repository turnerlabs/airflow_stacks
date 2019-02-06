# IAM Role

# Execution
resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "${var.prefix}_ecsTaskExecutionRole"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role_policy.json}"
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = "${aws_iam_role.ecsTaskExecutionRole.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Task
resource "aws_iam_role" "iam_role" {

  name = "${var.prefix}_iam_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
          "ecs.amazonaws.com",
          "ecs-tasks.amazonaws.com"
        ]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# IAM S3 Role Policy

resource "aws_iam_role_policy" "airflow_s3" {
  depends_on  = ["aws_iam_role.iam_role"]

  name = "${var.prefix}_s3"
  role = "${aws_iam_role.iam_role.name}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
              "s3:ListBucket"
            ],
            "Resource": [
              "${aws_s3_bucket.s3_airflow_bucket.arn}",
              "${aws_s3_bucket.s3_airflow_log_bucket.arn}"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
              "s3:PutObject",
              "s3:GetObject",
              "s3:DeleteObject"
            ],
            "Resource": [
              "${aws_s3_bucket.s3_airflow_bucket.arn}/*",
              "${aws_s3_bucket.s3_airflow_log_bucket.arn}/*"
            ]
        }

    ]
}
EOF
}

# IAM Logs Role Policy

resource "aws_iam_role_policy" "airflow_logs" {
  depends_on  = ["aws_iam_role.iam_role"]

  name = "${var.prefix}_logs"
  role = "${aws_iam_role.iam_role.name}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ],
        "Resource": [
          "arn:aws:logs:*:*:*"
        ]
      }
   ]
}
EOF
}

# IAM Secrets Manager Role Policy

resource "aws_iam_role_policy" "airflow_secrets" {
  depends_on  = ["aws_iam_role.iam_role"]

  name = "${var.prefix}_secrets"
  role = "${aws_iam_role.iam_role.name}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "secretsmanager:GetSecretValue"
        ],
        "Resource": [
          "${aws_secretsmanager_secret.airflow_sm_secret.id}"
        ]
      }
   ]
}
EOF
}
