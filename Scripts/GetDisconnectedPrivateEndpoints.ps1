#Look for Private Endpoints that are not connected
#Version 1.0
#Changelog - 10/2025 - 1.0 - creation


#Login steps example
Connect-AzAccount



# Get all subscriptions
$subscriptions = Get-AzSubscription

$count = 0
$totalPEs = 0
$results = @()

# List of subscription names to exclude (case-insensitive)
$excludedNames = @(
    "Azure subscription 1",
    "Visual Studio Enterprise Subscription",
    "Visual Studio Professional Subscription",
    "Basic Free Subscription",
    "Azure for Students"#,
    #"Dev Environment"
) | ForEach-Object { $_.ToLower() }

# Loop through each subscription and check the provider registration
foreach ($sub in $subscriptions) {
    if ($sub.State -ne "Enabled") {
        Write-Host "Skipping subscription: $($sub.Name) [$($sub.Id)] - State: $($sub.State)" -ForegroundColor DarkGray
        continue
    }
    # Skip subscriptions with names in the exclusion list (case-insensitive)
    if ($excludedNames -contains $sub.Name.ToLower()) {
        Write-Host "Skipping subscription: $($sub.Name) [$($sub.Id)] - Name matches exclusion list" -ForegroundColor DarkGray
        continue
    }
    Write-Host "Checking subscription: $($sub.Name) [$($sub.Id)]" -ForegroundColor Cyan
    Set-AzContext -SubscriptionId $sub.Id | Out-Null

    $privateEndpoints = Get-AzPrivateEndpoint

    foreach ($pe in $privateEndpoints) {
        #write-host $pe.NetworkInterfaces[0].IpConfigurations[0].PrivateIpAddress
        $totalPEs++
        $connectionsText = $pe.privatelinkserviceconnectionstext
        $connections = $connectionsText | ConvertFrom-Json
        $pestatus = $connections.privatelinkserviceconnectionstate.status
        $groupid = $connections.GroupIds
        $peNic = $pe.networkinterfacestext | convertfrom-json
        $nicId = $peNic.Id
        $nic = Get-AzNetworkInterface -ResourceId $nicId
        $resourceId = $pe.privatelinkserviceconnections.privatelinkserviceid
        $resourceName = ($resourceId -split "/")[-1]
        if ($pestatus -ne "Approved") {
            $count++
            $results += [PSCustomObject]@{
                Subscription      = $sub.Name
                Name              = $pe.Name
                Status            = $pestatus
                PrivateIP         = $nic.IpConfigurations.privateipaddress
                ResourceName      = $resourceName
                GroupId           = $groupid
                ResourceGroupName = $pe.ResourceGroupName
                Location          = $pe.location
            }
            #write-host $pe.Name, $pestatus, $nic.IpConfigurations.privateipaddress, $resourceName,  $groupid, $pe.ResourceGroupName, $pe.location -ForegroundColor DarkGray | format-table -autosize
        }
    }   
}
$results | Format-Table -AutoSize
write-host "Total PEs $totalPEs"
write-host "PEs with issues $count"
