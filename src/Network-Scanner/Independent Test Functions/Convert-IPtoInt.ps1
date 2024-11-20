
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

# Example usage 
$firsthostDecimal = "192.168.1.1"
$lasthostDecimal = "192.168.1.17"

# Convert first and last IPs to integers
$firstHostInt = Convert-IPToInt -IPAddress $firsthostDecimal
$lastHostInt = Convert-IPToInt -IPAddress $lasthostDecimal

# Iterate through the range using integers
for ($ipInt = $firstHostInt; $ipInt -le $lastHostInt; $ipInt++) {
    # Convert integer back to IP string for use
    $currentIP = Convert-IntToIP -IntAddress $ipInt
    # Do whatever you want with the IP address
    Write-Host $currentIP
}
