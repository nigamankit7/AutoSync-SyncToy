# AutoSync-SyncToy
A utility which can be used as a background service. As soon as desired USB device is connected, service will immediately start backup profile of Sync Toy utility. 

## Dependency 
* [Sync Toy](https://www.microsoft.com/en-in/download/details.aspx?id=15155)

## Script Configuration 
* Line 39 - $Exe = "C:\Program Files\SyncToy 2.1\SyncToyCmd.exe" . Provide path to SyncToyCmd as per your env. 
* Line 63 - if ($driveLetter -eq 'H:' -and $driveLabel -eq 'Ankit'). Provide driveletter and drivelabel as per your requirement.



