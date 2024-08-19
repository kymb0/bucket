# Specify the domain
$Domain = 'umbrellacorp.local'

# Specify the GPO names
$GpoNameAllUsers = 'Windows Firewall Policy - All Users'
$GpoNameAdmins = 'Windows Firewall Policy - Admins'

# Check if the GPOs exist, and create them if they don't
if (-not (Get-GPO -Name $GpoNameAllUsers -ErrorAction SilentlyContinue)) {
    New-GPO -Name $GpoNameAllUsers -Domain $Domain
}

if (-not (Get-GPO -Name $GpoNameAdmins -ErrorAction SilentlyContinue)) {
    New-GPO -Name $GpoNameAdmins -Domain $Domain
}

# Combine the domain and GPO names to create the $PolicyStore variables
$PolicyStoreAllUsers = "$Domain\$GpoNameAllUsers"
$PolicyStoreAdmins = "$Domain\$GpoNameAdmins"

# Open GPO sessions (ensure domain connectivity and correct permissions)
$GpoSessionAllUsers = Open-NetGPO -PolicyStore $PolicyStoreAllUsers
$GpoSessionAdmins = Open-NetGPO -PolicyStore $PolicyStoreAdmins

# Modify Firewall Rules for All Users
$BlockedPorts = @(21, 22, 23, 69, 161, 2049, 3389)
foreach ($Port in $BlockedPorts) {
    # Separate Inbound and Outbound rules
    New-NetFirewallRule -GPOSession $GpoSessionAllUsers -DisplayName "Block Inbound Port $Port" -Direction Inbound -LocalPort $Port -Protocol TCP,UDP -Action Block
    New-NetFirewallRule -GPOSession $GpoSessionAllUsers -DisplayName "Block Outbound Port $Port" -Direction Outbound -LocalPort $Port -Protocol TCP,UDP -Action Block
}

# Block ICMP (all ICMPv4)
New-NetFirewallRule -GPOSession $GpoSessionAllUsers -DisplayName "Block ICMPv4 Inbound" -Direction Inbound -Protocol ICMPv4 -Action Block
New-NetFirewallRule -GPOSession $GpoSessionAllUsers -DisplayName "Block ICMPv4 Outbound" -Direction Outbound -Protocol ICMPv4 -Action Block

# Allow DNS (UDP/53) only to a specific server
New-NetFirewallRule -GPOSession $GpoSessionAllUsers -DisplayName "Allow DNS to Specific Server" -Direction Outbound -LocalPort 53 -Protocol UDP -RemoteAddress "SPECIFIC_SERVER_IP" -Action Allow

# Allow HTTP/HTTPS for domain profiles, block for private/public profiles
New-NetFirewallRule -GPOSession $GpoSessionAllUsers -DisplayName "Allow HTTP Domain Profile" -Direction Outbound -LocalPort 80 -Protocol TCP -Action Allow -Profile Domain
New-NetFirewallRule -GPOSession $GpoSessionAllUsers -DisplayName "Block HTTP Private/Public Profile" -Direction Outbound -LocalPort 80 -Protocol TCP -Action Block -Profile Private,Public

New-NetFirewallRule -GPOSession $GpoSessionAllUsers -DisplayName "Allow HTTPS Domain Profile" -Direction Outbound -LocalPort 443 -Protocol TCP -Action Allow -Profile Domain
New-NetFirewallRule -GPOSession $GpoSessionAllUsers -DisplayName "Block HTTPS Private/Public Profile" -Direction Outbound -LocalPort 443 -Protocol TCP -Action Block -Profile Private,Public

# Allow SMB (TCP/445) internally, block externally
New-NetFirewallRule -GPOSession $GpoSessionAllUsers -DisplayName "Allow SMB Internal Inbound" -Direction Inbound -LocalPort 445 -Protocol TCP -RemoteAddress "LOCAL_SUBNET" -Action Allow
New-NetFirewallRule -GPOSession $GpoSessionAllUsers -DisplayName "Allow SMB Internal Outbound" -Direction Outbound -LocalPort 445 -Protocol TCP -RemoteAddress "LOCAL_SUBNET" -Action Allow
New-NetFirewallRule -GPOSession $GpoSessionAllUsers -DisplayName "Block SMB External Inbound" -Direction Inbound -LocalPort 445 -Protocol TCP -RemoteAddress "ANY" -Action Block
New-NetFirewallRule -GPOSession $GpoSessionAllUsers -DisplayName "Block SMB External Outbound" -Direction Outbound -LocalPort 445 -Protocol TCP -RemoteAddress "ANY" -Action Block

# Modify Firewall Rules for Admins
$AllowedPorts = @(21, 22, 23, 69, 161, 2049, 3389, 80, 443)
foreach ($Port in $AllowedPorts) {
    # Allow specific ports for all profiles
    New-NetFirewallRule -GPOSession $GpoSessionAdmins -DisplayName "Allow Inbound Port $Port" -Direction Inbound -LocalPort $Port -Protocol TCP,UDP -Action Allow
    New-NetFirewallRule -GPOSession $GpoSessionAdmins -DisplayName "Allow Outbound Port $Port" -Direction Outbound -LocalPort $Port -Protocol TCP,UDP -Action Allow
}

# Allow ICMP (all ICMPv4)
New-NetFirewallRule -GPOSession $GpoSessionAdmins -DisplayName "Allow ICMPv4 Inbound" -Direction Inbound -Protocol ICMPv4 -Action Allow
New-NetFirewallRule -GPOSession $GpoSessionAdmins -DisplayName "Allow ICMPv4 Outbound" -Direction Outbound -Protocol ICMPv4 -Action Allow

# Allow SMB (TCP/445) internally, block externally
New-NetFirewallRule -GPOSession $GpoSessionAdmins -DisplayName "Allow SMB Internal Inbound" -Direction Inbound -LocalPort 445 -Protocol TCP -RemoteAddress "LOCAL_SUBNET" -Action Allow
New-NetFirewallRule -GPOSession $GpoSessionAdmins -DisplayName "Allow SMB Internal Outbound" -Direction Outbound -LocalPort 445 -Protocol TCP -RemoteAddress "LOCAL_SUBNET" -Action Allow
New-NetFirewallRule -GPOSession $GpoSessionAdmins -DisplayName "Block SMB External Inbound" -Direction Inbound -LocalPort 445 -Protocol TCP -RemoteAddress "ANY" -Action Block
New-NetFirewallRule -GPOSession $GpoSessionAdmins -DisplayName "Block SMB External Outbound" -Direction Outbound -LocalPort 445 -Protocol TCP -RemoteAddress "ANY" -Action Block

# Save the GPO for Admins
Save-NetGPO -GPOSession $GpoSessionAdmins
