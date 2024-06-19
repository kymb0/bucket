# Requires running as Administrator and the GroupPolicy and AppLocker PowerShell modules

# Import the necessary modules
Import-Module GroupPolicy
Import-Module AppLocker

# Create a new GPO
$gpoName = "Secure Environment Policy"
New-GPO -Name $gpoName -Comment "This policy configures AppLocker and Constrained Language Mode, and blocks specific LOLBins"
$gpo = Get-GPO -Name $gpoName

# Set up base AppLocker policy with default rules
$policy = New-Object -TypeName Microsoft.Security.ApplicationId.PolicyManagement.PolicyModel.Policy
$policy = Get-AppLockerPolicy -Default
Set-AppLockerPolicy -PolicyObject $policy -GpoName $gpoName

# Add rules to block specific LOLBins
$lolbins = @("msbuild.exe", "powershell.exe", "cscript.exe", "wscript.exe", "regsvr32.exe", "rundll32.exe")

foreach ($lolbin in $lolbins) {
    $rule = New-Object -TypeName Microsoft.Security.ApplicationId.PolicyManagement.PolicyModel.ExeRule
    $rule.Id = [Guid]::NewGuid()
    $rule.Name = "Block $lolbin"
    $rule.Description = "Blocks the $lolbin from executing"
    $rule.Action = "Deny"
    $rule.UserOrGroupSid = "S-1-1-0"  # This SID represents "Everyone"
    $rule.ApplicationPath = "%WINDIR%\System32\$lolbin"
    $policy.RuleCollection.Add($rule)
}

# Save the updated policy back to the GPO
Set-AppLockerPolicy -PolicyObject $policy -GpoName $gpoName

# Set PowerShell Constrained Language Mode via GPO (Registry Setting)
$registryPath = "HKLM:\Software\Policies\Microsoft\Windows\PowerShell"
$registryKeyName = "LanguageMode"
$registryValue = "ConstrainedLanguage"
New-GPRegistryValue -Name $gpoName -Key $registryPath -ValueName $registryKeyName -Type String -Value $registryValue -Action Update

# Output a success message
Write-Host "GPO Created and configured successfully with additional LOLBin blocking rules."
