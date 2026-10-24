
variable "monthly_budget_limit" {
  description = "Monthly AWS budget target in USD"
  type        = number
  default     = 10

  validation {
    condition     = var.monthly_budget_limit > 0
    error_message = "The monthly budget limit must be greater than zero."
  }
}

variable "notification_email" {
  description = "Email address for AWS budget notifications"
  type        = string
  sensitive   = true

  validation {
    condition = can(regex(
      "^[^@ ]+@[^@ ]+\\.[^@ ]+$",
      var.notification_email
    ))
    error_message = "Provide a valid email address."
  }
}
