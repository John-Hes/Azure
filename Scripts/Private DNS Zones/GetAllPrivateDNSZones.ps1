#basic script to check for private dns zones.  Was checking for any that we may need and are missing but could use an upgrade to this script
#Connect-AzAccount
login-azaccount
#get-azcontext

$subscription = "SubWithThePrivateDNSZones"
$resourceGroup = "RGWithThePrivateDNSZones"

set-azcontext $subscription
$zones = Get-AzPrivateDnsZone -ResourceGroupName $resourceGroup
#$zones.Name
#$zones.NumberOfVirtualNetworkLinksWithRegistration
foreach ($zone in $zones) {
    $links = Get-AzPrivateDnsVirtualNetworkLink -ResourceGroupName $resourceGroup -zonename $zone.name
    $zone.Name
    $links.Name
    $links.VirtualNetworkId
    $links.RegistrationEnabled
    $links.VirtualNetworkLinkState
    $links.ProvisioningState
    Write-Host ------------------------------------------------------------------------
}
