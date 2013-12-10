<#
    Copyright © 2013 Citrix Systems, Inc. All rights reserved.

.SYNOPSIS
This script will reset the passsword on the specified local user account

.DESCRIPTION

.NOTES
    KEYWORDS: PowerShell, Citrix
    REQUIRES: PowerShell Version 2.0 

.LINK
     http://community.citrix.com/
#>
Param ( 
    [string]$UserName,
    [string]$Password
)

$ErrorActionPreference = "Stop"
$computername = (Get-WmiObject win32_computersystem).Name
$account = [adsi]"WinNT://$computername/$UserName"
$account.SetPassword($Password)