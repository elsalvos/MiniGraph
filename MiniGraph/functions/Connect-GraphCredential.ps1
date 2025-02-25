﻿function Connect-GraphCredential {
    <#
    .SYNOPSIS
        Connect to graph using username and password.
    
    .DESCRIPTION
        Connect to graph using username and password.
        This logs into graph as a user, not as an application.
        Only cloud-only accounts can be used for this workflow.
        Consent to scopes must be granted before using them, as this command cannot show the consent prompt.
    
    .PARAMETER Credential
        Credentials of the user to connect as.
        
    .PARAMETER TenantID
        The Guid of the tenant to connect to.

    .PARAMETER ClientID
        The ClientID / ApplicationID of the application to use.
    
    .PARAMETER Scopes
        The permission scopes to request.
    
    .EXAMPLE
        PS C:\> Connect-GraphCredential -Credential max@contoso.com -ClientID $client -TenantID $tenant -Scopes 'user.read','user.readbasic.all'
        
        Connect as max@contoso.com with the rights to read user information.
    #>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[System.Management.Automation.PSCredential]
		$Credential,
		
		[Parameter(Mandatory = $true)]
		[string]
		$ClientID,
		
		[Parameter(Mandatory = $true)]
		[string]
		$TenantID,
		
		[string[]]
		$Scopes = 'user.read'
	)
	
	$request = @{
        client_id = $ClientID
        scope = $Scopes -join " "
        username = $Credential.UserName
        password = $Credential.GetNetworkCredential().Password
        grant_type = 'password'
    }
    
	try { $answer = Invoke-RestMethod -Method POST -Uri "https://login.microsoftonline.com/$TenantID/oauth2/v2.0/token" -Body $request -ErrorAction Stop }
	catch { $PSCmdlet.ThrowTerminatingError($_) }
	$script:token = $answer.access_token
}