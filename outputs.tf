# outputs.tf
# Display important information after terraform apply
output "resource_group_name" {
    description = "Name of the resource group"
    value = azurerm_resource_group.rg.name
    }
output "public_ip_address" {
    description = "Public IP address of the VM"
    value = azurerm_public_ip.ip.ip_address
    }
output "ssh_command" {
    description = "SSH command to connect to the VM"
    value = "ssh azureuser@${azurerm_public_ip.ip.ip_address}"
    }
output "website_url" {
    description = "URL to access the nginx web server"
    value = "http://${azurerm_public_ip.ip.ip_address}"
    }
