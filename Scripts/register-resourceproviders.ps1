#Resource Providers should be enabled on all subscriptions
#Version 1.0
#Changelog - 7/2025 - 1.0 - creation
#uploaded 12/2025

#Login steps example
Connect-AzAccount

#Set these variables
$rpsToCheck = @(
    "Microsoft.Compute",
    "Microsoft.Network"
    # Add other features here as needed, for example:
    # "Microsoft.Network",
    # "SpotVMPreview"
)

$featuresToCheck = @{
    "Microsoft.Compute" = @("EncryptionAtHost")#,
    # Add other features here as needed, for example:
    # "UltraSSDEnabled",
    # "SpotVMPreview"
}

# List of subscription names to exclude (case-insensitive)
$excludedNames = @(
    "Azure subscription 1",
    "Visual Studio Enterprise Subscription",
    "Visual Studio Professional Subscription",
    "Basic Free Subscription",
    "Azure for Students"#,
    #"Dev Environment"
) | ForEach-Object { $_.ToLower() }

# Get all subscriptions
$subscriptions = Get-AzSubscription

$count = 0

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

    foreach ($rp in $rpsToCheck) {
        $provider = Get-AzResourceProvider -ProviderNamespace $rp
        if ($provider.RegistrationState -ne "Registered") {
            Write-Host "  '$rp' is NOT registered." -ForegroundColor Red
            $count +=1
            Write-Host "  Registering $rp resource provider..." -ForegroundColor Magenta
            Register-AzResourceProvider -ProviderNamespace $rp #| Out-Null
        }
        if ($featuresToCheck.ContainsKey($rp)) {
            foreach ($feat in $featuresToCheck[$rp]) {
                $feature = Get-AzProviderFeature -ProviderNamespace $rp -FeatureName $feat -ErrorAction SilentlyContinue
                if ($feature.RegistrationState -ne "Registered") {
                        Write-Host "  Feature '$feat' is NOT registered. State: $($feature.RegistrationState)" -ForegroundColor Red
                        $count +=1
                        Write-Host "    Attempting to register feature '$featureName'..." -ForegroundColor Magenta
                        Register-AzProviderFeature -FeatureName $feat -ProviderNamespace $rp
                }
            }
        }
    }
}
Write-Host "Total rps/features missing: $count"
