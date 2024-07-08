#import-module ActiveDirectory
#Import-Module ExchangeOnlineManagement
#Connect-ExchangeOnline
#Connect-MsolService

#SamAccountName
$aduseraccount = "AD User Name"

#Get ADUser
$ADUser = (Get-ADUser -Identity $aduseraccount)

#Get ADUser UserPrincipalName
$UPN = $ADUser.UserPrincipalName

#Get ADUser GUID
$GUID = $ADUser.objectGUID

#Set-Mailbox -Identity $user -Type Shared

#If Changing UPN to .onmicrosoft account
$NewUPN = $UPN.split(".")[0]+".onmicrosoft.com"
Write-Host("Created New UserPrincipalName: "+$NewUPN)

#Define Distinguished Name of target OU
$TargetOU = "OU=NoAADSync,DC=domain,DC=local"

#move user to unsynced OU in AD
Move-ADObject -Identity $GUID -TargetPath $TargetOU
Write-Host("Modified User: "+$UPN)

#At this point user should be soft deleted in office 365
Restore-MsolUser -UserPrincipalName $UPN

#Change ImmutableID to something different than AD GUID
Set-MsolUser -UserPrincipalName $UPN -ImmutableId $UPN
#Set-MsolUserPrincipalName -UserPrincipalName $UPN -NewUserPrincipalName $NewUPN

#Verify new Immutable ID
Get-MsolUser -UserPrincipalName $UPN | Select ImmutableID
