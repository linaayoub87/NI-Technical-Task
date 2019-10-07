locals {
  table_name = replace(var.name, "-", "_")
  account_id = data.aws_arn.this.account
  region     = data.aws_arn.this.region
  query      = <<EOF
CREATE EXTERNAL TABLE IF NOT EXISTS ${local.table_name} (
  type string,
  time string,
  lb string,
  client_ip string,
  client_port int,
  target_ip string,
  target_port int,
  request_processing_time double,
  target_processing_time double,
  response_processing_time double,
  lb_status_code string,
  target_status_code string,
  received_bytes bigint,
  sent_bytes bigint,
  request_verb string,
  request_url string,
  request_proto string,
  user_agent string,
  ssl_cipher string,
  ssl_protocol string,
  target_group_arn string,
  trace_id string,
  domain_name string,
  chosen_cert_arn string,
  matched_rule_priority int,
  request_creation_time string,
  actions_executed string
)
PARTITIONED BY(year string, month string, day string)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.RegexSerDe'
WITH SERDEPROPERTIES (
'serialization.format' = '1',
'input.regex' = '([^ ]*) ([^ ]*) ([^ ]*) ([^ ]*):([0-9]*) ([^ ]*)[:\-]([0-9]*) ([-.0-9]*) ([-.0-9]*) ([-.0-9]*) (|[-0-9]*) (-|[-0-9]*) ([-0-9]*) ([-0-9]*) \"([^ ]*) ([^ ]*) (- |[^ ]*)\" (\"[^\"]*\") ([A-Z0-9-]+) ([A-Za-z0-9.-]*) ([^ ]*) ([^ ]*) ([^ ]*) ([^ ]*) ([^ ]*) ([^ ]*) (.*)' )
LOCATION 's3://${var.bucket_name}/${var.bucket_prefix}/AWSLogs/${local.account_id}/elasticloadbalancing/${local.region}/'
TBLPROPERTIES ('classification'='loadbalancer');
EOF

}

resource "null_resource" "this" {
  count = var.load_balancer_type == "application" && var.bucket_name != "" ? 1 : 0
  provisioner "local-exec" {
    command = "aws athena start-query-execution --query-string \"${local.query}\" --query-execution-context Database=lblogs --result-configuration OutputLocation=s3://${var.bucket_name}/athena/"
  }
}
