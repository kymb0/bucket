# Load the required module
Import-Module GroupPolicy

# Create a new GPO named 'Deploy BGInfo'
$gpoName = "Deploy BGInfo"
New-GPO -Name $gpoName -Comment "This GPO deploys BGInfo to all client machines at startup"

# Retrieve the new GPO to manipulate it
$gpo = Get-GPO -Name $gpoName

# Path to the script that will be run at startup
$scriptPath = "\\DC01\Share\BGInfo\deploy-bginfo.cmd"

# Create the startup script command file on the shared path with BGInfo execution commands
$scriptContent = @"
@echo off
\\DC01\Share\BGInfo\BGInfo.exe \\DC01\Share\BGInfo\BGInfo.bgi /TIMER:0 /SILENT /NOLICPROMPT
"@

# Ensure the directory for the script exists and is writable
$scriptDirectory = "\\DC01\Share\BGInfo"
if (-not (Test-Path -Path $scriptDirectory)) {
    New-Item -Path $scriptDirectory -ItemType Directory
}

# Write the script to the network share
Set-Content -Path $scriptPath -Value $scriptContent -Force

# Add the startup script to the GPO
$StartupScripts = $gpo.GetComputerConfiguration().Policies.StartupScripts
$StartupScripts.Add($scriptPath, $null) # $null represents no script parameters
$gpo.Save()

# Output the success message
Write-Host "GPO with BGInfo deployment startup script created successfully."
