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
    [bool]$global:performMooving = $false # $true $false
    [string]$global:sourcePath = "" # predefine
    [string]$global:Filter = "*.jpg" # predefine

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
    start-transcript "$ScriptInPath\log\$TransScriptPrefix$(get-date -format yyyy-MM).txt"
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


log "importig exifFunctions.ps1" 1
. .\module\exifFunctions.ps1 #Import EXIF-Functions


$global:Modul = 'Get-Settings'
log "get Source-Path" 1
$global:sourcePath = Get-FolderDialog ("$PSScriptRoot", "Select Source-Path")
log "sourcePath:$global:sourcePath" 2

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

log "sourcePath:$global:sourcePath"

$global:Modul = 'register actions'
log "Load Start-Sorting()" 1
function Start-Sorting($sourcePath, $performMooving,$Filter) {
    <#
		Info/Example:

	#>
    $tempModul = $global:Modul # save Modul-Prefix
    $global:Modul = 'Start-Sorting'
    
    log "Function Entry" 	

    log "get Target-Path" 2
    $targetPath = Get-FolderDialog ("$sourcePath", "Select Target-Path")
    log "targetPath:$targetPath"

    if ($sourcePath -eq $targetPath) {
        Write-Warning "Source-Path and Target-Path can't be the same!"
        Write-Warning "Please select a different Target-Path"
        return $false
    }
    
    if (-not (Test-Path $targetPath)) {
        #New-Item -ItemType Directory -Path $targetPath | Out-Null
        Write-Error "Can't find selected Target-Path:[$targetPath]"
        return $false
    }

    $SelectedFiles = Get-ChildItem -Path $sourcePath -Filter $Filter -Recurse -File
    log "Selected Files:" 2
    log $SelectedFiles 2

    pause

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
        $parsedDate = Get-Date $takkenDate
        #[System.DateTime]::TryParseExact($takkenDate, 'dd.MM.yyyy HH:mm', [System.Globalization.CultureInfo]::InvariantCulture, [System.Globalization.DateTimeStyles]::None, [ref]$parsedDate)
        if ($null -ne $parsedDate) {
            $takkenDate = $parsedDate
        } else {
            $takkenDate = $SelectedFile.LastWriteTime
            log "Date-Takken (can't Parse date = LastWriteTime):[$takkenDate]"
        }

        log "Date-Takken (Date-obj):[$takkenDate]"
        $picYaer = $takkenDate.Year
        log "Yaer:[$picYaer]"

        # targetPath for Yaer
        $targetPicYearPath = Join-Path $targetPath $picYaer
        if (-not (Test-Path $targetPicYearPath)) {
            New-Item -ItemType Directory -Path $targetPicYearPath | Out-Null
        }

        $targetsourcePath = Join-Path $targetPicYearPath $SelectedFile.Name

        $counter = 1
        while (Test-Path $targetsourcePath) {
            $newName = "{0}_{1:D3}_{2}" -f $parsedDate.ToString('yyyy-MM-dd_HHmmss'), $counter, $SelectedFile.Extension
            $targetsourcePath = Join-Path $targetPicYearPath $newName
            Write-Warning "Rename duplicate file:[$SelectedFile.Name] --> [$targetsourcePath]"
            $counter++
        }

        if ($performMooving) {
            log "Move-Item $SelectedFile.FullName $targetsourcePath"
            Move-Item $SelectedFile.FullName $targetsourcePath -Force #-WhatIf
        } else {
            log "Copy-Item $SelectedFile.FullName $targetsourcePath -Force"
            Copy-Item $SelectedFile.FullName $targetsourcePath -Force #-WhatIf
        }

    }

    # catch { 
    #     Write-Warning "$global:Modul -  Something went wrong" 
    #     return $false
    # }
    # finally{
    #     $global:Modul = $tempModul #set saved Modul-Prefix
    # }	
	$global:Modul = $tempModul #set saved Modul-Prefix
    #return $true
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
        [bool]$global:YearAndMonth = $false
    } 
    elseif ($radioButton2.Checked) {
        log "RB2 - Year and Month" 1
        [bool]$global:YearAndMonth = $true
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
        $global:performMooving = $true
        log "performMooving:$global:performMooving"
    }
    else {
        $global:performMooving = $false
        log "performMooving:$global:performMooving"
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

    log "call Start-Sorting($global:sourcePath, $global:performMooving, $global:Filter)" 1
    Start-Sorting($global:sourcePath, $global:performMooving, $global:Filter)
    
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

pause

