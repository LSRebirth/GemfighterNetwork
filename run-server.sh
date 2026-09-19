#!/usr/bin/env bash
# Convenience launcher for the Gemnet Rumble Fighter server emulator on macOS.
set -e

export PATH="$HOME/.dotnet:$PATH"
export DOTNET_CLI_TELEMETRY_OPTOUT=1

# Ensure MySQL is running (Homebrew).
if ! /opt/homebrew/bin/mysqladmin ping >/dev/null 2>&1; then
  echo "Starting MySQL..."
  brew services start mysql
  sleep 3
fi

cd "$(dirname "$0")/Gemnet"

# BoxLoader reads Data/Boxes on startup; the folder must exist (empty is fine).
mkdir -p Data/Boxes

echo "Starting Gemnet on port 7000 (plaintext, UseEncryption=false)..."
exec dotnet run -c Debug
