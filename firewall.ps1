# Block all FTP (port 21) traffic for non-admins
New-NetFirewallRule -DisplayName "Block FTP Traffic (Non-Admins)" -Direction Outbound -Action Block -Protocol TCP -RemotePort 21 -User "Users"

# Block all SSH (port 22) traffic for non-admins
New-NetFirewallRule -DisplayName "Block SSH Traffic (Non-Admins)" -Direction Outbound -Action Block -Protocol TCP -RemotePort 22 -User "Users"

# Block Telnet (port 23) traffic for non-admins
New-NetFirewallRule -DisplayName "Block Telnet Traffic (Non-Admins)" -Direction Outbound -Action Block -Protocol TCP -RemotePort 23 -User "Users"

# Block SMTP (port 25) traffic for non-admins
New-NetFirewallRule -DisplayName "Block SMTP Traffic (Non-Admins)" -Direction Outbound -Action Block -Protocol TCP -RemotePort 25 -User "Users"

# Block POP3 (port 110) traffic for non-admins
New-NetFirewallRule -DisplayName "Block POP3 Traffic (Non-Admins)" -Direction Outbound -Action Block -Protocol TCP -RemotePort 110 -User "Users"

# Block IMAP (port 143) traffic for non-admins
New-NetFirewallRule -DisplayName "Block IMAP Traffic (Non-Admins)" -Direction Outbound -Action Block -Protocol TCP -RemotePort 143 -User "Users"

# Block SMB (port 445) traffic for non-admins, except internally
New-NetFirewallRule -DisplayName "Block SMB Traffic (Non-Admins)" -Direction Outbound -Action Block -Protocol TCP -RemotePort 445 -RemoteAddress Any -User "Users"
New-NetFirewallRule -DisplayName "Allow SMB Traffic Internally" -Direction Outbound -Action Allow -Protocol TCP -RemotePort 445 -RemoteAddress 192.168.66.0/24 -User "Users"

# Allow DNS requests only to the specified DNS server (192.168.66.1) for non-admins
New-NetFirewallRule -DisplayName "Allow DNS to 192.168.66.1 (Non-Admins)" -Direction Outbound -Action Allow -Protocol UDP -RemotePort 53 -RemoteAddress 192.168.66.1 -User "Users"
New-NetFirewallRule -DisplayName "Block DNS to other servers (Non-Admins)" -Direction Outbound -Action Block -Protocol UDP -RemotePort 53 -RemoteAddress Any -User "Users"

# Allow HTTP and HTTPS traffic to domain networks for non-admins
New-NetFirewallRule -DisplayName "Allow HTTP to domain (Non-Admins)" -Direction Outbound -Action Allow -Protocol TCP -RemotePort 80 -Profile Domain -User "Users"
New-NetFirewallRule -DisplayName "Allow HTTPS to domain (Non-Admins)" -Direction Outbound -Action Allow -Protocol TCP -RemotePort 443 -Profile Domain -User "Users"

# Block HTTP and HTTPS traffic to non-domain networks for non-admins
New-NetFirewallRule -DisplayName "Block HTTP to non-domain (Non-Admins)" -Direction Outbound -Action Block -Protocol TCP -RemotePort 80 -Profile Private,Public -User "Users"
New-NetFirewallRule -DisplayName "Block HTTPS to non-domain (Non-Admins)" -Direction Outbound -Action Block -Protocol TCP -RemotePort 443 -Profile Private,Public -User "Users"
