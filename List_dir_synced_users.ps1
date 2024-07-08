#Set Execution Policy
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

#ImportModules
Import-Module ExchangeOnlineManagement
Import-Module ActiveDirectory
Install-Module Microsoft.Graph -Scope AllUsers
#Connect to Instances
Connect-ExchangeOnline
Connect-Graph -Scopes User.ReadWrite.All, Organization.Read.All
$exportusers=@()

$adusers = Get-ADUser -Filter {(Enabled -eq $False)} | Where-Object {$_.DistinguishedName -like "*OU=Disabled-No-O365Sync,DC=domain,DC=local"}
$mailboxusers = Get-Mailbox | Where-Object { $_.IsDirSynced -eq "True"}
foreach($aduser in $adusers){
	write-host($aduser.UserPrincipalName)
	foreach($mailboxuser in $mailboxusers){
		
		if($aduser.UserPrincipalName -eq $mailboxuser.UserPrincipalName)
		{
			write-host($mailboxuser.UserPrincipalName+", "+ $mailboxuser.RecipientTypeDetails+", "+ $mailboxuser.ForwardingAddress)
		}	
	}
}
