# VM Details
$RG = "K8S"
$Location = "CentralIndia"
$AVset = "AVset"
$VMSize = "Standard_D2s_v4"
$VNetName = "K8S-VNET"
$VnetAddressPrefix = "30.0.0.0/16"

$SubnetName = "K8S-SubNet"
$SubnetAddressPrefix = "30.0.0.0/24"




# $SingleSubnet = New-AzVirtualNetworkSubnetConfig -Name $SubnetName -AddressPrefix $SubnetAddressPrefix
# $Vnet = New-AzVirtualNetwork -Name $VNetName -ResourceGroupName $RG -Location $Location -AddressPrefix $VnetAddressPrefix -Subnet $SubnetAddressPrefix
# $NIC = New-AzNetworkInterface -Name $NICName -ResourceGroupName $RG -Location $Location -SubnetId $Vnet.Subnets[0].Id


$VirtualMachine = New-AzVMConfig <#-VMName $VMName #> -VMSize $VMSize
$VirtualMachine = Set-AzVMOperatingSystem -VM $VirtualMachine -Linux -ComputerName master -Credential $Credential -ProvisionVMAgent -EnableAutoUpdate
# $VirtualMachine = Add-AzVMNetworkInterface -VM $VirtualMachine -Id $NIC.Id
$VirtualMachine = Set-AzVMSourceImage -VM $VirtualMachine -PublisherName 'OpenLogic' -Offer 'CentOS' -Skus '8_2' -Version latest



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

$SingleSubnet = New-AzVirtualNetworkSubnetConfig -Name $SubnetName -AddressPrefix $SubnetAddressPrefix
New-AzVirtualNetwork -Name $VNetName -ResourceGroupName $RG -Location $Location -AddressPrefix $VnetAddressPrefix -Subnet $SingleSubnet

   $cred = Get-Credential

   New-AzVM -ResourceGroupName $ResourceGroupName -Location $LocationName -VM $VirtualMachine -Verbose



   for ($i=1; $i -le 2; $i++)
{
    New-AzVm `
        -ResourceGroupName $RG `
        -Name "Internal$i" `
        -Location $Location `
        -Size $VMSize `
        -VirtualNetworkName $VNetName `
        -SubnetName $SubnetName `
        -SecurityGroupName "myNetworkSecurityGroup" `
        -PublicIpAddressName "myPublicIpAddress$i" `
        -AvailabilitySetName $AVset `
        -Credential $cred
}

