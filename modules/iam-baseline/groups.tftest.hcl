# Native tests for the CIS 2.14 IAM groups + break-glass scaffold. mock_provider
# lets these run with `command = plan` and no AWS credentials. Each run disables
# the unrelated baseline resources so the plan focuses on groups.tf.

# Mock the assume-role policy document so its computed `.json` is valid JSON;
# without this the mocked value is not a JSON object and aws_iam_role rejects it.
mock_provider "aws" {
  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
    }
  }
}

# Defaults: no groups, no memberships, no break-glass role.
run "defaults_create_nothing" {
  command = plan

  variables {
    manage_password_policy                = false
    enable_account_s3_block_public_access = false
    create_support_role                   = false
  }

  assert {
    condition     = length(aws_iam_group.this) == 0
    error_message = "Default iam_groups should create zero groups."
  }

  assert {
    condition     = length(aws_iam_group_policy_attachment.this) == 0
    error_message = "Default config should create zero group policy attachments."
  }

  assert {
    condition     = length(aws_iam_user_group_membership.this) == 0
    error_message = "Default config should create zero user-group memberships."
  }

  assert {
    condition     = length(aws_iam_role.break_glass) == 0
    error_message = "Break-glass role must be disabled by default."
  }
}

# A populated iam_groups map: 2 groups, 3 total policy attachments, and
# memberships for 2 distinct users (one user is in both groups).
run "populated_groups_plan_expected_counts" {
  command = plan

  variables {
    manage_password_policy                = false
    enable_account_s3_block_public_access = false
    create_support_role                   = false

    iam_groups = {
      readonly = {
        managed_policy_arns = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
        members             = ["claude-readonly", "prowler"]
      }
      audit = {
        managed_policy_arns = [
          "arn:aws:iam::aws:policy/job-function/ViewOnlyAccess",
          "arn:aws:iam::aws:policy/SecurityAudit",
        ]
        members = ["prowler"]
      }
    }
  }

  assert {
    condition     = length(aws_iam_group.this) == 2
    error_message = "Expected exactly 2 IAM groups."
  }

  assert {
    condition     = length(aws_iam_group_policy_attachment.this) == 3
    error_message = "Expected 3 group policy attachments (1 readonly + 2 audit)."
  }

  # claude-readonly + prowler => 2 distinct users => 2 membership resources.
  assert {
    condition     = length(aws_iam_user_group_membership.this) == 2
    error_message = "Expected one membership resource per distinct user (2)."
  }
}

# Break-glass enabled: a role + customer-managed admin policy + attachment.
run "break_glass_enabled_plans_role_and_policy" {
  command = plan

  variables {
    manage_password_policy                = false
    enable_account_s3_block_public_access = false
    create_support_role                   = false

    break_glass_admin = {
      enabled                = true
      trusted_principal_arns = ["arn:aws:iam::111122223333:role/Admins"]
    }
  }

  assert {
    condition     = length(aws_iam_role.break_glass) == 1
    error_message = "Break-glass role should be created when enabled."
  }

  assert {
    condition     = length(aws_iam_policy.break_glass_admin) == 1
    error_message = "Customer-managed admin policy should be created by default when enabled."
  }

  assert {
    condition     = length(aws_iam_role_policy_attachment.break_glass_admin) == 1
    error_message = "Admin policy should be attached to the break-glass role."
  }
}
