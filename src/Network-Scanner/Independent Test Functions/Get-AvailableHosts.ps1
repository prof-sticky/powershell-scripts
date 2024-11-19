function Get-AvailableHosts {
    param (
        [string]$SubnetBinary
    )
    # Uses a regular expression to count the nuumber of 0's in the string
    $totalzeroes = ([regex]::Matches($SubnetBinary, "0" )).count
    # 2 to the power of the number of zeroes
    $hosts = [Math]::Pow(2, $totalzeroes)
    # Remove 2 hosts for network address and broadcast address and return
    return $hosts - 2
}

# Example Usage
$subnetMask = "11111111111111111111111100000000" # /24 network of 254 hosts
$hosts = Get-AvailableHosts -SubnetBinary $subnetMask
Write-Output $hosts

# this doesn't check if the 0's are out of order or anything, just counts them, so it won't check if the subnet mask is invalid or anything.