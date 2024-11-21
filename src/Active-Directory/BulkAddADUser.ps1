# Very basic script to add bulk users from a CSV to Active Directory

Import-Module ActiveDirectory 
$Users = Import-Csv -Delimiter "," -Path "BulkAddADUser-Userlist.csv"  
foreach ($User in $Users)  
{  
    $OU = $User.OU
    $Password = $User.Password 
    $Detailedname = $User.Firstname + " " + $User.Surname 
    $username =  $User.Username
    $SAM = $username.toLower()

    New-ADUser -Name $Detailedname -SamAccountName $SAM -UserPrincipalName $SAM -DisplayName $Detailedname -GivenName $user.firstname -Surname $user.surname -AccountPassword (ConvertTo-SecureString $Password -AsPlainText -Force) -Enabled $true -Path $OU  
} 
