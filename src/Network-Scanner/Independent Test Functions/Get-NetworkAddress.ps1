function Get-NetworkAddress {
    param (
        [string]$ip,
        [string]$subnetMask
    )
    # Convert them to integer arrays
    $ipArray = $ipstring.ToCharArray() | ForEach-Object { [int]$_.ToString() }
    $subnetArray = $subnetstring.ToCharArray() | ForEach-Object { [int]$_.ToString() }

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

# Example Usage with IP Address: 192.168.152.79 and subnet mask: /22
$ipstring = "11000000101010001001100001001111"
$subnetstring = "11111111111111111111110000000000"

$networkAddress = Get-NetworkAddress -ip $ipstring -subnetMask $subnetstring
Write-Host "Result in Binary:" $networkAddress #Outputs: 11000000101010001001100000000000
