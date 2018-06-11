Set-PSDebug -Trace 0
$CurrentFolder = $PWD
$UserProfile = $Env:USERPROFILE
$DownloadsFolder = "$UserProfile\Downloads\paltry"
$TempFolder = "$UserProfile\Temp"
$ToolsFolder = "$CurrentFolder\tools"
$SourceFolder = "$CurrentFolder\src"
$PluginsFolder = "$SourceFolder\plugins"
$LaunchFolder = "$CurrentFolder\launch"
$ScriptsFolder = "$CurrentFolder\scripts"
$Config = Get-Content 'config.json' | Out-String | ConvertFrom-Json
$Online = Test-Connection -ComputerName 8.8.8.8 -Quiet -ErrorAction Ignore
$ConfigCwd = Resolve-Path -Path "$($Config.cwd)"
$DisabledPlugins = $Config.disabled
$Global:PathExtensions = @()
$Global:ToolsInstalled = @()
$Global:EnvExtensions = @()

Import-Module $SourceFolder\lib.psm1

Out-Info "Setting Up..."
SetupFolders

Out-Info "Loading Plugins..."
Get-ChildItem "$PluginsFolder\*.ps1" | ForEach-Object {
  if (!($DisabledPlugins.Contains($_.BaseName))) {
    Out-Title "[$($_.BaseName)]"
    $Version = $Config.versions. "$($_.BaseName)"
    & $_ -Version $Version -UseLatestVersion (!$Version) -Config ($Config. "$($_.BaseName)")
  }
}

Write-Files
if (!($DisabledPlugins.Contains("launch"))) {
  explorer $LaunchFolder
}
