
$USERNAME = $HOME | Select-String -Pattern '\\([^\\]+)$' | ForEach-Object { $_.Matches.Groups[1].Value }

#https://www.shareus.com/windows/which-files-can-be-safely-deleted-from-c-drive-windows-10-8-7.html

function cleanFolders(){

    $prefetchFolder = "C:\Windows\Prefetch"
    $windowsTempFolder = "C:\Windows\Temp"
    $userTempFolder = "C:\Users\" + $USERNAME + "\AppData\Local\Temp"
    $braveFolder = "C:\Users\" + $USERNAME + "\AppData\Local\BraveSoftware\Brave-Browser\User Data\Default\Cache"

    $liveKernelReportFolders = "C:\Windows\LiveKernelReports"
    $downloadFolder = "C:\Users\" + $USERNAME + "\Downloads"


    $folderArray = @($prefetchFolder,
                     $windowsTempFolder,
                     $userTempFolder,
                     $braveFolder
                      )

    Foreach ($element in $folderArray) {
        # Remove all items (files and directories) 
        Get-ChildItem $element -Force -Recurse -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue  
         
        Write-Host ("Removed all folders and files successfully in {0}" -f $element) -ForegroundColor Green
        Start-Sleep -Seconds 1 
    }
}

cleanFolders
