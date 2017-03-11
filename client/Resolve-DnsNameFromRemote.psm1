<#
    A Powershell client for the the Python REST server.

    https://github.com/magnuswatn/remotedns
#>

Function Resolve-DnsNameFromRemote {
    <#
    .Synopsis
       Does a remote DNS lookup
    .DESCRIPTION
        Resolves a DNS name from the point of view of a remote server
    .EXAMPLE
       Resolve-DnsNameFromRemote github.com
       
       Resolves github.com from the remote server
    .EXAMPLE
       Resolve-DnsNameFromRemote github.com -Type MX -Server 8.8.8.8
       
       Resolves the MX record for github.com against 8.8.8.8 from the remote server
    .INPUTS
       A DNS name, and optionally a type and/or a server 
    .OUTPUTS
       The results of the query
    .NOTES
       You must have the following variables defined in your Powershell profile:
       ResolveDnsNameFromRemote_URL
       ResolveDnsNameFromRemote_Username
       ResolveDnsNameFromRemote_Password

       See https://github.com/magnuswatn/remotedns for more information
    #>
    [cmdletbinding()]
    Param([Parameter(mandatory=$true)][String]$Name,
          [Parameter(mandatory=$false)][String]$Type,
          [Parameter(mandatory=$false)][String]$Server)

    $ErrorActionPreference = "Stop"
    $oldtlsprotocols = [Net.ServicePointManager]::SecurityProtocol
    [Net.ServicePointManager]::SecurityProtocol = 'tls12'

    # If no Type specified, try to see if the Name is an ipaddress, and do an in-addr-arpa lookup
    if (!($Type)) {
        try {
            $ipadress = [ipaddress]$Name

        } catch {
            $ipadress = $null
        }
        if ($ipadress) {
            $Type = 'PTR'
            $octets = $ipadress.GetAddressBytes()
            $Name = "$($octets[3]).$($octets[2]).$($octets[1]).$($octets[0]).in-addr.arpa"
        } else {
            $Type = 'A'
        }
    }

    $basicauth = [System.Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$($ResolveDnsNameFromRemote_Username):$($ResolveDnsNameFromRemote_Password)"))
    $basicauthheader = @{Authorization = "Basic $($basicauth)"}

    $URI = "$($ResolveDnsNameFromRemote_URL)/$($Type)/$($Name)" -replace "(?<!:)\/\/", "/" # ugly hack to avoid double slashes
    if ($Server) {
       $URI += "?server=$($server)"
    }

    try {
        $answer = Invoke-RestMethod -Uri $URI -Headers $basicauthheader
    } catch {
        throw
    } finally {
        [Net.ServicePointManager]::SecurityProtocol = $oldtlsprotocols
    }

    $answer.answer | foreach {
        "$_"
    }
    
}

Export-ModuleMember Resolve-DnsNameFromRemote
