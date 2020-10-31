# To get a list of resources and resoucegroup names
Get-AzureRmResource
# To check the access
$r = Get-AzureRMResource -ResourceName <NAME_OF_RESOURCE> -ResourceGroupName <YOUR_COPIED_INFORMATION>
# Setting Tags
Set-AzureRMResource -Tag @{Department = "Engineering";Environment = "Dev"} -ResourceName $r.ResourceID