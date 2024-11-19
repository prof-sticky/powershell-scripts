function Convert-BinaryToIp {
    param (
        [string]$Binary
    )
    return ($Binary -split '(.{8})' -ne '').ForEach{ [convert]::ToInt32($_, 2) } -join '.'
}

# Example Usage
$binaryString = "11000000101010000000000100000001"
$ipAddress = Convert-BinaryToIp -Binary $binaryString
Write-Output $ipAddress  # Outputs: 192.168.1.1