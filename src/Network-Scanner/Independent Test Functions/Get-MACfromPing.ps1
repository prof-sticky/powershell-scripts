# Define the IP address you want to ping
$IPAddress = "10.135.188.1"

# Ping the IP address
$pingResult = Test-Connection -ComputerName $IPAddress -Count 1 -Quiet

if ($pingResult) {
    # If the ping was successful, retrieve the MAC address using ARP
    $arpResult = arp -a | Select-String $IPAddress

    if ($arpResult) {
        # Extract the MAC address from the ARP output
        $macAddress = ($arpResult -split '\s+')[2]
        Write-Output "The MAC address for $IPAddress is: $macAddress"
    }
    else {
        Write-Output "MAC address not found in ARP cache."
    }
}
else {
    Write-Output "Ping to $IPAddress failed."
}