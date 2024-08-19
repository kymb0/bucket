# Import necessary modules
Import-Module GroupPolicy

# Define GPO names and the Workstations OU
$UserGPOName = "Firewall Rules for All Users"
$AdminGPOName = "Firewall Rules for Admins"
$WorkstationsOUPath = "OU=Workstations,DC=umbrellacorp,DC=local"

# Create or retrieve the User GPO
$UserGPO = Get-GPO -Name $UserGPOName -ErrorAction SilentlyContinue
if (-not $UserGPO) {
    $UserGPO = New-GPO -Name $UserGPOName -Comment "Block specific firewall settings for all users"
}

# Create or retrieve the Admin GPO
$AdminGPO = Get-GPO -Name $AdminGPOName -ErrorAction SilentlyContinue
if (-not $AdminGPO) {
    $AdminGPO = New-GPO -Name $AdminGPOName -Comment "Allow specific firewall settings for admins"
}

# Link the GPOs to the Workstations OU
New-GPLink -Name $UserGPOName -Target $WorkstationsOUPath
New-GPLink -Name $AdminGPOName -Target $WorkstationsOUPath

# Define firewall rules as an array of custom objects for users (Blocking)
$firewallRules = @(
    @{Name="Block FTP Traffic"; Protocol="TCP"; LocalPort="21"; Direction="Outbound"; Action="Block"},
    @{Name="Block SSH Traffic"; Protocol="TCP"; LocalPort="22"; Direction="Outbound"; Action="Block"},
    @{Name="Allow DNS to Specific Server"; Protocol="UDP"; LocalPort="53"; RemoteAddress="192.168.66.1"; Direction="Outbound"; Action="Allow"},
    @{Name="Block Other DNS"; Protocol="UDP"; LocalPort="53"; Direction="Outbound"; Action="Block"},
    @{Name="Allow HTTP to Domain"; Protocol="TCP"; LocalPort="80"; Profile="Domain"; Direction="Outbound"; Action="Allow"},
    @{Name="Allow HTTPS to Domain"; Protocol="TCP"; LocalPort="443"; Profile="Domain"; Direction="Outbound"; Action="Allow"},
    @{Name="Block HTTP to Non-Domain"; Protocol="TCP"; LocalPort="80"; Profile="Private,Public"; Direction="Outbound"; Action="Block"},
    @{Name="Block HTTPS to Non-Domain"; Protocol="TCP"; LocalPort="443"; Profile="Private,Public"; Direction="Outbound"; Action="Block"},
    @{Name="Allow SMB Internally"; Protocol="TCP"; LocalPort="445"; RemoteAddress="192.168.66.0/24"; Direction="Outbound"; Action="Allow"},
    @{Name="Block External SMB"; Protocol="TCP"; LocalPort="445"; Profile="Public,Private"; Direction="Outbound"; Action="Block"},
    @{Name="Block Telnet"; Protocol="TCP"; LocalPort="23"; Direction="Outbound"; Action="Block"},
    @{Name="Block TFTP"; Protocol="UDP"; LocalPort="69"; Direction="Outbound"; Action="Block"},
    @{Name="Block SNMP"; Protocol="UDP"; LocalPort="161"; Direction="Outbound"; Action="Block"},
    @{Name="Block NFS"; Protocol="TCP"; LocalPort="2049"; Direction="Outbound"; Action="Block"},
    @{Name="Block ICMP"; Protocol="ICMPv4"; Direction="Outbound"; Action="Block"},
    @{Name="Block Outbound RDP Traffic"; Protocol="TCP"; LocalPort="3389"; Direction="Outbound"; Action="Block"}
)

# Function to construct registry values for firewall rules
function Construct-FirewallRegistryValue {
    param (
        [string]$Name,
        [string]$Direction,
        [string]$Action,
        [string]$Profile,
        [string]$Protocol,
        [string]$LocalPort,
        [string]$RemoteAddress
    )
    
    # Build the registry value string
    $registryValue = "v2.24|$Name|$Direction|$Action|"
    
    # Add profile if provided
    if ($Profile) { 
        $registryValue += "$Profile|" 
    } else {
        $registryValue += "|" 
    }
    
    # Add protocol, local port, and remote address
    $registryValue += "$Protocol|$LocalPort|$RemoteAddress|@FirewallAPI.dll,-28502"
    
    return $registryValue
}

# Add rules to the User GPO (Blocking Rules)
foreach ($rule in $firewallRules) {
    $registryValue = Construct-FirewallRegistryValue -Name $rule.Name -Direction $rule.Direction -Action $rule.Action -Profile $rule.Profile -Protocol $rule.Protocol -LocalPort $rule.LocalPort -RemoteAddress $rule.RemoteAddress
    Set-GPRegistryValue -Name $UserGPOName -Key "HKLM\Software\Policies\Microsoft\WindowsFirewall\FirewallRules" -ValueName $rule.Name -Type String -Value $registryValue
}

# Add inverse rules to the Admin GPO (Allowing Rules)
foreach ($rule in $firewallRules) {
    # Convert the block action to allow for Admin GPO
    $inverseAction = if ($rule.Action -eq "Block") { "Allow" } else { $rule.Action }
    $registryValue = Construct-FirewallRegistryValue -Name $rule.Name -Direction $rule.Direction -Action $inverseAction -Profile $rule.Profile -Protocol $rule.Protocol -LocalPort $rule.LocalPort -RemoteAddress $rule.RemoteAddress
    Set-GPRegistryValue -Name $AdminGPOName -Key "HKLM\Software\Policies\Microsoft\WindowsFirewall\FirewallRules" -ValueName $rule.Name -Type String -Value $registryValue
}

# Apply Security Filtering to ensure the User GPO applies to all users and Admin GPO to admins only
# Remove "Authenticated Users" from Admin GPO and add "Domain Admins" or relevant group

# Remove Authenticated Users from Admin GPO
Set-GPPermissions -Name $AdminGPOName -TargetName "Authenticated Users" -TargetType Group -PermissionLevel None

# Add Domain Admins to Admin GPO
Set-GPPermissions -Name $AdminGPOName -TargetName "Domain Admins" -TargetType Group -PermissionLevel GpoApply

# Force update of GPOs (useful only for testing, as it's not typically done in production)
Invoke-GPUpdate -Force
