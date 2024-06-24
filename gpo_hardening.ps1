# Create default AppLocker policy
$defaultExePolicy = Get-AppLockerFileInformation -Directory "C:\Windows\System32" |  New-AppLockerPolicy -RuleType Path -User Everyone -Xml

# Save the policy to a file
$xmlPath = "C:\Temp\DefaultAppLockerPolicy.xml"
$defaultExePolicy.Save($xmlPath)

# Load the XML policy
[xml]$appLockerPolicy = Get-Content $xmlPath
$exeRuleCollection = $appLockerPolicy.SelectSingleNode("//RuleCollection[@Type='Exe']")

# Define LOLBins to block
$lolbins = @(
    "C:\Windows\System32\mshta.exe",
    "C:\Windows\System32\certutil.exe",
    "C:\Windows\System32\regsvr32.exe"
)

# Add rules to block LOLBins
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

# Save the modified policy
$appLockerPolicy.Save($xmlPath)

# Import the Group Policy module
Import-Module GroupPolicy

# Create a new GPO
$gpoName = "Default AppLocker Policy with LOLBins"
New-GPO -Name $gpoName

# Get the GPO object
$gpo = Get-GPO -Name $gpoName

# Import the AppLocker policy into the GPO
Import-GPO -Path $xmlPath -TargetName $gpoName -CreateIfNeeded
