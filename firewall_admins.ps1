# Import necessary modules
Import-Module GroupPolicy

# Define GPO name and OU where admin accounts reside
$GPOName = "Firewall Rules for Admins"
$AdminOUPath = "OU=Admins,DC=umbrellacorp,DC=local"

# Create a new GPO for Admins
New-GPO -Name $GPOName -Comment "Manage firewall settings for admin accounts"
# Link the GPO to the designated OU for Admins
New-GPLink -Name $GPOName -Target $AdminOUPath

# Path to configure Firewall Rules
$GPOPath = "Computer Configuration\Policies\Windows Settings\Security Settings\Windows Defender Firewall with Advanced Security"

# Define firewall rules as an array of custom objects to ALLOW traffic
$firewallRules = @(
    @{Name="Allow All FTP Traffic"; Protocol="TCP"; Port="21"; Direction="Outbound"; Action="Allow"},
    @{Name="Allow All SSH Traffic"; Protocol="TCP"; Port="22"; Direction="Outbound"; Action="Allow"},
    @{Name="Allow All DNS Requests"; Protocol="UDP"; Port="53"; Direction="Outbound"; Action="Allow"},
    @{Name="Allow All HTTP and HTTPS to Domain"; Protocol="TCP"; Port="80,443"; Profile="Domain"; Direction="Outbound"; Action="Allow"},
    @{Name="Allow All HTTP and HTTPS Traffic"; Protocol="TCP"; Port="80,443"; Profile="Private,Public"; Direction="Outbound"; Action="Allow"},
    @{Name="Allow All SMB Traffic"; Protocol="TCP"; Port="445"; Direction="Outbound"; Action="Allow"},
    @{Name="Allow All Telnet Traffic"; Protocol="TCP"; Port="23"; Direction="Outbound"; Action="Allow"},
    @{Name="Allow All TFTP Traffic"; Protocol="UDP"; Port="69"; Direction="Outbound"; Action="Allow"},
    @{Name="Allow All SNMP Traffic"; Protocol="UDP"; Port="161"; Direction="Outbound"; Action="Allow"},
    @{Name="Allow All NFS Traffic"; Protocol="TCP"; Port="2049"; Direction="Outbound"; Action="Allow"},
    @{Name="Allow All ICMP Traffic"; Protocol="ICMPv4"; Direction="Outbound"; Action="Allow"},
    @{Name="Allow All RDP Traffic"; Protocol="TCP"; Port="3389"; Direction="Outbound"; Action="Allow"}
)

# Add each rule to the GPO using the same loop as before
foreach ($rule in $firewallRules) {
    $cmd = "netsh advfirewall firewall add rule name=`"$($rule.Name)`" dir=$($rule.Direction) action=$($rule.Action) protocol=$($rule.Protocol)"
    if ($rule.Port) { $cmd += " localport=$($rule.Port)" }
    if ($rule.Profile) { $cmd += " profile=$($rule.Profile)" }
    Invoke-Command -ScriptBlock { param($cmd) Invoke-Expression $cmd } -ArgumentList $cmd
}

# Apply and update GPO settings
Invoke-GPUpdate -Force
