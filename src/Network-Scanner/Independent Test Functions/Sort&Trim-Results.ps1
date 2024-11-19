#Create a test results array, one address with no results

$pingResults = @(
    [PSCustomObject]@{
        IPAddress = "192.168.1.5"
        Status    = "Unreachable"
        DNSName   = "N/A"
    },
    [PSCustomObject]@{
        IPAddress = "192.168.1.3"
        Status    = "Unreachable"
        DNSName   = "N/A"
    }
    [PSCustomObject]@{
        IPAddress = "192.168.1.2"
        Status    = "Reachable"
        DNSName   = "PC"
    }
    [PSCustomObject]@{
        IPAddress = "192.168.1.1"
        Status    = "Reachable"
        DNSName   = "Router"
    }
)

#Sort Results by IP Address, sort by version instead of string otherwise IP addresses won't sort properly
$sortedResults = $pingResults | Sort-Object { $_.IPAddress -as [Version]}

# Filter out objects without a response
$filteredResults = $sortedResults | Where-Object { $_.Status -eq "Reachable"}

# Display the filtered results
Write-Host ($filteredResults | Format-Table | Out-String)