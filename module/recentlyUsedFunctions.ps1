
# C:\Windows\System32\WindowsPowerShell\v1.0
#C:\Program Files\PowerShell\7\pwsh.exe
<#______________________________________________________________________________________________________________________

	(c) Vitaly Ruhl 2021-2022
    Homepage: Vitaly-Ruhl.de
    Github:https://github.com/vitalyruhl/
    License: GNU General Public License v3.0
______________________________________________________________________________________________________________________#>
#>

$Funktion = 'recentlyUsedFunctions.ps1'

<#  
______________________________________________________________________________________________________________________
    
    		Version  	Datum           Author        Beschreibung
    		-------  	----------      -----------   -----------

$Version = 'V1.0.0' #	26.03.2021		Vitaly Ruhl		init
		

______________________________________________________________________________________________________________________
    Function:
    Find and or delete duplicate Files - Step 1 from 3
    get all files in contained folder recursivla in a json with simple hash
______________________________________________________________________________________________________________________
#>


#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#region Debugging Functions


# #**********************************************************************************************************************
# # Debug Settings
# [bool]$global:debug = $true # $true $false
# $global:LogLevel = 1 # 0 = Errors and Warnings, 1 = Errors and Warnings and Infos, 2 = Errors, Warnings, Infos And Debugging Infos
# [bool]$global:debugTransScript = $false # $true $false
# $global:DebugPrefix = $Funktion + ' ' + $Version + ' -> ' #Variable für Debug-log vorbelegen
# $global:TransScriptPrefix = "Log_" + $Funktion + '_' + $Version
# $global:Modul = 'Main' #Variable für Debug-log vorbelegen
# $ErrorActionPreference = "Continue" #(Ignore,SilentlyContinue,Continue,Stop,Inquire) 
# $global:DebugPreference = if ($global:debug) { "Continue" } else { "SilentlyContinue" } #Powershell-Own Debug settings
# #**********************************************************************************************************************


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
	
function log ($text, $level=-1) {
    if ($global:debug -and ($global:LogLevel -ge $level)) {
        Write-Host "$global:DebugPrefix $global:Modul -> $text" -ForegroundColor DarkGray	
    }
}

function debug ($text){
    if ($global:debug) {
        Write-debug "$global:DebugPrefix $global:Modul -> $text"# -ForegroundColor DarkGray
    }	
}

#endregion



function MsgBox($Title, $msg, $Typ, $Aussehen) {
		
    <# example:
            $test = MsgBox  "test tittel"  "Test text" 0 5 
    #>

    <#
		Types of Messageboxes	
		0:	OK
		1:	OK Cancel
		2:	Abort Retry Ignore
		3:	Yes No Cancel
		4:	Yes No
		5:	Retry Cancel
		
		#Icons...
			Symbol			Icon	                english
			0				kein Symbol				None
			1				(i)				        Information
			2				(?)					    Question
			3				Fehler (X)			    Error
			4				Ausruf /!\		        Exclamation
			5				(i)		                Asterisk
			6				Hand (X)			    Hand
			7				Stopp (X)			    Stop
			8				Warnung /!\		        Warning
		#>
    $tempModul = $global:Modul
    $global:Modul = 'MsgBox'
    try {
        log "passed parameters ($Title, $msg, $Typ, $Aussehen)"
        switch ($Aussehen) {
            0 { $result = [System.Windows.MessageBox]::show($msg, $Title, $Typ) }
            1 { $result = [System.Windows.Forms.MessageBox]::show($msg, $Title, $Typ, [System.Windows.Forms.MessageBoxIcon]::Information) }
            2 { $result = [System.Windows.Forms.MessageBox]::show($msg, $Title, $Typ, [System.Windows.Forms.MessageBoxIcon]::Question) }
            3 { $result = [System.Windows.Forms.MessageBox]::show($msg, $Title, $Typ, [System.Windows.Forms.MessageBoxIcon]::Error) }
            4 { $result = [System.Windows.Forms.MessageBox]::show($msg, $Title, $Typ, [System.Windows.Forms.MessageBoxIcon]::Exclamation) }
            5 { $result = [System.Windows.Forms.MessageBox]::show($msg, $Title, $Typ, [System.Windows.Forms.MessageBoxIcon]::Asterisk) }
            6 { $result = [System.Windows.Forms.MessageBox]::show($msg, $Title, $Typ, [System.Windows.Forms.MessageBoxIcon]::Hand) }
            7 { $result = [System.Windows.Forms.MessageBox]::show($msg, $Title, $Typ, [System.Windows.Forms.MessageBoxIcon]::Stop) }
            8 { $result = [System.Windows.Forms.MessageBox]::show($msg, $Title, $Typ, [System.Windows.Forms.MessageBoxIcon]::Warning) }
            9 { $result = [System.Windows.Forms.MessageBox]::show($msg, $Title, $Typ, [System.Windows.Forms.MessageBoxIcon]::Exclamation -band [System.Windows.Forms.MessageBoxIcon]::SystemModal) }
        }		
        log "Function Sceleton execute" 
    }
    catch { 
        Write-Warning "$global:Modul -  Something went wrong" 
    }	
    $global:Modul = $tempModul #restore old module text	
    return $result
}

