config {
  call_module_type = "local"
}

plugin "terraform" {
  enabled = true
  # Enables the recommended ruleset preset (naming, deprecated syntax, etc.).
  preset = "recommended"
}

plugin "aws" {
  enabled = true
  version = "0.31.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}
