<#
    Copyright © 2014 Citrix Systems, Inc. All rights reserved.

.SYNOPSIS
 This script will create/delete a scheduled task to mount the specified ISO on boot. 

.DESCRIPTION

.NOTES
    KEYWORDS: PowerShell, Citrix
    REQUIRES: PowerShell Version 2.0 

.LINK
     http://community.citrix.com/
#>
Param ( 
    [switch]$Create,
    [Parameter(Mandatory=$true)]
    [string]$IsoPath,
    [switch]$Delete
)
$task = 'IsoMount'

$ErrorActionPreference = "Stop"
$args = "-IsoPath $IsoPath"
$command = "C:\cfn\scripts\MountIso.cmd"

if ($Create) { 
    Start-Process -FilePath $command -ArgumentList $args -Wait
    schtasks.exe /create /tn $task /sc onstart /tr "$command $args" /ru SYSTEM    
    
} elseif ($Delete) {
    schtasks.exe /delete /tn $task /F
    $args = "-Eject $args"
    Start-Process -FilePath $command -ArgumentList $args -Wait
} else {
    Write-Warning "No ISO task option selected"
}