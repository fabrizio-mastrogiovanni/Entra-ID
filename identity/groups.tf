resource "azuread_group" "licensing_basic" {
  display_name     = "grp-licensing-basic"
  description      = "Members receive the Microsoft 365 Business Basic license"
  security_enabled = true
}

resource "azuread_group" "finance_team" {
  display_name     = "grp-finance-team"
  description      = "Finance department access"
  security_enabled = true
}

resource "azuread_group_member" "licensing_members" {
  for_each = azuread_user.lab

  group_object_id  = azuread_group.licensing_basic.object_id
  member_object_id = each.value.object_id
}

resource "azuread_group_member" "finance_members" {
  for_each = { for k, v in azuread_user.lab : k => v if contains(["alice", "bob"], k) }

  group_object_id  = azuread_group.finance_team.object_id
  member_object_id = each.value.object_id
}