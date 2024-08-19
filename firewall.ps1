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
$BlockedPorts = @(21, 22, 23, 69, 161, 2049, 3389)
foreach ($Port in $BlockedPorts) {
    # Block specific ports for all profiles
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
$AllowedPortsTCP = @(21, 22, 23, 2049, 3389)  # Ports to allow for TCP
$AllowedPortsUDP = @(69, 161)  # Ports to allow for UDP

foreach ($Port in $AllowedPortsTCP) {
    New-NetFirewallRule -GPOSession $GpoSessionAdmins -DisplayName "Allow Inbound TCP Port $Port" -Direction Inbound -LocalPort $Port -Protocol TCP -Action Allow
    New-NetFirewallRule -GPOSession $GpoSessionAdmins -DisplayName "Allow Outbound TCP Port $Port" -Direction Outbound -LocalPort $Port -Protocol TCP -Action Allow
}

foreach ($Port in $AllowedPortsUDP) {
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
