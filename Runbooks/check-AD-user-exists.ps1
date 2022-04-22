Param(
   [String]$UPN
  )
# Test connection to Domain Controller
try { 
    $pdc = Get-ADDomainController -Discover -Service PrimaryDC -ErrorAction Stop
    $server = $pdc.HostName[0]
    $test = Test-ComputerSecureChannel -Server $server -ErrorAction Stop 
}
catch {
$ErrorMessage = $_.Exception.Message
 Write-Output "ErrorMessage : " $ErrorMessage
 Exit
}

# Get user info from AD
  try {
    $myCredential = Get-AutomationPSCredential -Name 'windows-ad'
    $userName = $myCredential.UserName
    $securePassword = $myCredential.Password
  $Credential = New-Object System.Management.Automation.PSCredential ($userName,$securePassword)
  $getuser = Get-ADUser -Filter "UserPrincipalName -like '*$UPN*'" -Server $server -Credential $Credential -ErrorAction Stop|Select Name,Enabled,UserPrincipalName,SamAccountName| ConvertTo-JSON
  }
  catch {
   $ErrorMessage = $_.Exception.Message
    Write-Output "ErrorMessage : " $ErrorMessage
    Exit
  }
return $getuser
