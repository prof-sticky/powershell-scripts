# Define common ports with services
$commonPorts = @(
    [pscustomobject]@{service = "FTP"; port = 21 },
    [pscustomobject]@{service = "SSH"; port = 22 },
    [pscustomobject]@{service = "Telnet"; port = 23 },
    [pscustomobject]@{service = "SMTP"; port = 25 },
    [pscustomobject]@{service = "DNS"; port = 53 },
    [pscustomobject]@{service = "HTTP"; port = 80 },
    [pscustomobject]@{service = "POP3"; port = 110 },
    [pscustomobject]@{service = "SFTP"; port = 115 },
    [pscustomobject]@{service = "RPC"; port = 135 },
    [pscustomobject]@{service = "NetBIOS"; port = 139 },
    [pscustomobject]@{service = "IMAP"; port = 143 },
    [pscustomobject]@{service = "HTTPS"; port = 443 },
    [pscustomobject]@{service = "SMB"; port = 445 },
    [pscustomobject]@{service = "SQL"; port = 3306 },
    [pscustomobject]@{service = "Microsoft RDP"; port = 3389 },
    [pscustomobject]@{service = "VNC"; port = 5900 }
)

function Scan-Ports {
    param (
        [string]$address
    )
    # Scan each port in commonports array
    foreach ($entry in $commonPorts) {
        # Test-NetConnection works, but takes around 10 seconds to give up probing a blocked port which can be pretty slow when trying many
        # $result = Test-NetConnection -ComputerName $address -Port $entry.port -InformationLevel Quiet
        # This method is much faster
        $result = (New-Object System.Net.Sockets.TcpClient).ConnectAsync($address, $entry.port).Wait(100)
        if ($result) {
            Write-Host "Service: $($entry.service), Port: $($entry.port), Open" -ForegroundColor Green
        }
        else {
            Write-Host "Service: $($entry.service), Port: $($entry.port), Closed" -ForegroundColor Red
        }
    }

}

$address = Read-Host -Prompt "Enter Address or IP Address to scan:" 

Scan-Ports -address $address