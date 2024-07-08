Connect-MgGraph -Tenant tenant.onmicrosoft.com -Scopes User.ReadWrite.All

$findsku = Get-MgSubscribedSku -All | Where SkuPartNumber -eq '<name of license>'

$addLicenses = @( @{SkuId = 'd9d89b70-a645-4c24-b041-8d3cb1884ec7'}, @{SkuId = '078d2b04-f1bd-4111-bbd4-b4b1b354cef4'})
$userlist = @("<userlist(FQDN)>")

foreach ($user in $userlist){
Update-MgUser -UserId $user -UsageLocation US
Set-MGUserLicense -UserID $user -AddLicenses $addLicenses -RemoveLicenses @()
}
