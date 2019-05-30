resource "azurerm_resource_group" "rgGgroup" {
  name = "RG-AKS-TERRAFORM"
  location = "West Europe"
}

resource "azurerm_kubernetes_cluster" "cluster" {
  name = "k8s"
  location = "${azurerm_resource_group.rgGgroup.location}"
  resource_group_name = "${azurerm_resource_group.rgGgroup.name}"
  dns_prefix = "your_dns_prefix"

  role_based_access_control {
    enabled = true
  }

  agent_pool_profile {
    name = "agentpool"
    count = 2
    vm_size = "Standard_DS2_v2"
    os_type = "Linux"
    os_disk_size_gb = 30
    vnet_subnet_id = "${azurerm_subnet.subnet.id}"
  }

  service_principal {
    client_id = "your_client_id"
    client_secret = "your_client_secret"
  }

  network_profile {
    network_plugin = "kubenet"
    service_cidr = "x.x.x.x/xx"
    dns_service_ip = "x.x.x.x"
    docker_bridge_cidr = "x.x.x.x/xx"
    pod_cidr = "x.x.x.x/xx"
  }

  tags = {
    Environment = "Development"
  }
}
