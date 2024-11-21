# ----------------------------------------------------------------
#                  Active Directory OU Selector
# ----------------------------------------------------------------
#
# Allows a user to browse around Active Directory Organizational Units to select a particular OU to use 
# as part of a script. 

function Select-OU {
    param (
        [string]$currentPath
    )

    while ($true) {
        # Initialize the result array
        $result = @()
        $idCounter = 1

        # Get OUs in the current path
        $foundOUs = Get-ADOrganizationalUnit -Filter 'Name -like "*"' -SearchBase $currentPath -SearchScope 1

        if ($foundOUs) {
            $result += $foundOUs | ForEach-Object {
                [PSCustomObject]@{
                    ID                = $idCounter
                    Name              = $_.Name
                    DistinguishedName = $_.DistinguishedName
                }
                $idCounter++
            }
        }
        else {
            # No child OUs found
            $result += [PSCustomObject]@{
                ID                = "-"
                Name              = "No child Organizational Units found."
                DistinguishedName = "N/A"
            }
        }

        # Add spacer
        $result += [PSCustomObject]@{
            ID                = "-"
            Name              = "--------------------------------"
            DistinguishedName = "N/A"
        }

        # Add "Back" if applicable
        if ($currentPath -match '^OU=') {
            $result += [PSCustomObject]@{
                ID                = "B"
                Name              = "Back one level"
                DistinguishedName = "N/A"
            }
        }

        # Add "Select Current OU"
        $result += [PSCustomObject]@{
            ID                = "Y"
            Name              = "Select Current OU"
            DistinguishedName = $currentPath
        }

        # Display the current path and table
        Clear-Host
        Write-Host "Current Path: $currentPath"
        Write-Host ($result | Format-Table ID, Name | Out-String)

        # Prompt user for input
        $choice = Read-Host -Prompt "Enter the ID of your choice"

        if ($choice -eq 'Y') {
            return $currentPath
        }
        elseif ($choice -eq 'B') {
            # Go back to the parent OU
            if ($currentPath -match '^OU=') {
                $currentPath = $currentPath -replace '^.+?,', ''
                Write-Host "Moved back to parent OU: $currentPath"
            }
            else {
                Write-Host "You are already at the top-level OU."
            }
        }
        elseif ([int]::TryParse($choice, [ref]$null) -and $choice -gt 0 -and $choice -le ($idCounter - 1)) {
            # Navigate into the chosen OU
            $currentPath = $result[$choice - 1].DistinguishedName
        }
        else {
            Write-Host "Invalid input. Please enter a valid choice."
        }
    }
}

# Get the baseDN for the domain
$baseDN = Get-ADDomain

# Start the navigation process
$SelectedOU = Select-OU -currentPath $baseDN.DistinguishedName
Write-Host "Selected OU: $SelectedOU"
