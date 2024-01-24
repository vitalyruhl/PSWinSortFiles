#C:\Windows\System32\WindowsPowerShell\v1.0
#C:\Program Files\PowerShell\7\pwsh.exe
<#______________________________________________________________________________________________________________________

	(c) Vitaly Ruhl 2024
______________________________________________________________________________________________________________________#>

$Funktion = 'SortImagesDM.ps1'

  
<#______________________________________________________________________________________________________________________    
    		Version  	Datum           Author          Description
    		-------  	----------      -----------     -----------                                                       #>

    $Version = 100 #	03.08.2021		Vitaly Ruhl		create
    $Version = 120 #	24.01.2024		Vitaly Ruhl		Add select folder and option dialog
    $Version = 130 #	24.01.2024		Vitaly Ruhl		Add Autoupdate


<#______________________________________________________________________________________________________________________
    Function:
    Get-ExifData and sort images by year/Month taken
______________________________________________________________________________________________________________________#>


<#______________________________________________________________________________________________________________________
    To-Do / Errors:
______________________________________________________________________________________________________________________#>

<#______________________________________________________________________________________________________________________
    Pre-Settings:#>
    [bool]$global:YearAndMonth = $false # $true $false if false, then only year is used
    [bool]$global:performMoving = $false # $true $false
    [string]$global:sourcePath = "" # predefine
    [string]$global:Filter = "*.jpg;*.png;*.jpeg" # predefine
    
<#______________________________________________________________________________________________________________________#>
<#______________________________________________________________________________________________________________________
    Pre-Settings for autoupdate:#>
   
    $UpdateVersion = 0
    [bool]$AllowUpdate = $false
    $UpdateFromPath = "https://raw.githubusercontent.com/vitalyruhl/PSWinSortFiles/master"
    $UpdateFiles = @("WinSortFiles.ps1","./module/exifFunctions.ps1","./module/mainform.ps1.ps1","./module/recentlyUsedFunctions.ps1")
    $UpdateVersionFile = "VersionSettings.json"
    #$ProjectName = (get-item $PSScriptRoot ).Name #only the Name of the Path
    $SettingsFile = "$PSScriptRoot\AutoUpdateSettings.json"
    #$currentDateTime = Get-Date -Format yyyy.MM.dd_HHmm
    
<#______________________________________________________________________________________________________________________#>


#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#region Debugging Settings

#**********************************************************************************************************************
# Debug Settings
[bool]$global:debug = $true # $true $false
[int]$global:logLevel = 1 # 0 = Errors and Warnings, 1 = Errors and Warnings and Infos, 2 = Errors, Warnings, Infos And Debugging Infos
[bool]$global:debugTransScript = $false # $true $false
$global:DebugPrefix = $Funktion + ' ' + $Version + ' -> ' #Variable für Debug-log vorbelegen
$global:TransScriptPrefix = "Log_" + $Funktion + '_' + $Version
$global:Modul = 'Main' #Variable für Debug-log vorbelegen
$ErrorActionPreference = "Continue" #(Ignore,SilentlyContinue,Continue,Stop,Inquire) 
$global:DebugPreference = if ($global:debug) { "Continue" } else { "SilentlyContinue" } #Powershell-Own Debug settings
#**********************************************************************************************************************
function log ($text, $level=-1) {
    if ($global:debug -and ($global:logLevel -ge $level)) {
        Write-Host "$global:DebugPrefix $global:Modul -> $text" -ForegroundColor DarkGray	
    }
}

#endregion


$global:Modul = 'Start-Sequenz'
log "Start" 1

if ($global:debugTransScript) {
    start-transcript "$PSScriptRoot\log\$TransScriptPrefix$(get-date -format yyyy-MM).txt"
}

log "importig recentlyUsedFunctions.ps1" 1
. .\module\recentlyUsedFunctions.ps1 #Import misk Functions

