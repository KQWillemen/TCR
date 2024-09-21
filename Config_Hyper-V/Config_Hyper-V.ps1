#Load Windows Forms and drawing
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

#HelpSite for incorrect OS
$HelpSite = "https://www.google.com"

#Remove scheduled task at startup  if exists
$taskName = "ConfigHyperV"
$taskExists = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
if ($taskExists) {
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
}

#Check vmms service and Restart service
$serviceName = "vmms"
$service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue

if ($service.Status -eq 'Running') {
    Restart-Service -Name $serviceName -Force
}

#Function to check if Hyper-V is enabled
function Get-HyperVStatus {
    $feature = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All
    if ($feature.State -eq "Enabled") {
        return "Enabled"
    } else {
        return "Disabled"
    }
}

#Function to get the Windows version
function Get-WindowsVersion {
    $WinVer = (Get-computerInfo).OSname
    return $WinVer
}

#Function pop-up errormessage 
function Show-ErrorPopup {
    param (
        [string]$message
    )

    # Create the pop-up window
    [System.Windows.Forms.MessageBox]::Show($message, "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
}

#Function Enable Hyper-V
Function Enable-HyperV{
    $exitButton.Visible = $false
    $HVEnableButton.Visible = $false
    $hypervLabel.Text = "Progress:"
    $hypervTextBox.Visible = $false
    $progressBar.Visible = $true

    #Lol not needed, but people like to see it :)
    for ($i = 1; $i -le 80; $i += 10) {
        Start-Sleep -Milliseconds 200
        $progressBar.Value = $i
    }

    #enable Hyper-V
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All -NoRestart -All -ErrorAction Stop
    $progressBar.Value = 100

    if ($LASTEXITCODE -eq 0){
        $errorDetails = "Error occurred:`n$($_.Exception.Message)`n`nSee Event Viewer for more information"
        Show-ErrorPopup -message $errorDetails
        $exitButton.Visible = $true
    }else {
        $exitButton.Visible = $true
        $RestartButton.Visible = $true
    }
 
}

#Function Restart
function Start-Restart{
    #Path of the .exe
    $exePath = (Get-Process -Id $PID).Path

    #Register the task
    $taskDescription = "Restart HyperVConfig once after system reboot"
    $action = New-ScheduledTaskAction -Execute $exePath
    $trigger = New-ScheduledTaskTrigger -AtLogon
    $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
    Register-ScheduledTask -Action $action -Trigger $trigger -TaskName $taskName -Description $taskDescription -User $env:USERNAME -RunLevel Highest -Settings $settings

    Restart-Computer -Force
}

#Function to config Hyper-V
function set-HyperV {
    $exitButton.Visible = $false
    $ConfigButton.Visible = $false
    $hypervLabel.Text = "Progress:"
    $hypervTextBox.Visible = $false
    $progressBar.Visible = $true
    

    #Lol not needed, but people like to see it :)
    for ($i = 1; $i -le 80; $i += 10) {
        Start-Sleep -Milliseconds 200
        $progressBar.Value = $i
    }

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
    
    #Names of the virtual switches
    $switchNames = @("PrivateSwitch", "InternalSwitch")

    #Switch types
    $switchTypes = @("Private", "Internal")

    foreach ($index in 0..1) {
        $switchName = $switchNames[$index]
        $switchType = $switchTypes[$index]

        #Check if the virtual switch exists
        $switch = Get-VMSwitch -Name $switchName -ErrorAction SilentlyContinue

        if ($null -eq $switch) {
            New-VMSwitch -Name $switchName -SwitchType $switchType
        } 
    }
    $progressBar.Value = 100
    $hypervLabel.Text = "Complete!"
    $exitButton.Visible = $true
}

#Create the form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Config Hyper-V"
$form.Size = New-Object System.Drawing.Size(400, 200)
$form.StartPosition = "CenterScreen"
$form.TopMost = $true

#create Icon
$base64Icon = "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"
$iconBytes = [Convert]::FromBase64String($base64Icon)
$memoryStream = New-Object System.IO.MemoryStream(,$iconBytes)
$icon = [System.Drawing.Icon]::FromHandle(([System.Drawing.Bitmap]::FromStream($memoryStream)).GetHicon())
$form.Icon = $icon

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

#Add progress bar
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(150, 60)
$progressBar.Size = New-Object System.Drawing.Size(200, 20)
$progressBar.Style = 'Continuous'
$progressBar.Value = 0
$progressBar.Visible = $false
$form.Controls.Add($progressBar)

#Create a hidden button, appears if Windows Ver is incorrect
$HelpButton = New-Object System.Windows.Forms.Button
$HelpButton.Text = "OS Help"
$HelpButton.Location = New-Object System.Drawing.Point(150, 100)
$HelpButton.Size = New-Object System.Drawing.Size(120, 30)
$HelpButton.Visible = $false  # Set to hidden by default
$form.Controls.Add($HelpButton)

#Config Button Event
$HelpButton.Add_Click({
    Start-Process $HelpSite
})

$Winver = Get-WindowsVersion
if (-not($Winver -like "*Pro*" -or $Winver -like "*Education*")) {
    $HelpButton.Visible = $true 
} 

#Create a hidden Config button, appears if Hyper-V is enabled
$ConfigButton = New-Object System.Windows.Forms.Button
$ConfigButton.Text = "Config Hyper-V"
$ConfigButton.Location = New-Object System.Drawing.Point(150, 100)
$ConfigButton.Size = New-Object System.Drawing.Size(120, 30)
$ConfigButton.Visible = $false  # Set to hidden by default
$form.Controls.Add($ConfigButton)

#Config Button Event
$ConfigButton.Add_Click({
    set-HyperV
})

#Create a hidden HVEnable button, appears if Hyper-V is Disabled
$HVEnableButton = New-Object System.Windows.Forms.Button
$HVEnableButton.Text = "Enable Hyper-V"
$HVEnableButton.Location = New-Object System.Drawing.Point(150, 100)
$HVEnableButton.Size = New-Object System.Drawing.Size(120, 30)
$HVEnableButton.Visible = $false  # Set to hidden by default
$form.Controls.Add($HVEnableButton)

#HVEnable Button Event
$HVEnableButton.Add_Click({
    Enable-HyperV
})

#Create a hidden Enable button, appears if Hyper-V is enabled
$RestartButton = New-Object System.Windows.Forms.Button
$RestartButton.Text = "Restart"
$RestartButton.Location = New-Object System.Drawing.Point(150, 100)
$RestartButton.Size = New-Object System.Drawing.Size(120, 30)
$RestartButton.Visible = $false  # Set to hidden by default
$form.Controls.Add($RestartButton)

#Restart Button Event
$RestartButton.Add_Click({
    Start-Restart
})

#Activate Correct Buttons Based on Hyper-V Detection
$hypervStatus = Get-HyperVStatus
if ($hypervStatus -eq "Disabled"){
    $HVEnableButton.Visible = $true
}elseif ($hypervStatus -eq "Enabled") {
    $ConfigButton.Visible = $true
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
    $memoryStream.Dispose()
})

# Show the form
$form.ShowDialog()