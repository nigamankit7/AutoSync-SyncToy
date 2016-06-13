clear
$scriptpath = $MyInvocation.MyCommand.Path
$dir = Split-Path $scriptpath
$TARGETDIR = $dir + "\log"

if(!(Test-Path -Path $TARGETDIR ))
{
    New-Item -ItemType directory -Path $dir -Name "log"
}
$logFile = $TARGETDIR + "\sync.log"

function baloon-notify($logpath, $title_tip, $title)
    {   [void] [System.Reflection.Assembly]::LoadWithPartialName(“System.Windows.Forms”)#Remove any registered events related to notifications
        Remove-Event BalloonClicked_event -ea SilentlyContinue
        Unregister-Event -SourceIdentifier BalloonClicked_event -ea silentlycontinue
        Remove-Event BalloonClosed_event -ea SilentlyContinue
        Unregister-Event -SourceIdentifier BalloonClosed_event -ea silentlycontinue 
        Remove-Event Disposed -ea SilentlyContinue
        Unregister-Event -SourceIdentifier Disposed -ea silentlycontinue
        $notification = New-Object System.Windows.Forms.NotifyIcon 
        $notification.Icon = [System.Drawing.SystemIcons]::Information
        $notification.BalloonTipTitle = $title_tip
        $notification.BalloonTipIcon = “info”
        $notification.BalloonTipText = $title + $logpath
        $notification.Visible = $True
        register-objectevent $notification BalloonTipClicked BalloonClicked_event `
        -Action {Invoke-Item $logpath} | Out-Null
        $notification.ShowBalloonTip(600)
        Start-Sleep -s 10
        $notification.Dispose()
    
    }




function Run-SyncToy ($backupPlan)
{
    $Exe = "C:\Program Files\SyncToy 2.1\SyncToyCmd.exe"
    & $Exe -R #$backupPlan
}

Register-WmiEvent -Class win32_VolumeChangeEvent -SourceIdentifier volumeChange -ea silentlycontinue  
write-host (get-date -format s) " Beginning script..."
do{
    $newEvent = Wait-Event -SourceIdentifier volumeChange
    $eventType = $newEvent.SourceEventArgs.NewEvent.EventType
    $eventTypeName = switch($eventType)
    {
        1 {"Configuration changed"}
        2 {"Device arrival"}
        3 {"Device removal"}
        4 {"docking"}
    }
    write-host (get-date -format s) " Event detected = " $eventTypeName
    if ($eventType -eq 2)
    {
        $driveLetter = $newEvent.SourceEventArgs.NewEvent.DriveName
        $driveLabel = ([wmi]"Win32_LogicalDisk='$driveLetter'").VolumeName
        write-host (get-date -format s) " Drive name = " $driveLetter
        write-host (get-date -format s) " Drive label = " $driveLabel
        # Execute process if drive matches specified condition(s)
        if ($driveLetter -eq 'H:' -and $driveLabel -eq 'Ankit')
            {
            write-host (get-date -format s) " Starting task in 3 seconds..."
            start-sleep -seconds 3
            write-host (get-date -format s)" Sync Process started"
            $tip = "Auto Sync Started. Do not remove USB."
            $text = "SyncToy started syncing. Do not remove USB till next notification."
            baloon-notify $TARGETDIR $tip $text
            Run-SyncToy ("Media Sync") | out-file $logFile -Append -Force
            write-host (get-date -format s) " Sync Process Ended"
            $tip = "Auto Sync Completed"
            $text = "Path to log file ->"
            baloon-notify $logFile $tip $text
            }
    }
    Remove-Event -SourceIdentifier volumeChange
} while (1-eq1) #Loop until next event

Unregister-Event -SourceIdentifier volumeChange