if ($global:debug) {   
    $global:Modul = 'ENV'
    log "ENV-Test"
    $psv = $PSVersionTable.PSVersion.ToString()
    log "PS-Version:$psv" 
    
    $PC = $env:computername
    log $PC
    log "logevel:$global:logLevel"
    log "Project in Path:$PSScriptRoot"
}
   
function performSelfUpdate() {
    $tempModul = $global:Modul # save Modul-Prefix
    $global:Modul = 'update'
    log "Entry performSelfUpdate" 2
    $isUri = $false

    $global:Modul = 'update:Get-Settings'
    if (Test-Path($SettingsFile)) {
        $json = (Get-Content $SettingsFile -Raw) | ConvertFrom-Json
        #$json = ConvertFrom-Json (Get-Content $SettingsFile -Raw) -AsArray
        foreach ($var in $json.psobject.properties) {
            $valueInfo = $json.psobject.properties.Where({ $_.name -eq $var.name })
            $value = $json.psobject.properties.Where({ $_.name -eq $var.name }).value
            if ($valueInfo.TypeNameOfValue -eq "System.Boolean") {
                #16.04.2023 bugfix on bools
                #convert to bool
                $value = [bool]$value
            }
            if ($valueInfo.TypeNameOfValue -eq "System.Object[]") {
                #16.04.2023 bugfix on arrays with one element
                #convert to bool
                $value = @($value)
            }
            Set-Variable -Name $var.name -Value $value
            $logText = "Set-Variable " + $var.name + "-->[$value]"
            log $logText 1
        }
    }
    else {
        log "No Settings-File found"
    }

    if ($UpdateFromPath -match "http") {
        #check if $UpdateFromPath contains a Uri
        $isUri = $true
    }
   
    #check version
    if ($isUri) {
        log "Update from Uri" 1
        try {
            $VersionJson = (Invoke-WebRequest -Uri "$UpdateFromPath/$UpdateVersionFile" -UseBasicParsing).Content | ConvertFrom-Json
        }
        catch {
            Write-Warning "Error in Update-Check - Check your Internet-Connection"
            $global:Modul = $tempModul #set saved Modul-Prefix
            return 
        }
           
    }
   
    $NewestVersion = $VersionJson.psobject.properties.Where({ $_.name -eq "CurrentVersion" }).value
    log "NewestVersion: $NewestVersion, UpdateVersion:  $NewestVersion"

    if ($UpdateVersion -lt $NewestVersion) {
                  
        try {
        log "Update from $UpdateVersion to $NewestVersion"
        if ($isUri) {
            log "Get files from Uri"
            foreach ($UpdateFile in $UpdateFiles) {
                log "UpdateFile: $UpdateFile"
                #https://www.thomasmaurer.ch/2021/07/powershell-download-script-or-file-from-github/
                #Invoke-WebRequest -Uri https://raw.githubusercontent.com/thomasmaurer/demo-cloudshell/master/helloworld.ps1 -OutFile .\helloworld.ps1
                Invoke-WebRequest -Uri "$UpdateFromPath/$UpdateFile" -OutFile "$PSScriptRoot\$UpdateFile"
            }
        }
        else {
            log "Copy files from Path"

            foreach ($UpdateFile in $UpdateFiles) {
                log "UpdateFile: $UpdateFile"
                copy-item "`"$UpdateFromPath\$UpdateFile`"" "`"$PSScriptRoot\$UpdateFile`"" -force #-WhatIf
            }
        }

        Log "Set New Version in actual Settings-Json"
        $json.UpdateVersion = $NewestVersion
        $json | ConvertTo-Json -depth 32 | set-content $SettingsFile
    
        sectionY "Update"
        Write-Warning "This script is updated now! Plese restart it again to perform your Backup"
        pause
        if ($global:debugTransScript) { Stop-Transcript }
        $global:Modul = $tempModul #set saved Modul-Prefix
        exit #exit this script
        }
        catch {
            Write-Warning "Error in Update-Check - Check your Settings or internet-Connection"
            if ($global:debugTransScript) { Stop-Transcript }
            $global:Modul = $tempModul #set saved Modul-Prefix
            return #exit this script
        }
    }
    $global:Modul = $tempModul #set saved Modul-Prefix
    return
}
   
