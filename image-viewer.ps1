#based on https://stackoverflow.com/questions/22447326/powershell-download-image-from-an-image-url
param(
[parameter (Mandatory=$false, position=0, ParameterSetName='src')]
[string]$url = ''
)
if (-not (Test-Path -Path "$(Write-Output $env:LOCALAPPDATA)\image-viewer-temp" )) {
    Write-Error 'The Directory does not exist, creating...'
    Start-CreateDir
}
else {
    "Directory already exists"
}

$Global:pos = 0
Add-Type -AssemblyName 'System.Windows.Forms'
[void][reflection.assembly]::LoadWithPartialName("System.Windows.Forms")
[System.Windows.Forms.Application]::EnableVisualStyles()

Function Start-Load-Images{
    param (
        [parameter (Mandatory=$true, position=0, ParameterSetName='path')]
        $path
    )   
    $Global:max = $path.Length
    Write-Output "Size " $Global:max
    if ($null -eq $path.Fullname) {
        Start-Error    
    }

    $screen = [System.Windows.Forms.Screen]::AllScreens
    $form = New-Object Windows.Forms.Form
    $pictureBox = new-object Windows.Forms.PictureBox

    $form.Text = "Image Viewer"
    $form.Size = New-Object System.Drawing.Size($screen.WorkingArea[0].Width, $screen.WorkingArea[0].Height)
    $form.Add_KeyUp({

        if ($_.KeyCode -eq "Left") {
            
            if ($Global:pos -gt 0) {
                $Global:pos -= 1
            }else{
                $Global:pos = 0
            }
            $pictureBox.Image = [System.Drawing.Image]::Fromfile((Get-Item $path.Fullname[$Global:pos]))
            #Write-Output $Global:pos
        }
        
    })

    $form.Add_KeyUp({

        if ($_.KeyCode -eq "Right") {
            
            if ($Global:pos -lt $Global:max) {
                $Global:pos += 1
            }else{
                $Global:pos = $path.length
            }
            $pictureBox.Image = [System.Drawing.Image]::Fromfile((Get-Item $path.Fullname[$Global:pos]))
            Write-Output $path.Fullname[$Global:pos]
        }
        
    })

    $form.Add_KeyDown({
        if ($PSItem.KeyCode -eq "Escape") 
        {
            $form.Close()
        }
    })
    
    $pictureBox.Size = New-Object System.Drawing.Size($screen.WorkingArea[0].Width, $screen.WorkingArea[0].Height)
    $pictureBox.Image = [System.Drawing.Image]::Fromfile((Get-Item $path.Fullname[$pos]))
    $pictureBox.SizeMode = 'Zoom'
    $pictureBox.Anchor = 'Top, Left, Bottom, Right'

    $form.controls.add($pictureBox)
    $form.KeyPreview = $true
    $form.Add_Shown( { $form.Activate() } )
    Write-Output $Global:pos
    $form.ShowDialog()
    #$img.dispose()
}

Function Start-Error{
    $curPath = Get-Location
    [System.Windows.Forms.MessageBox]::Show("No files found in: $curPath")
    exit
}
Function Start-CreateDir {
    $newDir = "$(Write-Output $env:LOCALAPPDATA)\image-viewer-temp"
    try {
        New-Item -Path $newDir -ItemType Directory -ErrorAction Stop | Out-Null #-Force
    }
    catch {
        Write-Error -Message "Unable to create directory '$newDir'. Error was: $_" -ErrorAction Stop
    }
    "Successfully created $newDir."
}

if(!$url) {

    $dir = Get-Location
    $Files = @(Get-ChildItem "$($dir.Path)\*" -Include *.jpg, *.jpeg, *.png)
    $Files.Length    
    Start-Load-Images -path $Files

}else{
    
}
