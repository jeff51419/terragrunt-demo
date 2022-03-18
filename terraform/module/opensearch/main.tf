resource "aws_elasticsearch_domain" "this" {
  #checkov:skip=CKV_AWS_137:The Elasticsearch is a public and limited ip address
  #ts:skip=AWS.Elasticsearch.Logging.Medium.0573 already add slow logs
  domain_name           = var.domain
  elasticsearch_version = var.elasticsearch_version

  cluster_config {
    instance_type  = var.data_node_instance
    instance_count = var.data_node_count
    zone_awareness_enabled = true
    zone_awareness_config  {
      availability_zone_count = var.availability_zone_count
    }
    // master node
    dedicated_master_enabled = var.master_instance_enabled
    dedicated_master_type = var.master_instance_enabled ? var.master_node_instance : null
    dedicated_master_count = var.master_instance_enabled ?var.master_node_count : null
  }

  vpc_options {
    security_group_ids = var.security_group_ids != [] ? var.security_group_ids : null
    subnet_ids = var.subnet_ids  != [] ? var.subnet_ids : null
  }

  ebs_options {
    ebs_enabled = true
    volume_size = var.data_node_size
  }

  advanced_options = {
    "indices.fielddata.cache.size"           = "20"
    "indices.query.bool.max_clause_count"    = "1024"
    "override_main_response_version"         = "true"
  }

  advanced_security_options  {
    enabled = true
    internal_user_database_enabled = var.user_database_enabled

    master_user_options  {
      master_user_arn = var.master_user_arn != "" ? var.master_user_arn : null
      master_user_name = var.master_user_arn != ""  ? null : var.master_user_name
      master_user_password = var.master_user_arn != "" ? null : var.master_user_password
    }
  }

  domain_endpoint_options  {
    enforce_https = true
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
    custom_endpoint_enabled = true
    custom_endpoint_certificate_arn = var.domain_acm
    custom_endpoint = var.opensearch_domain
  }

  auto_tune_options  {
    desired_state = "ENABLED"
    rollback_on_disable = "NO_ROLLBACK"
    maintenance_schedule {
      start_at = time_offset.this.rfc3339
      duration {
        value = 2
        unit = "HOURS"
      }
      cron_expression_for_recurrence = "cron(0 0 ? * 1 *)"
    }
  }

  encrypt_at_rest {
    enabled = true
    kms_key_id = "aws/es"
    // kms_key_id = "arn:aws:kms:ap-northeast-1:385284847228:key/f21720ff-e736-4b87-b3c5-a5b090b50aed"
  }

  node_to_node_encryption {
    enabled = true
  }

  tags ={
    Environment = var.environment
    Project = var.project
  }

  log_publishing_options {
    enabled = true
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.index_slow.arn
    log_type                 = "INDEX_SLOW_LOGS"
  }

  log_publishing_options {
    enabled = true
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.audit.arn
    log_type                 = "AUDIT_LOGS"
  }

  // log_publishing_options {
  //   enabled = true
  //   cloudwatch_log_group_arn = aws_cloudwatch_log_group.search_slow.arn
  //   log_type                 = "SEARCH_SLOW_LOGS"
  // }
}

resource "time_offset" "this" {
  offset_minutes = 10
}

output "time_offset_from_now" {
  value = time_offset.this.rfc3339
}

#### elasticsearch access policy
resource "aws_elasticsearch_domain_policy" "this" {
  domain_name = aws_elasticsearch_domain.this.domain_name

  access_policies = <<POLICIES
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "es:*",
      "Resource": "arn:aws:es:${var.region}:${data.aws_caller_identity.current.account_id}:domain/${var.domain}/*",
      "Condition": {
        "IpAddress": {
          "aws:SourceIp": ${jsonencode(var.whitelist_ips)}
        }
      }
    }
  ]
}
POLICIES
}


#### Log Publishing to CloudWatch Logs
resource "aws_cloudwatch_log_group" "index_slow" {
  name = "/aws/OpenSearchService/domains/${var.domain}/index-logs"
  tags = {
    Environment = var.environment
    Project = var.project
  }
  kms_key_id = var.cloudwatch_kms
  retention_in_days = 14 
}

resource "aws_cloudwatch_log_resource_policy" "index_slow" {
  policy_name = "OpenSearchService-${var.domain}-Index-logs"

  policy_document = <<CONFIG
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "es.amazonaws.com"
      },
      "Action": [
        "logs:PutLogEvents",
        "logs:PutLogEventsBatch",
        "logs:CreateLogStream"
      ],
      "Resource": "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/OpenSearchService/domains/${var.domain}/index-logs:*"
    }
  ]
}
CONFIG
}

resource "aws_cloudwatch_log_group" "audit" {
  name = "/aws/OpenSearchService/domains/${var.domain}/audit-logs"
  tags = {
    Environment = var.environment
    Project = var.project
  }
  kms_key_id = var.cloudwatch_kms
  retention_in_days = 14 
}

resource "aws_cloudwatch_log_resource_policy" "audit" {
  policy_name = "OpenSearchService-${var.domain}-Audit-logs"

  policy_document = <<CONFIG
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "es.amazonaws.com"
      },
      "Action": [
        "logs:PutLogEvents",
        "logs:CreateLogStream"
      ],
      "Resource": "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/OpenSearchService/domains/${var.domain}/audit-logs:*"
    }
  ]
}
CONFIG
}

// resource "aws_cloudwatch_log_group" "search_slow" {
//   name = "/aws/OpenSearchService/domains/${var.domain}/search-logs"
//   tags = {
//     Environment = var.environment
//     Project = var.project
//   }
//   kms_key_id = var.cloudwatch_kms
//   retention_in_days = 14 
// }

// resource "aws_cloudwatch_log_resource_policy" "search_slow" {
//   policy_name = "OpenSearchService-${var.domain}-search-logs"

//   policy_document = <<CONFIG
// {
//   "Version": "2012-10-17",
//   "Statement": [
//     {
//       "Effect": "Allow",
//       "Principal": {
//         "Service": "es.amazonaws.com"
//       },
//       "Action": [
//         "logs:PutLogEvents",
//         "logs:CreateLogStream"
//       ],
//       "Resource": "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/OpenSearchService/domains/${var.domain}/search-logs:*"
//     }
//   ]
// }
// CONFIG
// }

#### dns records settings 
data "aws_route53_zone" "selected" {
  name         = var.domain_zone
  private_zone = false
}

resource "aws_route53_record" "this" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = var.opensearch_domain
  type    = "CNAME"
  ttl     = "300"
  records = [aws_elasticsearch_domain.this.endpoint]
}