#Load Windows Forms assembly
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

#Create a new form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Basic Installer"
$form.Size = New-Object System.Drawing.Size(400, 300)
$form.StartPosition = "CenterScreen"

#Add a label for the installation path
$label = New-Object System.Windows.Forms.Label
$label.Text = "Installation Path:"
$label.Location = New-Object System.Drawing.Point(20, 20)
$label.Size = New-Object System.Drawing.Size(100, 20)
$form.Controls.Add($label)

#Add a text box for the installation path input
$textBox = New-Object System.Windows.Forms.TextBox
$textBox.Location = New-Object System.Drawing.Point(130, 20)
$textBox.Size = New-Object System.Drawing.Size(200, 20)
$form.Controls.Add($textBox)

#Add a button to browse for installation path
$browseButton = New-Object System.Windows.Forms.Button
$browseButton.Text = "Browse"
$browseButton.Location = New-Object System.Drawing.Point(340, 18)
$browseButton.Size = New-Object System.Drawing.Size(50, 24)
$form.Controls.Add($browseButton)

#Browse button click event
$browseButton.Add_Click({
    $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    if ($folderBrowser.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $textBox.Text = $folderBrowser.SelectedPath
    }
})

#Add a label for the installation status
$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Text = "Status:"
$statusLabel.Location = New-Object System.Drawing.Point(20, 60)
$statusLabel.Size = New-Object System.Drawing.Size(100, 20)
$form.Controls.Add($statusLabel)

#Add a progress bar
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(130, 60)
$progressBar.Size = New-Object System.Drawing.Size(200, 20)
$progressBar.Style = 'Continuous'
$progressBar.Value = 0
$form.Controls.Add($progressBar)

#Add an Install button
$installButton = New-Object System.Windows.Forms.Button
$installButton.Text = "Install"
$installButton.Location = New-Object System.Drawing.Point(130, 100)
$installButton.Size = New-Object System.Drawing.Size(75, 30)
$form.Controls.Add($installButton)

#Install button click event
$installButton.Add_Click({
    $progressBar.Value = 0
    $statusLabel.Text = "Installing..."
    
    #Simulate installation with a loop
    for ($i = 1; $i -le 100; $i += 10) {
        Start-Sleep -Milliseconds 200
        $progressBar.Value = $i
    }

    $statusLabel.Text = "Installation Complete!"
    [System.Windows.Forms.MessageBox]::Show("Installation Complete!", "Installation", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
})

#Add a Cancel button
$cancelButton = New-Object System.Windows.Forms.Button
$cancelButton.Text = "Cancel"
$cancelButton.Location = New-Object System.Drawing.Point(230, 100)
$cancelButton.Size = New-Object System.Drawing.Size(75, 30)
$form.Controls.Add($cancelButton)

#Cancel button click event
$cancelButton.Add_Click({
    $form.Close()
})

#Show the form
$form.ShowDialog()