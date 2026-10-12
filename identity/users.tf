locals {
  lab_users = {
    alice = { display = "Alice Nguyen", job = "Analyst" }
    bob   = { display = "Bob Martinez", job = "Accountant" }
    carol = { display = "Carol Osei", job = "Operations" }
  }
}

resource "azuread_user" "lab" {
  for_each = local.lab_users

  user_principal_name   = "${each.key}@${var.domain}"
  display_name          = each.value.display
  mail_nickname         = each.key
  job_title             = each.value.job
  password              = var.initial_password
  force_password_change = true
  account_enabled       = true
}