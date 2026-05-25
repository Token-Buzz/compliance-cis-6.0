# Partial backend config: real values are supplied at init time via a backend
# file kept out of version control:
#
#   terraform init -backend-config=backend.hcl
#
# See backend.hcl.example for the expected keys.
terraform {
  backend "s3" {}
}
