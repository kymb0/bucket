# Import the Active Directory module
Import-Module ActiveDirectory

# Define the base Organizational Unit (OU)
$baseOU = "OU=UmbrellaCorp,DC=yourdomain,DC=local"

# Define AD groups and corresponding departments
$adGroups = @(
    @{ Name = "Research Clearance Level Blue"; Department = "Research" },
    @{ Name = "Research Clearance Level Red"; Department = "Research" },
    @{ Name = "Research Clearance Level Yellow"; Department = "Research" },
    @{ Name = "Finance Clearance Level Blue"; Department = "Finance" },
    @{ Name = "Finance Clearance Level Red"; Department = "Finance" },
    @{ Name = "Finance Clearance Level Yellow"; Department = "Finance" },
    @{ Name = "Weapons Division"; Department = "Weapons" },
    @{ Name = "Operations Division"; Department = "Operations" },
    @{ Name = "Administration Division"; Department = "Administration" }
)

# Create the AD groups
foreach ($group in $adGroups) {
    New-ADGroup -Name $group.Name -GroupScope Global -Path $baseOU -Description "$($group.Department) department group with $($group.Name) clearance"
}

# Define logical users (with relevant job titles)
$residentEvilUsers = @(
    @{ FirstName = "Albert"; LastName = "Wesker"; JobTitle = "Director of Operations"; Department = "Operations"; Group = "Operations Division" },
    @{ FirstName = "William"; LastName = "Birkin"; JobTitle = "Lead Researcher"; Department = "Research"; Group = "Research Clearance Level Red" },
    @{ FirstName = "Alexia"; LastName = "Ashford"; JobTitle = "Head of Research"; Department = "Research"; Group = "Research Clearance Level Yellow" },
    @{ FirstName = "James"; LastName = "Marcus"; JobTitle = "Senior Researcher"; Department = "Research"; Group = "Research Clearance Level Blue" },
    @{ FirstName = "Oswell"; LastName = "Spencer"; JobTitle = "Chairman of the Board"; Department = "Administration"; Group = "Administration Division" },
    @{ FirstName = "Annette"; LastName = "Birkin"; JobTitle = "Research Scientist"; Department = "Research"; Group = "Research Clearance Level Red" },
    @{ FirstName = "Alexander"; LastName = "Ashford"; JobTitle = "Assistant Head of Research"; Department = "Research"; Group = "Research Clearance Level Yellow" },
    @{ FirstName = "Enrico"; LastName = "Marini"; JobTitle = "Deputy Director of Operations"; Department = "Operations"; Group = "Operations Division" },
    @{ FirstName = "Sergei"; LastName = "Vladimir"; JobTitle = "Chief Security Officer"; Department = "Operations"; Group = "Operations Division" },
    @{ FirstName = "Edward"; LastName = "Ashford"; JobTitle = "Chief Weapons Developer"; Department = "Weapons"; Group = "Weapons Division" },
    @{ FirstName = "Jessica"; LastName = "Trevor"; JobTitle = "Financial Analyst"; Department = "Finance"; Group = "Finance Clearance Level Yellow" },
    @{ FirstName = "Lisa"; LastName = "Trevor"; JobTitle = "Accountant"; Department = "Finance"; Group = "Finance Clearance Level Blue" },
    @{ FirstName = "Daniel"; LastName = "Fabron"; JobTitle = "Strategic Planner"; Department = "Administration"; Group = "Administration Division" },
    @{ FirstName = "Rachel"; LastName = "Foley"; JobTitle = "Public Relations Manager"; Department = "Administration"; Group = "Administration Division" },
    @{ FirstName = "Patrick"; LastName = "Evers"; JobTitle = "Weapons Development Engineer"; Department = "Weapons"; Group = "Weapons Division" }
)


# Store created users for assigning managers
$createdUsers = @()

# Loop through and create each user sequentially
foreach ($index in 0..($residentEvilUsers.Length - 1)) {
    $firstName = $residentEvilUsers[$index]["FirstName"]
    $lastName = $residentEvilUsers[$index]["LastName"]
    $jobTitle = $residentEvilUsers[$index]["JobTitle"]
    $department = $residentEvilUsers[$index]["Department"]
    $group = $residentEvilUsers[$index]["Group"]

    # Create the username and email
    $userName = $firstName.ToLower() + "." + $lastName.ToLower()
    $email = $userName + "@yourdomain.local"

    # Define the distinguished name for the new user
    $distinguishedName = "CN=$firstName $lastName,$baseOU"

    # Create a new user object in AD
    New-ADUser `
        -Name "$firstName $lastName" `
        -GivenName $firstName `
        -Surname $lastName `
        -SamAccountName $userName `
        -UserPrincipalName $userName"@yourdomain.local" `
        -EmailAddress $email `
        -Department $department `
        -Title $jobTitle `
        -AccountPassword (ConvertTo-SecureString "SecurePassword123!" -AsPlainText -Force) `
        -Path $baseOU `
        -Enabled $true

    # Retrieve the newly created user and add to the list
    $createdUser = Get-ADUser -Filter { SamAccountName -eq $userName }
    $createdUsers += $createdUser

    # Add the user to the relevant group
    Add-ADGroupMember -Identity $group -Members $createdUser

    # If not the first user, set the previous user as the manager
    if ($index -gt 0) {
        $manager = $createdUsers[$index - 1]
        Set-ADUser -Identity $createdUser -Manager $manager.DistinguishedName
    }
}

Write-Output "Users and groups created successfully with logical names and job titles."
