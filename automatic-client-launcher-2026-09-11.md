# Automatic routing launcher — September 11, 2026

The user accepted an external launcher that manages hosts entries automatically
after the direct EXE patch triggered integrity errors. This approach changes the
Windows hosts file internally; it is not a claim of zero system configuration.
Testers perform no manual edits. One administrator prompt is required per launch.

## Package and behavior

Source: `Tools/ClientLauncher`. Self-contained win-x64 .NET 8 executable, with no
runtime installation required. The package contains only GemnetLauncher.exe,
RumbleFighter.ini and README.txt. No server settings, accounts, database credentials,
game binaries or routing DLLs are packaged.

Copy these files beside the existing game and open GemnetLauncher.exe. It reads
`[Network] ServerIP=127.0.0.1` from RumbleFighter.ini. The original game and official
launcher remain unchanged. The launcher validates the original client SHA256 and
starts it with the observed `/DIRECT:Author:KimDongJin:V0935` argument and slahslrtm
event. This does not modify game authentication or integrity checks.

Ten exact modern/legacy gameplay hostnames (login, peer, chat, guild, square) are
temporarily mapped to the INI address. Other hostnames, including website/CDN and
integrity services, are not redirected. Native game sockets to those other services
may therefore remain external. Routing does not implement missing server services.

A machine-wide mutex prevents concurrent sessions. Before changing hosts, an undo
record is flushed to disk in an administrator-only ProgramData/GemnetLauncher folder.
Writes use same-directory atomic replacement. Setup verifies all ten DNS results.
Cleanup restores the original hosts bytes exactly when nobody else edited the file;
otherwise it removes only exact session entries and preserves unrelated changes and
new administrator overrides. A failed/terminated launch can be recovered on the next
launcher run, or using `--restore`. The journal is deleted only after verified cleanup.

Windows hosts changes affect the named services system-wide while the game runs.
The launcher must stay running until the game exits. Sudden power loss or forced
termination cannot guarantee immediate cleanup; next-launch recovery handles that.

## Tests

Four regression groups pass without touching the system hosts file:

- Conflicting addresses, mixed-alias lines, case/trailing-dot names and exact restore
  across UTF8 with/without BOM and UTF16 LE/BE.
- Cleanup preserving concurrent unrelated edits and newer administrator mappings.
- Strict IPv4 INI parsing, rejecting duplicates, malformed values and command text.
- Real temporary-file transactions: durable undo, duplicate lease rejection, a new
  instance recovering simulated crashes before/after apply, and read-only write
  failure followed by restoration.

Build: `Tools/ClientLauncher/build-package.ps1`. Packages use an explicit three-file
allowlist, avoiding accidental server configuration or backup inclusion.

## Current installed validation

Installed C:/PlayRedFox/RumbleFighter/GemnetLauncher.exe and RumbleFighter.ini.
Launched PID21792, unmodified game PID39752. All ten gameplay names verified127.0.0.1;
actual established login7000 andpeer33343 sockets local. Original game SHA remains
94194afa95d3d2cc81a55438a0f584bfaf039ca85adab5b07966ae3e4d593a59, original launcherSHA
21dd6e1efb35d140876db353cbf57130f215e7173b80bb6df7d0f29c66e1b77b.
System hosts SHA before this launch:
74bc8c8a7dea633533f7e8529bb6c7b15ca5083cbb0070596a9c6d54bd4549e0.
The game ran through the local connection and the user reported in-game feature
bugs. At 09:55:12Z the launcher observed game exit and restored routing. The hosts
file returned to the exact SHA above; original game/launcher hashes are unchanged.
The user separately reported an in-game exit crash/hang, which is not explained
by launcher cleanup. Full client compatibility is not established by this test.
The ZIP in artifacts/automatic-client-launcher-v2 was checked: exactly the EXE,
public INI and README, with valid ZIP checksums and no server configuration.
