#Requires -RunAsAdministrator
<#
1.2.1.1 Windows - Werkstation - Filesystem - Disk Cleanup Advanced
 
Stops the windows update service so that c:\windows\softwaredistribution can be cleaned up
Deletes the contents of windows software distribution.
Deletes the contents of the Windows Temp folder.
Deletes all files and folders in user's Temp folder older then 1 Day
Removes all files and folders in user's Temporary Internet Files older then 7 Days
Removes *.log from C:\windows\CBS
Removes IIS Logs older then 7 Days
Removes C:\Config.Msi
Removes c:\PerfLogs
Removes $env:windir\memory.dmp
Removes Windows Error Reporting files
Removes System and User Temp Files - lots of access denied will occur.
Cleans up c:\windows\temp
Cleans up minidump
Cleans up prefetch
Cleans up c:\temp
Cleans up windows.old
Cleans up old windows upgrade folders
Cleans up ESD Downloads
Cleans up ESD Windows
Cleans up old inplace update folders
Cleans up old updatelog folder
Cleans up each users temp folder
Cleans up all users windows error reporting
Cleans up users temporary internet files
Cleans up Internet Explorer cache
Cleans up Internet Explorer download history
Cleans up Internet Cache
Cleans up Outlook Roam Cache
Cleans up Chrome Cache for default user
Cleans up Chrome Cache for profile 1 user
Cleans up Chrome Cache for profile 2 user
Cleans up Chrome Cache for profile 3 user
Cleans up Internet Cookies
Cleans up terminal server cache
Cleans up the recycling bin.
Removes the hidden recycling bin.
Restarts the windows update service
Checks if the Windows update service is running, else tries to start the service again every 20 seconds.

#>

