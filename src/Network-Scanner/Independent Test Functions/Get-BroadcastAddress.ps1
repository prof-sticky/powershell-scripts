function Get-BroadcastAddress {
    param (
        [string]$ip,
        [string]$subnetMask
    )
    # Convert them to integer arrays
    $ipArray = $ipstring.ToCharArray() | ForEach-Object { [int]$_.ToString() }
    $subnetArray = $subnetstring.ToCharArray() | ForEach-Object { [int]$_.ToString() }

    # Initialize an empty array to store the results
    $resultArray = @()

    # Loop through each bit in ipArray and if subnet is 1, return the network bit, otherwise 1
    for ($i = 0; $i -lt $ipArray.Length; $i++) {
        if ($subnetArray[$i] -eq '1') {
            $resultArray += $ipArray[$i]
        } else {
            $resultArray += '1'
        }
    }

    # Join the result array into a single binary string
    $resultNetworkString = ($resultArray -join '')
    return $resultNetworkString
}

# Example Usage with IP Address: 192.168.152.79 and subnet mask: /22
$ipstring = "11000000101010001001100001001111"
$subnetstring = "11111111111111111111110000000000"

$networkAddress = Get-BroadcastAddress -ip $ipstring -subnetMask $subnetstring
Write-Host "Result in Binary:" $networkAddress #Outputs: 11000000101010001001100000000000
