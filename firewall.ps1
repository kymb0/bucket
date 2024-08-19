# Import necessary modules
Import-Module GroupPolicy

# Define GPO name and OU
$GPOName = "Firewall Rules for All Users"
$OUPath = "OU=Users,DC=umbrellacorp,DC=local"

# Create a new GPO
New-GPO -Name $GPOName -Comment "Manage firewall settings for all users"
# Link the GPO to the designated OU
New-GPLink -Name $GPOName -Target $OUPath

# Path to configure Firewall Rules
$GPOPath = "Computer Configuration\Policies\Windows Settings\Security Settings\Windows Firewall with Advanced Security"

# Define firewall rules as an array of custom objects
$firewallRules = @(
    @{Name="Block FTP Traffic"; Protocol="TCP"; Port="21"; Direction="Outbound"; Action="Block"},
    @{Name="Block SSH Traffic"; Protocol="TCP"; Port="22"; Direction="Outbound"; Action="Block"},
    @{Name="Allow DNS to Specific Server"; Protocol="UDP"; Port="53"; Address="192.168.66.1"; Direction="Outbound"; Action="Allow"},
    @{Name="Block Other DNS"; Protocol="UDP"; Port="53"; Direction="Outbound"; Action="Block"},
    @{Name="Allow HTTP to Domain"; Protocol="TCP"; Port="80"; Profile="Domain"; Direction="Outbound"; Action="Allow"},
    @{Name="Allow HTTPS to Domain"; Protocol="TCP"; Port="443"; Profile="Domain"; Direction="Outbound"; Action="Allow"},
    @{Name="Block HTTP to Non-Domain"; Protocol="TCP"; Port="80"; Profile="Private,Public"; Direction="Outbound"; Action="Block"},
    @{Name="Block HTTPS to Non-Domain"; Protocol="TCP"; Port="443"; Profile="Private,Public"; Direction="Outbound"; Action="Block"},
    @{Name="Allow SMB Internally"; Protocol="TCP"; Port="445"; Address="192.168.66.0/24"; Direction="Outbound"; Action="Allow"},
    @{Name="Block External SMB"; Protocol="TCP"; Port="445"; Profile="Public,Private"; Direction="Outbound"; Action="Block"},
    @{Name="Block Telnet"; Protocol="TCP"; Port="23"; Direction="Outbound"; Action="Block"},
    @{Name="Block TFTP"; Protocol="UDP"; Port="69"; Direction="Outbound"; Action="Block"},
    @{Name="Block SNMP"; Protocol="UDP"; Port="161"; Direction="Outbound"; Action="Block"},
    @{Name="Block NFS"; Protocol="TCP"; Port="2049"; Direction="Outbound"; Action="Block"},
    @{Name="Block ICMP"; Protocol="ICMPv4"; Direction="Outbound"; Action="Block"}
    @{Name="Block Outbound RDP Traffic"; Protocol="TCP"; Port="3389"; Direction="Outbound"; Action="Block"}
)
)

# Add each rule to the GPO
foreach ($rule in $firewallRules) {
    $cmd = "netsh advfirewall firewall add rule name=`"$($rule.Name)`" dir=$($rule.Direction) action=$($rule.Action) protocol=$($rule.Protocol)"
    if ($rule.Port) { $cmd += " localport=$($rule.Port)" }
    if ($rule.Address) { $cmd += " remoteip=$($rule.Address)" }
    if ($rule.Profile) { $cmd += " profile=$($rule.Profile)" }
    Invoke-GPUpdate -RandomDelayInMinutes 0 -Cmd $cmd -PolicyStore (Get-GPO -Name $GPOName).Id
}

# Apply and update GPO
Invoke-GPUpdate -Force
