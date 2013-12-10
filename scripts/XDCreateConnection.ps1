<#
    Copyright © 2013 Citrix Systems, Inc. All rights reserved.

.SYNOPSIS
    This script will create a connection to a cloud.

.DESCRIPTION
    ...

.NOTES
    KEYWORDS: PowerShell, Citrix
    REQUIRES: PowerShell Version 2.0 

.LINK
     http://community.citrix.com/
#>
Param (
    [string]$ConnectionName = "CwConnection",
    [string]$CloudUrl =  "http://192.168.2.1:8080/client/api",
    [string]$ApiKey = "NTbOqdGSM2KWzS0GIMO9fBO6TiKb2oEKo59t7hmPWNna4rQtftX3sarCO-sAMXfL8l3zm55mND__53bV-wyZrA",
    [string]$SecretKey = "G379F22wYG_ISyG4Y-0saikSyUQNf9hVozwcep-LqsGNRvSBx81bN-mZ1bDyckMYNItYypIfzjU-MlFrS5IEIw",
    [string]$ConnectionType = "CloudPlatform"
)
$ErrorActionPreference = "Stop"
Add-PSSnapin -Name Citrix.Host.Admin.V2

$connection = Get-Item -Path "xdhyp:\Connections\*" | Where-Object {$_.PSChildName -eq $ConnectionName}
if ($connection -eq $null) {
   New-Item -Path "xdhyp:\Connections" -Name $ConnectionName -Type $ConnectionType -HypervisorAddress $CloudUrl -UserName $ApiKey - Password $Secretkey -Persist
} else {
    "Connection $ConnectionName already exists"
}

