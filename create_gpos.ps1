# Import necessary modules
Import-Module GroupPolicy

# Define GPO names
$baselineGpoName = "BaselinePolicy"
$dcGpoName = "DomainControllerPolicy"
$dbGpoName = "DatabaseServerPolicy"
$webServerGpoName = "WebServerPolicy"
$clientGpoName = "ClientPolicy"
$sccmGpoName = "SCCMPolicy"

# Create Baseline GPO
$baselineGpo = New-GPO -Name $baselineGpoName

# Set common settings in Baseline GPO
# Configure Firewall to be on with default rules
Set-GPRegistryValue -Name $baselineGpoName -Key "HKLM\Software\Policies\Microsoft\WindowsFirewall\DomainProfile" -ValueName "EnableFirewall" -Type DWORD -Value 1
Set-GPRegistryValue -Name $baselineGpoName -Key "HKLM\Software\Policies\Microsoft\WindowsFirewall\PrivateProfile" -ValueName "EnableFirewall" -Type DWORD -Value 1
Set-GPRegistryValue -Name $baselineGpoName -Key "HKLM\Software\Policies\Microsoft\WindowsFirewall\PublicProfile" -ValueName "EnableFirewall" -Type DWORD -Value 1

# Allow SQL Server traffic on port 1433
Invoke-Command {
    netsh advfirewall firewall add rule name="Allow SQL Server" dir=in action=allow protocol=TCP localport=1433
}

# Enforce Constrained Language Mode for PowerShell
Set-GPRegistryValue -Name $baselineGpoName -Key "HKLM\Software\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging" -ValueName "EnableScriptBlockLogging" -Type DWORD -Value 1
Set-GPRegistryValue -Name $baselineGpoName -Key "HKLM\Software\Policies\Microsoft\Windows\PowerShell" -ValueName "EnableScriptBlockInvocationLogging" -Type DWORD -Value 1

# Create specific GPOs for each role
$dcGpo = New-GPO -Name $dcGpoName
$dbGpo = New-GPO -Name $dbGpoName
$webServerGpo = New-GPO -Name $webServerGpoName
$clientGpo = New-GPO -Name $clientGpoName
$sccmGpo = New-GPO -Name $sccmGpoName

# Specific settings for Domain Controllers
Set-GPRegistryValue -Name $dcGpoName -Key "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" -ValueName "fDenyTSConnections" -Type DWORD -Value 1

# Specific settings for Database Servers
Set-GPRegistryValue -Name $dbGpoName -Key "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" -ValueName "fDenyTSConnections" -Type DWORD -Value 1

# Specific settings for Web Servers
Invoke-Command {
    netsh advfirewall firewall add rule name="Allow Web Traffic" dir=in action=allow protocol=TCP localport=80
    netsh advfirewall firewall add rule name="Allow Web Traffic" dir=in action=allow protocol=TCP localport=443
}

# Apply Baseline GPO to the domain
New-GPLink -Name $baselineGpoName -Target "DC=yourdomain,DC=com"

# Link specific GPOs to appropriate OUs
New-GPLink -Name $dcGpoName -Target "OU=DomainControllers,DC=yourdomain,DC=com"
New-GPLink -Name $dbGpoName -Target "OU=DatabaseServers,DC=yourdomain,DC=com"
New-GPLink -Name $webServerGpoName -Target "OU=WebServers,DC=yourdomain,DC=com"
New-GPLink -Name $clientGpoName -Target "OU=Clients,DC=yourdomain,DC=com"
New-GPLink -Name $sccmGpoName -Target "OU=SCCM,DC=yourdomain,DC=com"
