variable "hosts" {
  description = "This hosts will be added as dns names and rules for forwarding traffic"
  default = {
    "diminutive" = "bundles"
    "phineas"    = "rates"
    "microbots"  = "payments"
    "django"     = "calls"
  }
}


// Please keep the same order on maps here and above
variable "ports" {
  description = "This ports will be used in the ALB listener definition for each service"
  default = {
    "diminutive" = "80"
    "phineas"    = "8080"
    "microbots"  = "8000"
    "django"     = "8080"
  }
}