# terraform config 
variable "new_relic_region" {
  type = string
}
terraform {
  required_version = ">= 1.3.1"
  required_providers {
    newrelic = {
      source  = "newrelic/newrelic"
      version = "~> 3.11.0, <4.0.0"
    }
  }
}

provider "newrelic" {
  region = var.new_relic_region 
}
