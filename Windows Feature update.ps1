Function Install-Windows-10-feature-update {
    $dir = 'C:\Temp\WindowsFeatureUpdate\packages'
    mkdir $dir -ErrorAction SilentlyContinue | Out-Null
    $webClient = New-Object System.Net.WebClient
    $url = 'https://go.microsoft.com/fwlink/?LinkID=799445'
    $file = "$($dir)\Win10Upgrade.exe"
    Write-Host "Downloading Win10Upgrade.exe..." -NoNewline
    $webClient.DownloadFile($url, $file)
    if ((Test-Path -PathType Leaf $file) -eq $true) {
        Write-Host " Successful" -ForegroundColor Green
    } 
    else {
        Write-Host " Failed" -ForegroundColor Red
        start-sleep -Seconds 4
        $trycount = 1
        while ($trycount -ne 10 -or (Test-Path -PathType Leaf $file) -eq $true) {
            write-host "Attempting download"
            $trycount += 1
            Write-Host "Try $trycount Downloading Win10Upgrade.exe..." -NoNewline
            $webClient.DownloadFile($url, $file)
            if ((Test-Path -PathType Leaf $file) -eq $true) {
                Write-Host " Successful" -ForegroundColor Green
            }
            else { Write-Host " Failed" -ForegroundColor Red }
            start-sleep -Seconds 4
        }
    }

    if ((Test-Path -PathType Leaf $file) -eq $true) {
        Start-Process -FilePath $file -ArgumentList "/quietinstall /skipeula /auto upgrade /copylogs $dir"
        write-host "Started Windows Feature Update"
    }
    else {
        Write-Host "Failed to download Win10Upgrade.exe. Aborting installation"
        Stop-Transcript
        exit 1001
    }
    
    
}