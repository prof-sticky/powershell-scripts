# ----------------------------------------------------------------
#                            Functions
# ----------------------------------------------------------------
function Find-InactiveUsers {
    <#
        .SYNOPSIS
        Finds users who have been inactive for over a year in Active Directory.
    #>
    # Specify the time frame for inactive accounts (1 year)
    $oneYearAgo = (Get-Date).AddYears(-1)

    # Search for users in Active Directory
    $inactiveUsers = Get-ADUser -Filter { LastLogonDate -lt $oneYearAgo -and Enabled -eq $true } -Properties LastLogonDate, DisplayName, SamAccountName | 
    Select-Object DisplayName, SamAccountName, LastLogonDate |
    Sort-Object LastLogonDate

    # Output results
    if ($inactiveUsers) {
        Write-Host "Users inactive for over a year:" -ForegroundColor Red
        $inactiveUsers | Format-Table -AutoSize
    }
    else {
        Write-Host "No users found inactive for over a year." -ForegroundColor Green
    }
}

function Find-InactiveComputers {
    <#
        .SYNOPSIS
        Finds computers who have been inactive for over a year in Active Directory.
    #>
    # Specify the time frame for inactive accounts (1 year)
    $oneYearAgo = (Get-Date).AddYears(-1)

    # Search for computers in Active Directory
    $inactiveComputers = Get-ADComputer -Filter { LastLogonDate -lt $oneYearAgo -and Enabled -eq $true } -Properties LastLogonDate, SamAccountName | 
    Select-Object SamAccountName, LastLogonDate |
    Sort-Object LastLogonDate

    # Output results
    if ($inactiveComputers) {
        Write-Host "Computers inactive for over a year:" -ForegroundColor Red
        $inactiveComputers | Format-Table -AutoSize
    }
    else {
        Write-Host "No computers found inactive for over a year." -ForegroundColor Green
    }
}
function Find-UsersPasswordExpiry {
    # Search for users with password expiry enabled (PasswordNeverExpires is False)
    $usersWithPasswordExpiry = Get-ADUser -Filter { PasswordNeverExpires -eq $false } -Properties DisplayName, SamAccountName, PasswordNeverExpires |
    Select-Object DisplayName, SamAccountName, PasswordNeverExpires

    # Output results
    if ($usersWithPasswordExpiry) {
        Write-Host "Users with Password Expiry enabled:" -ForegroundColor Green
        $usersWithPasswordExpiry | Format-Table -AutoSize
    }
    else {
        Write-Host "No users found with Password Expiry enabled." -ForegroundColor Yellow
    }
}
function Find-UsersPasswordReset {
    # Import the Active Directory module
    Import-Module ActiveDirectory

    # Search for users with "Change Password at Next Logon" enabled
    $usersToChangePassword = Get-ADUser -Filter { pwdLastSet -eq 0 } -Properties DisplayName, SamAccountName, pwdLastSet |
    Select-Object DisplayName, SamAccountName, pwdLastSet

    # Output results
    if ($usersToChangePassword) {
        Write-Host "Users with 'Change Password at Next Logon' enabled:" -ForegroundColor Yellow
        $usersToChangePassword | Format-Table -AutoSize
    }
    else {
        Write-Host "No users found with 'Change Password at Next Logon' enabled." -ForegroundColor Green
    }

}
function Find-UsersPWExpiryNoReset {
    # Searches Active Directory for any users that have have a password not set to change at next logon and with expiry enabled.
    # Active Directory does not allow set password at next logon and passwords to have no expiry at the same time.
    # I often ended up creating accounts for new staff, sent them their username and temporary password and they would set their own password.
    # But it could be months before they started, and I'd forget to disable password expiry and they would be changing their password every 90 days,
    # often writing passwords on sticky notes on their PC or engaging in other poor security practises to compensate for the constantly changing password.

    # Search for users with password expiry enabled but not set to change password at next logon
    $usersWithPasswordExpiry = Get-ADUser -Filter { PasswordNeverExpires -eq $false -and pwdLastSet -ne 0 } -Properties DisplayName, SamAccountName, PasswordNeverExpires, pwdLastSet |
    Select-Object DisplayName, SamAccountName, PasswordNeverExpires, pwdLastSet |
    Where-Object { 
        $_.SamAccountName -notmatch '^DefaultAccount$' -and $_.SamAccountName -notmatch '^krbtgt$' 
    }

    # Output results
    if ($usersWithPasswordExpiry) {
        Write-Host "Users with Password Expiry enabled (excluding 'Change Password at Next Logon'):" -ForegroundColor Green
        $usersWithPasswordExpiry | Format-Table -AutoSize
        $choice = Read-Host -Prompt "Would you like to disable password expiry for these users? (Y/N)"
        if ($choice -eq 'Y') {
            Write-Output "Updating Users..."
            foreach ($user in $usersWithPasswordExpiry) {
                Write-Host $user.SamAccountName "(" $user.DisplayName ") removed password expiry."
                Set-ADUser -identity $user.SamAccountName -PasswordNeverExpires:$True
            }
        }
        elseif ($choice -eq 'N') {
            Write-Output "No changes made."
        }
        else {
            Write-Output "Invalid input. Please enter Yes or No."
        }
    }
    else {
        Write-Host "No users found with Password Expiry enabled and not set to 'Change Password at Next Logon'." -ForegroundColor Yellow
    }

}
# -------------------------------------------
# Main
# -------------------------------------------

# Import the Active Directory module
Import-Module ActiveDirectory

# Define options available
$options = @(
    [PSCustomObject]@{
        ID          = 1
        Function    = 'Find-InactiveUsers'
        Description = 'Finds users who have been inactive for over a year in Active Directory.'
    },
    [PSCustomObject]@{
        ID          = 2
        Function    = 'Find-InactiveComputers'
        Description = 'Finds computers that have been inactive for over a year in Active Directory.'
    }
    [PSCustomObject]@{
        ID          = 3
        Function    = 'Find-UsersPasswordReset'
        Description = 'List Users with password reset at next logon enabled.'
    }
    [PSCustomObject]@{
        ID          = 4
        Function    = 'Find-UsersPasswordExpiry'
        Description = 'Finds users with passwords with password expiry enabled.'
    }
    [PSCustomObject]@{
        ID          = 5
        Function    = 'Find-UsersPWExpiryNoReset'
        Description = 'Finds users with password expiry enabled and not changing at next logon.'
    }
)

# Display the options to the user
$options | Format-Table ID, Function, Description -AutoSize

# Prompt user for input
$choice = Read-Host -Prompt "Enter the ID of your choice"

# Get the chosen function and invoke it
$selectedFunction = $options | Where-Object { $_.ID -eq [int]$choice }
if ($selectedFunction) {
    Write-Host "You chose function: $($selectedFunction.Function)" -ForegroundColor Yellow
    Invoke-Expression $selectedFunction.Function
}
else {
    Write-Host "Invalid choice. Please try again." -ForegroundColor Red
}
