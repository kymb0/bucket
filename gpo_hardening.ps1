# Ensure the Group Policy module is installed
Install-WindowsFeature -Name GPMC

# Create the default AppLocker policy
$xmlPath = "C:\Temp\DefaultAppLockerPolicy.xml"
New-AppLockerPolicy -Default -Xml $xmlPath

# Add custom rules to block LOLBins (Example: mshta.exe)
[xml]$appLockerPolicy = Get-Content $xmlPath
$exeRuleCollection = $appLockerPolicy.SelectSingleNode("//RuleCollection[@Type='Exe']")

$lolbins = @(
    "C:\Windows\System32\mshta.exe",
    "C:\Windows\System32\certutil.exe",
    "C:\Windows\System32\regsvr32.exe"
)

foreach ($lolbin in $lolbins) {
    $newRule = $exeRuleCollection.OwnerDocument.CreateElement("FilePathRule")
    $newRule.SetAttribute("Id", [guid]::NewGuid().ToString())
    $newRule.SetAttribute("Name", "Block " + [System.IO.Path]::GetFileName($lolbin))
    $newRule.SetAttribute("Description", "Block " + [System.IO.Path]::GetFileName($lolbin))
    $newRule.SetAttribute("UserOrGroupSid", "S-1-1-0")
    $newRule.SetAttribute("Action", "Deny")

    $conditions = $newRule.OwnerDocument.CreateElement("Conditions")
    $filePathCondition = $newRule.OwnerDocument.CreateElement("FilePathCondition")
    $filePathCondition.SetAttribute("Path", $lolbin)
    $conditions.AppendChild($filePathCondition)
    $newRule.AppendChild($conditions)

    $exeRuleCollection.AppendChild($newRule)
}

$appLockerPolicy.Save($xmlPath)

# Import the Group Policy module
Import-Module GroupPolicy

# Create a new GPO
$gpoName = "Secure Environment Policy"
New-GPO -Name $gpoName

# Get the GPO object
$gpo = Get-GPO -Name $gpoName

# Import the AppLocker policy into the GPO
Import-GPO -Path $xmlPath -TargetName $gpoName -CreateIfNeeded
