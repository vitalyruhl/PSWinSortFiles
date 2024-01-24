
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