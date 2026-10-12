output "user_ids" {
  value = { for k, v in azuread_user.lab : k => v.object_id }
}

output "licensing_group_id" {
  value = azuread_group.licensing_basic.object_id
}

output "automation_client_id" {
  value = azuread_application.lab_automation.client_id
}

output "automation_secret" {
  value     = azuread_application_password.lab_automation.value
  sensitive = true
}