# Clear and restart the Print Spooler

# Specify if you want to backup the contents of the print spooler
[bool]$backup = false
# Specify if you want to restart the computer after clearing the print spooler
[bool]$restart = false
# Specify the path to backup the print spooler to
$backupPath = 'C:\spool-backup'

#--------------------------------------------------------------------------------------#

# Stop Print Spooler
Stop-Service -Name Spooler -Force
# Wait 10 Seconds for spooler to stop
Start-Sleep -Seconds 10

if ($backup -eq $true) {
    # To backup the files
    Move-Item -Path "$env:SystemRoot\System32\spool\PRINTERS\*.*" -Destination $backupPath -Force
}
elseif ($backup -eq $false) {
    # To delete the files
    Remove-Item -Path "$env:SystemRoot\System32\spool\PRINTERS\*.*"
}

Start-Service -Name Spooler

if ($restart -eq $true) {
    # Wait 30 Seconds and restart PC
    Start-Sleep -Seconds 30
    Restart-Computer
}
