# C:\Windows\System32\WindowsPowerShell\v1.0
#C:\Program Files\PowerShell\7\pwsh.exe 
<#______________________________________________________________________________________________________________________

	(c) Vitaly Ruhl 2024
    Homepage: Vitaly-Ruhl.de
    Github:https://github.com/vitalyruhl/
    License: GNU General Public License v3.0
______________________________________________________________________________________________________________________#>
#>


function Show-EmptyFolderConfirmationForm {
    param(
        [string[]]$Folders
    )

    $form = New-Object Windows.Forms.Form
    $form.Text = "Confirm Deletion"
    $form.Size = New-Object Drawing.Size @(400,300)
    $form.StartPosition = "CenterScreen"

    $listBox = New-Object Windows.Forms.ListBox
    $listBox.Location = New-Object Drawing.Point @(10,10)
    $listBox.Size = New-Object Drawing.Size @(360,200)
    $listBox.SelectionMode = "MultiExtended"

    foreach ($folder in $Folders) {
        $listBox.Items.Add($folder) | Out-Null
    }

    $form.Controls.Add($listBox)

    $yesButton = New-Object Windows.Forms.Button
    $yesButton.Location = New-Object Drawing.Point @(10,220)
    $yesButton.Size = New-Object Drawing.Size @(75,23)
    $yesButton.Text = "Yes"
    $yesButton.DialogResult = [Windows.Forms.DialogResult]::Yes
    $form.Controls.Add($yesButton)

    $noButton = New-Object Windows.Forms.Button
    $noButton.Location = New-Object Drawing.Point @(90,220)
    $noButton.Size = New-Object Drawing.Size @(75,23)
    $noButton.Text = "No"
    $noButton.DialogResult = [Windows.Forms.DialogResult]::No
    $form.Controls.Add($noButton)

    $form.AcceptButton = $yesButton
    $form.CancelButton = $noButton

    $result = $form.ShowDialog()

    if ($result -eq [Windows.Forms.DialogResult]::Yes) {
        return "Yes"
    } else {
        return "No"
    }
}