Function Start-Cleanup {


    ## Allows the use of -WhatIf
    [CmdletBinding(SupportsShouldProcess = $True)]

    param(
        ## Delete data older then $daystodelete
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, Position = 0)]
        $DaysToDelete = 7,

        ## LogFile path for the transcript to be written to
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, Position = 1)]
        $LogFile = ("$env:TEMP\" + (get-date -format "dd-mm-yyyy-HH-mm") + '-cleanup.log'),

        ## All verbose outputs will get logged in the transcript($logFile)
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, Position = 2)]
        $VerbosePreference = "Continue",

        ## All errors should be withheld from the console
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, Position = 3)]
        $ErrorActionPreference = "SilentlyContinue"
    )

    ## Begin the timer
    $Starters = (Get-Date)
    
    ## Check $VerbosePreference variable, and turns -Verbose on
    Function global:Write-Verbose ( [string]$Message ) {
        if ( $VerbosePreference -ne 'SilentlyContinue' ) {
            Write-Host "$Message" -ForegroundColor 'Green'
        }
    }

    ## Tests if the log file already exists and renames the old file if it does exist
    if (Test-Path $LogFile) {
        ## Renames the log to be .old
        Rename-Item $LogFile $LogFile.old -Verbose -Force
    }
    else {
        ## Starts a transcript in C:\temp so you can see which files were deleted
        Write-Host (Start-Transcript -Path $LogFile) -ForegroundColor Green
    }

    ## Writes a verbose output to the screen for user information
    Write-Host "Retriving current disk percent free for comparison once the script has completed.                 " -NoNewline -ForegroundColor Green
    Write-Host "[DONE]" -ForegroundColor Green -BackgroundColor Black

    ## Gathers the amount of disk space used before running the script
    $Before = Get-WmiObject Win32_LogicalDisk | Where-Object { $_.DriveType -eq "3" } | Select-Object SystemName,
    @{ Name = "Drive" ; Expression = { ( $_.DeviceID ) } },
    @{ Name = "Size (GB)" ; Expression = { "{0:N1}" -f ( $_.Size / 1gb) } },
    @{ Name = "FreeSpace (GB)" ; Expression = { "{0:N1}" -f ( $_.Freespace / 1gb ) } },
    @{ Name = "PercentFree" ; Expression = { "{0:P1}" -f ( $_.FreeSpace / $_.Size ) } } |
    Format-Table -AutoSize |
    Out-String

    ## Stops the windows update service so that c:\windows\softwaredistribution can be cleaned up
    Get-Service -Name wuauserv | Stop-Service -Force -ErrorAction SilentlyContinue -WarningAction SilentlyContinue -Verbose

    ## Deletes the contents of windows software distribution.
    Get-ChildItem "C:\Windows\SoftwareDistribution\*" -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -recurse -ErrorAction SilentlyContinue -Verbose
    Write-Host "The Contents of Windows SoftwareDistribution have been removed successfully!                      " -NoNewline -ForegroundColor Green
    Write-Host "[DONE]" -ForegroundColor Green -BackgroundColor Black

    ## Deletes the contents of the Windows Temp folder.
    Get-ChildItem "C:\Windows\Temp\*" -Recurse -Force -Verbose -ErrorAction SilentlyContinue |
    Where-Object { ($_.CreationTime -lt $(Get-Date).AddDays( - $DaysToDelete)) } | Remove-Item -force -recurse -ErrorAction SilentlyContinue -Verbose
    Write-host "The Contents of Windows Temp have been removed successfully!                                      " -NoNewline -ForegroundColor Green
    Write-Host "[DONE]" -ForegroundColor Green -BackgroundColor Black


    ## Deletes all files and folders in user's Temp folder older then $DaysToDelete
    Get-ChildItem "C:\users\*\AppData\Local\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue |
    Where-Object { ($_.CreationTime -lt $(Get-Date).AddDays( - $DaysToDelete)) } |
    Remove-Item -force -recurse -ErrorAction SilentlyContinue -Verbose
    Write-Host "The contents of `$env:TEMP have been removed successfully!                                         " -NoNewline -ForegroundColor Green
    Write-Host "[DONE]" -ForegroundColor Green -BackgroundColor Black

    ## Removes all files and folders in user's Temporary Internet Files older then $DaysToDelete
    Get-ChildItem "C:\users\*\AppData\Local\Microsoft\Windows\Temporary Internet Files\*" `
        -Recurse -Force -Verbose -ErrorAction SilentlyContinue |
    Where-Object { ($_.CreationTime -lt $(Get-Date).AddDays( - $DaysToDelete)) } |
    Remove-Item -Force -Recurse -ErrorAction SilentlyContinue -Verbose
    Write-Host "All Temporary Internet Files have been removed successfully!                                      " -NoNewline -ForegroundColor Green
    Write-Host "[DONE]" -ForegroundColor Green -BackgroundColor Black

    ## Removes *.log from C:\windows\CBS
    if (Test-Path C:\Windows\logs\CBS\) {
        Get-ChildItem "C:\Windows\logs\CBS\*.log" -Recurse -Force -ErrorAction SilentlyContinue |
        remove-item -force -recurse -ErrorAction SilentlyContinue -Verbose
        Write-Host "All CBS logs have been removed successfully!                                                      " -NoNewline -ForegroundColor Green
        Write-Host "[DONE]" -ForegroundColor Green -BackgroundColor Black
    }
    else {
        Write-Host "C:\windows\CBS does not exist, there is nothing to cleanup.                         " -NoNewline -ForegroundColor DarkGray
        Write-Host "[WARNING]" -ForegroundColor DarkYellow -BackgroundColor Black
    }

    ## Cleans IIS Logs older then $DaysToDelete
    if (Test-Path C:\inetpub\logs\LogFiles\) {
        Get-ChildItem "C:\inetpub\logs\LogFiles\*" -Recurse -Force -ErrorAction SilentlyContinue |
        Where-Object { ($_.CreationTime -lt $(Get-Date).AddDays(-60)) } | Remove-Item -Force -Verbose -Recurse -ErrorAction SilentlyContinue
        Write-Host "All IIS Logfiles over $DaysToDelete days old have been removed Successfully!                  " -NoNewline -ForegroundColor Green
        Write-Host "[DONE]" -ForegroundColor Green -BackgroundColor Black
    }
    else {
        Write-Host "C:\inetpub\logs\LogFiles does not exist, there is nothing to cleanup.                                 " -NoNewline -ForegroundColor DarkGray
        Write-Host "[WARNING]" -ForegroundColor DarkYellow -BackgroundColor Black
    }

    ## Removes C:\Config.Msi
    if (test-path C:\Config.Msi) {
        remove-item -Path C:\Config.Msi -force -recurse -Verbose -ErrorAction SilentlyContinue
    }
    else {
        Write-Host "C:\Config.Msi does not exist, there is nothing to cleanup.                                        " -NoNewline -ForegroundColor DarkGray
        Write-Host "[WARNING]" -ForegroundColor DarkYellow -BackgroundColor Black
    }

    ## Removes c:\PerfLogs
    if (test-path c:\PerfLogs) {
        remove-item -Path c:\PerfLogs -force -recurse -Verbose -ErrorAction SilentlyContinue
    }
    else {
        Write-Host "c:\PerfLogs does not exist, there is nothing to cleanup.                                          " -NoNewline -ForegroundColor DarkGray
        Write-Host "[WARNING]" -ForegroundColor DarkYellow -BackgroundColor Black
    }

    ## Removes $env:windir\memory.dmp
    if (test-path $env:windir\memory.dmp) {
        remove-item $env:windir\memory.dmp -force -Verbose -ErrorAction SilentlyContinue
    }
    else {
        Write-Host "C:\Windows\memory.dmp does not exist, there is nothing to cleanup.                                " -NoNewline -ForegroundColor DarkGray
        Write-Host "[WARNING]" -ForegroundColor DarkYellow -BackgroundColor Black
    }

    ## Removes rouge folders
    Write-host "Deleting Rouge folders                                                                            " -NoNewline -ForegroundColor Green
    Write-Host "[DONE]" -ForegroundColor Green -BackgroundColor Black

    ## Removes Windows Error Reporting files
    if (test-path C:\ProgramData\Microsoft\Windows\WER) {
        Get-ChildItem -Path C:\ProgramData\Microsoft\Windows\WER -Recurse | Remove-Item -force -recurse -Verbose -ErrorAction SilentlyContinue
        Write-host "Deleting Windows Error Reporting files                                                            " -NoNewline -ForegroundColor Green
        Write-Host "[DONE]" -ForegroundColor Green -BackgroundColor Black
    }
    else {
        Write-Host "C:\ProgramData\Microsoft\Windows\WER does not exist, there is nothing to cleanup.            " -NoNewline -ForegroundColor DarkGray
        Write-Host "[WARNING]" -ForegroundColor DarkYellow -BackgroundColor Black
    }

    ## Removes System and User Temp Files - lots of access denied will occur.
    ## Cleans up c:\windows\temp
    if (Test-Path $env:windir\Temp\) {
        Remove-Item -Path "$env:windir\Temp\*" -Force -Recurse -Verbose -ErrorAction SilentlyContinue
    }
    else {
        Write-Host "C:\Windows\Temp does not exist, there is nothing to cleanup.                                 " -NoNewline -ForegroundColor DarkGray
        Write-Host "[WARNING]" -ForegroundColor DarkYellow -BackgroundColor Black
    }

    ## Cleans up minidump
    if (Test-Path $env:windir\minidump\) {
        Remove-Item -Path "$env:windir\minidump\*" -Force -Recurse -Verbose -ErrorAction SilentlyContinue
    }
    else {
        Write-Host "$env:windir\minidump\ does not exist, there is nothing to cleanup.                           " -NoNewline -ForegroundColor DarkGray
        Write-Host "[WARNING]" -ForegroundColor DarkYellow -BackgroundColor Black
    }

    ## Cleans up prefetch
    if (Test-Path $env:windir\Prefetch\) {
        Remove-Item -Path "$env:windir\Prefetch\*" -Force -Recurse -Verbose -ErrorAction SilentlyContinue
    }
    else {
        Write-Host "$env:windir\Prefetch\ does not exist, there is nothing to cleanup.                           " -NoNewline -ForegroundColor DarkGray
        Write-Host "[WARNING]" -ForegroundColor DarkYellow -BackgroundColor Black
    }

    ## Cleans up c:\temp
    if (Test-Path "C:\temp\") {
        Remove-Item -Path "C:\temp\*" -Force -Recurse -Verbose -ErrorAction SilentlyContinue
    }
    else {
        Write-Host "C:\TEMP does not exist, there is nothing to cleanup.                  " -NoNewline -ForegroundColor DarkGray
        Write-Host "[WARNING]" -ForegroundColor DarkYellow -BackgroundColor Black
    }

    ## Cleans up windows.old
    if (Test-Path "C:\windows.old\") {
        Remove-Item -Path "C:\windows.old" -Force -Recurse -Verbose -ErrorAction SilentlyContinue
    }
    else {
        Write-Host "C:\windows.old does not exist, there is nothing to cleanup.                  " -NoNewline -ForegroundColor DarkGray
        Write-Host "[WARNING]" -ForegroundColor DarkYellow -BackgroundColor Black
    }
    
    ## Cleans up old windows upgrade folder
    if (Test-Path 'C:\$WINDOWS.~BT') {
        Remove-Item -Path 'C:\$WINDOWS.~BT' -Force -Recurse -Verbose -ErrorAction SilentlyContinue
    }
    else {
        Write-Host 'C:\$Windows.~BT\ does not exist, there is nothing to cleanup.                  ' -NoNewline -ForegroundColor DarkGray
        Write-Host "[WARNING]" -ForegroundColor DarkYellow -BackgroundColor Black
    }

    ## Cleans up old windows upgrade folder
    if (Test-Path 'C:\$Windows.~LS') {
        Remove-Item -Path 'C:\$Windows.~LS' -Force -Recurse -Verbose -ErrorAction SilentlyContinue
    }
    else {
        Write-Host 'C:\$Windows.~LS does not exist, there is nothing to cleanup.                  ' -NoNewline -ForegroundColor DarkGray
        Write-Host "[WARNING]" -ForegroundColor DarkYellow -BackgroundColor Black
    }

    ## Cleans up old windows upgrade folder
    if (Test-Path 'C:\$Windows.~WS') {
        Remove-Item -Path "C:\$Windows.~WS" -Force -Recurse -Verbose -ErrorAction SilentlyContinue
    }
    else {
        Write-Host 'C:\$Windows.~WS does not exist, there is nothing to cleanup.                  ' -NoNewline -ForegroundColor DarkGray
        Write-Host "[WARNING]" -ForegroundColor DarkYellow -BackgroundColor Black
    }

    ## Cleans up ESD Downloads
    if (Test-Path "C:\ESD\Download\") {
        Remove-Item -Path "C:\ESD\Download\*" -Force -Recurse -Verbose -ErrorAction SilentlyContinue
    }
    else {
        Write-Host "C:\ESD\Download\ does not exist, there is nothing to cleanup.                  " -NoNewline -ForegroundColor DarkGray
        Write-Host "[WARNING]" -ForegroundColor DarkYellow -BackgroundColor Black
    }

    ## Cleans up ESD Windows
    if (Test-Path "C:\ESD\Windows\") {
        Remove-Item -Path "C:\ESD\Windows\*" -Force -Recurse -Verbose -ErrorAction SilentlyContinue
    }
    else {
        Write-Host "C:\ESD\Windows\ does not exist, there is nothing to cleanup.                  " -NoNewline -ForegroundColor DarkGray
        Write-Host "[WARNING]" -ForegroundColor DarkYellow -BackgroundColor Black
    }

    ## Cleans up old inplace update folder
    if (Test-Path 'C:\$WINDOWS.~Q') {
        Remove-Item -Path 'C:\$WINDOWS.~Q' -Force -Recurse -Verbose -ErrorAction SilentlyContinue
    }
    else {
        Write-Host 'C:\$WINDOWS.~Q does not exist, there is nothing to cleanup.                  ' -NoNewline -ForegroundColor DarkGray
        Write-Host "[WARNING]" -ForegroundColor DarkYellow -BackgroundColor Black
    }

    ## Cleans up old inplace update folder
    if (Test-Path 'C:\$INPLACE.~TR') {
        Remove-Item -Path 'C:\$INPLACE.~TR' -Force -Recurse -Verbose -ErrorAction SilentlyContinue
    }
    else {
        Write-Host 'C:\$INPLACE.~TR does not exist, there is nothing to cleanup.                  ' -NoNewline -ForegroundColor DarkGray
        Write-Host "[WARNING]" -ForegroundColor DarkYellow -BackgroundColor Black
    }

    ## Cleans up old updatelog folder
    if (Test-Path "C:\Windows\Panther\") {
        Remove-Item -Path "C:\Windows\Panther\*" -Force -Recurse -Verbose -ErrorAction SilentlyContinue
    }
    else {
        Write-Host "C:\Windows\Panther\ does not exist, there is nothing to cleanup.                  " -NoNewline -ForegroundColor DarkGray
        Write-Host "[WARNING]" -ForegroundColor DarkYellow -BackgroundColor Black
    }

    ## Cleans up each users temp folder
    if (Test-Path "C:\Users\*\AppData\Local\Temp\") {
        Remove-Item -Path "C:\Users\*\AppData\Local\Temp\*" -Force -Recurse -Verbose -ErrorAction SilentlyContinue
    }
    else {
        Write-Host "C:\Users\*\AppData\Local\Temp\ does not exist, there is nothing to cleanup.                  " -NoNewline -ForegroundColor DarkGray
        Write-Host "[WARNING]" -ForegroundColor DarkYellow -BackgroundColor Black
    }

    ## Cleans up all users windows error reporting
    if (Test-Path "C:\Users\*\AppData\Local\Microsoft\Windows\WER\") {
        Remove-Item -Path "C:\Users\*\AppData\Local\Microsoft\Windows\WER\*" -Force -Recurse -Verbose -ErrorAction SilentlyContinue
    }
    else {
        Write-Host "C:\ProgramData\Microsoft\Windows\WER does not exist, there is nothing to cleanup.            " -NoNewline -ForegroundColor DarkGray
        Write-Host "[WARNING]" -ForegroundColor DarkYellow -BackgroundColor Black
    }

    ## Cleans up users temporary internet files
    if (Test-Path "C:\Users\*\AppData\Local\Microsoft\Windows\Temporary Internet Files\") {
        Remove-Item -Path "C:\Users\*\AppData\Local\Microsoft\Windows\Temporary Internet Files\*" -Force -Recurse -Verbose -ErrorAction SilentlyContinue
    }
    else {
        Write-Host "C:\Users\*\AppData\Local\Microsoft\Windows\Temporary Internet Files\ does not exist.              " -NoNewline -ForegroundColor DarkGray
        Write-Host "[WARNING]" -ForegroundColor DarkYellow -BackgroundColor Black
    }

    ## Cleans up Internet Explorer cache
    if (Test-Path "C:\Users\*\AppData\Local\Microsoft\Windows\IECompatCache\") {
        Remove-Item -Path "C:\Users\*\AppData\Local\Microsoft\Windows\IECompatCache\*" -Force -Recurse -Verbose -ErrorAction SilentlyContinue
    }
    else {
        Write-Host "C:\Users\*\AppData\Local\Microsoft\Windows\IECompatCache\ does not exist.                         " -NoNewline -ForegroundColor DarkGray
        Write-Host "[WARNING]" -ForegroundColor DarkYellow -BackgroundColor Black
    }

    ## Cleans up Internet Explorer cache
    if (Test-Path "C:\Users\*\AppData\Local\Microsoft\Windows\IECompatUaCache\") {
        Remove-Item -Path "C:\Users\*\AppData\Local\Microsoft\Windows\IECompatUaCache\*" -Force -Recurse -Verbose -ErrorAction SilentlyContinue
    }
    else {
        Write-Host "C:\Users\*\AppData\Local\Microsoft\Windows\IECompatUaCache\ does not exist.                       " -NoNewline -ForegroundColor DarkGray
        Write-Host "[WARNING]" -ForegroundColor DarkYellow -BackgroundColor Black
    }

    ## Cleans up Internet Explorer download history
    if (Test-Path "C:\Users\*\AppData\Local\Microsoft\Windows\IEDownloadHistory\") {
        Remove-Item -Path "C:\Users\*\AppData\Local\Microsoft\Windows\IEDownloadHistory\*" -Force -Recurse -Verbose -ErrorAction SilentlyContinue
    }
    else {
        Write-Host "C:\Users\*\AppData\Local\Microsoft\Windows\IEDownloadHistory\ does not exist.                     " -NoNewline -ForegroundColor DarkGray
        Write-Host "[WARNING]" -ForegroundColor DarkYellow -BackgroundColor Black
    }

    ## Cleans up Internet Cache
    if (Test-Path "C:\Users\*\AppData\Local\Microsoft\Windows\INetCache\") {
        Remove-Item -Path "C:\Users\*\AppData\Local\Microsoft\Windows\INetCache\*" -Force -Recurse -Verbose -ErrorAction SilentlyContinue
    }
    else {
        Write-Host "C:\Users\*\AppData\Local\Microsoft\Windows\INetCache\ does not exist.                             " -NoNewline -ForegroundColor DarkGray
        Write-Host "[WARNING]" -ForegroundColor DarkYellow -BackgroundColor Black
    }

    ## Cleans up Outlook Cache
    if (Test-Path "C:\Users\*\AppData\Local\Microsoft\Outlook\RoamCache\") {
        Remove-Item -Path "C:\Users\*\AppData\Local\Microsoft\Outlook\RoamCache\*" -Force -Recurse -Verbose -ErrorAction SilentlyContinue
    }
    else {
        Write-Host "C:\Users\*\AppData\Local\Microsoft\Outlook\RoamCache\ does not exist.                         " -NoNewline -ForegroundColor DarkGray
        Write-Host "[WARNING]" -ForegroundColor DarkYellow -BackgroundColor Black
    }

    ## Cleans up Chrome Cache for default user
    if (Test-Path "C:\Users\*\AppData\Local\Google\Chrome\User Data\Default\Cache\") {
        Remove-Item -Path "C:\Users\*\AppData\Local\Google\Chrome\User Data\Default\Cache\*" -Force -Recurse -Verbose -ErrorAction SilentlyContinue
    }
    else {
        Write-Host "C:\Users\*\AppData\Local\Google\Chrome\User Data\Default\Cache does not exist.                         " -NoNewline -ForegroundColor DarkGray
        Write-Host "[WARNING]" -ForegroundColor DarkYellow -BackgroundColor Black
    }

    ## Cleans up Chrome Cache for profile 1 user
    if (Test-Path "C:\Users\*\AppData\Local\Google\Chrome\User Data\Profile 1\Cache\") {
        Remove-Item -Path "C:\Users\*\AppData\Local\Google\Chrome\User Data\Profile 1\Cache\*" -Force -Recurse -Verbose -ErrorAction SilentlyContinue
    }
    else {
        Write-Host "C:\Users\*\AppData\Local\Google\Chrome\User Data\Profile 1\Cache\ does not exist.                         " -NoNewline -ForegroundColor DarkGray
        Write-Host "[WARNING]" -ForegroundColor DarkYellow -BackgroundColor Black
    }

    ## Cleans up Chrome Cache for profile 2 user
    if (Test-Path "C:\Users\*\AppData\Local\Google\Chrome\User Data\Profile 2\Cache\") {
        Remove-Item -Path "C:\Users\*\AppData\Local\Google\Chrome\User Data\Profile 2\Cache\*" -Force -Recurse -Verbose -ErrorAction SilentlyContinue
    }
    else {
        Write-Host "C:\Users\*\AppData\Local\Google\Chrome\User Data\Profile 2\Cache\ does not exist.                         " -NoNewline -ForegroundColor DarkGray
        Write-Host "[WARNING]" -ForegroundColor DarkYellow -BackgroundColor Black
    }

    ## Cleans up Chrome Cache for profile 3 user
    if (Test-Path "C:\Users\*\AppData\Local\Google\Chrome\User Data\Profile 3\Cache\") {
        Remove-Item -Path "C:\Users\*\AppData\Local\Google\Chrome\User Data\Profile 3\Cache\*" -Force -Recurse -Verbose -ErrorAction SilentlyContinue
    }
    else {
        Write-Host "C:\Users\*\AppData\Local\Google\Chrome\User Data\Profile 3\Cache\ does not exist.                         " -NoNewline -ForegroundColor DarkGray
        Write-Host "[WARNING]" -ForegroundColor DarkYellow -BackgroundColor Black
    }

    ## Cleans up Internet Cookies
    if (Test-Path "C:\Users\*\AppData\Local\Microsoft\Windows\INetCookies\") {
        Remove-Item -Path "C:\Users\*\AppData\Local\Microsoft\Windows\INetCookies\*" -Force -Recurse -Verbose -ErrorAction SilentlyContinue
    }
    else {
        Write-Host "C:\Users\*\AppData\Local\Microsoft\Windows\INetCookies\ does not exist.                           " -NoNewline -ForegroundColor DarkGray
        Write-Host "[WARNING]" -ForegroundColor DarkYellow -BackgroundColor Black
    }

    ## Cleans up terminal server cache
    if (Test-Path "C:\Users\*\AppData\Local\Microsoft\Terminal Server Client\Cache\") {
        Remove-Item -Path "C:\Users\*\AppData\Local\Microsoft\Terminal Server Client\Cache\*" -Force -Recurse -Verbose -ErrorAction SilentlyContinue
    }
    else {
        Write-Host "C:\Users\*\AppData\Local\Microsoft\Terminal Server Client\Cache\ does not exist.                  " -NoNewline -ForegroundColor DarkGray
        Write-Host "[WARNING]" -ForegroundColor DarkYellow -BackgroundColor Black
    }

    Write-host "Removing System and User Temp Files                                                               " -NoNewline -ForegroundColor Green
    Write-Host "[DONE]" -ForegroundColor Green -BackgroundColor Black

    ## Removes the hidden recycling bin.
    if (Test-path 'C:\$Recycle.Bin') {
        Remove-Item 'C:\$Recycle.Bin' -Recurse -Force -Verbose -ErrorAction SilentlyContinue
    }
    else {
        Write-Host "C:\`$Recycle.Bin does not exist, there is nothing to cleanup.                                      " -NoNewline -ForegroundColor DarkGray
        Write-Host "[WARNING]" -ForegroundColor DarkYellow -BackgroundColor Black
    }
    
    dism /Online /Cleanup-Image /StartComponentCleanup

    ## Turns errors back on
    $ErrorActionPreference = "Continue"

    ## Checks the version of PowerShell
    ## If PowerShell version 4 or below is installed the following will process
    if ($PSVersionTable.PSVersion.Major -le 4) {

        ## Empties the recycling bin, the desktop recyling bin
        $Recycler = (New-Object -ComObject Shell.Application).NameSpace(0xa)
        $Recycler.items() | ForEach-Object { 
            ## If PowerShell version 4 or bewlow is installed the following will process
            Remove-Item -Include $_.path -Force -Recurse -Verbose
            Write-Host "The recycling bin has been cleaned up successfully!                                        " -NoNewline -ForegroundColor Green
            Write-Host "[DONE]" -ForegroundColor Green -BackgroundColor Black
        }
    }
    elseif ($PSVersionTable.PSVersion.Major -ge 5) {
        ## If PowerShell version 5 is running on the machine the following will process
        Clear-RecycleBin -DriveLetter C:\ -Force -Verbose
        Write-Host "The recycling bin has been cleaned up successfully!                                               " -NoNewline -ForegroundColor Green
        Write-Host "[DONE]" -ForegroundColor Green -BackgroundColor Black
    }

    ## gathers disk usage after running the cleanup cmdlets.
    $After = Get-WmiObject Win32_LogicalDisk | Where-Object { $_.DriveType -eq "3" } | Select-Object SystemName,
    @{ Name = "Drive" ; Expression = { ( $_.DeviceID ) } },
    @{ Name = "Size (GB)" ; Expression = { "{0:N1}" -f ( $_.Size / 1gb) } },
    @{ Name = "FreeSpace (GB)" ; Expression = { "{0:N1}" -f ( $_.Freespace / 1gb ) } },
    @{ Name = "PercentFree" ; Expression = { "{0:P1}" -f ( $_.FreeSpace / $_.Size ) } } |
    Format-Table -AutoSize | Out-String

    ## Restarts wuauserv
    $ServiceName = 'Windows Update'

    Function restart-selected-service {
        
        $arrService = Get-Service -Name $ServiceName
        if ($arrService.Status -ne 'Running') {
            $ServiceStarted = $false
        }
        Else { $ServiceStarted = $true }
        
        while ($ServiceStarted -ne $true) {
            Start-Service $ServiceName
            write-host $arrService.status
            write-host "$ServiceName Service started"
            Start-Sleep -seconds 20
            $arrService = Get-Service -Name $ServiceName
            if ($arrService.Status -eq 'Running') {
                $ServiceStarted = $true
            }
        }
        
    }
    restart-selected-service

    ## Stop timer
    $Enders = (Get-Date)

    ## Calculate amount of seconds your code takes to complete.
    Write-Verbose "Elapsed Time: $(($Enders - $Starters).totalseconds) seconds

"
    ## Sends hostname to the console for ticketing purposes.
    Write-Host (Hostname) -ForegroundColor Green

    ## Sends the date and time to the console for ticketing purposes.
    Write-Host (Get-Date | Select-Object -ExpandProperty DateTime) -ForegroundColor Green

    ## Sends the disk usage before running the cleanup script to the console for ticketing purposes.
    Write-Verbose "Before: $Before"

    ## Sends the disk usage after running the cleanup script to the console for ticketing purposes.
    Write-Verbose "After: $After"

    ## Completed Successfully!
    Write-Host (Stop-Transcript) -ForegroundColor Green

    Write-host "
Script finished                                                                                   " -NoNewline -ForegroundColor Green
    Write-Host "[DONE]" -ForegroundColor Green -BackgroundColor Black

}
Start-Cleanup
exit 0
