# Returns an array of all connected networks from multiple NICS (eg. Wifi and Ethernet connected simultaneously)
function Get-NetworkInfo {
    # Initialize a counter for the ID number
    $idCounter = 1

    # Get IPv4 addresses, excluding link-local and loopback addresses
    $networks = Get-NetIPAddress -AddressFamily IPv4 |
    Where-Object { 
        $_.IPAddress -notmatch '^169\.254' -and $_.IPAddress -notmatch '^127' 
    } |
    ForEach-Object {
        # Add an ID property to each entry
        [PSCustomObject]@{
            ID        = $idCounter
            Name      = $_.InterfaceAlias
            IPAddress = $_.IPAddress
            Subnet    = $_.PrefixLength
        }
        # Increment the counter
        $idCounter++
    }
    return $networks
}

# Output
$connectednetworks = Get-NetworkInfo
Write-Host ($connectednetworks | Format-Table | Out-String)