function Get-UserInput($title, $msg, $Vorbelegung) {
    <# example:
		
        $global:Modul = 'Input-Test:'
        sectionY " Input - Test "
        $test = get-UserInput  "test titel"  "for exsample 192.168.2.250" "192.168.2.250"
        Write-Host "Returnvalue from Inputdialog: $test"

	#>

    $tempModul = $global:Modul # Save pre-text temporarily 
    $global:Modul = 'Get-UserInput'
    try {
        log "passed parameters ($Title, $msg, $Vorbelegung)"
        [void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')
        $inp = [Microsoft.VisualBasic.Interaction]::InputBox($msg, $title, $Vorbelegung, 5)
    }
    catch { 
        Write-Warning "$global:Modul -  Something went wrong" 
    }	
    $global:Modul = $tempModul #restore old module text	
    return $inp
}

#endregion


#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#region File and Direcrory Functions

function Get-FileDialog($InitialDirectory, [switch]$AllowMultiSelect) {
    $tempModul = $global:Modul # Save pre-text temporarily 
    $global:Modul = 'Get-FileDialog'
    try {
        Add-Type -AssemblyName System.Windows.Forms
        $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
        $openFileDialog.initialDirectory = $InitialDirectory
        $openFileDialog.filter = "All files (*.*)| *.*"
        if ($AllowMultiSelect) { 
            $openFileDialog.MultiSelect = $true 
        }
        $openFileDialog.ShowDialog() > $null
        if ($allowMultiSelect) { 
            $global:Modul = $tempModul #restore old module text	
            return $openFileDialog.Filenames 
        } 
        else { 
            $global:Modul = $tempModul #restore old module text	
            return $openFileDialog.Filename 
        }
    }
    catch { 
        Write-Warning "$global:Modul -  Something went wrong" 
    }	
    $global:Modul = $tempModul #restore old module text	
}
function  Get-FolderDialog([string]$InitialDirectory="",$Description = "Select a folder") {
	$tempModul = $global:Modul # save Modul-Prefix
	$global:Modul = 'Get-FolderDialog'
    
    $logLevel = 2
    log "Passed Init Directory is:$InitialDirectory" 1
    log "Passed Init Description is:$Description" 1

	try {
		#Add-Type -AssemblyName System.Windows.Forms
        [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")|Out-Null
        log 1 $logLevel
		$openFolderDialog = New-Object System.Windows.Forms.FolderBrowserDialog
        log 2 $logLevel
        $openFolderDialog.Description = $Description
        log 3 $logLevel
		$openFolderDialog.ShowNewFolderButton = $true
        log 4 $logLevel
		$openFolderDialog.rootfolder  = "MyComputer"
        log 5 $logLevel
		$openFolderDialog.SelectedPath   = $InitialDirectory
        log 6 $logLevel
		#$openFolderDialog.ShowDialog()
        $od = $openFolderDialog.ShowDialog()
        if($od -eq "OK")
            {
                $folder = $openFolderDialog.SelectedPath	
                return $folder
            }
            else{
                Write-Warning "$global:Modul - Dialog are canceled" 
                return ("-CANCEL-")
            }
	}
	catch { 
		Write-Warning "$global:Modul -  Something went wrong" 
        return  ("-ERROR-" )
	}	
    finally{
        $global:Modul = $tempModul #set saved Modul-Prefix
    }
    
}

function Add-Path($MyPath) {
    #Checks path exists, otherwise creates a new one .....
    <#
               example: 
               $Pfad="$env:TEMP\PS_Skript"
               Add-Path($Pfad)
       #>
    $tempModul = $global:Modul # Save pre-text temporarily 
    $global:Modul = 'Add-Path'
   
    try {
           
        if (!(Test-Path -path $MyPath -ErrorAction SilentlyContinue )) {
            # Pfad anlegen wenn nicht vorhanden
            if (!(Test-Path -Path $MyPath)) {
                New-Item -Path $MyPath -ItemType Directory -ErrorAction SilentlyContinue # | Out-Null
            }      
        }
   
    }
    catch { 
        Write-Warning "$global:Modul -  Something went wrong" 
    }	
    $global:Modul = $tempModul #restore old module text	
}	

Function Send-ToRecycleBin{
    #https://social.technet.microsoft.com/Forums/en-US/ff39d018-9c38-4276-a4c9-3234f088c630/how-can-i-delete-quotto-recycle-binquot-in-powershell-instead-of-remove-item-?forum=winserverpowershell

    Param(
    [Parameter(Mandatory = $true,
    ValueFromPipeline = $true)]
    [alias('FullName')]
    [string]$FilePath
    )
    Begin{$shell = New-Object -ComObject 'Shell.Application'}
    Process{
        $Item = Get-Item $FilePath
        $shell.namespace(0).ParseName($item.FullName).InvokeVerb('delete')
    }
}


function DeleteEmptyFolder($sourcePath) {
    SetDebugState($true)
    $global:Modul = "DeleteEmptyFolder()"
    log "`r`n`r`n------------------------------------------------------`r`n" 2
    log "DeleteEmptyFolder are called" 2
    
    $emptyFolders = @()
    
    $SD = $PSScriptRoot
    
    if ($null -eq $sourcePath -or $sourcePath -eq ""){
        $SerchPath = Get-FolderDialog ("$SD")
    }
    else {
        $SerchPath = $sourcePath
    }

    if ($SerchPath -eq "-CANCEL-"){
        Write-Warning "No Folder selected - Exit Script"
        exit
    }
    elseif ($SerchPath -eq "-ERROR-") {
        Write-Error "Error in Get-Folder-Dialog - Exit Script"
        exit
    }
    else {
         
        log "Selected folder for Search is:$SerchPath" 1

        log "`r`n`r`n------------------------------------------------------`r`n" 2
        log 'Get Folder to delete:' 2

        function Get-EmptyFolders {
            param (
                [string]$Path #,
                #[array]$emptyFolders
            )

            $emptyFolders = @()

            foreach ($childDirectory in Get-ChildItem -Force -LiteralPath $Path -Directory) {
                $emptyFolders += Get-EmptyFolders -Path $childDirectory.FullName
            }

        $currentChildren = Get-ChildItem -Force -LiteralPath $Path
        $isEmpty = $null -eq $currentChildren
        if ($isEmpty) {
            log "found empty folder at path '$Path'." 2
            $emptyFolders += $Path
        }

        return $emptyFolders
        }
        
        
<#
        $tailRecursion = {
        
            param(
                $Path
            )
            
            try { 
                foreach ($childDirectory in Get-ChildItem -Force -LiteralPath $Path -Directory) {
                        & $tailRecursion -Path $childDirectory.FullName
                    }
            
                $currentChildren = Get-ChildItem -Force -LiteralPath $Path
                $isEmpty = $null -eq $currentChildren
                if ($isEmpty) {
                    # Write-Verbose "Removing empty folder at path '${Path}'." -Verbose
                    # Remove-Item -Force -LiteralPath $Path -Confirm:$true #-WhatIf
                    log "found empty folder at path '${Path}'." 2
                    $script:emptyFolders += $Path
                }
        
            }
            catch { 
                Write-Error "$global:Modul -  Something went wrong" 
            }	
        }

        & $tailRecursion -Path $SerchPath
#>
        #Get-EmptyFolders -Path $SerchPath -emptyFolders $emptyFolders
        $emptyFolders = Get-EmptyFolders -Path $SerchPath

        log "emptyFolders: '$emptyFolders'" 2
        log "emptyFolders.Count: '$($emptyFolders.Count)'" 2

        if ($emptyFolders.Count -gt 0) {
            log "load module/confirmationForm.ps1" 1
            . .\module/confirmationForm.ps1
            $confirmationResult = Show-EmptyFolderConfirmationForm -Folders $emptyFolders

            if ($confirmationResult -eq "Yes") {
                foreach ($folder in $emptyFolders) {
                    Write-Verbose "Removing empty folder at path '$folder'." -Verbose
                    Remove-Item -Force -LiteralPath $folder
                }
            } else {
                Write-Host "Deletion canceled by user."
            }
        } else {
            Write-Host "No empty folders found in the selected path."
        }

    }
}

#endregion


function ftimer(){
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    $window = New-Object System.Windows.Forms.Form
    $window.Width = 1000
    $window.Height = 800
    $Label = New-Object System.Windows.Forms.Label
    $Label.Location = New-Object System.Drawing.Size(10,10)
    $Label.Text = "Text im Fenster"
    $Label.AutoSize = $True
    $window.Controls.Add($Label)

    $i=0
    $timer_Tick={
        $script:i++
        $Label.Text= "$i new text"
    }
    $timer = New-Object 'System.Windows.Forms.Timer'
    $timer.Enabled = $True 
    $timer.Interval = 1000
    $timer.add_Tick($timer_Tick)
    
    [void]$window.ShowDialog()

}


function start-countdown ($sleepintervalsec) {
    <#
			Use: start-countdown 60
		#>
    $ec = 0
    foreach ($step in (1..$sleepintervalsec)) {
        try {
            if ([console]::KeyAvailable) {
                $key = [system.console]::readkey($true)
                if (($key.modifiers -band [consolemodifiers]"control") -and ($key.key -eq "C")) {
                    Write-Warning "CTRL-C pressed" 
                    return
                }
                else {
                    Write-Host "Key Pressed [$($key.keychar)]"
                    pause
                    return
                }
            }
        }
        catch {
            if ($ec -eq 0) {
                Write-Warning "Start in Powershell ISE - console functions are not avaible"
                $ec++
            }
        }
        finally {
            $rest = $sleepintervalsec - $step
            write-progress -Activity "Please wait" -Status " $rest Sek..." -SecondsRemaining ($rest) -PercentComplete  ($step / $sleepintervalsec * 100)
            start-sleep -seconds 1
        }
    }
}
