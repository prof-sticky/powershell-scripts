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

# Example Usage
$ipAddress = "192.168.1.1"
$binaryString = Convert-IPtoBinary -ip $ipAddress
Write-Output $binaryString  # Outputs: 11000000101010000000000100000001