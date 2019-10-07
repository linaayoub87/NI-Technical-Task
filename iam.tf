resource "aws_iam_role" "web_instance_role" {
  name = "web_instance_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
      "owner" = "${var.owner}"
  }
}

resource "aws_iam_instance_profile" "web_instance_profile" {
  name = "web_instance_profile"
  role = "${aws_iam_role.web_instance_role.name}"
}

resource "aws_iam_role_policy" "s3_code_policy" {
  name = "s3_code_policy"
  role = "${aws_iam_role.web_instance_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::flask-code-tech-task/*"
    }
  ]
}
EOF
}