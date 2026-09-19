# Rumble Fighter Emulator

Current-client archive tooling: [NSZ listing, decryption, extraction, and verification](docs/nsz-tools.md).

> September 9, 2026: the RedFox black-screen wait was traced to its separate
> ProudNet peer-service initialization. A local prototype completed the real
> client's handshake, allowing post-login requests to begin. The next `ServerErr`
> exposed an avatar-list count mismatch (byte versus u32), now corrected along
> with equipment-slot parsing. Eight Gemnet tests and four peer-prototype tests
> pass. The user confirmed the real client reaches the main menu and stays open
> after waiting 20 seconds and clicking Lobby, with peer keepalives handled.
> Room entry is user-confirmed for Classic Battle and other tested modes except
> Hyper Battle. Hyper Battle requires level 5; the local test account now has
> 5000 EXP, awaiting a fresh login and room test. Multiplayer fights remain unverified. See the
> [ProudNet investigation and setup](docs/redfox-proudnet.md).

> September 8, 2026 (historical checkpoint): the current RedFox client connects to local Gemnet and
> accepts `test@test.com / test` through its real encrypted login exchange.
> The launcher restarts the game without the native server argument, so local
> testing requires the login-hostname redirect described below. The client opens
> its windowed game screen and reaches `GS_SPLASH`, but currently displays a black
> screen with no post-login requests observed. Lobby/gameplay remain unverified.
> Six protocol tests pass; both structured and raw replies now share outbound RC4.

### Current RedFox local login setup

1. Start MySQL and Gemnet on TCP port 7000, with encryption enabled and key `abcde`.
2. Run [Tools/seed-development-account.sql](Tools/seed-development-account.sql)
   against the `rumblefighter` schema after its tables have been created. It seeds
   the local test account, one avatar, and two starter inventory items. Existing
   accounts keep their passwords. BCrypt storage requires `Password varchar(72)`.
3. Run [client/set-redfox-local-host.ps1](client/set-redfox-local-host.ps1) in an
   elevated PowerShell. It backs up the Windows hosts file, adds only
   `127.0.0.1 rumble-fighter.gss1.playredfox.net`, flushes DNS, and verifies resolution.
   This affects this computer's game login routing. Remove the marked entry and
   flush DNS to restore official login routing.
4. For the post-login experiment, run `python Tools/proudnet_probe.py` (requires
   `cryptography`) and run the hosts helper with `-PeerService` in elevated
   PowerShell. This additionally routes the peer hostname to local TCP 33343.
   The prototype implements initial negotiation and ping replies, not full P2P.
5. Restart the normal RedFox launcher and use the local test credentials above.
   Confirm a real connection and `LOGIN/0x90` followed by `LOGIN/0x84` in Gemnet's logs.

No modern game binary patches have been applied. The notes below describe earlier
milestones and the historical v1.1.2 client; the September 9 status takes precedence.

> September 7, 2026: research has begun on the newer RedFox client. All ten
> historical post-login operations now have identified counterparts in its loaded
> code. See the [RedFox protocol map](docs/redfox-2026-09-protocol-map.md) for new
> opcodes, function addresses, corrected operation names, and parser layouts.
> This mapping preceded the successful September 8 local-login test above.

> September 6, 2026 update: see [memory.md](memory.md) for the current handoff.
> Query replies now use action + 1; QUERY/0x36 is a status-only acknowledgement
> based on client disassembly. TCP fragmentation/coalescing and disconnect cleanup
> are fixed, and the client v2 patch restores receive matching. Build, encrypted
> replay, and four protocol tests pass. Actual game lobby access is still unverified.
> The older status and patch details below are historical where they conflict.

A .NET 8 private-server emulator for the beat-'em-up MMO **Rumble Fighter**. Fork of [Primitheus/Gemnet](https://github.com/Primitheus/Gemnet), continued at [oyenmwen/rumble-fighter-emulator](https://github.com/oyenmwen/rumble-fighter-emulator).

## What this is

**Rumble Fighter** is a free-to-play, arena-style 3D fighting MMO originally operated by OGPlanet. The official servers are long gone. This project reimplements the **server** side of the game — the TCP service the client talks to for version checks, login, accounts, avatars, inventory, and (eventually) lobby/room/match flow.

