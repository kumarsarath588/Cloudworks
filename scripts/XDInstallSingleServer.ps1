<#
    
Copyright © 2013 Citrix Systems, Inc. All rights reserved.

.SYNOPSIS
This script will install XenDesktop on the local machine

.DESCRIPTION

.NOTES
    KEYWORDS: PowerShell, Citrix
    REQUIRES: PowerShell Version 2.0 

.LINK
     http://community.citrix.com/
#>

Param (
    [string]$InstallerPath = "D:\x64\XenDesktop Setup\"
)

function Install-DotNet () {
    try {
       $dotnet351 = "AS-NET-Framework"
       Import-Module ServerManager   
       $feature = Get-WindowsFeature | Where-Object {$_.Name -eq $dotnet351}
       if (-not $feature.Installed) {
           Add-WindowsFeature $dotnet351
       }
    } catch {
      Write-Log "Error attempting to install .NET 3.5.1"
      throw
    }
}

#
# Main
#
$ErrorActionPreference = "Stop"
Import-Module CloudworksTools
Start-Logging
try { 
     # Seems to be a problem with the installation of pre-requisites if .NET 3.5.1 not installed.
    Install-DotNet

    $installargs = "/components controller,desktopstudio,storefront /quiet /configure_firewall /noreboot"
    $installer = Join-Path -Path $InstallerPath -ChildPath "XenDesktopServerSetup.exe"
    Start-ProcessAndWait $installer $installargs
} 
finally {
    Stop-Logging
}