$global:Modul = 'Self-Update'
log "try Self-Update" 1
performSelfUpdate

$global:Modul = 'Get-Settings'
log "get Source-Path" 1
$global:sourcePath = Get-FolderDialog "$PSScriptRoot" "Select Source-Path"
#$global:sourcePath = "C:\temp\Sort-test\quelle"
log "sourcePath:$global:sourcePath" 1

if ($null -eq $global:sourcePath -or $global:sourcePath -eq ""){
    Write-Error "Error in Get-Source-Path: Path is empty - Exit Script"
    Pause
    exit
}
elseif ($global:sourcePath -eq "-CANCEL-"){
    Write-Warning "No Folder selected (dialog are canceled) - Exit Script"
    Pause
    exit
}
elseif ($global:sourcePath -eq "-ERROR-") {
    Write-Error "Error in Get-Folder-Dialog - Exit Script"
    Pause
    exit
}

$global:Modul = 'register actions'
log "Load Start-Sorting()" 1
function Start-Sorting($sourcePath, $performMoving, $Filter, $YearAndMonth = $false) {
        
    log "importig exifFunctions.ps1" 1
    . .\module\exifFunctions.ps1 #Import EXIF-Functions

    $tempModul = $global:Modul # save Modul-Prefix
    $global:Modul = 'Start-Sorting'
    
    log "Function Entry" 	

    log "get Target-Path" 2
    $targetPath = Get-FolderDialog "$sourcePath" "Select Target-Path"
    log "targetPath:$targetPath"

    if ($sourcePath.ToString() -eq $targetPath.ToString()) {
        Write-Warning "Source-Path and Target-Path can't be the same!"
        Write-Warning "Please select a different Target-Path"
        return $false
    }
    
    if (-not (Test-Path $targetPath)) {
        #New-Item -ItemType Directory -Path $targetPath | Out-Null
        Write-Warning "Can't find selected Target-Path:[$targetPath]"
        return $false
    }
    #*.jpg;*.png;*.jpeg
    $Extensions = $Filter -split ';'
    #$SelectedFiles = Get-ChildItem -Path $sourcePath -Filter $Extensions -Recurse -File
    $SelectedFiles = Get-ChildItem -Path $sourcePath -Include $Extensions -Recurse -File
    log "Selected Files:" 2
    log $SelectedFiles 2

    foreach ($SelectedFile in $SelectedFiles) {
            
        $takkenDate = Get-ExifDateTaken -filePath $SelectedFile.FullName
        $takkenDate = $takkenDate.Trim()
        $takkenDate = $takkenDate -replace '[^\p{L}\p{N}\p{P}\p{S}\p{Z}]', '' # remove all non-ASCII characters
    
        log "Date-Takken EXIF:[$takkenDate]"
        
        if ($takkenDate -eq "NOEXIF") { #fallback to filedate
            $takkenDate = $SelectedFile.LastWriteTime
            log "Date-Takken (NO Exif = LastWriteTime):[$takkenDate]"
        }
        
        $parsedDate = $null
        $parsedDate = Get-Date $takkenDate -ErrorAction SilentlyContinue
        if ($null -ne $parsedDate) {
            $takkenDate = $parsedDate
        } else {
            $takkenDate = $SelectedFile.LastWriteTime
            log "Date-Takken (can't Parse date = use LastWriteTime):[$takkenDate]"
        }
    
        log "Date-Takken (Date-obj):[$takkenDate]" 2
        $fileYear = $takkenDate.Year
        $fileMonth = $takkenDate.Month
    
        # targetPath for Year
        $targetFileYearPath = Join-Path $targetPath $fileYear
        if (-not (Test-Path $targetFileYearPath)) {
            New-Item -ItemType Directory -Path $targetFileYearPath | Out-Null
        }
    
        # targetPath for Year and Month
        if ($YearAndMonth) {
            $targetFileMonthPath = Join-Path $targetFileYearPath "$fileMonth"
            if (-not (Test-Path $targetFileMonthPath)) {
                New-Item -ItemType Directory -Path $targetFileMonthPath | Out-Null
            }
        }
    
        $targetFilePath = Join-Path $targetFileYearPath $SelectedFile.Name
    
        if ($YearAndMonth) {
            $targetFilePath = Join-Path $targetFileMonthPath $SelectedFile.Name
        }
    
        $counter = 1
        while (Test-Path $targetFilePath) {
            $newName = "{0}_{1:D3}_{2}" -f $parsedDate.ToString('yyyy-MM-dd_HHmmss'), $counter, $SelectedFile.Extension
            $targetFilePath = Join-Path $targetFileYearPath $newName
    
            if ($YearAndMonth) {
                $targetFilePath = Join-Path $targetFileMonthPath $newName
            }
    
            Write-Warning "Rename duplicate file:`r`n   [$SelectedFile.Name]`r`n --> [$targetFilePath]"
            $counter++
        }
    
        if ($performMoving) {
            log "Move-Item $($SelectedFile.FullName) $targetFilePath"
            Move-Item $SelectedFile.FullName $targetFilePath -Force #-WhatIf
        } else {
            log "Copy-Item $($SelectedFile.FullName) $targetFilePath -Force"
            Copy-Item $SelectedFile.FullName $targetFilePath -Force #-WhatIf
        }
    }
    
	$global:Modul = $tempModul #set saved Modul-Prefix
   
}

