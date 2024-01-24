#C:\Windows\System32\WindowsPowerShell\v1.0
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
    Settings:#>
    $Targets = "__Sorted"
    $MovePics = $true # $true $false
<#______________________________________________________________________________________________________________________#>



#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#region Debugging and User-Interface Functions


#**********************************************************************************************************************
# Debug Settings
[bool]$global:debug = $false # $true $false
[bool]$global:debugTransScript = $false # $true $false
$global:DebugPrefix = $Funktion + ' ' + $Version + ' -> ' #Variable für Debug-log vorbelegen
$global:TransScriptPrefix = "Log_" + $Funktion + '_' + $Version
$global:Modul = 'Main' #Variable für Debug-log vorbelegen
$ErrorActionPreference = "Continue" #(Ignore,SilentlyContinue,Continue,Stop,Inquire) 
$global:DebugPreference = if ($global:debug) { "Continue" } else { "SilentlyContinue" } #Powershell-Own Debug settings
#**********************************************************************************************************************


function SetDebugState ($b){
    $global:DebugPreference = if ($b) {"Continue"} else {"SilentlyContinue"} #Powershell-Own Debug settings
}


function whr ()	{ Write-Host "`r`n`r`n" }
	
function section ($text) {
    Write-Host "`r`n-----------------------------------------------------------------------------------------------"
    Write-Host " $text"
    Write-Host "`r`n"
}
	
function sectionY ($text) {
    Write-Host "`r`n-----------------------------------------------------------------------------------------------" -ForegroundColor Yellow
    Write-Host " $text" -ForegroundColor Yellow
    Write-Host "`r`n"
}
	
function log ($text) {
    if ($global:debug) {
        Write-Host "$global:DebugPrefix $global:Modul -> $text" -ForegroundColor DarkGray	
    }
}

function debug ($text){
    if ($global:debug) {
        Write-debug "$global:DebugPrefix $global:Modul -> $text"# -ForegroundColor DarkGray
    }	
}

#endregion

#region EXIF Functions

function Get-ExifData {
    param (
        [string]$filePath
    )
    $tempModul = $global:Modul # save Modul-Prefix
    $global:Modul = 'Get-ExifDat'

    log "Function execute" 

    try {
        $shell = New-Object -ComObject Shell.Application
        $folder = $shell.Namespace((Get-Item $filePath).DirectoryName)
        $file = $folder.ParseName((Get-Item $filePath).Name)
        $exifProperties = @{}
        for ($i = 0; $i -lt 266; $i++) {
            $propertyValue = $folder.GetDetailsOf($file, $i)
            if ($propertyValue) {
                $exifProperties[$folder.GetDetailsOf($folder.Items, $i)] = $propertyValue
            }
        }
        return $exifProperties
    }
    catch { 
        Write-Warning "$global:Modul -  Something went wrong" 
        return "NOEXIF"
    }
    finally{
        $global:Modul = $tempModul #set saved Modul-Prefix
    }	
	
    return "NOEXIF"
    
}

function Get-ExifDateTaken {
    param (
        [string]$filePath
    )
    $tempModul = $global:Modul # save Modul-Prefix
    $global:Modul = 'Get-ExifDat'

    log "Function execute" 

    try {
        $shell = New-Object -ComObject Shell.Application
        $folder = $shell.Namespace((Get-Item $filePath).DirectoryName)
        $file = $folder.ParseName((Get-Item $filePath).Name)
        $dateTakenProperty = $folder.GetDetailsOf($file, 12)  # get date taken: Index 12
        
        if ($dateTakenProperty) {
            return $dateTakenProperty
        } else {
            return "NOEXIF"
        }
    }
    catch { 
        Write-Warning "$global:Modul -  Something went wrong" 
        return "NOEXIF"
    }
    finally{
        $global:Modul = $tempModul #set saved Modul-Prefix
    }	

    return "NOEXIF"
}

#endregion

if ($global:debugTransScript) {
    start-transcript "$ScriptInPath\log\$TransScriptPrefix$(get-date -format yyyy-MM).txt"
}

$projectPath = $PSScriptRoot

if ($global:debug) {
    log "entry"
    log "module imported"
    $global:Modul = 'ENV'
    sectiony "ENV-Test"
    $PC = $env:computername
    log $PC

    log "Targets:$Targets"
    log "MovePics:$MovePics"

}


$picPath = $projectPath
$targetPath = Join-Path $projectPath $Targets


if (-not (Test-Path $targetPath)) {
    New-Item -ItemType Directory -Path $targetPath | Out-Null
}

#$pictures = Get-ChildItem -Path $picPath -Filter *.jpg -Recurse -File
$pictures = Get-ChildItem -Path $picPath -Filter *.* -Recurse -File
log $pictures

foreach ($picture in $pictures) {
    #try {
        
        $takkenDate = Get-ExifDateTaken -filePath $picture.FullName
        $takkenDate = $takkenDate.Trim()
        $takkenDate = $takkenDate -replace '[^\p{L}\p{N}\p{P}\p{S}\p{Z}]', '' # Entferne alle nicht sichtbaren Zeichen
        #$takkenDate = $takkenDate -replace '\s+', ' '

        log "Date-Takken EXIF:[$takkenDate]"
        
        if ($takkenDate -eq "NOEXIF") { #fallback to filedate
            $takkenDate = $picture.LastWriteTime
            log "Date-Takken (NO Exif = LastWriteTime):[$takkenDate]"
        }
        
        $parsedDate = $null
        $parsedDate = Get-Date $takkenDate
        #[System.DateTime]::TryParseExact($takkenDate, 'dd.MM.yyyy HH:mm', [System.Globalization.CultureInfo]::InvariantCulture, [System.Globalization.DateTimeStyles]::None, [ref]$parsedDate)
        if ($null -ne $parsedDate) {
            $takkenDate = $parsedDate
        } else {
            $takkenDate = $picture.LastWriteTime
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

        $targetPicPath = Join-Path $targetPicYearPath $picture.Name

        $counter = 1
        while (Test-Path $targetPicPath) {
            $newName = "{0}_{1:D3}_{2}" -f $parsedDate.ToString('yyyy-MM-dd_HHmmss'), $counter, $picture.Extension
            $targetPicPath = Join-Path $targetPicYearPath $newName
            Write-Warning "Rename duplicate file:[$picture.Name] --> [$targetPicPath]"
            $counter++
        }

        if ($MovePics) {
            log "Move-Item $picture.FullName $targetPicPath"
            Move-Item $picture.FullName $targetPicPath -Force #-WhatIf
        } else {
            log "Copy-Item $picture.FullName $targetPicPath -Force"
            Copy-Item $picture.FullName $targetPicPath -Force #-WhatIf
        }

    # } catch {
    #     Write-Warning "error: $($picture.FullName): $_"
    # }
}

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

