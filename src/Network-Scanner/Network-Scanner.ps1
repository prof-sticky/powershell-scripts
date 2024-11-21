# ----------------------------------------------------------------
#                           Functions
# ----------------------------------------------------------------

# Get-NetworkInfo - Returns an array of all connected networks from multiple NICS (eg. Wifi and Ethernet connected simultaneously)
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
# Convert-IPtoBinary - Converts an IPv4 Address string to a binary string
function Convert-IPtoBinary {
    param (
        [string]$ip
    )
    # Split the IP address into octets, convert each to binary, pad to 8 bits, and store them in an array
    $binaryOctets = $ip -split '\.' | ForEach-Object { 
        [Convert]::ToString([int]$_, 2).PadLeft(8, '0') 
    }
    # Join the array into a single binary string
    $binaryResult = -join $binaryOctets
    return $binaryResult
}
# Convert-BinarytoIP - Converts a binary string to an IPv4 Address string
function Convert-BinarytoIp {
    param (
        [string]$Binary
    )
    return ($Binary -split '(.{8})' -ne '').ForEach{ [convert]::ToInt32($_, 2) } -join '.'
}
# Convert-CIDRtoDecimal - Converts the CIDR notation of a subnet mask to the decimal value of the subnet mask
function Convert-CIDRtoDecimal {
    param (
        [int]$bitCount
    )
    # Initialize an empty array to hold each octet of the subnet mask
    $mask = @()
    # Loop through 4 octets
    for ($i = 0; $i -lt 4; $i++) {
        # Determine the number of bits to set in this octet
        $n = [math]::Min($bitCount, 8)
        # Calculate the octet value and add it to the mask array
        $mask += 256 - [math]::Pow(2, 8 - $n)
        # Decrease the bit count for the next octet
        $bitCount -= $n
    }

    # Join the octets with dots to create a dotted-decimal netmask
    return ($mask -join '.')
}
# Gets the network address by comparing the IPv4 Address and subnet mask in decimal, and returns the network address in decimal
function Get-NetworkAddress {
    param (
        [string]$ip,
        [string]$subnetMask
    )
    # Convert them to integer arrays
    $ipArray = $ip.ToCharArray() | ForEach-Object { [int]$_.ToString() }
    $subnetArray = $subnetMask.ToCharArray() | ForEach-Object { [int]$_.ToString() }

    # Initialize an empty array to store the results of the bitwise AND
    $resultArray = @()

    # Loop through each bit in ipArray and subnetArray and apply bitwise AND
    for ($i = 0; $i -lt $ipArray.Length; $i++) {
        $resultArray += $ipArray[$i] -band $subnetArray[$i]
    }

    # Join the result array into a single binary string
    $resultNetworkString = ($resultArray -join '')
    return $resultNetworkString
}
function Get-BroadcastAddress {
    param (
        [string]$ip,
        [string]$subnetMask
    )
    # Convert them to integer arrays
    $ipArray = $ip.ToCharArray() | ForEach-Object { [int]$_.ToString() }
    $subnetArray = $subnetMask.ToCharArray() | ForEach-Object { [int]$_.ToString() }

    # Initialize an empty array to store the results
    $resultArray = @()

    # Loop through each bit in ipArray and if subnet is 1, return the network bit, otherwise 1
    for ($i = 0; $i -lt $ipArray.Length; $i++) {
        if ($subnetArray[$i] -eq '1') {
            $resultArray += $ipArray[$i]
        }
        else {
            $resultArray += '1'
        }
    }

    # Join the result array into a single binary string
    $resultNetworkString = ($resultArray -join '')
    return $resultNetworkString
}
# Calculate the total amount of hosts possible on te network
function Get-AvailableHosts {
    param (
        [string]$SubnetBinary
    )
    # Uses a regular expression to count the nuumber of 0's in the string
    $totalzeroes = ([regex]::Matches($SubnetBinary, "0" )).count
    # 2 to the power of the number of 0's
    $hosts = [Math]::Pow(2, $totalzeroes)
    # Remove 2 hosts for network address and broadcast address and return
    return $hosts - 2
}


# Convert the IP Address String into a single integer in big-endian format, this allows us to perform arithmatic and comparisons on IP adddresses
function Convert-IPToInt {
    param (
        [string]$IPAddress
    )
    # Split the IP into octets, parse them as integers, and combine into a single 32-bit integer
    $octets = $IPAddress -split '\.' | ForEach-Object { [int]$_ }
    return ($octets[0] -shl 24) -bor ($octets[1] -shl 16) -bor ($octets[2] -shl 8) -bor $octets[3]
}

# Convert the integer back into a meaningful IP Address
function Convert-IntToIP {
    param (
        [int]$IntAddress
    )
    # Extract each octet using bitwise operations and shifts
    return "{0}.{1}.{2}.{3}" -f (($IntAddress -shr 24) -band 255),
                               (($IntAddress -shr 16) -band 255),
                               (($IntAddress -shr 8) -band 255),
                               ($IntAddress -band 255)
}

