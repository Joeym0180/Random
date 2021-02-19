Function Create-FourtopDialog 
{
    param(
		$WindowTitle,
		$TitleBlock,
        $MessageBlock,        
        $Button1Text,
        $Button1Tooltip, 
        $Button1Function,      
        $Button2Text,
        $Button2Tooltip,
        $Button2Function,
        $Button3Tooltip,
        $Button3Function,
        $Button4Tooltip,
        $Button4Function,
        $ExitFunction
	)

$uiHash = [hashtable]::Synchronized(@{})



Set-Location $(Split-Path $script:MyInvocation.MyCommand.Path)
$Global:Path = $(Split-Path $script:MyInvocation.MyCommand.Path)
$Global:ComputerName = $env:COMPUTERNAME


#Load Required Assemblies
Add-Type -assemblyName PresentationFramework
Add-Type -assemblyName PresentationCore
Add-Type -assemblyName WindowsBase
Add-Type -assemblyName Microsoft.VisualBasic
Add-Type -assemblyName System.Windows.Forms

$base64icon = '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'
$bitmapicon = New-Object System.Windows.Media.Imaging.BitmapImage
$bitmapicon.BeginInit()
$bitmapicon.StreamSource = [System.IO.MemoryStream][System.Convert]::FromBase64String($base64icon)
$bitmapicon.EndInit()
$bitmapicon.Freeze()


$base64logo = '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'
$bitmaplogo = New-Object System.Windows.Media.Imaging.BitmapImage
$bitmaplogo.BeginInit()
$bitmaplogo.StreamSource = [System.IO.MemoryStream][System.Convert]::FromBase64String($base64logo)
$bitmaplogo.EndInit()
$bitmaplogo.Freeze() 


#region GUI
[xml]$xaml = @"
<Window WindowStartupLocation = 'CenterScreen'
        xmlns='http://schemas.microsoft.com/winfx/2006/xaml/presentation'
    xmlns:x='http://schemas.microsoft.com/winfx/2006/xaml'
    x:Name='MainWindow'        
        BorderBrush="White"  
        Title="$WindowTitle" Height="450" Width="800" Background="White"  ShowInTaskbar="True">       

    <Grid> 

        <Grid.ColumnDefinitions>
            <ColumnDefinition Width="221*"/>
            <ColumnDefinition Width="587*"/>
        </Grid.ColumnDefinitions>
        <Grid.RowDefinitions>
             <RowDefinition Height="60"/>
            <RowDefinition Height="240"/>
            <RowDefinition Height="50"/>
            <RowDefinition Height="50"/>
        </Grid.RowDefinitions>

         <TextBlock Grid.Column="0" Grid.ColumnSpan="2" Grid.Row="0" x:Name='TitleBlock' IsEnabled='False' 
                  Margin="40,15,10,5" Background='#FFFFFF' FontSize="34px" LineHeight="38px"  FontFamily="Arial, sans-serif" Foreground='#1a1246' TextWrapping="Wrap" >
                 $TitleBlock              
        </TextBlock>
        
        <TextBlock Grid.Column="0" Grid.ColumnSpan="2" Grid.Row="1" x:Name='MessageBlock' IsEnabled='False' 
                  Margin="40,10,10,10" Background='#FFFFFF' FontSize="18px" LineHeight="24px" FontFamily="Arial, sans-serif" Foreground='#1a1246' TextWrapping="Wrap" >
                  $MessageBlock
        </TextBlock>
        <StackPanel Grid.Column="1" Grid.Row="2" Orientation="Horizontal" HorizontalAlignment="Right" >
            <Button x:Name="Button1" Width="100" ToolTip="$Button1Tooltip" Margin="0,0,60,0" Background="Transparent" Foreground="#1A1246" BorderBrush="#1A1246" FontSize="20" FontWeight="Normal" >
                 <Button.Content>$Button1Text</Button.Content>
            </Button>
            <Button x:Name="Button2" Width="100" ToolTip="$Button2Tooltip" Margin="0,0,60,0" Background="Transparent" Foreground="#1A1246" BorderBrush="#1A1246" FontSize="20" FontWeight="Normal" >
                <Button.Content>$Button2Text</Button.Content>
            </Button>
        </StackPanel>

             <Image Grid.Column="0" Grid.Row="2" Grid.RowSpan="2"  Margin="10,30,0,0" HorizontalAlignment="Left" Height="100"  VerticalAlignment="Top" Width="200" 
                 x:Name="ImageLogo" /> 
        <TextBlock Grid.Column="1" Grid.Row="3" Margin="10,20,40,0" HorizontalAlignment="Left">
            <Hyperlink x:Name="Link" TextDecorations="None"   
               NavigateUri="https://www.fourtop.nl/contact">Fourtop Servicedesk</Hyperlink>
        </TextBlock>
    </Grid>
</Window>

"@ 
#endregion

#region Load XAML into PowerShell
$reader=(New-Object System.Xml.XmlNodeReader $xaml)
$uiHash.Window=[Windows.Markup.XamlReader]::Load( $reader )

#region Connect to all controls
[xml]$XAML = $xaml
        $xaml.SelectNodes("//*[@*[contains(translate(name(.),'n','N'),'Name')]]") | ForEach-Object{
        #Find all of the form types and add them as members to the synchash
        $uiHash.Add($_.Name,$uiHash.Window.FindName($_.Name) )
    }

        $uiHash.Window.Icon = $bitmapicon
        $uiHash.ImageLogo.Source =  $bitmaplogo 
        $uiHash.Window.topmost = $true



[System.Windows.Forms.Application]::EnableVisualStyles();

#region Window Close Events
#Window Close Events

#endregion

$buttonclicked = $false

$uiHash.Button1.Add_Click({
$buttonclicked = $true
    Invoke-Command -ScriptBlock $Button1Function
  })

  if($Button2Text -eq $NULL) {
  $uiHash.Button2.Visibility="Hidden"
  }
$uiHash.Button2.Add_Click({
$buttonclicked = $true
 Invoke-Command -ScriptBlock $Button2Function
  })

  $uiHash.Link.Add_Click({
    start $uiHash.Link.NavigateUri.ToString()
})

$uiHash.Window.Add_Closed({
	if ($buttonclicked -eq $false) {
    Invoke-Command -ScriptBlock $ExitFunction
    }
}) 


#Start the GUI

$uiHash.Window.ShowDialog() | Out-Null

}

