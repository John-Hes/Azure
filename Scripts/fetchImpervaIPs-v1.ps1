#Select the NSG
$subscriptionName = 'subname'
$rg = 'resourcegroup'
$nsgName = 'nsg'

#Connect-AzAccount
Set-AzContext "$subscriptionName"

# Fetch the IPs from Imperva and save to a file
Invoke-RestMethod -Uri "https://my.imperva.com/api/integration/v1/ips" -Method Post -Body "resp_format=json" | 
    ConvertTo-Json -Depth 5 | 
    Set-Content -Path "c:\temp\imperva-ips.json"


# Get the NSG and display its rules
$nsg = Get-AzNetworkSecurityGroup -ResourceGroupName $rg -Name $nsgName
#$nsg.SecurityRules
#$nsg.DefaultSecurityRules
# Export custom and default rules to JSON
$nsg.SecurityRules | ConvertTo-Json -Depth 5 | Set-Content -Path "C:\temp\nsg-custom-rules.json"
#$nsg.DefaultSecurityRules | ConvertTo-Json -Depth 5 | Set-Content -Path "C:\temp\nsg-default-rules.json"

# Load NSG rules and Imperva IPs
$nsgRules = Get-Content "C:\temp\nsg-custom-rules.json" | ConvertFrom-Json
$impervaIPs = Get-Content "C:\temp\imperva-ips.json" | ConvertFrom-Json

# Get all allowed source IPs/ranges from NSG
$nsgAllowedIPs = $nsgRules | ForEach-Object {
    if ($_.SourceAddressPrefixes) {
        $_.SourceAddressPrefixes
    } else {
        $_.SourceAddressPrefix
    }
}

# Get Imperva IPs
$impervaIPRanges = $impervaIPs.ipRanges + $impervaIPs.ipv6Ranges


$missingIPs = $impervaIPRanges | Where-Object { $_ -notin $nsgAllowedIPs }


if ($missingIPs) {
    Write-Output "The following Imperva IPs are NOT allowed by your NSG rules:"
    $missingIPs
} else {
    Write-Output "All Imperva IPs are currently allowed by your NSG rules."
}