This repository contains **only the server**. The game **client** (`RumbleFighter.exe` and its data) is a separate, copyrighted Windows binary that is **not** included here (see [Prerequisites](#prerequisites)). The server runs on macOS or Linux (developed and verified on macOS/arm64); the client runs on Windows and connects over the network.

## Status

| Component | Status |
|---|---|
| Server builds (`dotnet build`) | ✅ Working |
| TCP listener on port 7000 | ✅ Working |
| MySQL schema + accounts/avatars/inventory | ✅ Working |
| RC4 encryption (login handshake) | ✅ Working |
| Real v1.1.2 client **login** end-to-end | ✅ Working (with client patches) |
| Client **rendering** (Parallels Desktop) | ✅ Working — DirectX 9 renders via Parallels GPU adapter |
| Post-login packet exchange | ⚠️ Mostly working — server list, channels, GetCash, session blob all handled |
| QUERY/0x36 response format | ❌ **Current blocker** — client retries then disconnects |
| Lobby / room / match flow | ⏳ Not implemented (blocked by QUERY/0x36) |

**Summary:** the server runs, the real v1.1.2 client logs in and renders successfully in Parallels. The full post-login packet exchange works except for QUERY/0x36 — the response body format needs further reverse engineering of the client binary. Once this is solved, the lobby should become accessible.

## Prerequisites

- **.NET 8 SDK.** Developed against SDK `8.0.x` (there's no `global.json`, so any 8.0.x works). Install it for your platform and use the `dotnet` CLI. If `dotnet` isn't on your `PATH` (e.g. a side-by-side install under a user directory), prepend your SDK dir to `PATH` for the session — e.g. `export PATH="$HOME/.dotnet:$PATH"`.
- **MySQL 8.0+** (verified against Homebrew MySQL `9.7.1` on macOS/arm64). MySQL 8.0+ is required because the schema uses the `utf8mb4_0900_ai_ci` collation.
- **A Rumble Fighter v1.1.2 game client (Windows).** **Not included** — the installers and `RumbleFighter.exe` are copyrighted and are not part of this repository. You must supply your own copy. All protocol work targets the **v1.1.2** build (the RC4 key was extracted from it).

## Database setup

The server **auto-creates the tables** on first startup, but it does **not** create the database (schema) or the MySQL user — those must exist first, because the connection string already targets `Database=rumblefighter` and startup aborts if it can't connect.

> There is no `.sql` schema file in the repo; the schema is defined in C# (`Persistence/Models/Model*.cs`) and created via reflection at startup.

### 1. Start MySQL and create the schema + user

```bash
# Ensure MySQL is running (Homebrew example)
export PATH="/opt/homebrew/bin:$PATH"
brew services start mysql

# Create the database
mysql -uroot -e "CREATE DATABASE IF NOT EXISTS rumblefighter CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;"

# Create the 'gemnet' user for both localhost (socket) and TCP/remote access.
# The server connects over TCP to 127.0.0.1, which does NOT match a 'localhost'
# host entry — so the '%' (or '127.0.0.1') grant is what the server actually uses.
mysql -uroot -e "CREATE USER IF NOT EXISTS 'gemnet'@'localhost' IDENTIFIED BY 'gemnet'; CREATE USER IF NOT EXISTS 'gemnet'@'%' IDENTIFIED BY 'gemnet';"

# Grant privileges
mysql -uroot -e "GRANT ALL PRIVILEGES ON rumblefighter.* TO 'gemnet'@'localhost'; GRANT ALL PRIVILEGES ON rumblefighter.* TO 'gemnet'@'%'; FLUSH PRIVILEGES;"
```

> **Note (auth plugin):** MySQL 9.x defaults new users to `caching_sha2_password`, which `MySql.Data 8.0.33` supports over TCP. If your MySQL build/config requires `mysql_native_password` instead, be aware MySQL 9.x no longer ships it as a built-in default — treat any `IDENTIFIED WITH mysql_native_password` workaround as unverified for 9.x. TODO: document the exact auth-plugin resolution if you hit a handshake error.

### 2. Let the server create the tables, then widen the password column

Run the server once (see [Build & Run](#build--run)) so it creates the `accounts`, `inventory`, `avatar`, and `friends` tables, then stop it (Ctrl-C).

The `accounts.Password` column is declared as `varchar(50)` in code, but BCrypt hashes are 60 characters. **You must widen it** or login will break:

```bash
mysql -ugemnet -pgemnet rumblefighter -e "ALTER TABLE accounts MODIFY Password varchar(72) NOT NULL;"
```

### 3. Seed a test account

A working login account needs `State=1` (Active) **and** at least one avatar row.

**Easiest path:** register through the game client's character-creation flow — the server's `CreateAccount` handler automatically inserts the inventory items and 10 avatars for you.

**Manual path:** insert an account row directly. The password must be a **BCrypt hash** (cost factor 11) — the repo has no hash CLI, so generate one with any bcrypt tool (e.g. a small `BCrypt.Net.BCrypt.HashPassword("test")` snippet). Each hash embeds a random salt, so you cannot copy a fixed string:

```bash
# Replace <BCRYPT_HASH_OF_test> with a freshly generated cost-11 BCrypt hash of "test"
mysql -ugemnet -pgemnet rumblefighter -e "INSERT INTO accounts (Email,Password,IGN,ForumName,State) VALUES ('test@test.com','<BCRYPT_HASH_OF_test>','TestUser','TestUser',1);"
```

Then create at least one `avatar` row for `OwnerID = <the new UUID>` (or, again, just use the in-client character creation which does this). The reference seed used `test@test.com` / `test` with 10 avatars and 3 inventory rows.

> **Note:** The v1.1.2 client's login path (`CredentialCheckV112`) is a bring-up stub that accepts **any** credentials and returns a hardcoded session (user id `1`, IGN `TestUser`) — it does **not** validate against the DB. The DB-backed BCrypt login path (`CredentialCheck`) is used by other client builds. Either way, the server still requires a successful DB connection at startup.

#### Read-only verification

```bash
mysql -ugemnet -pgemnet -e "SELECT VERSION(); SHOW TABLES IN rumblefighter;"
mysql -ugemnet -pgemnet -e "SHOW COLUMNS FROM rumblefighter.accounts;"
mysql -ugemnet -pgemnet -e "SELECT UUID,Email,IGN,State,LENGTH(Password) FROM rumblefighter.accounts;"
```

## Configuration

All runtime config lives in `Gemnet/settings.json`, loaded relative to the current working directory (the project dir). There is no `appsettings.json`.

> **Note:** `settings.json` is `.gitignored`, so it does not appear in commits/diffs. If you clone fresh and it's missing, recreate it with the fields below.

| Field | Shipped value | Meaning |
|---|---|---|
| `ipAddress` | `127.0.0.1` | Configured address. Note the actual listener binds `IPAddress.Any` (0.0.0.0) on the port below. |
| `Port` | `7000` | The single TCP port the server listens on. |
| `P2PPort` | `33343` | Present in config but **not used** — no listener is opened on it. (Real P2P/PvP over RakNet is not implemented.) |
| `DBConnectionString` | `Server=127.0.0.1;Port=3306;User=gemnet;Password=gemnet;Database=rumblefighter;` | MySQL connection. `Database=rumblefighter` must already exist. |
| `UseEncryption` | `true` | Enables RC4 on the login connection. |
| `RC4Key` | `abcde` | RC4 key (bytes `61 62 63 64 65`), extracted from `RumbleFighter.exe`. Login uses two independent per-direction keystreams, both seeded from this key. |
| `MaxConnections` | `1000` | Max concurrent connections. |

Example `Gemnet/settings.json`:

```json
{
  "ipAddress": "127.0.0.1",
  "Port": 7000,
  "P2PPort": 33343,
  "DBConnectionString": "Server=127.0.0.1;Port=3306;User=gemnet;Password=gemnet;Database=rumblefighter;",
  "UseEncryption": true,
  "RC4Key": "abcde",
  "MaxConnections": 1000
}
```

## Build & Run

The repo root contains a nested `Gemnet/` directory that holds the actual .NET project. All commands below run from that nested project dir:

```bash
# From the repo root, enter the nested .NET project dir
cd Gemnet

# Build
dotnet build -c Debug

# Run (settings.json and Data/Boxes are resolved relative to this dir)
mkdir -p Data/Boxes          # BoxLoader requires this folder to exist (empty is fine)
dotnet run -c Debug
```

The server listens on **port 7000** (all interfaces).

### Convenience launcher (macOS)

`run-server.sh` does the above for you — it puts `~/.dotnet` on `PATH`, starts Homebrew MySQL if it isn't running, creates `Data/Boxes`, `cd`s into the project dir, and runs `dotnet run -c Debug`:

```bash
bash run-server.sh
```

> **Note:** `run-server.sh` prints a stale message claiming *"plaintext, UseEncryption=false"*. Ignore it — the server follows `settings.json`, which has `UseEncryption: true` / `RC4Key: abcde`.

Startup order: bind the TCP listener → load boxes from `Data/Boxes` → connect to MySQL → auto-create tables. Missing `Data/Boxes` throws `DirectoryNotFoundException`; a missing/unreachable database throws `InvalidOperationException("Could not connect to the database")`.

## Connecting a client

The client normally talks to OGPlanet's servers by hostname. To point it at your emulator, you redirect those hostnames and apply a few binary patches to the client. **The client binaries are copyrighted and not distributed here; you must supply and patch your own.**

### 1. Redirect the game hostnames (hosts file)

On the Windows client, edit `C:\Windows\System32\drivers\etc\hosts` and map the game hosts to the machine running the server:

```
<SERVER_IP>   gss1.rf.ogplanet.com
<SERVER_IP>   nps1.rf.ogplanet.com
<SERVER_IP>   nps2.rf.ogplanet.com
<SERVER_IP>   gchat.rf.ogplanet.com
<SERVER_IP>   guild.rf.ogplanet.com
```

`<SERVER_IP>` is wherever the server is reachable from the client — e.g. the host's LAN IP, or `10.0.2.2` when the client runs in a VM using SLIRP/emulated networking. The client then connects to `gss1:7000`.

### 2. Encryption (RC4)

The login connection is RC4-encrypted with key `abcde`. Inbound client packets are decrypted; outbound server replies are **re-encrypted** (the real client decrypts server→client traffic via its recv RC4 context). Keep `UseEncryption: true` / `RC4Key: abcde` in `settings.json`.

### 3. Client binary patches (high level)

The v1.1.2 client needs four patches to reach and pass TCP login. Offsets are **file-offset = virtual-address − 0x400000**:

| # | Purpose | File offset(s) | Change |
|---|---|---|---|
| 1 | Bypass the P2P "server closed" dialog gate so the client reaches TCP login | `0x66B23` | `0x75` → `0xEB` (`jne` → `jmp`) |
| 2 | NOP the recv accept-gate checks | `0x0F5B04`, `0x0F5B0F`, `0x0F5B1F` | each `0x75` → `0x90 0x90` (`jne` → 2× `NOP`) |
| 3 | Force P2P NAT-check success (removes "Network Type Check Failed") | `0x8D2F7` | `0x75` → `0xEB` (`jne` → `jmp`) |
| 4 | Launcher-event stub | n/a (external) | The exe refuses to start unless a named Windows event `slahslrtm` exists; a small launcher stub creates the event, starts the exe, and holds the event open |

**You don't have to patch by hand.** This repo ships the tooling in [`client/`](client/):

```bash
# Apply patches 1–3 to YOUR OWN copy of RumbleFighter.exe (v1.1.2, verifies bytes, safe to re-run)
python3 client/patch_client.py "C:\Program Files (x86)\OGPlanet\RumbleFighter\RumbleFighter.exe"

# Build the launcher stub (patch #4) and place gemnet_launch.exe next to the game
i686-w64-mingw32-gcc -O2 -s -mwindows -o gemnet_launch.exe client/gemnet_launch.c
```

> Full byte sequences, the launcher-stub source, and the wire protocol are in **[`AGENTS.md`](AGENTS.md)** and **[`client/README.md`](client/README.md)**. GameGuard is not present in the v1.1.2 client, so there is nothing anti-cheat to disable.

## Current limitations & roadmap

**The QUERY/0x36 blocker.** Login and rendering are solved. The client completes the full post-login packet exchange (server list, channels, GetCash, session blob) but the **QUERY/0x36 response body format** is incorrect — the client retries 5 times then disconnects. The server sends a 26-byte encrypted response but the client's receive handler doesn't match it. This requires further reverse engineering of the client binary's packet receive dispatch for Type `0x40`. See `AGENTS.md` §5 for detailed RE findings including disassembly of the relevant client functions.

**Rendering is solved** in Parallels Desktop on Apple Silicon — the Parallels GPU adapter provides working DirectX 9/12 acceleration. No special configuration needed. Note: macOS AirPlay Receiver must be disabled (it uses port 7000).

**End goal:** a **browser-playable** Rumble Fighter private server.

**Remaining protocol work (after QUERY/0x36 is solved):**

- Lobby → room → match flow.
- Real PvP fights run peer-to-peer over RakNet, which is currently **patched out** on the client — actual fighting needs separate future work.

Near-term realistic milestone: *walk around the lobby.*

## Credits

- **Primitheus** — original author of [Gemnet](https://github.com/Primitheus/Gemnet), the emulator this fork is built on.
- **Rumble Fighter** is the property of its respective rights holders (OGPlanet / developers). This is an unofficial, non-commercial preservation/emulation project. No client binaries or copyrighted game assets are distributed here.
