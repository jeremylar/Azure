#Set Execution Policy
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

#ImportModules
Import-Module ExchangeOnlineManagement
Import-Module ActiveDirectory
Install-Module Microsoft.Graph -Scope AllUsers
Import-Module ADSync
#Connect to Instances
Connect-ExchangeOnline
Connect-Graph -Scopes User.ReadWrite.All, Organization.Read.All

$TargetOU = "OU=Disabled-No-O365Sync,DC=domain,DC=org"
$aduseraccounts = @("<list of user accounts>")

foreach($aduseraccount in $aduseraccounts)
{
$ADUser = Get-ADUser -Identity $aduseraccount
$UPN = $ADUser.UserPrincipalName
$GUID = $ADUser.objectGUID

write-host($UPN)

#Remove AD User Group Memberships
Get-AdPrincipalGroupMembership -Identity $GUID | Where-Object -Property Name -Ne -Value 'Domain Users' | Remove-AdGroupMember -Members $GUID -Confirm:$False

#AD Hide from gal
Set-ADUser -identity $GUID -Replace @{msExchHideFromAddressLists=$true}


#Office365 change mailbox type to Shared
Set-Mailbox $UPN -Type Shared


#remove licenses from office365
$licensesToRemove = Get-MgUserLIcenseDetail -UserId $UPN | Select -ExpandProperty SkuId
foreach($license in $licensesToRemove){Set-MgUserLicense -UserId $UPN -RemoveLicenses $license -AddLicenses @{} }


#AD move ou that does not sync
Move-ADObject -Identity $GUID -TargetPath $TargetOU
}


Start-ADSyncSyncCycle -PolicyType Delta

Start-Sleep -Seconds 60

foreach($aduseraccount in $aduseraccounts)
{
$ADUser = (Get-ADUser -Identity $aduseraccount)
$UPN = $ADUser.UserPrincipalName
$GUID = $ADUser.objectGUID
$NewUPN = $UPN.split(".")[0]+"org.onmicrosoft.com"
#Office365 restore deleted account
$deletedazureid = Get-MGDirectoryDeletedItemAsUser | Where-Object {$_.Mail -eq $UPN} | Select -ExpandProperty Id
Restore-MgDirectoryDeletedItem -DirectoryObjectId $deletedazureid

Set-Mailbox $UPN -ImmutableId $NewUPN
Set-Mailbox $UPN -HiddenFromAddressListsEnabled $True


#change immutableID to email address
Write-Host("UPN: "+$UPN)
Write-Host("NewUPN: "+$NewUPN)
}
