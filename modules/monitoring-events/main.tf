locals {
  # CIS AWS Foundations Benchmark section 5: EventBridge rules matching the
  # CloudTrail-delivered events that the metric-filter alarms used to watch.
  # EventBridge rules + SNS targets are free, unlike CloudWatch metric alarms.
  rule_definitions = {
    root_account_usage = {
      description = "CIS 5.3 - Usage of root account"
      event_pattern = jsonencode({
        "detail-type" = ["AWS API Call via CloudTrail"]
        detail = {
          userIdentity = {
            type = ["Root"]
          }
        }
      })
    }
    console_signin_without_mfa = {
      description = "CIS 5.2 - Management Console sign-in without MFA"
      event_pattern = jsonencode({
        "detail-type" = ["AWS Console Sign In via CloudTrail"]
        detail = {
          additionalEventData = {
            MFAUsed = ["No"]
          }
        }
      })
    }
    console_authentication_failures = {
      description = "CIS 5.6 - Console authentication failures"
      event_pattern = jsonencode({
        "detail-type" = ["AWS Console Sign In via CloudTrail"]
        detail = {
          responseElements = {
            ConsoleLogin = ["Failure"]
          }
        }
      })
    }
    unauthorized_api_calls = {
      description = "CIS 5.1 - Unauthorized API calls"
      event_pattern = jsonencode({
        "detail-type" = ["AWS API Call via CloudTrail"]
        detail = {
          errorCode = ["AccessDenied", "UnauthorizedOperation", "Client.UnauthorizedOperation"]
        }
      })
    }
    iam_policy_changes = {
      description = "CIS 5.4 - IAM policy changes"
      event_pattern = jsonencode({
        "detail-type" = ["AWS API Call via CloudTrail"]
        detail = {
          eventSource = ["iam.amazonaws.com"]
          eventName = [
            "DeleteGroupPolicy", "DeleteRolePolicy", "DeleteUserPolicy",
            "PutGroupPolicy", "PutRolePolicy", "PutUserPolicy",
            "CreatePolicy", "DeletePolicy", "CreatePolicyVersion", "DeletePolicyVersion",
            "AttachRolePolicy", "DetachRolePolicy", "AttachUserPolicy", "DetachUserPolicy",
            "AttachGroupPolicy", "DetachGroupPolicy",
          ]
        }
      })
    }
    cloudtrail_config_changes = {
      description = "CIS 5.5 - CloudTrail configuration changes"
      event_pattern = jsonencode({
        "detail-type" = ["AWS API Call via CloudTrail"]
        detail = {
          eventSource = ["cloudtrail.amazonaws.com"]
          eventName   = ["CreateTrail", "UpdateTrail", "DeleteTrail", "StartLogging", "StopLogging"]
        }
      })
    }
    s3_bucket_policy_changes = {
      description = "CIS 5.8 - S3 bucket policy changes"
      event_pattern = jsonencode({
        "detail-type" = ["AWS API Call via CloudTrail"]
        detail = {
          eventSource = ["s3.amazonaws.com"]
          eventName = [
            "PutBucketAcl", "PutBucketPolicy", "PutBucketCors", "PutBucketLifecycle",
            "PutBucketReplication", "DeleteBucketPolicy", "DeleteBucketCors",
            "DeleteBucketLifecycle", "DeleteBucketReplication",
          ]
        }
      })
    }
    kms_disable_or_delete_cmk = {
      description = "CIS 5.7 - Disabling or scheduled deletion of customer-managed KMS keys"
      event_pattern = jsonencode({
        "detail-type" = ["AWS API Call via CloudTrail"]
        detail = {
          eventSource = ["kms.amazonaws.com"]
          eventName   = ["DisableKey", "ScheduleKeyDeletion"]
        }
      })
    }
    aws_config_changes = {
      description = "CIS 5.9 - AWS Config configuration changes"
      event_pattern = jsonencode({
        "detail-type" = ["AWS API Call via CloudTrail"]
        detail = {
          eventSource = ["config.amazonaws.com"]
          eventName = [
            "StopConfigurationRecorder", "DeleteDeliveryChannel",
            "PutDeliveryChannel", "PutConfigurationRecorder",
          ]
        }
      })
    }
    security_group_changes = {
      description = "CIS 5.10 - Security group changes"
      event_pattern = jsonencode({
        "detail-type" = ["AWS API Call via CloudTrail"]
        detail = {
          eventSource = ["ec2.amazonaws.com"]
          eventName = [
            "AuthorizeSecurityGroupIngress", "AuthorizeSecurityGroupEgress",
            "RevokeSecurityGroupIngress", "RevokeSecurityGroupEgress",
            "CreateSecurityGroup", "DeleteSecurityGroup",
          ]
        }
      })
    }
    nacl_changes = {
      description = "CIS 5.11 - Network ACL changes"
      event_pattern = jsonencode({
        "detail-type" = ["AWS API Call via CloudTrail"]
        detail = {
          eventSource = ["ec2.amazonaws.com"]
          eventName = [
            "CreateNetworkAcl", "CreateNetworkAclEntry", "DeleteNetworkAcl",
            "DeleteNetworkAclEntry", "ReplaceNetworkAclEntry", "ReplaceNetworkAclAssociation",
          ]
        }
      })
    }
    network_gateway_changes = {
      description = "CIS 5.12 - Network gateway changes"
      event_pattern = jsonencode({
        "detail-type" = ["AWS API Call via CloudTrail"]
        detail = {
          eventSource = ["ec2.amazonaws.com"]
          eventName = [
            "CreateCustomerGateway", "DeleteCustomerGateway", "AttachInternetGateway",
            "CreateInternetGateway", "DeleteInternetGateway", "DetachInternetGateway",
          ]
        }
      })
    }
    route_table_changes = {
      description = "CIS 5.13 - Route table changes"
      event_pattern = jsonencode({
        "detail-type" = ["AWS API Call via CloudTrail"]
        detail = {
          eventSource = ["ec2.amazonaws.com"]
          eventName = [
            "CreateRoute", "CreateRouteTable", "ReplaceRoute", "ReplaceRouteTableAssociation",
            "DeleteRouteTable", "DeleteRoute", "DisassociateRouteTable",
          ]
        }
      })
    }
    vpc_changes = {
      description = "CIS 5.14 - VPC changes"
      event_pattern = jsonencode({
        "detail-type" = ["AWS API Call via CloudTrail"]
        detail = {
          eventSource = ["ec2.amazonaws.com"]
          eventName = [
            "CreateVpc", "DeleteVpc", "ModifyVpcAttribute", "AcceptVpcPeeringConnection",
            "CreateVpcPeeringConnection", "DeleteVpcPeeringConnection", "RejectVpcPeeringConnection",
            "AttachClassicLinkVpc", "DetachClassicLinkVpc", "DisableVpcClassicLink", "EnableVpcClassicLink",
          ]
        }
      })
    }
    organizations_changes = {
      description = "CIS 5.15 - AWS Organizations changes"
      event_pattern = jsonencode({
        "detail-type" = ["AWS API Call via CloudTrail"]
        detail = {
          eventSource = ["organizations.amazonaws.com"]
          eventName = [
            "AcceptHandshake", "AttachPolicy", "CreateAccount", "CreateOrganizationalUnit",
            "CreatePolicy", "DeclineHandshake", "DeleteOrganization", "DeleteOrganizationalUnit",
            "DeletePolicy", "DetachPolicy", "DisablePolicyType", "EnablePolicyType",
            "InviteAccountToOrganization", "LeaveOrganization", "MoveAccount",
            "RemoveAccountFromOrganization", "UpdatePolicy", "UpdateOrganizationalUnit",
          ]
        }
      })
    }
  }

  active_rules = { for k, v in local.rule_definitions : k => v if lookup(var.enabled_rules, k, true) }

  topic_arn = coalesce(var.existing_sns_topic_arn, try(aws_sns_topic.this[0].arn, null))
}

resource "aws_sns_topic" "this" {
  count = var.existing_sns_topic_arn == null ? 1 : 0

  name = var.sns_topic_name

  tags = var.tags
}

data "aws_iam_policy_document" "topic" {
  statement {
    sid       = "AllowEventBridgePublish"
    effect    = "Allow"
    actions   = ["SNS:Publish"]
    resources = [local.topic_arn]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}

resource "aws_sns_topic_policy" "this" {
  arn    = local.topic_arn
  policy = data.aws_iam_policy_document.topic.json
}

resource "aws_sns_topic_subscription" "email" {
  count = var.notification_email != null ? 1 : 0

  topic_arn = local.topic_arn
  protocol  = "email"
  endpoint  = var.notification_email
}

resource "aws_cloudwatch_event_rule" "this" {
  for_each = local.active_rules

  name          = each.key
  description   = each.value.description
  event_pattern = each.value.event_pattern

  tags = var.tags
}

resource "aws_cloudwatch_event_target" "this" {
  for_each = local.active_rules

  rule = aws_cloudwatch_event_rule.this[each.key].name
  arn  = local.topic_arn
}
