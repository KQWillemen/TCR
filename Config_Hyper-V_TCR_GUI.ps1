#Load Windows Forms and drawing
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

#Function to check if Hyper-V is enabled
function Get-HyperVStatus {
    $feature = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All
    if ($feature.State -eq "Enabled") {
        return "Disabled"
    } else {
        return "Disabled"
    }
}

#Function to get the Windows version
function Get-WindowsVersion {
    $WinVer = (Get-computerInfo).OSname
    return $WinVer
}

#Function to config Hyper-V
function set-HyperV {
    #Test if folders exist otherwise Create folders
    If (-not (Test-Path -Path "$env:SystemDrive\hv")){
        New-Item -Name HV -Path $env:SystemDrive -ItemType Directory
    }
    
    $HyperV_DirList = @(
        "VM",
        "ISO",
        "Base"
    )
    
    foreach ($Dir in $HyperV_DirList) {
        If (-not(Test-path -Path "$env:SystemDrive\hv\$Dir")){
            New-Item -Name $Dir -Path "$env:SystemDrive\HV" -ItemType Directory
        }
    }
    
    #Set Default Virtual Machine path on machine.
    Set-VMHost -VirtualMachinePath "$env:SystemDrive\HV\VM" -VirtualHardDiskPath "$env:SystemDrive\HV\VM"    
    #Create Internal Switch
    New-VMSwitch -Name InternalSwitch -SwitchType Internal
    #Create Private Switch
    New-VMSwitch -Name PrivateSwitch -SwitchType Private
}

#Create the form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Config Hyper-V"
$form.Size = New-Object System.Drawing.Size(400, 200)
$form.StartPosition = "CenterScreen"

#create Icon
#$base64Icon = ""
#$iconBytes = [Convert]::FromBase64String($base64Icon)
#$memoryStream = New-Object System.IO.MemoryStream(,$iconBytes)
#$icon = [System.Drawing.Icon]::FromHandle(([System.Drawing.Bitmap]::FromStream($memoryStream)).GetHicon())
#$form.Icon = $icon

#label for Windows version
$WinVerLabel = New-Object System.Windows.Forms.Label
$WinVerLabel.Text = "OS Version:"
$WinVerLabel.Location = New-Object System.Drawing.Point(20, 20)
$WinVerLabel.Size = New-Object System.Drawing.Size(120, 20)
$form.Controls.Add($WinVerLabel)

#text box to display Windows version
$WinVerTextBox = New-Object System.Windows.Forms.TextBox
$WinVerTextBox.Location = New-Object System.Drawing.Point(150, 20)
$WinVerTextBox.Size = New-Object System.Drawing.Size(200, 20)
$WinVerTextBox.ReadOnly = $true
$WinVerTextBox.Text = Get-WindowsVersion
$form.Controls.Add($WinVerTextBox)

#label for Hyper-V status
$hypervLabel = New-Object System.Windows.Forms.Label
$hypervLabel.Text = "Hyper-V Status:"
$hypervLabel.Location = New-Object System.Drawing.Point(20, 60)
$hypervLabel.Size = New-Object System.Drawing.Size(120, 20)
$form.Controls.Add($hypervLabel)

#text box for Hyper-V status
$hypervTextBox = New-Object System.Windows.Forms.TextBox
$hypervTextBox.Location = New-Object System.Drawing.Point(150, 60)
$hypervTextBox.Size = New-Object System.Drawing.Size(200, 20)
$hypervTextBox.ReadOnly = $true
$hypervTextBox.Text = Get-HyperVStatus
$form.Controls.Add($hypervTextBox)

#Create a hidden Help button, appears if Windows Verion is incorrect
$enableHelpButton = New-Object System.Windows.Forms.Button
$enableHelpButton.Text = "OS Help"
$enableHelpButton.Location = New-Object System.Drawing.Point(150, 100)
$enableHelpButton.Size = New-Object System.Drawing.Size(120, 30)
$enableHelpButton.Visible = $false  # Set to hidden by default
$form.Controls.Add($enableHelpButton)

$Winver = Get-WindowsVersion
if (-not($Winver -like "*Pro*" -or $Winver -like "*Education*")) {
    $enableHelpButton.Visible = $true 
} 

#Create a hidden Config button, appears if Hyper-V is enabled
$enableConfigButton = New-Object System.Windows.Forms.Button
$enableConfigButton.Text = "Config Hyper-V"
$enableConfigButton.Location = New-Object System.Drawing.Point(150, 100)
$enableConfigButton.Size = New-Object System.Drawing.Size(120, 30)
$enableConfigButton.Visible = $false  # Set to hidden by default
$form.Controls.Add($enableConfigButton)

#Config Button Event
$enableConfigButton.Add_Click({
})

#Create a hidden Enable button, appears if Hyper-V is enabled
$HVEnableButton = New-Object System.Windows.Forms.Button
$HVEnableButton.Text = "Enable Hyper-V"
$HVEnableButton.Location = New-Object System.Drawing.Point(150, 100)
$HVEnableButton.Size = New-Object System.Drawing.Size(120, 30)
$HVEnableButton.Visible = $false  # Set to hidden by default
$form.Controls.Add($HVEnableButton)

#Enable Button Event
$HVEnableButton.Add_Click({
})

#Activate Correct Buttons Based on Hyper-V Detection
$hypervStatus = Get-HyperVStatus
Write-host $HypervStatus
if ($hypervStatus -eq "Disabled"){

}elseif ($hypervStatus -eq "Enabled") {
    $enableConfigButton.Visible = $true
}

#exit button
$exitButton = New-Object System.Windows.Forms.Button
$exitButton.Text = "Exit"
$exitButton.Location = New-Object System.Drawing.Point(275, 100)
$exitButton.Size = New-Object System.Drawing.Size(75, 30)
$form.Controls.Add($exitButton)

#exit button event
$exitButton.Add_Click({
    $form.Close()
})

# Show the form
$form.ShowDialog()