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

# If connection success , password reset user from AD
  try {
    $myCredential = Get-AutomationPSCredential -Name 'windows-ad'
    $userName = $myCredential.UserName
    $securePassword = $myCredential.Password
    $pdc = Get-ADDomainController -Discover -Service PrimaryDC -ErrorAction Stop
    $server = $pdc.HostName[0]
  $Credential = New-Object System.Management.Automation.PSCredential ($userName,$securePassword)
  $PasswordReset = Get-ADUser -Filter {UserPrincipalName -eq $UPN} -Server $server -Credential $Credential -ErrorAction Stop| Set-ADUser -ChangePasswordAtLogon $true -ErrorAction Stop
  }
  catch {
   $ErrorMessage = $_.Exception.Message
    Write-Output "ErrorMessage : " $ErrorMessage
    Exit
  }

# Wait for 1 min
Start-Sleep -s 60

# confirm user password reset action
  try {
    $myCredential = Get-AutomationPSCredential -Name 'windows-ad'
    $userName = $myCredential.UserName
    $securePassword = $myCredential.Password
    $pdc = Get-ADDomainController -Discover -Service PrimaryDC -ErrorAction Stop
    $server = $pdc.HostName[0]
  $Credential = New-Object System.Management.Automation.PSCredential ($userName,$securePassword)
  $getuser = Get-ADUser -Filter {UserPrincipalName -eq $UPN} -Server $server -Credential $Credential -ErrorAction Stop -Properties *|select Description,Name,Enabled,UserPrincipalName,admincount,pwdlastset| ConvertTo-JSON 
  }
  catch {
   $ErrorMessage = $_.Exception.Message
    Write-Output "ErrorMessage : " $ErrorMessage
    Exit
  }
  return $getuser
