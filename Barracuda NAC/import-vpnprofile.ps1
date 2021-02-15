
function Install-VPNfile {
    # download VPNfile

    $tempdir = "C:\Temp"   
    New-Item -ItemType Directory -Force -Path $tempdir -ErrorAction SilentlyContinue
    $url = 'http://cargospot.globalgsagroup.com/cargospot/barracudavpnfiles/QuitoVPN.exe'
    $vpnfile = 'C:\Temp\Quito_VPN.vpn'
    invoke-webrequest $url -OutFile $vpnfile

   
    # import NAC module
    import-module "C:\Program Files\Barracuda\Network Access Client\Modules\BarracudaNetworkAccessClient\BarracudaNetworkAccessClient.psd1"

    #import VPNfile
    Import-NACAppConfiguration -InputFile $vpnfile

} #function
Install-VPNfile