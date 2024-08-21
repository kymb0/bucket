# Import the Active Directory module
Import-Module ActiveDirectory

# Define the base Organizational Unit (OU)
$baseOU = "OU=Umbrella Staff,DC=umbrellacorp,DC=local"
$groupOU = "OU=Security Groups,DC=umbrellacorp,DC=local"

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
    New-ADGroup -Name $group.Name -GroupScope Global -Path $groupOU -Description "$($group.Department) department group with $($group.Name) clearance"
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
    $email = $userName + "@umbrellacorp.local"

    # Define the distinguished name for the new user
    $distinguishedName = "CN=$firstName $lastName,$baseOU"

    # Create a new user object in AD
    New-ADUser `
        -Name "$firstName $lastName" `
        -GivenName $firstName `
        -Surname $lastName `
        -SamAccountName $userName `
        -UserPrincipalName $userName"@umbrellacorp.local" `
        -EmailAddress $email `
        -Department $department `
        -Title $jobTitle `
        -AccountPassword (ConvertTo-SecureString "<something>" -AsPlainText -Force) `
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

# List of users with corresponding descriptions
$userDescriptions = @(
    @{
        UserName = "albert.wesker";
        Description = "Director of Operations overseeing strategic and tactical decision-making, ensuring operational efficiency and security."
    },
    @{
        UserName = "william.birkin";
        Description = "Lead Researcher responsible for coordinating research projects and leading the team in developing innovative viral research."
    },
    @{
        UserName = "alexia.ashford";
        Description = "Head of Research overseeing research initiatives and managing the team to drive progress toward key scientific objectives."
    },
    @{
        UserName = "james.marcus";
        Description = "Senior Researcher focused on developing advanced bio-organic weapons technology and leading high-impact scientific projects."
    },
    @{
        UserName = "oswell.spencer";
        Description = "Chairman of the Board, responsible for strategic direction and governance, ensuring organizational objectives are met."
    },
    @{
        UserName = "annette.birkin";
        Description = "Research Scientist specializing in viral research and supporting her team in achieving project milestones effectively."
    },
    @{
        UserName = "alexander.ashford";
        Description = "Assistant Head of Research, responsible for managing key research initiatives and supporting the head of research."
    },
    @{
        UserName = "enrico.marini";
        Description = "Deputy Director of Operations focused on managing field operations and ensuring compliance with corporate security policies."
    },
    @{
        UserName = "sergei.vladimir";
        Description = "Chief Security Officer managing corporate security protocols, safeguarding sensitive information, and preventing breaches."
    },
    @{
        UserName = "edward.ashford";
        Description = "Chief Weapons Developer leading the development of innovative weapons technology and managing the technical team."
    },
    @{
        UserName = "jessica.trevor";
        Description = "Financial Analyst responsible for budget analysis, cost control, and ensuring accurate financial reporting."
    },
    @{
        UserName = "lisa.trevor";
        Description = "Accountant managing financial transactions, preparing budgets, and supporting the finance team in data accuracy."
    },
    @{
        UserName = "daniel.fabron";
        Description = "Strategic Planner coordinating strategic initiatives and optimizing corporate strategy to enhance global market reach."
    },
    @{
        UserName = "patrick.evers";
        Description = "Weapons Development Engineer overseeing technical advancements in weapons technology and driving product innovation."
    },
    @{
        UserName = "rachel.foley";
        Description = "Public Relations Manager responsible for maintaining corporate image and managing media communications effectively."
    }
)

# Loop through each user and update their description in AD
foreach ($user in $userDescriptions) {
    $userName = $user["UserName"]
    $description = $user["Description"]

    # Get the user object from AD
    $adUser = Get-ADUser -Filter { SamAccountName -eq $userName }

    # Update the description if the user is found
    if ($adUser) {
        Set-ADUser -Identity $adUser -Description $description
        Write-Output "Description updated for user '$userName'."
    } else {
        Write-Output "User '$userName' not found."
    }
}

Write-Output "Descriptions have been updated."
