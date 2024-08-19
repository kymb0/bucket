# Import necessary modules
Import-Module GroupPolicy

# Define GPO names and OUs
$UserGPOName = "Firewall Rules for All Users"
$AdminGPOName = "Firewall Rules for Admins"
$UserOUPath = "OU=Users,DC=umbrellacorp,DC=local"
$AdminOUPath = "OU=Admins,DC=umbrellacorp,DC=local"

# Create or retrieve the User GPO
$UserGPO = Get-GPO -Name $UserGPOName -ErrorAction SilentlyContinue
if (-not $UserGPO) {
    $UserGPO = New-GPO -Name $UserGPOName -Comment "Block specific firewall settings for all users"
}

# Create or retrieve the Admin GPO
$AdminGPO = Get-GPO -Name $AdminGPOName -ErrorAction SilentlyContinue
if (-not $AdminGPO) {
    $AdminGPO = New-GPO -Name $AdminGPOName -Comment "Allow certain firewall settings for admins"
}

# Link the GPOs to the designated OUs
New-GPLink -Name $UserGPOName -Target $UserOUPath
New-GPLink -Name $AdminGPOName -Target $AdminOUPath

# Define firewall rules as an array of custom objects for users
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
    @{Name="Block ICMP"; Protocol="ICMPv4"; Direction="Outbound"; Action="Block"},
    @{Name="Block Outbound RDP Traffic"; Protocol="TCP"; Port="3389"; Direction="Outbound"; Action="Block"}
)

# Function to construct firewall rule registry value strings
function Construct-RegistryValue {
    param (
        [string]$Name,
        [string]$Direction,
        [string]$Action,
        [string]$Profile,
        [string]$Protocol,
        [string]$Port,
        [string]$Address
    )
    
    # Initialize the base rule string
    $ruleString = "v2.24|$Name|$Direction|$Action|"
    
    # Add profile if provided
    if ($Profile) { 
        $ruleString += "$Profile|"
    } else {
        $ruleString += "|"
    }
    
    # Add protocol
    $ruleString += "$Protocol|$Port|$Address|@FirewallAPI.dll,-28502"
    
    return $ruleString
}

# Add rules to the User GPO
foreach ($rule in $firewallRules) {
    $registryValue = Construct-RegistryValue -Name $rule.Name -Direction $rule.Direction -Action $rule.Action -Profile $rule.Profile -Protocol $rule.Protocol -Port $rule.Port -Address $rule.Address
    New-GPRegistryValue -Name $UserGPOName -Key "HKLM\Software\Policies\Microsoft\WindowsFirewall\FirewallRules" -ValueName $rule.Name -Type String -Value $registryValue
}

# Add inverse rules to the Admin GPO (allow instead of block)
foreach ($rule in $firewallRules) {
    # Convert the block action to allow
    $inverseAction = if ($rule.Action -eq "Block") { "Allow" } else { $rule.Action }
    $registryValue = Construct-RegistryValue -Name $rule.Name -Direction $rule.Direction -Action $inverseAction -Profile $rule.Profile -Protocol $rule.Protocol -Port $rule.Port -Address $rule.Address
    New-GPRegistryValue -Name $AdminGPOName -Key "HKLM\Software\Policies\Microsoft\WindowsFirewall\FirewallRules" -ValueName $rule.Name -Type String -Value $registryValue
}

# Apply and update GPOs on client and admin machines
Invoke-GPUpdate -Force
