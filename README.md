Terraform Deployment
===============

What still has to be done?
------------------------------

- Make it so you can start/destroy seperate layers of the application. 
  So you can for example only create the kubernetes cluster without having to
  deploy everything
  
- Integrate some manual steps after the resource creation so less manual steps
  have to be done.
  
  
Setup Azure Key Vault and Azure Storage?
------------------------------
First we create the Azure Storage Account. Execute the next command within the
`/terraform/config/` directory. You might can change the first 4 variables:
- RESOURCE_GROUP_NAME=###YOUR_RESOURCE_GROUP_NAME###
- STORAGE_ACCOUNT_NAME=###YOUR_STORAGE_ACCOUNT_NAME###$RANDOM
- CONTAINER_NAME=###YOUR_CONTAINER_NAME###
                                   
Finally run the command:
    
    ./create_storage_account.sh

Once the command is finished you will get 3 value's in return. Save these so
you can replace the value's in `/terraform/main.tf`. Update the following value's with
the output value's.

    storage_account_name = "your_generated_account_name"
    container_name = "your_generated_container_name"
    
The third value `access_key` will be saved in an Azure Key Vault.
First create the resource group for the Key Vault.

    az group create --name "vault_resource_group" --location westeurope

Next create the key vault itself.

    az keyvault create --name "vault_name" --resource-group "vault_resource_group" --location westeurope
    
Now insert the access_key inside the Key Vault.

    az keyvault secret set --vault-name "vault_name" --name "name_of_key" --value "value_for_key"
    
To make the key available for Terraform, save it in a export variable, exectly called like this:

    export ARM_ACCESS_KEY=$(az keyvault secret show --name name_of_your_key --vault-name name_of_your_key_vault --query value -o tsv)


How to setup a `new` Terraform environment?
------------------------------
The state of the Terraform deployment is saved inside an Azure Storage account. The access key to access 
the storage account is saved in an Azure Key Vault.

The first step is to initiate a Terraform environment. This command is executed within the terraform
deployment folder and will use the storage account and key vault you just created.

     terraform init
     
Now you can use 3 commands to either create resources, delete resources or make a execution plan.

Creating an execution plan which is saved in the `plan.out` file:

    terraform plan -out plan.out
    
To create resources:
    
    terraform apply plan.out
    
When the resources are created save your connection to the Kubernetes cluster:

    echo "$(terraform output kube_config)" > /home/$USER/azurek8s
    export KUBECONFIG=/home/$USER/azurek8s
    
To delete resources:
        
    terraform destroy

Extra configuration after Terraform created all resources
===============
Once you run the Terraform scripts it will only create the accual resources. It won't
make all the configurations. The next topics have to be configured manually for now:

###Configurations related to Azure Kubernetes Cluster:
####How to connect to the Azure Kubernetes Cluster
Load your kube configuration to connect to the cluster:
    
    export KUBECONFIG=/home/debruynn/azurek8s
    
####Install Helm on the Azure Kubernetes Cluster
To be able to run Helm deployments on the cluster you need to install the 
tiller service. The `helm-rbac.yaml` file can be found at `/terraform/config/`
and does not need any changes.

    kubectl create -f helm-rbac.yaml
    helm init --service-account tiller --history-max 200 --upgrade
    

#####Allow access for the cluster to the Azure Container Repository
The Kubernetes cluster needs access to the Container Repository so that the docker images can be read. You can
execute the `grant_aks_access_to_acr.sh` script in `/terraform/config/`. You can change the first 4 variables:
- AKS_RESOURCE_GROUP=###YOUR_AKS_RESOURCE_GROUP###
- AKS_CLUSTER_NAME=###YOUR_CLUSTER_NAME###
- ACR_RESOURCE_GROUP=###YOUR_ACR_RESOURCE_GROUP###
- ACR_NAME=###YOUR_ACR_NAME###
    
Finally run the command:

    ./grant_aks_access_to_acr.sh

###Configurations related to Azure PostgreSQL:
#####Configure network settings on the database
Because at this moment Azure does not support the linking between an Azure PostgreSQL database and a subnet it is not possible to get a private IP-adress on the database. Because of this you need to add a firewall rule which makes it so your network is allowed. To do this, log into the Azure portal, go to the database, open `Connection Security`, click the `Add client ip` button and save.

As as a second configuration you need to enable the endpoint between the database and the VNET. To do so, click the VNET-rule and click the enable button.

###Configurations related to External-DNS:
#####Create DNS-secret on Kubernetes Cluster
To make the external-DNS service work you need to create a DNS-secret on the cluster, the `azure.json` file is located at `/terraform/config/`:

    kubectl create secret generic azure-config-file --from-file=azure.json
    
Now that the secret is added, the secret can be configured. Two roles have to be added, the first one is so that the service principal
has `Reader` rights on the resource group of the DNS-zone and secondary you need to make the service principal have `Contributor` rights on the 
DNS-zone itself.

First to get the id of the resource group of the external DNS-zone:
    
    az group show --name resourceGroupNameOfExternalDns
    
Secondary to grant the `Reader` role to the service principal:

    az role assignment create --role "Reader" --assignee <appId GUID> --scope <resource group resource id>


First to get the id of the DNS-zone:

    az network dns zone show --name yourDomainName.com -g resourceGroupNameOfExternalDns
    
Secondary to grant the role to the service principal:

    az role assignment create --role "Contributor" --assignee <appId GUID> --scope <dns zone resource id>
