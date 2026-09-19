<#
.SYNOPSIS
    Provision a portable MySQL 8.0 for the Gemnet server on Windows - no installer, no admin,
    no Windows service.

.DESCRIPTION
    The server needs a reachable MySQL 8.0+ with schema `rumblefighter` and user gemnet/gemnet
    (AGENTS.md section 4). This script unpacks the official MySQL ZIP archive, initializes a
    private data directory, starts mysqld on 127.0.0.1:3306, and provisions the schema, user
    and grants. Everything lives under -InstallRoot and is removed by deleting that folder.

    MySQL, not MariaDB: the table DDL in Gemnet/Persistence/Models/Model*.cs specifies
    COLLATE=utf8mb4_0900_ai_ci, which is a MySQL 8.0 collation that MariaDB does not implement.
    MariaDB would reject CREATE TABLE outright.

    InstallRoot deliberately defaults OUTSIDE OneDrive: a live database inside a synced folder
    causes file-locking conflicts and continuous multi-gigabyte uploads.

.PARAMETER ZipPath
    Path to an already-downloaded mysql-8.0.x-winx64.zip. If omitted and the archive is not
    already present under -InstallRoot, the script downloads it from dev.mysql.com (~243 MB).

.PARAMETER InstallRoot
    Where MySQL and its data directory live. Default C:\Users\<you>\gemnet-mysql.

.PARAMETER Force
    Re-initialize the data directory even if one already exists. DESTROYS existing data.

.EXAMPLE
    .\setup-mysql-windows.ps1 -ZipPath C:\downloads\mysql-8.0.40-winx64.zip
#>
[CmdletBinding()]
param(
    [string]$ZipPath,
    [string]$InstallRoot = (Join-Path $env:USERPROFILE 'gemnet-mysql'),
    [int]$Port = 3306,
    [switch]$Force
)

$ErrorActionPreference = 'Stop'

$MysqlVersion = '8.0.40'
$ZipUrl = "https://dev.mysql.com/get/Downloads/MySQL-8.0/mysql-$MysqlVersion-winx64.zip"
$DataDir = Join-Path $InstallRoot 'data'
$LogFile = Join-Path $InstallRoot 'mysqld.log'

function Write-Step { param([string]$m) Write-Host "[mysql] $m" -ForegroundColor Cyan }
function Write-Warn { param([string]$m) Write-Host "[mysql] $m" -ForegroundColor Yellow }
function Write-Fail { param([string]$m) Write-Host "[mysql] $m" -ForegroundColor Red }

New-Item -ItemType Directory -Force -Path $InstallRoot | Out-Null

# --- 1. Acquire the archive --------------------------------------------------
if (-not $ZipPath) {
    $ZipPath = Join-Path $InstallRoot "mysql-$MysqlVersion-winx64.zip"
}
if (-not (Test-Path $ZipPath)) {
    Write-Step "Downloading MySQL $MysqlVersion (~243 MB) from dev.mysql.com ..."
    Invoke-WebRequest -Uri $ZipUrl -OutFile $ZipPath -UseBasicParsing
}
Write-Step "Archive: $ZipPath"

# --- 2. Extract --------------------------------------------------------------
$BaseDir = Join-Path $InstallRoot "mysql-$MysqlVersion-winx64"
if (-not (Test-Path (Join-Path $BaseDir 'bin\mysqld.exe'))) {
    Write-Step "Extracting to $InstallRoot ..."
    Expand-Archive -Path $ZipPath -DestinationPath $InstallRoot -Force
}
$Mysqld = Join-Path $BaseDir 'bin\mysqld.exe'
$Mysql = Join-Path $BaseDir 'bin\mysql.exe'
$MysqlAdmin = Join-Path $BaseDir 'bin\mysqladmin.exe'
if (-not (Test-Path $Mysqld)) {
    Write-Fail "mysqld.exe not found under $BaseDir - extraction failed or the archive layout changed."
    exit 1
}
Write-Step "Base dir: $BaseDir"

