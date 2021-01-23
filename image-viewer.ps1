#based on https://stackoverflow.com/questions/22447326/powershell-download-image-from-an-image-url
param(
[parameter (Mandatory=$false, position=0, ParameterSetName='url')]
[string]$url = ''
)
Add-Type -AssemblyName 'System.Windows.Forms'
[void][reflection.assembly]::LoadWithPartialName("System.Windows.Forms")
[System.Windows.Forms.Application]::EnableVisualStyles()
New-Item -Path "$($HOME)\image-viewer-temp" -ItemType Directory
$screen = [System.Windows.Forms.Screen]::AllScreens
Function Load-Images{
    param (
        [parameter (Mandatory=$true, position=0, ParameterSetName='path')]
        $path
    )

    
    $form = new-object Windows.Forms.Form

    $form.Text = "Image Viewer"
    $form.Size = New-Object System.Drawing.Size($screen.WorkingArea[0].Width, $screen.WorkingArea[0].Height)
    
    $pictureBox = new-object Windows.Forms.PictureBox
    $pictureBox.Size = New-Object System.Drawing.Size($screen.WorkingArea[0].Width, $screen.WorkingArea[0].Height)
    
   
    $pictureBox.Image = $path
    $pictureBox.SizeMode = 'Zoom'
    $pictureBox.Anchor = 'Top,Left,Bottom,Right'

    $form.controls.add($pictureBox)
    $form.Add_Shown( { $form.Activate() } )

    $form.ShowDialog()
    $path.dispose()
    Remove-Item "$($HOME)\image-viewer-temp\img.jpg" -Force
}

if(!$url) {
    $dir = Get-Location

    $Files = @(Get-ChildItem "$($dir.Path)\*" -Include *.jpg, *.jpeg, *.png)
    $maxSize = $Files.Length
    Write-Output $maxSize
    Write-Output $Files.Fullname
    $img = [System.Drawing.Image]::Fromfile((Get-Item $Files.Fullname[0]))
    Load-Images -path $img

}else{
    
    $wc = New-Object System.Net.WebClient
    $wc.DownloadFile($url.ToString(), "$($HOME)\image-viewer-temp\img.jpg") 
    $webimg = [System.Drawing.Image]::FromFile((Get-Item "$($HOME)\image-viewer-temp\img.jpg"))
    Load-Images -path $webimg
}
