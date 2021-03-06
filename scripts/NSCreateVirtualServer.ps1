<#
    
Copyright © 2014 Citrix Systems, Inc. All rights reserved.

.SYNOPSIS
This script will create and configure a Netscaler Gateway virtual server for a new Tenant.

.DESCRIPTION

.NOTES
    KEYWORDS: PowerShell, Citrix
    REQUIRES: PowerShell Version 2.0 

.LINK
     http://community.citrix.com/
#>
Param (
    [Parameter(Mandatory=$true)]
    [string]$NsIp,
    [Parameter(Mandatory=$true)]
    [string]$NetScalerAddress,
    [Parameter(Mandatory=$true)]
    [string]$TenantDomain,
    [string]$EnterpriseDomain,
    [string]$NsUser = "nsroot",
    [string]$NsPassword = "nsroot"
)

function Install-PuTTY {   

    $file = "putty-0.63-installer.exe"
    $Url = "https://s3.amazonaws.com/citrix-cloudworks/$file"
    $installer = "$Env:Temp\$file"

    try {

        (New-Object System.Net.WebClient).DownloadFile($Url, $installer)
    } catch {
        Write-Error $error[0]
    }
    Start-ProcessAndWait -FilePath $installer -ArgumentList "/silent"

    Remove-Item -Path $installer
}
 
$ErrorActionPreference = "Stop"
Import-Module CloudworksTools
Install-PuTTY
$putty = "C:\Program Files (x86)\PuTTY"
if (-not (Test-Path $putty)) {
    Install-PuTTY
} 
$here = Split-Path -Path $MyInvocation.MyCommand.Path -Parent
$nshost = "${NsUser}@${NsIp}"

$tenant = $TenantDomain.Split('.')[0]
$tenantIp = (Get-Ipv4Address -DnsName $TenantDomain)[0]
$tenantDN = ConvertTo-DistinguishedName $TenantDomain

$NetScalerIP = (Get-Ipv4Address -DnsName $NetScalerAddress)[0]

$script = @"
# Add name server to resolve tenant names
add dns nameServer $tenantIp

# Add certificate and link to CA chain
add ssl certKey $tenant-certificate -cert "/nsconfig/ssl/$tenant-gateway.cer" -key "/nsconfig/ssl/cc-ns01.key" -passcrypt RgWSKLa4Y9ewDGhucN5YRA==
link ssl certKey $tenant-certificate CITRITEIssuingCA01

# Create Authentication Server and Policy for tenant resource domain
add authentication ldapAction $tenant-dc -serverIP $tenantIp -ldapBase "$tenantDN" -ldapBindDn Administrator@$TenantDomain -ldapBindDnPassword fd2604527edf7371a2 -encrypted -ldapLoginName samAccountName -groupAttrName memberOf -subAttributeName CN -ssoNameAttribute userPrincipalName
add authentication ldapPolicy $tenant-policy ns_true $tenant-dc

# Create session profile and policy
add vpn sessionAction $tenant-sessionprofile -wihome "http://xdc01.$TenantDomain/Citrix/StoreWeb" -defaultAuthorizationAction ALLOW -proxy BROWSER -forceCleanup none -clientOptions all -clientConfiguration all -SSO ON -icaProxy ON -wiPortalMode NORMAL -clientlessVpnMode ON -clientlessPersistentCookie ALLOW
add vpn sessionPolicy $tenant-sessionpolicy ns_true $tenant-sessionprofile

# Create virtual server
add vpn vserver $tenant-gateway SSL $NetScalerIP 443 -doubleHop ENABLED -downStateFlush DISABLED -cginfraHomePageRedirect DISABLED
set ssl vserver $tenant-gateway -tls11 DISABLED -tls12 DISABLED

bind ssl vserver $tenant-gateway -certkeyName $tenant-certificate

# Bind the authentication policies, session policies and STA to the gateway
bind vpn vserver $tenant-gateway -policy $tenant-policy -priority 100
bind vpn vserver $tenant-gateway -policy $tenant-sessionpolicy -priority 100
bind vpn vserver $tenant-gateway -staServer "http://xdc01.$TenantDomain"
"@

if ($EnterpriseDomain) {

    $enterprise = $EnterpriseDomain.Split('.')[0]
    $enterpriseDN = ConvertTo-DistinguishedName $EnterpriseDomain
    $enterpriseIp = (Get-Ipv4Address -DnsName $EnterpriseDomain)[0]

    $script += @"

# Add name server to resolve enterprise names
add dns nameServer $enterpriseIp

# Create Authentication Server and Policy for enterprise domain
add authentication ldapAction $enterprise-dc -serverIP $enterpriseIp -ldapBase "$enterpriseDN" -ldapBindDn Administrator@$EnterpriseDomain -ldapBindDnPassword fd2604527edf7371a2 -encrypted -ldapLoginName samAccountName -groupAttrName memberOf -subAttributeName CN -ssoNameAttribute userPrincipalName
add authentication ldapPolicy $enterprise-policy ns_true $enterprise-dc

# Bind the entperise authentication policy
bind vpn vserver $tenant-gateway -policy $enterprise-policy -priority 110

"@
}

$scriptFile = [IO.Path]::GetTempFileName()
$script | Out-File -Encoding ASCII $scriptFile

# Accept server certificate
echo y | &$putty\plink -pw $NsPassword $nshost exit | Out-Null

# This converts Windows to Unix line endings
&$putty\pscp -batch -pw $NsPassword $here\convert-eol.sh "${nshost}:/root"
&$putty\plink -batch -pw $NsPassword $NsHost shell chmod a+x convert-eol.sh

# This is the NS script to execute (see above)
&$putty\pscp -pw $NsPassword $scriptFile "${nshost}:/root/tenant-setup.nscmd"
&$putty\plink -batch -pw $NsPassword $nshost shell ./convert-eol.sh tenant-setup.nscmd

&$putty\plink -batch -pw $NsPassword $nshost source tenant-setup.nscmd

Remove-Item -Path $scriptFile