$runcount = 0
$remindertext = $null
## Vanaf hieronder kunnen de variablen worden aangepast
$global:taal = (Get-WinUserLanguageList).LanguageTag
$nederlands = "nl-NL"

function Reminder
{
if ( $runcount -eq 1) {

#set reminder after 60 minutes
Write-Host "setting delay, will prompt again in 60 minutes"
if($taal -eq $nederlands) {

#Nederlanse Prompt

Create-FourtopDialog -WindowTitle "Bericht van Fourtop ICT" `
-TitleBlock "Uitgesteld" `
-MessageBlock "<LineBreak/>Bedankt voor je reactie, Je ontvangt van ons een reminder over een uur<LineBreak/>" `
-Button1Text "OK"`
-Button1Function $b4 `
-ExitFunction $b4

} else { 

#Engelse Prompt

Create-FourtopDialog -WindowTitle "Fourtop message" `
-TitleBlock "Postponed" `
-MessageBlock "<LineBreak/>Thank you for your reaction, we will send you a reminder in an hour.<LineBreak/>" `
-Button1Text "OK" `
-Button1Function $b4 `
-ExitFunction $b4

}
start-sleep -Seconds 3600
$remindertext = "Reminder:"
screen1

}
else
{
#End prompts
Write-Host "Already reminded the user, scheduled reboot is aborted by user."
exit 1001
}
}

function Button1Function
{
    $uiHash.Window.Close()
    Write-Host "Button1 Clicked"    
    Shutdown.exe /r /t 120 
    screen2
}

function Button2Function
{
    $uiHash.Window.Close()
    Write-Host "Button2 Clicked"
    Reminder
}

