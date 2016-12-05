<#
.Synopsis
   Allows you to retrieve win32_bios information from multiple Computers
.DESCRIPTION
   Commandlet uses an Active Directory query to return a Computer names as plain strings.
   It then will use the invoke-command to retrieve the win32_bios information on each object.
.EXAMPLE
   Display to the screen all the Serial Numbers for each computer starting with LTCKEITHLAB
   Get-ADInventory -searchParameter LTCKEITHLAB*

.EXAMPLE
   Save as a CSV file all the Serial Numbers for each computer starting with LTCKEITHLAB
   Get-ADInventory -searchParameter LTCKEITHLAB* -outFileName test.csv

.EXAMPLE
   Display to the screen for each computer starting with LTCKEITHLAB all the Properties of win32_bios
   Get-ADInventory -searchParameter LTCKEITHLAB* -Property *
#>

function Get-ADInventory
{
    param (
        [Parameter(Mandatory=$True)]
        [String]$searchParameter,
        [Parameter()]
        [String]$outFileName,
        [Parameter()]
        [String[]]$Property = ("PSComputerName", "SerialNumber")
    )

    $PClist = (Get-ADComputer -Filter "Name -like '$searchParameter'" | Select-Object -ExpandProperty Name)
    Write-Verbose "Following PC's were found on Active Directory `n$PClist"

    $PCInfo = Invoke-Command -ComputerName $PClist {Get-WmiObject -Class win32_bios | Select-Object -Property $Property}

    if ($outFileName -eq ""){
        $PCInfo | Select-Object -Property $Property | Sort-Object -Property PSComputerName
        }
    elseif ($outFileName.Contains(".csv")){
        $PCInfo | Select-Object -Property $Property | Sort-Object -Property PSComputerName |
        Export-Csv -Path ".\$outFileName"
    }
    elseif ($outFileName.Contains(".htm")){
        $PCInfo | Select-Object -Property $Property | Sort-Object -Property PSComputerName |
        ConvertTo-Html > ".\$outFileName"
    }
    else{
        $PCInfo | Select-Object -Property $Property | Sort-Object -Property PSComputerName |
        Out-File ".\$outFileName"
    }
} # End Function Get-ADInventory

function Get-ADQuery
{
    param (
        [Parameter(Mandatory=$True)]
        [String]$searchParameter,
        [Parameter()]
        [ValidateSet("String","Object")]
        [String]$Type = "Object",
        [Parameter()]
        [String[]]$Property = "*"
    )
    
    if ($Type -eq "String"){
        Get-ADComputer -Filter "Name -like '$searchParameter'" | Select-Object -ExpandProperty Name
    }
    else{
        Get-ADComputer -Filter "Name -like '$searchParameter'" | Select-Object -Property $Property
    }
} # End Function Get-ADQuery
