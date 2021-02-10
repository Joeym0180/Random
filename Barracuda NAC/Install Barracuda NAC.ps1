function Install-NAC {
    $tempdir = "C:\Temp"   
    New-Item -ItemType Directory -Force -Path $tempdir -ErrorAction SilentlyContinue
    $Logfile = "C:\Temp\NACInstall.log"
    Start-Transcript -Path $Logfile
    $url = 'https://github.com/Joeym0180/Random/raw/main/Installatiebestanden/BarracudaNAC.msi'
    $msi = 'C:\Temp\BarracudaNAC.msi'
    invoke-webrequest $url -OutFile $msi
    msiexec.exe /i $msi /qn /norestart
    Stop-Transcript
} #function
Install-NAC