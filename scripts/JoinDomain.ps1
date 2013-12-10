<#
    
Copyright © 2013 Citrix Systems, Inc. All rights reserved.

.SYNOPSIS
This script will join the specified domain

.DESCRIPTION

.NOTES
    KEYWORDS: PowerShell, Citrix
    REQUIRES: PowerShell Version 2.0 

.LINK
     http://community.citrix.com/
#>
Param (
    [Parameter(Mandatory=$true)]
    [string]$DomainName,    
    [Parameter(Mandatory=$true)]
    [string]$UserName,  
    [Parameter(Mandatory=$true)]
    [string]$Password,  
    [scriptblock]$OnBoot,   
    [switch]$Reboot = $true
)

$ErrorActionPreference = "Stop"
Import-Module CloudworksTools

Start-Logging
try {
    if (-not $UserName.Contains('\') -and -not $UserName.Contains('@')) {
        $UserName = "$DomainName\$UserName"
    }
    $securePassword = ConvertTo-SecureString $Password -AsPlainText -Force 
    $DomainCredentials = New-Object System.Management.Automation.PSCredential $UserName, $securePassword
    Write-Output "Adding computer to domain $DomainName with credentials from $UserName"   
    Add-Computer -DomainName $DomainName -Credential $DomainCredentials
    if ($OnBoot) {
        New-RunOnceTask $OnBoot
    }
} 
finally {
    Stop-Logging
}
if ($Reboot) {
    Restart-Computer -Force
}
