# One default provider (home region us-east-1) plus one aliased provider per
# non-home active region. Static aliases are required because Terraform
# providers cannot be created dynamically (for_each over providers is not
# supported); each regional module call selects its provider explicitly.

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = var.tags
  }
}

provider "aws" {
  alias  = "us_east_2"
  region = "us-east-2"

  default_tags {
    tags = var.tags
  }
}

provider "aws" {
  alias  = "us_west_1"
  region = "us-west-1"

  default_tags {
    tags = var.tags
  }
}

provider "aws" {
  alias  = "us_west_2"
  region = "us-west-2"

  default_tags {
    tags = var.tags
  }
}

provider "aws" {
  alias  = "ca_central_1"
  region = "ca-central-1"

  default_tags {
    tags = var.tags
  }
}

provider "aws" {
  alias  = "eu_west_1"
  region = "eu-west-1"

  default_tags {
    tags = var.tags
  }
}

provider "aws" {
  alias  = "eu_west_2"
  region = "eu-west-2"

  default_tags {
    tags = var.tags
  }
}

provider "aws" {
  alias  = "eu_west_3"
  region = "eu-west-3"

  default_tags {
    tags = var.tags
  }
}

provider "aws" {
  alias  = "eu_central_1"
  region = "eu-central-1"

  default_tags {
    tags = var.tags
  }
}

provider "aws" {
  alias  = "eu_north_1"
  region = "eu-north-1"

  default_tags {
    tags = var.tags
  }
}

provider "aws" {
  alias  = "ap_south_1"
  region = "ap-south-1"

  default_tags {
    tags = var.tags
  }
}

provider "aws" {
  alias  = "ap_northeast_1"
  region = "ap-northeast-1"

  default_tags {
    tags = var.tags
  }
}

provider "aws" {
  alias  = "ap_northeast_2"
  region = "ap-northeast-2"

  default_tags {
    tags = var.tags
  }
}

provider "aws" {
  alias  = "ap_northeast_3"
  region = "ap-northeast-3"

  default_tags {
    tags = var.tags
  }
}

provider "aws" {
  alias  = "ap_southeast_1"
  region = "ap-southeast-1"

  default_tags {
    tags = var.tags
  }
}

provider "aws" {
  alias  = "ap_southeast_2"
  region = "ap-southeast-2"

  default_tags {
    tags = var.tags
  }
}

provider "aws" {
  alias  = "sa_east_1"
  region = "sa-east-1"

  default_tags {
    tags = var.tags
  }
}
