# main.tf

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "tf-manual-rg"
  location = "swedencentral"
  tags = {
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "tf-manual-vnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
  tags = {
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

# Subnet — was missing entirely
resource "azurerm_subnet" "subnet" {
  name                 = "tf-manual-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Network Security Group — was missing entirely
resource "azurerm_network_security_group" "nsg" {
  name                = "tf-manual-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTP"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

# Public IP — was missing entirely
resource "azurerm_public_ip" "ip" {
  name                = "tf-manual-pip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags = {
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

# Network Interface
resource "azurerm_network_interface" "nic" {
  name                = "tf-manual-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.ip.id
  }

  tags = {
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

# NSG Association
resource "azurerm_network_interface_security_group_association" "nsg_assoc" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Linux Virtual Machine
resource "azurerm_linux_virtual_machine" "vm" {
  name                            = "tf-manual-vm"
  location                        = azurerm_resource_group.rg.location
  resource_group_name             = azurerm_resource_group.rg.name
  size                            = "Standard_D2s_v3"
  network_interface_ids           = [azurerm_network_interface.nic.id]
  admin_username                  = "azureuser"
  admin_password                  = "CloudAndDevOps#2026"
  disable_password_authentication = false

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  custom_data = base64encode(<<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y nginx
    systemctl start nginx
    systemctl enable nginx
    echo "<h1>Hello from Terraform!</h1>" > /var/www/html/index.html
    EOF
  )

  tags = {
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}
# Trigger CI/CD pipeline

# Fix CI/CD authentication

