<#
    Copyright © 2013 Citrix Systems, Inc. All rights reserved.

.SYNOPSIS
Diagnostic script to report Dns config

.DESCRIPTION

.NOTES
    KEYWORDS: PowerShell, Citrix
    REQUIRES: PowerShell Version 2.0 

.LINK
     http://community.citrix.com/
#>
$result = @{}
[System.Net.NetworkInformation.NetworkInterface]::GetAllNetworkInterfaces() | 
    Where {
        ($_.OperationalStatus -eq [System.Net.NetworkInformation.OperationalStatus]::Up) -and
        ($_.NetworkInterfaceType -eq [System.Net.NetworkInformation.NetworkInterfaceType]::Ethernet) 
    } | 
    ForEach-Object { 
      
        $dns = $_.GetIPProperties() | Select DnsAddresses | ForEach-Object {$_.DnsAddresses | ForEach-Object { $_.IPAddressToString } }
        $result.Add($_.Name, $dns)       
    }
$result