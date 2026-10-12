resource "azuread_application" "lab_automation" {
  display_name = "sp-lab-automation"
}

resource "azuread_service_principal" "lab_automation" {
  client_id = azuread_application.lab_automation.client_id
}

resource "azuread_application_password" "lab_automation" {
  application_id = azuread_application.lab_automation.id
  end_date       = timeadd(timestamp(), "720h") # 30 days
  lifecycle {
    ignore_changes = [end_date]
  }
}