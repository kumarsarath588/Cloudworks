<#
    Copyright © 2013 Citrix Systems, Inc. All rights reserved.

.SYNOPSIS
This script will set params in the DT2 web.config file.

.DESCRIPTION

.NOTES
    KEYWORDS: PowerShell, Citrix
    REQUIRES: PowerShell Version 2.0 

.LINK
     http://community.citrix.com/
#>
Param ( 
    
    [string]$Path = "C:\inetpub\wwwroot\Citrix\DT2\Web.config",
    [string]$CloudStackUrl,
    [string]$ApiKey,
    [string]$SecretKey,
    [string]$ZoneId,
    [string]$Hypervisor,
    [string]$XenDesktopAdminAddress,
    [string]$XenDesktopHostingUnitPath
)

function SetValue($doc, $name, $value) {
    if (($value -ne $null) -and ($value -ne "")) {
        Write-Host "$name has value ""$value"""
        $node = $doc.SelectSingleNode("//setting[@name='$name']/value")
        $node."#text" = $value
    }
}

$ErrorActionPreference = "Stop"

[xml]$doc = Get-Content $Path

SetValue $doc "CloudStackUrl" $CloudStackUrl
SetValue $doc "CloudStackApiKey" $ApiKey
SetValue $doc "CloudStackSecretKey" $SecretKey
SetValue $doc "CloudStackZoneId" $ZoneId
SetValue $doc "CloudStackHypervisor" $Hypervisor
SetValue $doc "XenDesktopAdminAddress" $XenDesktopAdminAddress
SetValue $doc "XenDesktopHostingUnitPath" $XenDesktopHostingUnitPath

$doc.Save($Path)
