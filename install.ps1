$ErrorActionPreference = "Stop"

$SourceDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ItpBin = Join-Path $SourceDir "bin\itp"
$Prefix = if ($env:ITP_PREFIX) { $env:ITP_PREFIX } else { Join-Path $HOME ".local" }
$TargetDir = Join-Path $Prefix "bin"
$TargetScript = Join-Path $TargetDir "itp.js"
$TargetCmd = Join-Path $TargetDir "itp.cmd"

if (!(Test-Path $ItpBin)) {
  throw "itp binary not found at $ItpBin"
}

New-Item -ItemType Directory -Force -Path $TargetDir | Out-Null
Copy-Item -Force $ItpBin $TargetScript
Set-Content -Path $TargetCmd -Encoding ASCII -Value @"
@echo off
node "%~dp0itp.js" %*
"@

Write-Output "Installed itp to $TargetCmd"
if (($env:Path -split ';') -notcontains $TargetDir) {
  Write-Output "Add $TargetDir to PATH before running itp."
} else {
  & $TargetCmd --version
}
