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

# Example Usage
$cidr = 22
$netmaskDecimal = Convert-CIDRtoDecimal -bitCount $cidr
Write-Output $netmaskDecimal # Outputs 255.255.252.0