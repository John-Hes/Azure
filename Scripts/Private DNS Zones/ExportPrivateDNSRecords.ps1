#Export Azure Private DNS Zones
#Version 1.0
#Changelog - 10/2025 - 1.0 - creation


#Login steps example
#Connect-AzAccount

$subscription = "SubWithThePrivateDNSZones"
$resourceGroup = "RGWithThePrivateDNSZones"

# Get all private DNS zones in the resource group
Set-AzContext -Subscription $subscription
$zones = Get-AzPrivateDnsZone -ResourceGroupName $resourceGroup


$allRecords = @()

foreach ($zone in $zones) {
    write-host $zone.Name
    $records = Get-AzPrivateDnsRecordSet -ResourceGroupName $resourceGroup -ZoneName $zone.Name
    foreach ($record in $records) {
        $allRecords += [PSCustomObject]@{
            ZoneName     = $zone.Name
            RecordName   = $record.Name
            RecordType   = $record.RecordType
            Records      = ($record.Records | ForEach-Object { $_.Ipv4Address, $_.Ipv6Address, $_.Value } | Where-Object { $_ }) -join ";"
            Ttl          = $record.Ttl
        }
    }
}

# Export to CSV
$allRecords | Export-Csv -Path "C:\Azure\Backup\Private DNS Entries\PrivateDNSEntries-$(Get-Date -Format "yyyy-MM-dd").csv" -NoTypeInformation
Write-Output "All DNS records have been exported to C:\Azure\Backup\Private DNS Entries\PrivateDNSEntries-$(Get-Date -Format "yyyy-MM-dd").csv"
