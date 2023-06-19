variable "apigee_host" {
  type = string
}

variable "apigee_protocol" {
  type = string
}

variable "trace_insert_license_api_key" {
  type = string
}

resource "newrelic_synthetics_secure_credential" "trace_insert_license_api_key" {
  key = "TRACE_INSERT_LICENSE_API_KEY"
  value = var.trace_insert_license_api_key
  description = "NR trace api insert license key"
}

resource "newrelic_synthetics_script_monitor" "newrelic_trace_monitor" {
  name                 = "newrelic-trace"
  type                 = "SCRIPT_API"
  locations_public     = ["EU_WEST_2"]
  period               = "EVERY_15_MINUTES"
  status               = "ENABLED"
  script               = templatefile("./script.tftpl", { ENDPOINT = "/newrelic/trace", APIGEE_PROTOCOL = var.apigee_protocol, APIGEE_HOST = var.apigee_host, REGION = var.new_relic_region })
  script_language      = "JAVASCRIPT"
  runtime_type         = "NODE_API"
  runtime_type_version = "16.10"
  tag {
    key = "terraform"
    values = [true]
  }
}

resource "newrelic_synthetics_script_monitor" "newrelic_logging_monitor" {
  name                 = "newrelic-logging"
  type                 = "SCRIPT_API"
  locations_public     = ["EU_WEST_2"]
  period               = "EVERY_15_MINUTES"
  status               = "ENABLED"
  script               = templatefile("./script.tftpl", { ENDPOINT = "/newrelic/logging", APIGEE_PROTOCOL = var.apigee_protocol, APIGEE_HOST = var.apigee_host, REGION = var.new_relic_region })
  script_language      = "JAVASCRIPT"
  runtime_type         = "NODE_API"
  runtime_type_version = "16.10"
  tag {
    key = "terraform"
    values = [true]
  }
}

resource "newrelic_synthetics_script_monitor" "newrelic_trace_and_logging_monitor" {
  name                 = "newrelic-trace-and-logging"
  type                 = "SCRIPT_API"
  locations_public     = ["EU_WEST_2"]
  period               = "EVERY_15_MINUTES"
  status               = "ENABLED"
  script               = templatefile("./script.tftpl", { ENDPOINT = "/newrelic/trace-and-logging", APIGEE_PROTOCOL = var.apigee_protocol, APIGEE_HOST = var.apigee_host, REGION = var.new_relic_region })
  runtime_type         = "NODE_API"
  runtime_type_version = "16.10"
  tag {
    key = "terraform"
    values = [true]
  }
}
