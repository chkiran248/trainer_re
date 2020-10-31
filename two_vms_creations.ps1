# VM Details
$RG = "RG25102020"
$Location = "CentralIndia"
$AVset = "AVset"
$VMSize = "Standard_B1s"
$VNetName = "STGVNet"

$VnetAddressPrefix = "20.0.0.0/16"

$SubnetName = "STGSubNet"
$SubnetAddressPrefix = "20.0.0.0/24"


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

