function check-fastboot {
  $Hiberbootstatus = (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -Name "HiberbootEnabled").HiberbootEnabled
  $hiberboot = $null
if ($Hiberbootstatus -eq 1){
    $hiberboot = "Enabled"
} #if
elseif ($Hiberbootstatus -eq 0) {
    $hiberboot = "Disabled"
} #elseif
else {
Write-host "Cannot find value from registery"
exit 1001
}#else
    $hiberboot
} #function

function disable-fastboot {
  $status = check-fastboot
if ($status -eq "Enabled") {
    REG ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v HiberbootEnabled /t REG_DWORD /d "0" /f
    write-host "Disabled Fastboot"
    exit 0
} #if
elseif ($status -eq "Disabled") {
    write-host "Fastboot is already Disabled"
    exit 0
} #else
} #function

function enable-fastboot {
  $status = check-fastboot
if ($status -eq "Disabled") {
    REG ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v HiberbootEnabled /t REG_DWORD /d "1" /f
    write-host "Enabled Fastboot"
}#if
elseif ($status -eq "Enabled") {
    write-host "Fastboot is already Enabled"
    exit 0
} #elseif
} #function

#check-fastboot
disable-fastboot
#enable-fastboot