log "Load okButtonClick()" 1
function okButtonClick (){
    #Radiobuttons...
    #foreach ($o in @($radioButton1, $radioButton2, $radioButton3)){
    #    if ($o.Checked){
    #        $option = $o.Text}
    #    }

    if ($radioButton1.Checked){
        log "RB1 - Year only" 1
        $global:YearAndMonth = $false
    } 
    elseif ($radioButton2.Checked) {
        log "RB2 - Year and Month" 1
        $global:YearAndMonth = $true
    }  

    elseif ($radioButton3.Checked) {
        log "RB3" 1
        log "Delete empty Folders is selected" 1
        log "sourcePath is [$global:sourcePath]" 1
        $form.Dispose()
        DeleteEmptyFolder $global:sourcePath # function is in recentlyUsedFunctions.ps1
        return $true #exit script
    }  
    # elseif ($radioButton4.Checked) {
       
    # }  
    else {Write-Warning "No Option selected"}

    #checkboxes
    If ($objTypeCheckbox.Checked = $true)
    {
        $global:performMoving = $true
        log "performMoving:$global:performMoving"
    }
    else {
        $global:performMoving = $false
        log "performMoving:$global:performMoving"
    }
    
    if ($textBox.Text -ne "") {
        $global:Filter = $textBox.Text
        log "Filter:$global:Filter"
    }
    else {
        #$global:Filter = "*.jpg"
        log "Filter are not set, use default:[$global:Filter]"
        
    }
    
    $form.Dispose()

    log "call Start-Sorting $global:sourcePath $global:performMoving $global:Filter $global:YearAndMonth" 1
    Start-Sorting $global:sourcePath $global:performMoving $global:Filter $global:YearAndMonth
   
}

log "importig mainForm.ps1"
. .\module\mainForm.ps1 #open mainForm

section 'Skript is done!'
Write-Warning "When you don't see any red than is all fine ;-)"
    
if ($global:debugTransScript) { Stop-Transcript }

if ($global:debug) {
    #pause
}
# else {
#     start-countdown 30
# }