# ----------------------------------------------------------------
#                           Main
# ----------------------------------------------------------------

# Present connected networks
$connectednetworks = Get-NetworkInfo
Write-Host ($connectednetworks | Format-Table | Out-String)
# Ask which network to scan
$ChosenNetwork = Read-Host -Prompt "Which network would you like to scan?"
$ChosenNetwork = $ChosenNetwork - 1

# Calculate information about the chosen network

# Convert the CIDR notation of the subnet mask to decimal
$netmaskDecimal = Convert-CIDRtoDecimal -bitCount $ConnectedNetworks[$ChosenNetwork].Subnet
# Convert both IP and Netmask to binary
$ipBinary = Convert-IPtoBinary -ip $ConnectedNetworks[$ChosenNetwork].IPAddress
$netmaskBinary = Convert-IPToBinary -ip $netmaskDecimal
# Calculate the network address 
$netAddressBinary = Get-NetworkAddress -ip $ipBinary -subnetMask $netmaskBinary
$netAddressDecimal = Convert-BinaryToIp -Binary $netAddressBinary
# Calculate broadcast address
$broadcastAddressBinary = Get-BroadcastAddress -ip $ipBinary -subnetMask $netmaskBinary
$broadcastAddressDecimal = Convert-BinaryToIp -Binary $broadcastAddressBinary
# Calculate the first host by flipping the last bit of the network address to a 1
$firsthostBinary = $netAddressBinary.Substring(0, $netAddressBinary.Length - 1) + "1"
$firsthostDecimal = Convert-BinaryToIp -Binary $firsthostBinary
# Calculate the last host by flipping the last bit of the network address to a 0
$lasthostBinary = $broadcastAddressBinary.Substring(0, $broadcastAddressBinary.Length - 1) + "0"
$lasthostDecimal = Convert-BinaryToIp -Binary $lasthostBinary
# Calculate the number of hosts
$availableHosts = Get-AvailableHosts -SubnetBinary $netmaskBinary

# Write out the network info
Write-Host "----------------------------------------------------------------"
Write-Host "Network Address:" $netAddressDecimal
Write-Host "Subnet Mask:" $netmaskDecimal
Write-Host "Broadcast address:" $broadcastAddressDecimal
Write-Host "Host Min:"$firsthostDecimal
Write-Host "Host Max:" $lasthostDecimal
Write-Host "Number of hosts:" $availableHosts
Write-Host "----------------------------------------------------------------"

# Iterate through the IP range and ping hosts

$outputFile = "Network-Scanner.csv"  # Define output file name and path
# Clear the output file if it exists
if (Test-Path $outputFile) {
    Remove-Item $outputFile
}

# Present message that scan has begun
Write-Host "Scanning" $firsthostDecimal "to" $lasthostDecimal

# Create a stopwatch to time the scan
$timer = [Diagnostics.Stopwatch]::StartNew()

# Initialize an empty array to hold the results
$pingResults = @()

# Convert first and last IPs to integers
$firstHostInt = Convert-IPToInt -IPAddress $firsthostDecimal
$lastHostInt = Convert-IPToInt -IPAddress $lasthostDecimal

# Create array of addresses to be pinged as integer
$ipRangeInt = $firstHostInt..$lastHostInt
# Convert everything in the array to a regular IP address, so it can be pinged
$ipRangeDecimal = $ipRangeInt | ForEach-Object { Convert-IntToIP -IntAddress $_ }

$ipRangeDecimal | ForEach-Object -Parallel { 
    # Ping each IP and check if it’s reachable
    $pingResult = Test-Connection -ComputerName $_ -Count 1 -Quiet -TimeoutSeconds 2
    $dnsName = $null

    # If reachable, resolve DNS name
    if ($pingResult) {
        try {
            $dnsName = (Resolve-DnsName -Name $_ -ErrorAction Stop).NameHost
        }
        catch {
            $dnsName = "DNS Resolution Failed"
        }
    }

    # Create an object to store IP, result, and DNS name (if resolved)
    [PSCustomObject]@{
        IPAddress = $_
        Status    = if ($pingResult) { "Reachable" } else { "Unreachable" }
        DNSName   = if ($pingResult) { $dnsName } else { "N/A" }
    }
} -ThrottleLimit 20 | ForEach-Object { 
    # Collect each result and add it to the pingResults array
    $pingResults += $_
}

#Sort Results by IP Address, sort by version instead of string otherwise IP addresses won't sort properly
$sortedResults = $pingResults | Sort-Object { $_.IPAddress -as [Version] }

# Filter out objects without a response
$filteredResults = $sortedResults | Where-Object { $_.Status -eq "Reachable" }

# Export results to a CSV file
$filteredResults | Export-Csv -Path $outputFile -NoTypeInformation -Force

# Stop timer
$timer.stop() 

# Display completion message
Write-Host "Ping test complete. Results saved to $outputFile. Scan took $timer"