# --- 3. Initialize the data directory ----------------------------------------
$alreadyInit = Test-Path (Join-Path $DataDir 'mysql')
if ($alreadyInit -and $Force) {
    Write-Warn 'Force specified - deleting the existing data directory.'
    Remove-Item -Recurse -Force $DataDir
    $alreadyInit = $false
}
if (-not $alreadyInit) {
    if (Test-Path $DataDir) { Remove-Item -Recurse -Force $DataDir }
    Write-Step 'Initializing data directory (root has no password - local dev only) ...'
    & $Mysqld --initialize-insecure "--basedir=$BaseDir" "--datadir=$DataDir" 2>&1 | Out-Null
    if (-not (Test-Path (Join-Path $DataDir 'mysql'))) {
        Write-Fail 'Initialization failed. Check that the Visual C++ 2019 redistributable is installed.'
        exit 1
    }
}
else {
    Write-Step 'Data directory already initialized - reusing it.'
}

# --- 4. Start mysqld ---------------------------------------------------------
$listening = Test-NetConnection -ComputerName 127.0.0.1 -Port $Port -InformationLevel Quiet -WarningAction SilentlyContinue
if ($listening) {
    Write-Step "Something is already listening on 127.0.0.1:$Port - assuming it is our mysqld."
}
else {
    Write-Step "Starting mysqld on 127.0.0.1:$Port ..."
    Start-Process -FilePath $Mysqld `
        -ArgumentList "--basedir=$BaseDir", "--datadir=$DataDir", "--port=$Port", '--bind-address=127.0.0.1' `
        -WindowStyle Hidden `
        -RedirectStandardError $LogFile

    $deadline = 30
    for ($i = 0; $i -lt $deadline; $i++) {
        Start-Sleep -Seconds 1
        if (Test-NetConnection -ComputerName 127.0.0.1 -Port $Port -InformationLevel Quiet -WarningAction SilentlyContinue) {
            $listening = $true
            break
        }
    }
    if (-not $listening) {
        Write-Fail "mysqld did not start within ${deadline}s. See $LogFile"
        exit 1
    }
}
Write-Step 'mysqld is up.'

# --- 5. Provision schema, user, grants ---------------------------------------
# Note: the server connects over TCP to 127.0.0.1, which does NOT match a 'gemnet'@'localhost'
# grant, so the '%' grant below is the one that actually gets used.
$sql = @"
CREATE DATABASE IF NOT EXISTS rumblefighter CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
CREATE USER IF NOT EXISTS 'gemnet'@'localhost' IDENTIFIED BY 'gemnet';
CREATE USER IF NOT EXISTS 'gemnet'@'%' IDENTIFIED BY 'gemnet';
GRANT ALL PRIVILEGES ON rumblefighter.* TO 'gemnet'@'localhost';
GRANT ALL PRIVILEGES ON rumblefighter.* TO 'gemnet'@'%';
FLUSH PRIVILEGES;
"@

Write-Step 'Provisioning schema rumblefighter and user gemnet ...'
$sql | & $Mysql --host=127.0.0.1 --port=$Port --user=root
if ($LASTEXITCODE -ne 0) {
    Write-Fail 'Provisioning failed.'
    exit 1
}

& $Mysql --host=127.0.0.1 --port=$Port --user=gemnet --password=gemnet `
    -e 'SELECT VERSION() AS version; SHOW DATABASES;'

Write-Host ''
Write-Step 'Done. The Gemnet server can now connect.'
Write-Host "  base dir : $BaseDir"      -ForegroundColor Gray
Write-Host "  data dir : $DataDir"      -ForegroundColor Gray
Write-Host "  log      : $LogFile"      -ForegroundColor Gray
Write-Host "  stop     : & '$MysqlAdmin' --host=127.0.0.1 --port=$Port --user=root shutdown" -ForegroundColor Gray
Write-Host "  remove   : delete $InstallRoot" -ForegroundColor Gray
Write-Host ''
Write-Host '  Next: .\run-server.ps1' -ForegroundColor Green
