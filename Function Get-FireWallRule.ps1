Function Get-FireWallRule
{Param ($Name, $Direction, $Enabled, $Protocol, $profile, $action, $grouping)
$Rules=(New-object –comObject HNetCfg.FwPolicy2).rules
If ($name)      {$rules= $rules | where-object {$_.name     –like $name}}
If ($direction) {$rules= $rules | where-object {$_.direction  –eq $direction}}
If ($Enabled)   {$rules= $rules | where-object {$_.Enabled    –eq $Enabled}}
If ($protocol)  {$rules= $rules | where-object {$_.protocol  -eq $protocol}}
If ($profile)   {$rules= $rules | where-object {$_.Profiles -bAND $profile}}
If ($Action)    {$rules= $rules | where-object {$_.Action     -eq $Action}}
If ($Grouping)  {$rules= $rules | where-object {$_.Grouping -Like $Grouping}}
$rules}

## <Perform Pre-Installation tasks here>
write-log -Message "Searching for Java Firewall Rules" -Severity 1 -Source $deployAppScriptFriendlyName
$FWRules = Get-FirewallRule -Name java*

If ($FWRules) {
    write-log -Message "Firewall Rule Java found" -Severity 1 -Source $deployAppScriptFriendlyName
    ForEach ($Rule in $FWRules) {
        write-log -Message "Removing Firewall Rule Java on $envOSName" -Severity 1 -Source $deployAppScriptFriendlyName
            Remove-NetFirewallRule -DisplayName $Rule.Name
        }
            }
Else {
    write-log -Message "No Firewall Rule Java found" -Severity 1 -Source $deployAppScriptFriendlyName
}

##*===============================================
##* POST-INSTALLATION
##*===============================================
[string]$installPhase = 'Post-Installation'

## <Perform Post-Installation tasks here>
write-log -Message "64-bit OS.  Configuring for the 64-bit OS" -Severity 1 -Source $deployAppScriptFriendlyName
# Define Path to add
$DestPath = $envProgramFiles
$DestPathx86 = $envProgramFilesX86
$DestPathData = $envProgramData
## Adding Firewall Rules for $appname
Write-Log -Message "Adding Firewall Rules for $appName" -Severity 1 -Source $deployAppScriptFriendlyName
New-NetFirewallRule -DisplayName "Java(TM) Platform SE binary" -Direction Inbound -Program "$DestPath\bin\javaw.exe" -Action Allow -Enabled True -Profile Domain -Protocol UDP
New-NetFirewallRule -DisplayName "Java(TM) Platform SE binary" -Direction Inbound -Program "$DestPath\bin\javaw.exe" -Action Allow -Enabled True -Profile Domain -Protocol TCP