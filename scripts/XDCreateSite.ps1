<#
    Copyright © 2013 Citrix Systems, Inc. All rights reserved.

.SYNOPSIS
    This script will create a XenDesktop database and site.

.DESCRIPTION
    ...

.NOTES
    KEYWORDS: PowerShell, Citrix
    REQUIRES: PowerShell Version 2.0 

.LINK
     http://community.citrix.com/
#>
Param (
    [string]$SiteName = "CwSite",
    [string]$DatabaseServer = ".\SQLEXPRESS",
    [string]$LicenseServer = "license01.cloudworks.net",
    [int]$LicenseServerPort = 27000
)

Import-Module Citrix.XenDesktop.Admin

New-XDDatabase -AllDefaultDatabases -DatabaseServer $DatabaseServer -SiteName $SiteName  

New-XDSite -AllDefaultDatabases -DatabaseServer $DatabaseServer -SiteName $SiteName

Set-XDLicensing -LicenseServerAddress $LicenseServer -LicenseServerPort $LicenseServerPort