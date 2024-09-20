New-Item -Name HV -Path C:\ -ItemType Directory
New-Item -Name VM -Path C:\HV -ItemType Directory
New-Item -Name ISO -Path C:\HV -ItemType Directory
New-Item -Name Base -Path C:\HV -ItemType Directory
Set-VMHost -VirtualMachinePath C:\HV\VM -VirtualHardDiskPath C:\HV\VM
New-VMSwitch -Name InternalSwitch -SwitchType Internal
New-VMSwitch -Name PrivateSwitch -SwitchType Private