# This script will remove all shared printers from a particular print server
# Useful if an old print server has been renamed or retired and you want to remove all lingering printers from client computers

# Enter the name of the Print Server that hosted all the printers you want to remove
$PrintServer = "PServer"

#--------------------------------------------------------------------------------------#

# Loop through all printers and remove any with the printer name containing the print server
$Printers = Get-WmiObject -Class Win32_Printer
ForEach ($Printer in $Printers) {
    If ($Printer.SystemName -like "\\$PrintServer") {
        Write-Host "Removing" $Printer.Name
        (New-Object -ComObject WScript.Network).RemovePrinterConnection($($Printer.Name))   
    }
}