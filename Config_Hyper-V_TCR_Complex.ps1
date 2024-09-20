#Add type Windows Forms
Add-Type -AssemblyName System.Windows.Forms

#Check Windows Version
$Windows = (Get-computerInfo).OSname
$Winver = $Windows -replace "Microsoft Windows", ""
Write-host $WinVer

if((Get-WindowsOptionalFeature -online -FeatureName Microsoft-Hyper-V-All).length -eq 0){
    Write-Host "upgrade os to"
}

<#
 # {# Check if Hyper-V is enabled
$hyperv = Get-WindowsOptionalFeature -FeatureName Microsoft-Hyper-V-All -Online 
if($hyperv.State -eq "Enabled") {
    Write-Host "Hyper-V is enabled."} else {
    Write-Host "Hyper-V is disabled."
 }


#Test if folders exist otherwise Create folders
If (-not (Test-Path -Path "$env:SystemDrive\hv")){
    New-Item -Name HV -Path C:\ -ItemType Directory
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

#Create Completion Pop-up
[System.Windows.Forms.MessageBox]::Show("Hyper-V have been Configured"), "Process Complete", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information:Enter a comment or description}
#>