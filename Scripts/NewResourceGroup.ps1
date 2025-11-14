#Azure Resource Group Deployment
#Version 1.0
#Changelog - 1/2025 - 1.0 - creation
#          - 10/2025 - 1.1 - new tagging standard added


#Login steps example
#Connect-AzAccount


#Set these variables
#values should be in lowercase
$sub = 'sub1'
$region = 'eastus2'
$app = 'testrg'
#tags
$dep = "Infrastructure"
$env = "prod"
$owner = "Infrastructure"
$project = "Testing RGs"
$entity = "Company"
$dataclass = "Sensitive"


#region mapping
$changeMap = @{ 
    "eastus" = "use"
    "eastus2" = "use2"
    "centralus" = "usc"
    "southcentralus" = "ussc"
    "northcentralus" = "usnc"
    "westus" = "usw"
    "westus2" = "usw2"
    "westus3" = "usw3"
}

if ($changeMap.ContainsKey($region)) { 
    # Change the value if it matches 
    $regionPref = $changeMap[$region]
    Write-host $regionPref
}
else{
    Write-host "Region Not Found"
    exit
}

#az account show
$subscriptionName = $sub.ToLower()
Set-AzContext "$subscriptionName"
#az account set -s copilot staging


#Static Variables - dont usually change
$rgName = $regionPref + '-' + $subscriptionName + '-' + $app + '-rg'
$theDate = get-date
$tags = @{Creator=$env:UserName; 'Creation Date'=$theDate}


#create RG if it does not exist
$rgtags = @{Creator=$env:UserName; 'Creation Date'=$theDate; Department=$dep; Environment=$env; Owner=$owner; Project=$project; Entity=$entity; DataClassification=$dataclass}
$existingResourceGroup = Get-AzResourceGroup | Where-Object { $_.ResourceGroupName -eq $rgName } | Select-Object -First 1
if ($existingResourceGroup) {
    Write-Host "Resource group '$rgName' exists."
} else {
    Write-Host "Resource group '$rgName' does not exist."
    New-AzResourceGroup -name $rgName -location $region -Tag $rgtags 
}