function Button3Function
{
    $uiHash.Window.Close()
    Write-Host "Button3 Clicked"
    Write-host "Shutdown scheduled in 2 minutes, closing script"

}

function Button4Function
{
    $uiHash.Window.Close()
    Write-Host "Button4 Clicked"
    Write-host "Closing notification"
}

function ExitFunction
{
    $uiHash.Window.Close()
    Write-Host "ExitFunction triggerT"
    shutdown.exe /a
    Reminder
}

$b1=[ScriptBlock]::Create('Button1Function')
$b2=[ScriptBlock]::Create('Button2Function')
$b3=[ScriptBlock]::Create('Button3Function')
$b4=[ScriptBlock]::Create('Button4Function')
$ex=[ScriptBlock]::Create('ExitFunction')

function screen1
{
$Global:runcount++
if($taal -eq $nederlands) {

#Nederlanse Prompt

Create-FourtopDialog -WindowTitle "Bericht van Fourtop ICT" `
-TitleBlock "$remindertext Verzoek tot herstarten van PC" `
-MessageBlock "<LineBreak/>Goedendag! - namens de Servicedesk van Fourtop ICT<LineBreak/><LineBreak/> Je PC staat al twee weken aan en voor optimaal gebruik adviseren we je te herstarten.<LineBreak/><LineBreak/>Bij de optie 'Ja' zal je PC over 2 minuten opnieuw opgestart worden zodat je het openstaande werk kunt opslaan." `
-Button1Text "Ja" -Button1Tooltip "Bij de optie ja zal je PC over 2 minuten opnieuw opgestart worden zodat je het openstaande werk kunt opslaan."`
-Button2Text "Nee" -Button2Tooltip "Bij de optie nee zal de PC niet opnieuw worden opgestart"`
-Button1Function $b1 `
-Button2Function $b2 `
-ExitFunction $ex

} else { 

#Engelse Prompt

Create-FourtopDialog -WindowTitle "Fourtop message" `
-TitleBlock "$remindertext Request to reboot your computer" `
-MessageBlock "<LineBreak/>Hello! - On behalf of the Servicedesk of Fourtop ICT<LineBreak/><LineBreak/> Your PC hasn't been restarted for two weeks and for optimal performance we recommend that you restart now.<LineBreak/><LineBreak/>If you choose the option 'Yes' your PC will reboot after 2 minutes so there is still time to save your work." `
-Button1Text "Yes" -Button1Tooltip "If you choose 'Yes' your computer will reboot after 2 minutes so there is still time to save your work."`
-Button2Text "No" -Button2Tooltip "If you choose 'No' the computer will not be rebooted."`
-Button1Function $b1 `
-Button2Function $b2 `
-ExitFunction $ex

}

}

function screen2
{
if($taal -eq $nederlands) {

#Nederlanse Prompt

Create-FourtopDialog -WindowTitle "Bericht van Fourtop ICT" `
-TitleBlock "Herstart Bevestigd" `
-MessageBlock "<LineBreak/>Deze computer zal binnen 2 minuten opnieuw opstarten<LineBreak/><LineBreak/> Om te annuleren klik dit venster weg of klik op 'Annuleer Herstart'" `
-Button1Text "Oke"  -Button1Tooltip "Sluit deze melding"`
-Button1Function $b3 `
-Button2Text "Annuleer" -Button2Tooltip "Annuleer de herstart van de computer" `
-Button2Function $ex `
-ExitFunction $ex


} else { 

#Engelse Prompt

Create-FourtopDialog -WindowTitle "Fourtop message" `
-TitleBlock "`Reboot confirmed" `
-MessageBlock "<LineBreak/>This computer will reboot in less then 2 minutes<LineBreak/><LineBreak/> To abort the planned reboot click on 'Abort Reboot' or close this window" `
-Button1Text "Ok" -Button1Tooltip "Close this window" `
-Button1Function $b3 `
-Button2Text "Abort" -Button2Tooltip "Abort Reboot" `
-Button2Function $ex `
-ExitFunction $ex
}
}
screen1