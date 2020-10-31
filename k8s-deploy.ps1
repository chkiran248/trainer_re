<#
.SYNOPSIS
    K8S - One Master and Two Worker VM's Deployment setup with CentOS in Azure.
.PREREQUISITES
    Must be logged into Azure account
.DESCRIPTION
    Creation of a Three CentOS Virtual Machine for K8S master and workers which will be placed inside VNET. This is not having Public IP.
.EXAMPLE
    PS C:\\> k8s-deploy.ps1 
.INPUTS
    Prompts for a complex password for credentials. 
.OUTPUTS
    Succeeded
.NOTES   
Name       : k8s-deploy.ps1
Author     : Suryakiran V Chekka
Version    : 1.0.0
DateCreated: 2020-10-31
DateUpdated: 2020-11-01
.LINK
http://thecloudadmin.in
#>

# VM Details
$RG = "K8S"
$Location = "CentralIndia"
$AVset = "AVset"
$MasterVMSize = "Standard_D2s_v4"
$WorkerVMSize = "Standard_B2s"
$VNetName = "K8S-VNET"
$VnetAddressPrefix = "30.0.0.0/16"

$SubnetName = "K8S-SubNet"
$SubnetAddressPrefix = "30.0.0.0/24"

$NICName = "master-nic"
$VMName = "Master"
$DNSName = "Master"

$VMLocalAdminUser = "LocalAdminUser"
$VMLocalAdminSecurePassword = ConvertTo-SecureString  -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential ($VMLocalAdminUser, $VMLocalAdminSecurePassword);

New-AzResourceGroup `
   -Name $RG `
   -Location $Location

New-AzAvailabilitySet `
   -Location $Location `
   -Name $AVset `
   -ResourceGroupName $RG `
   -Sku aligned `
   -PlatformFaultDomainCount 2 `
   -PlatformUpdateDomainCount 2

# NIC Details
$SingleSubnet = New-AzVirtualNetworkSubnetConfig -Name $SubnetName -AddressPrefix $SubnetAddressPrefix
$Vnet= New-AzVirtualNetwork -Name $VNetName -ResourceGroupName $RG -Location $Location -AddressPrefix $VnetAddressPrefix -Subnet $SingleSubnet
$NIC = New-AzNetworkInterface -Name $NICName -ResourceGroupName $RG -Location $Location -SubnetId $VNet.Subnets[0].Id


# VM Config Details

$MasterVM = New-AzVMConfig -VMName $VMName -VMSize $MasterVMSize
$MasterVM = Set-AzVMOperatingSystem -VM $MasterVM -Linux -ComputerName $DNSName -Credential $Credential
$MasterVM = Add-AzVMNetworkInterface -VM $MasterVM -Id $NIC.Id
$MasterVM = Set-AzVMSourceImage -VM $MasterVM -PublisherName 'OpenLogic' -Offer 'CentOS' -Skus '8_2' -Version latest

# Master VM creation
   New-AzVM -ResourceGroupName $RG -Location $Location -VM $MasterVM -Verbose

# Worker VM creation
for ($i=1; $i -le 2; $i++)
{
    
$WorkerNIC = New-AzNetworkInterface -Name "WorkerNIC-$i" -ResourceGroupName $RG -Location $Location -SubnetId $VNet.Subnets[0].Id
$WorkerVM = New-AzVMConfig -VMSize $WorkerVMSize -Name "Worker$i"
$WorkerVM = Set-AzVMOperatingSystem -VM $WorkerVM -Linux -ComputerName "Worker$i" -Credential $Credential
$WorkerVM = Add-AzVMNetworkInterface -VM $WorkerVM -Id $WorkerNIC.Id
$WorkerVM = Set-AzVMSourceImage -VM $WorkerVM -PublisherName 'OpenLogic' -Offer 'CentOS' -Skus '8_2' -Version latest

New-AzVM -ResourceGroupName $RG -Location $Location  -VM $WorkerVM  -Verbose
}
 