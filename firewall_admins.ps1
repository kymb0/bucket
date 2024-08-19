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
$BlockedPortsTCP = @(21, 22, 23, 2049, 3389)  # TCP ports to block
$BlockedPortsUDP = @(69, 161)  # UDP ports to block

# Block TCP ports
foreach ($Port in $BlockedPortsTCP) {
    New-NetFirewallRule -GPOSession $GpoSessionAllUsers -DisplayName "Block Inbound TCP Port $Port" -Direction Inbound -LocalPort $Port -Protocol TCP -Action Block
    New-NetFirewallRule -GPOSession $GpoSessionAllUsers -DisplayName "Block Outbound TCP Port $Port" -Direction Outbound -LocalPort $Port -Protocol TCP -Action Block
}

# Block UDP ports
foreach ($Port in $BlockedPortsUDP) {
    New-NetFirewallRule -GPOSession $GpoSessionAllUsers -DisplayName "Block Inbound UDP Port $Port" -Direction Inbound -LocalPort $Port -Protocol UDP -Action Block
    New-NetFirewallRule -GPOSession $GpoSessionAllUsers -DisplayName "Block Outbound UDP Port $Port" -Direction Outbound -LocalPort $Port -Protocol UDP -Action Block
}
# Block ICMP (all ICMPv4)
New-NetFirewallRule -GPOSession $GpoSessionAllUsers -DisplayName "Block ICMPv4 Inbound" -Direction Inbound -Protocol ICMPv4 -Action Block
New-NetFirewallRule -GPOSession $GpoSessionAllUsers -DisplayName "Block ICMPv4 Outbound" -Direction Outbound -Protocol ICMPv4 -Action Block
# Allow DNS (UDP/53) only to a specific server
New-NetFirewallRule -GPOSession $GpoSessionAllUsers -DisplayName "Allow DNS to Specific Server" -Direction Outbound -LocalPort 53 -Protocol UDP -RemoteAddress "192.168.66.1" -Action Allow
# Allow HTTP/HTTPS for domain profiles, block for private/public profiles
New-NetFirewallRule -GPOSession $GpoSessionAllUsers -DisplayName "Allow HTTP Domain Profile" -Direction Outbound -LocalPort 80 -Protocol TCP -Action Allow -Profile Domain
New-NetFirewallRule -GPOSession $GpoSessionAllUsers -DisplayName "Block HTTP Private/Public Profile" -Direction Outbound -LocalPort 80 -Protocol TCP -Action Block -Profile Private,Public

New-NetFirewallRule -GPOSession $GpoSessionAllUsers -DisplayName "Allow HTTPS Domain Profile" -Direction Outbound -LocalPort 443 -Protocol TCP -Action Allow -Profile Domain
New-NetFirewallRule -GPOSession $GpoSessionAllUsers -DisplayName "Block HTTPS Private/Public Profile" -Direction Outbound -LocalPort 443 -Protocol TCP -Action Block -Profile Private,Public
# Allow TCP ports for Admins
foreach ($Port in $BlockedPortsTCP) {
    New-NetFirewallRule -GPOSession $GpoSessionAdmins -DisplayName "Allow Inbound TCP Port $Port" -Direction Inbound -LocalPort $Port -Protocol TCP -Action Allow
    New-NetFirewallRule -GPOSession $GpoSessionAdmins -DisplayName "Allow Outbound TCP Port $Port" -Direction Outbound -LocalPort $Port -Protocol TCP -Action Allow
}

# Allow UDP ports for Admins
foreach ($Port in $BlockedPortsUDP) {
    New-NetFirewallRule -GPOSession $GpoSessionAdmins -DisplayName "Allow Inbound UDP Port $Port" -Direction Inbound -LocalPort $Port -Protocol UDP -Action Allow
    New-NetFirewallRule -GPOSession $GpoSessionAdmins -DisplayName "Allow Outbound UDP Port $Port" -Direction Outbound -LocalPort $Port -Protocol UDP -Action Allow
}
# Allow ICMP (all ICMPv4)
New-NetFirewallRule -GPOSession $GpoSessionAdmins -DisplayName "Allow ICMPv4 Inbound" -Direction Inbound -Protocol ICMPv4 -Action Allow
New-NetFirewallRule -GPOSession $GpoSessionAdmins -DisplayName "Allow ICMPv4 Outbound" -Direction Outbound -Protocol ICMPv4 -Action Allow
# Allow SMB (TCP/445) internally, block externally
New-NetFirewallRule -GPOSession $GpoSessionAdmins -DisplayName "Allow SMB Internal Inbound TCP" -Direction Inbound -LocalPort 445 -Protocol TCP -RemoteAddress "LocalSubnet" -Action Allow
New-NetFirewallRule -GPOSession $GpoSessionAdmins -DisplayName "Allow SMB Internal Outbound TCP" -Direction Outbound -LocalPort 445 -Protocol TCP -RemoteAddress "LocalSubnet" -Action Allow

New-NetFirewallRule -GPOSession $GpoSessionAdmins -DisplayName "Block SMB External Inbound TCP" -Direction Inbound -LocalPort 445 -Protocol TCP -RemoteAddress "Any" -Action Block
New-NetFirewallRule -GPOSession $GpoSessionAdmins -DisplayName "Block SMB External Outbound TCP" -Direction Outbound -LocalPort 445 -Protocol TCP -RemoteAddress "Any" -Action Block
# Save the GPOs
Save-NetGPO -GPOSession $GpoSessionAllUsers
Save-NetGPO -GPOSession $GpoSessionAdmins
