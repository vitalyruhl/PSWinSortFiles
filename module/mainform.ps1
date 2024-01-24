# C:\Windows\System32\WindowsPowerShell\v1.0
 
<#______________________________________________________________________________________________________________________

	(c) Vitaly Ruhl 2024
    Homepage: Vitaly-Ruhl.de
    Github:https://github.com/vitalyruhl/
    License: GNU General Public License v3.0
______________________________________________________________________________________________________________________#>
#>

#region Checkform
# https://www.windowspro.de/script/grafische-oberflaeche-gui-fuer-powershell-scripts-erstellen
# https://lazyadmin.nl/powershell/powershell-gui-howto-get-started/

[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
$form = New-Object System.Windows.Forms.Form
#$form.Backcolor="white"
$form.BackgroundImageLayout = 2

$form.StartPosition = "CenterScreen"
$form.Size = New-Object System.Drawing.Size(300,350)
$form.Text = "Select Settings"
#endregion



#region Radio Buttons
    $radioButton1 = New-Object System.Windows.Forms.RadioButton
    $radioButton2 = New-Object System.Windows.Forms.RadioButton
    $radioButton3 = New-Object System.Windows.Forms.RadioButton
    $groupBox = New-Object System.Windows.Forms.GroupBox
    $groupBox.Controls.AddRange(
    @(
    $radioButton1,
    $radioButton2,
    $radioButton3
    ))
    $groupBox.Location = New-Object System.Drawing.Point(10, 10)
    $groupBox.Name = 'groupBox'
    $groupBox.Size = New-Object System.Drawing.Size(260, 144)
    $groupBox.Text = 'choose Option'

        # radioButton1
        $radioButton1.Location = New-Object System.Drawing.Point(8, 32)
        $radioButton1.Size = New-Object System.Drawing.Size(230,20)
        $radioButton1.Name = 'radioButton1'
        $radioButton1.Text = 'Yaer'
        $radioButton1.Checked = $true

        # radioButton2
        $radioButton2.Location = New-Object System.Drawing.Point(8, 64)
        $radioButton2.Size = New-Object System.Drawing.Size(230,20)
        $radioButton2.Name = 'radioButton2'
        $radioButton2.Text = 'Yaer and Month'

        # radioButton3
        $radioButton3.Location = New-Object System.Drawing.Point(8, 96)
        $radioButton3.Size = New-Object System.Drawing.Size(230,20)
        $radioButton3.Name = 'radioButton3'
        $radioButton3.Text = 'Delete empty folders'
    $form.Controls.Add($groupBox)
 
#endregion



#region checkboxes
    
    $objTypeCheckbox = New-Object System.Windows.Forms.Checkbox 
    $objTypeCheckbox.Location = New-Object System.Drawing.Size(10,170) 
    $objTypeCheckbox.Size = New-Object System.Drawing.Size(500,20)
    $objTypeCheckbox.Text = "Move files instade to copy them"
    $objTypeCheckbox.TabIndex = 4
    $form.Controls.Add($objTypeCheckbox)
    
#endregion



#region text and Inputs
    
    $label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Point(10,200)
    $label.Size = New-Object System.Drawing.Size(280,20)
    $label.Text = 'File filter:'
    $form.Controls.Add($label)

    $textBox = New-Object System.Windows.Forms.TextBox
    $textBox.Location = New-Object System.Drawing.Point(10,220)
    $textBox.Size = New-Object System.Drawing.Size(260,20)
    $textBox.Text = $global:Filter
    $form.Controls.Add($textBox)
    
#endregion

#region Buttons


    #region Cancel-Buttons
        $CancelButton = New-Object System.Windows.Forms.Button
        # Die nächsten beiden Zeilen legen die Position und die Größe des Buttons fest
        $CancelButton.Location = New-Object System.Drawing.Size(90,260)
        $CancelButton.Size = New-Object System.Drawing.Size(75,23)
        $CancelButton.Text = "Cancel"
        $CancelButton.Name = "Cancel"
        $CancelButton.DialogResult = "Cancel"
        
        #Die folgende Zeile ordnet dem Click-Event die Schließen-Funktion für das Formular zu
        $CancelButton.Add_Click({$form.Close()})
        $form.Controls.Add($CancelButton)
    #endregion


    #region OK Button 
        $okButton = New-Object System.Windows.Forms.Button
        $okButton.Location = New-Object System.Drawing.Size(190,260)
        $okButton.Size = New-Object System.Drawing.Size(75,23)
        $okButton.Text = 'OK'
        $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
        $form.AcceptButton = $okButton
        $form.Controls.Add($okButton)
        $okButton.Add_Click({
            okButtonClick
         })
    #endregion
    [void] $form.ShowDialog()
#endregion

