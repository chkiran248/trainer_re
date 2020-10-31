<#
.SYNOPSIS
    K8S Master VM config setup with CentOS in Azure.
.PREREQUISITES
    Must be logged into Azure account
.DESCRIPTION
    Creation of a single CentOS Virtual Machine for K8S master which will be placed inside VNET. This is not having Public IP.
.EXAMPLE
    PS C:\\> k8s-master.ps1 
.INPUTS
    Prompts for a complex password for credentials. 
.OUTPUTS
    Succeeded
.NOTES   
Name       : k8s-master.ps1
Author     : Suryakiran V Chekka
Version    : 1.0.0
DateCreated: 2020-10-31
DateUpdated: 2020-10-31
.LINK
http://thecloudadmin.in
#>

# VM Details
$RG = "K8S"
$Location = "CentralIndia"
$AVset = "AVset"
$VMSize = "Standard_D2s_v4"
$VNetName = "K8S-VNET"
$VnetAddressPrefix = "30.0.0.0/16"

$SubnetName = "K8S-SubNet"
$SubnetAddressPrefix = "30.0.0.0/24"

$NICName = "master-nic"
$VMName = "master"
$DNSName = "master"

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

$VirtualMachine = New-AzVMConfig -VMName $VMName -VMSize $VMSize
$VirtualMachine = Set-AzVMOperatingSystem -VM $VirtualMachine -Linux -ComputerName $DNSName -Credential $Credential
$VirtualMachine = Add-AzVMNetworkInterface -VM $VirtualMachine -Id $NIC.Id
$VirtualMachine = Set-AzVMSourceImage -VM $VirtualMachine -PublisherName 'OpenLogic' -Offer 'CentOS' -Skus '8_2' -Version latest

# VM creation
   New-AzVM -ResourceGroupName $RG -Location $Location -VM $VirtualMachine -Verbose