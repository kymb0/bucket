# Requires running as Administrator and the GroupPolicy and AppLocker PowerShell modules

# Check and Import the necessary modules
$requiredModules = @("GroupPolicy", "AppLocker")
foreach ($module in $requiredModules) {
    if (-not (Get-Module -ListAvailable -Name $module)) {
        Write-Error "Module $module is not installed. Please install it before proceeding."
        return
    }
    Import-Module $module
}

# Create a new GPO
$gpoName = "Secure Environment Policy"
New-GPO -Name $gpoName -Comment "This policy configures AppLocker and Constrained Language Mode, and blocks specific LOLBins"
$gpo = Get-GPO -Name $gpoName

# Set up base AppLocker policy with default rules
$policy = Get-AppLockerPolicy -Default
Set-AppLockerPolicy -PolicyObject $policy -GpoName $gpoName

# Add rules to block specific LOLBins, except allowed ones
$lolbins = @("msbuild.exe", "powershell.exe", "cscript.exe", "wscript.exe", "regsvr32.exe", "rundll32.exe")
$allowedLolbins = @("MSHTA.exe") # Define exceptions here

foreach ($lolbin in $lolbins) {
    if ($allowedLolbins -notcontains $lolbin) {
        $rule = New-Object -TypeName Microsoft.Security.ApplicationId.PolicyManagement.PolicyModel.ExeRule
        $rule.Id = [Guid]::NewGuid()
        $rule.Name = "Block $lolbin"
        $rule.Description = "Blocks the $lolbin from executing"
        $rule.Action = "Deny"
        $rule.UserOrGroupSid = "S-1-1-0"  # This SID represents "Everyone"
        $rule.ApplicationPath = "%WINDIR%\System32\$lolbin"
        $policy.RuleCollection.Add($rule)
    }
}

# Save the updated policy back to the GPO
Set-AppLockerPolicy -PolicyObject $policy -GpoName $gpoName

# Set PowerShell Constrained Language Mode via GPO (Registry Setting)
$registryPath = "HKLM:\Software\Policies\Microsoft\Windows\PowerShell"
$registryKeyName = "LanguageMode"
$registryValue = "ConstrainedLanguage"
New-GPRegistryValue -Name $gpoName -Key $registryPath -ValueName $registryKeyName -Type String -Value $registryValue -Action Update

# Output a success message
Write-Host "GPO Created and configured successfully with additional LOLBin blocking rules and exceptions."
