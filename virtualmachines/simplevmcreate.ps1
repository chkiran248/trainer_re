# Variables for common values
$resourceGroup = "myResourceGroup"
$location = "centralindia"
$vmName = "myVM"

# Create user object
$cred = Get-Credential -Message "Enter a username and password for the virtual machine."

# Create a resource group
New-AzResourceGroup -Name $resourceGroup -Location $location

# Create a virtual machine
New-AzVM `
  -ResourceGroupName $resourceGroup `
  -Name $vmName `
  -Location $location `
  -Image "Win2016Datacenter" `
  -VirtualNetworkName "myVnet" `
  -SubnetName "mySubnet" `
  -SecurityGroupName "myNetworkSecurityGroup" `
  -PublicIpAddressName "myPublicIp" `
  -Credential $cred `
  -OpenPorts 3389
  
# Active Directory


$newSubnetParams = @{ 'Name' = 'NetWatchSubnet'; 'AddressPrefix' = '10.0.0.0/24' } 
$subnet = New-AzureRmVirtualNetworkSubnetConfig @newSubnetParams


New-AzResourceGroup -Name Oct2020 -Location centralindia
$cred = Get-Credential -Message "Enter a username and password for the virtual machine."
$vmParams = @{
  ResourceGroupName = 'Oct2020'
  Name = 'dc1'
  Location = 'centralindia'
  ImageName = 'Win2016Datacenter'
  PublicIpAddressName = 'tutorialPublicIp'
  Credential = $cred
  OpenPorts = 3389
}
$newVM1 = New-AzVM @vmParams

$newVM1.OSProfile | Select-Object ComputerName,AdminUserName

$newVM1 | Get-AzNetworkInterface |
  Select-Object -ExpandProperty IpConfigurations |
    Select-Object Name,PrivateIpAddress

$publicIp = Get-AzPublicIpAddress -Name tutorialPublicIp -ResourceGroupName TutorialResources
$publicIp | Select-Object Name,IpAddress,@{label='FQDN';expression={$_.DnsSettings.Fqdn}}

$vm2Params = @{
  ResourceGroupName = 'Oct2020'
  Name = 'member1'
  ImageName = 'Win2016Datacenter'
  VirtualNetworkName = 'dc1'
  SubnetName = 'TutorialVM1'
  PublicIpAddressName = 'tutorialPublicIp2'
  Credential = $cred
  OpenPorts = 3389
}
$newVM2 = New-AzVM @vm2Params

$newVM2

$job = Remove-AzResourceGroup -Name TutorialResources -Force -AsJob

$job
