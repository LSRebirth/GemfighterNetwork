<#
.SYNOPSIS
    Windows launcher for the Gemnet Rumble Fighter server emulator.

.DESCRIPTION
    Windows equivalent of run-server.sh (which is macOS/Homebrew-only). Verifies the
    .NET SDK, ensures Data/Boxes and settings.json exist, checks that the configured
    MySQL host is reachable, then starts the server from the nested project directory.

    CWD matters: settings.json and Data/Boxes are resolved relative to the working
    directory, so this script cd's into Gemnet\ before running.

.PARAMETER SkipDbCheck
    Start the server without probing MySQL first. The server itself still aborts if it
    cannot connect (Program.cs Main), so this only skips the friendlier pre-flight error.

.PARAMETER Configuration
    Build configuration. Defaults to Debug.

.EXAMPLE
    .\run-server.ps1
#>
[CmdletBinding()]
param(
    [switch]$SkipDbCheck,
    [ValidateSet('Debug', 'Release')]
    [string]$Configuration = 'Debug'
)

$ErrorActionPreference = 'Stop'
$env:DOTNET_CLI_TELEMETRY_OPTOUT = '1'

$ProjectDir = Join-Path $PSScriptRoot 'Gemnet'
$SettingsPath = Join-Path $ProjectDir 'settings.json'
$BoxDir = Join-Path $ProjectDir 'Data\Boxes'

function Write-Step { param([string]$Message) Write-Host "[gemnet] $Message" -ForegroundColor Cyan }
function Write-Warn { param([string]$Message) Write-Host "[gemnet] $Message" -ForegroundColor Yellow }
function Write-Fail { param([string]$Message) Write-Host "[gemnet] $Message" -ForegroundColor Red }

# --- 1. .NET SDK -------------------------------------------------------------
$dotnet = Get-Command dotnet -ErrorAction SilentlyContinue
if (-not $dotnet) {
    Write-Fail 'dotnet not found on PATH. Install the .NET 8 SDK from https://dotnet.microsoft.com/download'
    exit 1
}

# The project targets net8.0. A newer SDK can build it as long as the 8.0 reference pack
# is present, and a newer runtime can host it via roll-forward, but warn if neither 8.0
# SDK nor 8.0 runtime is installed.
$runtimes = & dotnet --list-runtimes
if (-not ($runtimes | Select-String -SimpleMatch 'Microsoft.NETCore.App 8.')) {
    Write-Warn 'No .NET 8 runtime found. Enabling roll-forward to a newer major runtime.'
    $env:DOTNET_ROLL_FORWARD = 'Major'
}

# --- 2. Project layout -------------------------------------------------------
if (-not (Test-Path $ProjectDir)) {
    Write-Fail "Project directory not found: $ProjectDir"
    exit 1
}

# BoxLoader.LoadBoxes throws DirectoryNotFoundException if this is missing. Empty is fine.
if (-not (Test-Path $BoxDir)) {
    Write-Step "Creating $BoxDir (BoxLoader requires it; empty is fine)"
    New-Item -ItemType Directory -Force -Path $BoxDir | Out-Null
}

# settings.json is gitignored, so a fresh clone will not have one.
if (-not (Test-Path $SettingsPath)) {
    Write-Step 'settings.json missing - writing defaults (see AGENTS.md section 4)'
    $defaults = [ordered]@{
        ipAddress          = '127.0.0.1'
        BindAddress        = '127.0.0.1'
        CatalogPath        = 'Data/Shop/client-catalog.json'
        Port               = 7000
        P2PPort            = 33343
        DBConnectionString = 'Server=127.0.0.1;Port=3306;User=gemnet;Password=gemnet;Database=rumblefighter;'
        UseEncryption      = $true
        RC4Key             = 'abcde'
        MaxConnections     = 1000
    }
    $defaults | ConvertTo-Json | Out-File -FilePath $SettingsPath -Encoding utf8
}

$settings = Get-Content $SettingsPath -Raw | ConvertFrom-Json
$port = $settings.Port

# --- 3. MySQL reachability ---------------------------------------------------
# Program.Main aborts with InvalidOperationException if the DB connection fails, so
# probe first and give a useful message instead of a 30-line stack trace.
if (-not $SkipDbCheck) {
    $dbHost = '127.0.0.1'
    $dbPort = 3306
    if ($settings.DBConnectionString -match 'Server=([^;]+)') { $dbHost = $Matches[1] }
    if ($settings.DBConnectionString -match 'Port=(\d+)')     { $dbPort = [int]$Matches[1] }

    Write-Step "Checking MySQL at ${dbHost}:${dbPort} ..."
    $probe = Test-NetConnection -ComputerName $dbHost -Port $dbPort -InformationLevel Quiet -WarningAction SilentlyContinue
    if (-not $probe) {
        Write-Fail "No MySQL listening on ${dbHost}:${dbPort}."
        Write-Host ''
        Write-Host '  The server requires a reachable MySQL 8.0+ with schema `rumblefighter`' -ForegroundColor Gray
        Write-Host '  and user gemnet/gemnet. See AGENTS.md section 4, or run:' -ForegroundColor Gray
        Write-Host '      .\setup-mysql-windows.ps1' -ForegroundColor Gray
        Write-Host ''
        Write-Host '  To start anyway (the server will still abort on connect):' -ForegroundColor Gray
        Write-Host '      .\run-server.ps1 -SkipDbCheck' -ForegroundColor Gray
        exit 1
    }
    Write-Step 'MySQL reachable.'
}

# --- 4. Listener -------------------------------------------------------------
$bindAddress = if ($settings.BindAddress) { $settings.BindAddress } else { '0.0.0.0' }
Write-Step "Server listener: ${bindAddress}:$port"

# --- 5. Run ------------------------------------------------------------------
Push-Location $ProjectDir
try {
    Write-Step "Starting Gemnet on port $port (encryption=$($settings.UseEncryption), key=$($settings.RC4Key))"
    & dotnet run -c $Configuration
}
finally {
    Pop-Location
}
