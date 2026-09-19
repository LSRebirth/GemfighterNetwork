# AGENTS.md — Gemnet Rumble Fighter Server Emulator

> CURRENT HANDOFF (2026-09-06): read `memory.md` first. It supersedes the historical
> QUERY/0x36 body assumptions and receive-gate NOP instructions below. The v2 patch
> restores receive matching; query actions increment; TCP framing is buffered.
> Protocol replay and four integration tests pass, but game lobby access is unverified.

> Self-contained handoff for an AI coding agent (or human) picking this up from a **fresh clone with no prior context**. Everything needed is embedded here. Upstream: fork of `Primitheus/Gemnet`, continued at `oyenmwen/rumble-fighter-emulator` — a .NET 8 console app.

---

## 1. Mission & Current Status

The goal is to run this Rumble Fighter private-server emulator and get the real Windows client to fully play, with an eventual stretch goal of a browser-playable server. **Server + login are SOLVED**: the .NET 8 server listens on `0.0.0.0:7000`, MySQL-backed, RC4-encrypted, and the real v1.1.2 client logs in end-to-end via 4 client binary patches + encrypted server replies. **Rendering works in Parallels Desktop** (DirectX 9 with GPU acceleration on Apple Silicon). **The current blocker is the post-login protocol**: the client completes the full login + post-login packet exchange (server list, channels, GetCash, session blob) but the **QUERY/0x36 response body format** is not yet correct — the client retries 5 times then disconnects. This requires further reverse engineering of the client's QUERY response parser (see §5 Post-login section below).

---

## 2. Repo Map

**Doubled-directory layout (read once, applies everywhere below):** the git repo root holds `README.md`, `AGENTS.md`, `run-server.sh`, `client/`, a root `Gemnet.sln`, and a **nested .NET project directory `Gemnet/`**. The actual C# package lives one level down. **All paths in this document are repo-relative**, so `Gemnet/Server.cs` means the file at `<repo>/Gemnet/Server.cs` (i.e. inside the nested project dir), and `run-server.sh` / `client/…` are at the repo root.

| Path (repo-relative) | Purpose |
|---|---|
| `Gemnet/Program.cs` | Entry point. `Gemnet.Program.Main` (async) builds a generic Host (`Host.CreateDefaultBuilder`), loads settings, connects DB (throws `InvalidOperationException("Could not connect to the database")` if it fails), auto-creates tables, registers `Server` + `ServerHostedService`, then `host.RunAsync()`. |
| `Gemnet/Server.cs` | TCP server. `StartAsync`: `TcpListener(IPAddress.Any, Port=7000).Start()` first, THEN `BoxLoader.LoadBoxes("Data/Boxes")`. Contains `SendPacketAsync` overloads — see §5 for the critical encryption detail. |
| `Gemnet/Network/PacketProcessor.cs` | Packet dispatch. In the `ActionLogin` switch, routes v1.1.2 opcodes `V112_VERSION`→`Login.VersionCheckV112`, `V112_CREDENTIAL`→`Login.CredentialCheckV112`, `V112_SERVERTIME`→`Login.ServerTimeV112`. Legacy handlers (`VERSION_CHECK=0x90` etc.) preserved. |
| `Gemnet/PacketProcessors/Login.cs` | Login logic. Real DB path `CredentialCheck` (BCrypt.Verify). v1.1.2 bring-up path (`BuildV112Reply`, `VersionCheckV112`, `CredentialCheckV112`, `ServerTimeV112`). Also contains `PostLoginInit` (LOGIN/0x3E handler with session blob). `AccountState` enum. `CreateAccount` (seeds 10 avatars + 3 inventory rows). |
| `Gemnet/PacketProcessors/General.cs` | General packet handlers. Post-login handlers: `PostLoginGeneral14` (server list), `PostLoginGeneral16/18` (channel lists), `PostLoginGeneral20/22` (data stubs). |
| `Gemnet/PacketProcessors/Query.cs` | Query handlers. v1.1.2 post-login: `V112Query30`, `V112Query34`, `V112Query36` (stub responses — 0x36 body format is the current blocker). |
| `Gemnet/PacketProcessors/Inventory.cs` | Inventory handlers. `PostLoginInventory20` routes to `GetCash` (binary analysis confirmed INVENTORY/0x20 = GetCash query). |
| `Gemnet/Packets.cs` | `ActionLogin`, `ActionGeneral`, `ActionQuery`, `ActionInventory` enums. v1.1.2 opcodes: `V112_CREDENTIAL=0x14`, `V112_VERSION=0x32`, `V112_SERVERTIME=0x34` (LOGIN group 0x10). Post-login: `POST_LOGIN_GENERAL_14/16/18/20/22`, `POST_LOGIN_INVENTORY_20`, `V112_QUERY_30/34/36`, `POST_LOGIN_INIT=0x3E`. |
| `Gemnet/RC4.cs` | RC4 cipher. `ClientCipherState(string key)` seeds two independent keystreams (recv + send), both keyed `"abcde"`. |
| `Gemnet/settings.json` | Runtime config (see §4). **Gitignored** — will NOT appear in commits/diffs, only under `git status --ignored`. If missing after a fresh clone, recreate it from §4. |
| `Gemnet/Settings/Settings.cs` | `Settings.SData` model + `ImportSettings(path)` (Newtonsoft.Json). |
| `Gemnet/Persistence/Database.cs` | Dapper wrapper over `MySqlConnection`. `Connect()`, `Select/Update/Scalar/SelectFirst/Execute`. Static `ConnectionString`. |
| `Gemnet/Persistence/DBGeneral.cs` | `CheckAndCreateDatabase` auto-creates TABLES via reflection over `Model*` classes. `QueryCreateSchema="CREATE DATABASE rumblefighter"` is defined but NEVER called (dead code). Schema name hardcoded. |
| `Gemnet/Persistence/Models/ModelAccount.cs` | `accounts` table DDL + login/currency queries. **`Password varchar(50)` — must be widened to 72 for the real login path (§4).** Login uses `QueryLoginAccountByEmail`. |
| `Gemnet/Persistence/Models/ModelInventory.cs` | `inventory` table DDL + item queries. |
| `Gemnet/Persistence/Models/ModelAvatar.cs` | `avatar` table DDL (45 equipment/data columns, `Job`…`Waist_BP`). Real login path requires ≥1 avatar row. |
| `Gemnet/Persistence/Models/ModelFriends.cs` | `friends` table DDL (Status ENUM, FKs). |
| `Gemnet/Persistence/Models/ModelAvatarItems.cs` | Empty 0-byte file. No table. |
| `Gemnet/Shop/Boxes/BoxLoader.cs` | Reads `*.json` from `Data/Boxes` at startup. Throws `DirectoryNotFoundException` if folder missing; empty folder is fine. |
| `Gemnet/Data/Boxes` | Must exist before startup (currently empty). |
| `Gemnet/Gemnet.csproj` | `net8.0`, `OutputType=Exe`, `ImplicitUsings=enable`, `Nullable=enable`. Deps: BCrypt.Net-Next 4.0.3, Dapper 2.0.143, MySql.Data 8.0.33, Newtonsoft.Json 13.0.3, Microsoft.Extensions.Hosting/Logging(+Console/Debug)/DependencyInjection/Configuration(+Json) 8.0.0. |
| `Gemnet/Gemnet.sln` | Redundant solution file duplicated in the nested dir (a root `Gemnet.sln` also exists). Harmless — `dotnet build`/`dotnet run` in the nested dir both work — but a cleanup candidate; consider removing this nested duplicate. |
| `run-server.sh` | Convenience launcher (macOS/Homebrew-oriented; see §3). |
| `client/patch_client.py` | Applies client patches 1–3, verifies exact bytes, idempotent (§6). |
| `client/gemnet_launch.c` | Launcher-stub source for the `slahslrtm` gate (§6). |
| `client/hosts-add.txt` | Hostname reroute lines for the client `hosts` file (§7). |
| `client/README.md` | Client-tooling quick start. |

**The `client/` tooling must be committed to the repo** (`git add client/patch_client.py client/gemnet_launch.c client/hosts-add.txt client/README.md`). It contains only patch scripts and launcher source — no copyrighted game assets — so it is safe to track. Confirm with `git ls-files client/`; if a fresh clone lacks `client/`, these files were never committed and must be added before §6/§7 are actionable.

Not loaded at startup (no C# references): `Gemnet/rooms.json`, `Gemnet/players.json`. `P2PPort 33343` is in config but never bound in code.

---

## 3. Build / Run / Test Commands

**SDK:** developed and verified against the **.NET 8 SDK (8.0.x)**. There is no `global.json`, so any 8.0.x SDK works. Install the .NET 8 SDK for your platform and use the `dotnet` CLI directly. If `dotnet` is not on your `PATH` (e.g. a side-by-side install under a user directory), prepend your SDK directory to `PATH` for the session.

```bash
# Verify SDK (should report an 8.0.x SDK)
dotnet --info

# Build (cwd = <repo>/Gemnet). A bare build works — the dir resolves to a single
# project/solution. Expected: Build succeeded, 0 warnings, 0 errors → Gemnet/bin/Debug/net8.0/Gemnet.dll
dotnet build -c Debug          # cwd = <repo>/Gemnet
# Explicit equivalents if you prefer: `dotnet build Gemnet.csproj -c Debug`, or
# `dotnet build Gemnet.sln -c Debug` from the repo root.

# Ensure the box dir exists (BoxLoader requires it)
mkdir -p Data/Boxes            # cwd = <repo>/Gemnet

# Run directly (CWD MUST be the nested project dir — settings.json & Data/Boxes
# are resolved relative to CWD):
dotnet run -c Debug            # cwd = <repo>/Gemnet

# Or use the launcher from the repo root:
bash run-server.sh
```

`run-server.sh` is a **macOS/Homebrew convenience shim, not portable**: it hardcodes the SDK location `$HOME/.dotnet` (prepended to `PATH`), pings/starts MySQL via the Apple-Silicon Homebrew path `/opt/homebrew/bin/mysqladmin`, then `mkdir -p Data/Boxes`, `cd Gemnet`, and `dotnet run -c Debug`. If your .NET SDK lives elsewhere (system package, `/usr/local/share/dotnet`, Linux) or you use Intel-Mac Homebrew (`/usr/local`) or non-Homebrew MySQL, either edit those two lines or just run the plain `dotnet` commands above instead.

There is no test suite. Verification is behavioral: the client logs in; the server prints connection logs; the client's `RumbleFighter.log` shows progress (see §7).

GOTCHA: `run-server.sh` echoes `"Starting Gemnet on port 7000 (plaintext, UseEncryption=false)"` — this is STALE and WRONG. Actual behavior follows `Gemnet/settings.json`: **encryption ON, key `abcde`**.

---

## 4. Database Setup (MySQL)

**For the current v1.1.2 bring-up, all you need is a successful DB _connection_**: a running MySQL, the `rumblefighter` schema, and the `gemnet` user. The server auto-creates the tables on first run, but `Program.Main` aborts if it cannot connect (`InvalidOperationException`). The wired-in login path (`CredentialCheckV112`) does **not** query the DB (see the NOTE at the end of this section), so **account seeding, widening `Password`, and adding avatar rows are OPTIONAL for now** — they only matter for the real `CredentialCheck` path (future work). Do the schema + user steps; skip the seeding block unless you are exercising the real DB login.

Requirements: a running **MySQL 8.0+** on `127.0.0.1:3306`, a `rumblefighter` schema, and a user `gemnet`/`gemnet`. The code auto-creates TABLES but NOT the schema or user — those must be provisioned manually or `Connect()` throws. No `.sql` file exists in the repo; the schema is defined entirely in C# (`Gemnet/Persistence/Models/Model*.cs`). MySQL 8.0+ is required by the `utf8mb4_0900_ai_ci` collation.

`Gemnet/settings.json` (recreate if missing — it is gitignored):

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

Provision (adjust the MySQL start command to your platform/install):

```bash
# Ensure MySQL is running, then:
mysql -uroot -e "CREATE DATABASE IF NOT EXISTS rumblefighter CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;"
mysql -uroot -e "CREATE USER IF NOT EXISTS 'gemnet'@'localhost' IDENTIFIED BY 'gemnet'; CREATE USER IF NOT EXISTS 'gemnet'@'%' IDENTIFIED BY 'gemnet';"
mysql -uroot -e "GRANT ALL PRIVILEGES ON rumblefighter.* TO 'gemnet'@'localhost'; GRANT ALL PRIVILEGES ON rumblefighter.* TO 'gemnet'@'%'; FLUSH PRIVILEGES;"

# First server run auto-creates tables: accounts → inventory → avatar → friends. Then Ctrl-C.
bash run-server.sh    # or: (cd Gemnet && dotnet run -c Debug)

# Read-only verification (sufficient for the current v1.1.2 path)
mysql -ugemnet -pgemnet -e "SELECT VERSION(); SHOW TABLES IN rumblefighter;"
mysql -ugemnet -pgemnet -e "SHOW COLUMNS FROM rumblefighter.accounts;"
```

**OPTIONAL — real DB login path only (`CredentialCheck`), NOT needed for current v1.1.2 bring-up:**

```bash
# Widen Password for the 60-char BCrypt hash (DDL declares varchar(50) which truncates & breaks login)
mysql -ugemnet -pgemnet rumblefighter -e "ALTER TABLE accounts MODIFY Password varchar(72) NOT NULL;"

# Generate a BCrypt hash of 'test' (cost 11). No hash-CLI ships in the repo; either:
#   python3 -c "import bcrypt; print(bcrypt.hashpw(b'test', bcrypt.gensalt(11)).decode())"   # needs: pip install bcrypt
#   (or a BCrypt.Net.BCrypt.HashPassword(\"test\", 11) snippet in any .NET REPL)
# Simplest alternative: skip all of this and register through the game client
# (CreateAccount auto-makes 10 avatars + 3 inventory rows).
mysql -ugemnet -pgemnet rumblefighter -e "INSERT INTO accounts (Email,Password,IGN,ForumName,State) VALUES ('test@test.com','<BCRYPT_HASH_OF_test>','TestUser','TestUser',1);"
# Then add ≥1 avatar row (login for an Active account with CurrentAvatar==0 auto-equips the first avatar; zero avatars → aborts).

mysql -ugemnet -pgemnet -e "SELECT UUID,Email,IGN,State,LENGTH(Password) FROM rumblefighter.accounts;"
```

Schema facts:
- **Login table is `accounts`** (no `users` table). Real login path (`Gemnet/PacketProcessors/Login.cs` `CredentialCheck`): `SELECT * FROM rumblefighter.accounts WHERE Email=@Email;` then `BCrypt.Net.BCrypt.Verify(request.Password, row.Password)`.
- `accounts` columns: `UUID int PK AUTO_INCREMENT`, `Email varchar(50)`, `Password varchar(50→72)`, `IGN varchar(50) NULL`, `EXP int DEFAULT 0`, `Carats int DEFAULT 10000`, `Astros int DEFAULT 0`, `Medals int DEFAULT 0`, `ForumName varchar(50) NOT NULL` (no default — MUST supply on INSERT), `State int DEFAULT 0`, `CurrentAvatar int DEFAULT 0`. Charset utf8mb4 / utf8mb4_0900_ai_ci (needs MySQL 8.0+).
- `inventory`: `OwnerID int` (FK→accounts.UUID CASCADE), `ServerID int PK AI`, `ItemID int`, `ItemEnd int DEFAULT 0`.
- `avatar`: `AvatarID int PK AI`, `OwnerID int` (FK CASCADE), then **45 equipment/data int columns DEFAULT 0** (`Job`, `Hair`, `Forehead`, `Top`, `Bottom`, `Gloves`, `Shoes`, `Eyes`, `Nose`, `Mouth`, `Scroll`, `ExoA`, `ExoB`, `Null`, `Back`, `Neck`, `Ears`, `Glasses`, `Mask`, `Waist`, `Scroll_BU`, `Unknown_1..2`, `Inventory_1..3`, `Unknown_3..7`, `Title`, `Merit`, `Avalon`, and 10 `*_BP` columns ending `Waist_BP`).
- `friends`: `ID PK AI`, `RequesterUUID`/`ReceiverUUID` (FKs CASCADE), `Status ENUM('Pending','Accepted','Blocked') DEFAULT 'Pending'`, `CreatedAt datetime DEFAULT CURRENT_TIMESTAMP`, UNIQUE(Requester,Receiver).
- `AccountState` enum: `NoAvatar=0, Active=1, Locked=2, TimedOut=3, Banned=4`. A working account on the real path needs `State=1` AND ≥1 avatar row.

NOTE: the real v1.1.2 client uses the stubbed `CredentialCheckV112` path which does **NOT** query the DB (accepts any credentials, returns hardcoded user id=1 / IGN `TestUser`). But the server still requires a successful DB connection at startup regardless — hence schema + user are mandatory, seeding is not.

Auth-plugin caveat: MySQL 9.x defaults new users to `caching_sha2_password` (MySql.Data 8.0.33 supports it over TCP). MySQL 9.x removed built-in `mysql_native_password` — do NOT assume `IDENTIFIED WITH mysql_native_password` is available. Also, `127.0.0.1` TCP connections do NOT match a `'gemnet'@'localhost'` grant — the `'gemnet'@'%'` (or `'127.0.0.1'`) grant above is what the server actually uses.

---

## 5. Architecture & Wire Protocol

**6-byte packet header:**
- `Type` u16 **BIG-ENDIAN** @0
- `Size` u16 **BIG-ENDIAN** @2 = **TOTAL** length (whole packet incl. 6-byte header) — `Size = 6 + bodyLen`. This is the confirmed-working interpretation. (Older notes claimed body-only Size — WRONG; body-only makes the client compute a huge/negative body length and block until timeout.)
- `Action` u16 **LITTLE-ENDIAN** @4

**Login = synchronous request/reply RPC** (Type=`0x10` LOGIN group). The client does NOT route replies by opcode — it gates every step on reply header **`byte[5]` (Action high byte) == 0** meaning success. Replies also set **`byte[4] = request_action_low + 1`** (client recv-accept gate `fn 0x4f5ad0` requires this), and `byte[5]=0`.

`BuildV112Reply(ushort actionLow, byte[] body)` emits: `p[0]=0x00`, `p[1]=0x10` (Type=LOGIN), `p[2..3]=Size BE (=6+bodyLen)`, `p[4]=actionLow` (echoed; client ignores value), `p[5]=0x00` (success gate), then body.

Login opcodes and replies:
| Step | Request action-low | Reply action-low | Reply body |
|---|---|---|---|
| Version | `0x32` | `0x33` | none (Size=6) |
| Credential | `0x14` (body: id[20]@6, pw[21]@26 — **41-byte body** = id[20]+pw[21], ASCII NUL-trimmed) | `0x15` | 83-byte session blob |
| Server-time | `0x34` | `0x35` | 8 bytes = two uint32 copies of UTC unix seconds |

(Note: `@6` and `@26` are **full-packet** offsets — the body starts at packet offset 6, so `id` is body bytes 0..19 and `pw` is body bytes 20..40, giving a 41-byte body.)

**83-byte credential session blob** (offsets into body, per `Gemnet/PacketProcessors/Login.cs` `CredentialCheckV112`): `u32 user id @0x00` (must be nonzero; hardcoded 1); `char[20] nickname/IGN @0x04` NUL-terminated (`"TestUser"`); `byte observer flag @0x2d` (MUST be 0 for a normal, non-observer login). **All other bytes are currently zero-filled and not yet reverse-engineered.** The server/channel list is NOT in this blob.

**RC4 encryption:** key `"abcde"` (bytes `61 62 63 64 65`), extracted from `RumbleFighter.exe` `.data 0x6f6b20`. The client uses two independent per-direction keystreams (recv context conn+0x140, send conn+0x5d0; inbound-decrypt context conn+0x1c8), both seeded from `"abcde"`. **The server MUST encrypt server→client replies** — the client DOES decrypt them (an earlier "recv-decrypt flag never armed" RE was WRONG). The active path: `Gemnet/PacketProcessors/Login.cs` → `ServerHolder.ServerInstance.SendPacket(byte[])` → `Gemnet/Server.cs` `SendPacket(byte[],stream)` → `SendPacketAsync(byte[],stream)`, which encrypts via `connection.CipherState.Encryptor` when `CipherState != null`. WARNING: the two structured `SendPacketAsync(type,length,action,...)` overloads had their encryption REMOVED and carry a stale/misleading "plaintext" comment — those are NOT used by the v1.1.2 login path; do not be misled.

**Post-login (partially implemented — current blocker):** The v1.1.2 client sends a series of post-login packets after the server time response. Handlers have been implemented for all observed packets, but **QUERY/0x36 response body format is not yet correct** — the client retries 5x then disconnects.

Full post-login packet exchange (confirmed via server logs):
1. `INVENTORY/0x20` → GetCash query (confirmed via binary analysis: `push 0x20; push 0x31` at VA `0x0046A478`). Response: `GetCashRes` with UserID + Astros(1000000) + Medals(0). ✅ Working.
2. `GENERAL/0x14` → Server list. Response: count-prefixed 43-byte entries (1 server "Gemnet"). ✅ Working.
3. `GENERAL/0x22` → Unknown. Response: empty count=0. ✅ Working.
4. `GENERAL/0x20` → Unknown. Response: empty count=0. ✅ Working.
5. `LOGIN/0x3E` → Post-login init. Response: 83-byte session blob (same format as credential check). ✅ Working.
6. `GENERAL/0x16` → Channel list. Response: count-prefixed 24-byte entries (1 channel "Channel 1"). ✅ Working.
7. `QUERY/0x30` → Unknown query. Response: 10-byte stub. ✅ Working.
8. `GENERAL/0x18` → Channel list (alternate). Response: same as 0x16. ✅ Working.
9. **`QUERY/0x36`** → Item/server data query. Client sends 5-byte body (u32 item ID from lookup table + 1 flag byte). **Response body format unknown** — client retries 5x, then disconnects. ❌ Blocker.
10. `QUERY/0x34` → Unknown query. Response: 10-byte stub. ✅ Working.

**QUERY/0x36 reverse engineering findings** (from binary analysis of `RumbleFighter.exe`):
- Send site: VA `0x0046AA7F` — `push 0x0B; push 0; push 0x36; push 0x40; call SendQuery(0x559c30)`
- Response handler: VA `0x0046AA8C` — `call GetResult(0x559ce0)` which checks `this->0x10 != NULL` (response body pointer)
- Second check at VA `0x0046AAB0` — `call 0x4f5d70` (network receive with 10 retries × 3s timeout each)
- `0x4f5d70` returns `[this->0x168]` (response body buffer) — NULL if receive handler didn't match the response
- Error string at VA `0x0067A638`: `"FUNC_Q_GET_CASH ... NULL"` (Korean EUC-KR)
- The client's receive thread matches responses by Type+Action, stores the body in `this->0x168`, and signals the waiting thread
- **The response IS being sent (26 bytes encrypted) but the client's receive handler doesn't match it** — likely the response body format or action mapping is wrong
- Response action: tried both `request_action+1` (standard v1.0.x convention) and `request_action` (no increment) — neither works
- Key functions: `SendQuery` at `0x559c30`, `GetResult` at `0x559ce0`, response check at `0x5571a0` (`mov eax,[ecx+0x10]; test eax,eax`), network receive at `0x4f5d70`

All handlers use `SendPacket(byte[], stream)` which encrypts via `connection.CipherState.Encryptor`. Player is registered in `PlayerManager` during v1.1.2 credential check.

---

## 6. The Windows Client (NOT in repo — copyrighted)

Client binaries are copyrighted (OGPlanet/Redduck) and NOT committed. You must supply your own legally-obtained copy of the **v1.1.2** build. **The repo's `client/` folder ships the tooling to reproduce everything on your own copy** — no game assets: `client/patch_client.py` (applies patches 1–3 below, verifies the exact bytes, idempotent), `client/gemnet_launch.c` (launcher-stub source for the `slahslrtm` gate), and `client/hosts-add.txt` (hostname reroute lines). See `client/README.md`. (If a fresh clone lacks `client/`, these tooling files were never committed — see §2.)

- **Two versions exist**: v1.0 and v1.1.2. All login work targets **v1.1.2** (build R071128001); the RC4 key `abcde` was extracted from it.
- **GameGuard**: NOT present in the v1.1.2 client — nothing anti-cheat to disable.
- **Patch addressing convention**: file-offset = virtual-address − `0x400000`. Patches apply to the served `RumbleFighter.exe` (3,174,400 bytes), typically installed at `C:\Program Files (x86)\OGPlanet\RumbleFighter\` on the Windows client.

**The 4 client patches** (exact file offsets; 8 bytes total):
1. **P2P dialog gate** — `0x66B23`: `0x75` → `0xEB` (jne → jmp). Removes the "P2P server is closed" gate so the client reaches TCP login instead of aborting on the UDP P2P check.
2. **recv-accept-gate NOPs** — three sites `0x0F5B04`, `0x0F5B0F`, `0x0F5B1F`: each `0x75` → `0x90 0x90` (jne → two NOPs).
3. **P2P NAT-check force-success** — `0x8D2F7`: `0x75` → `0xEB` (jne → jmp; `P2PMan::Connect` always returns success; removes "Network Type Check Failed").
4. **Launcher-event stub** (external — patch #4 is not a byte edit): see below.

(Patches #1 and #3 are 1 byte each; patch #2 is three 2-byte NOP edits. Verified end-to-end: patching a pristine v1.1.2 exe — sha256 `4661caa3cc5fbadd9bc5942be3b70c24c861f59254389d72a3ab2721bc8c9d7a` — yields patched sha256 `18c857687241c8ceb0211f86ba597120d41bda7a738bed01da99d361704f1f5c`. Use `client/patch_client.py`, which verifies each offset and is idempotent.)

Apply the patches to your own copy:
```bash
python3 client/patch_client.py "C:\Program Files (x86)\OGPlanet\RumbleFighter\RumbleFighter.exe"
```

**Launcher-event stub (patch #4)**: `RumbleFighter.exe` refuses to run unless a named Windows event **`slahslrtm`** exists (normally created by the now-dead real launcher). Bypass = **`gemnet_launch.exe`**: creates the `slahslrtm` event, `CreateProcess RumbleFighter.exe` (self-locating — finds the exe next to itself), then `WaitForSingleObject` to hold the event open. Run `gemnet_launch.exe`, not the game exe directly. Source: `client/gemnet_launch.c` — cross-compile with mingw-w64 (install it first, e.g. `brew install mingw-w64` on macOS or your distro's `mingw-w64` package):
```bash
i686-w64-mingw32-gcc -O2 -s -mwindows -o gemnet_launch.exe client/gemnet_launch.c
```
Place `gemnet_launch.exe` next to the patched `RumbleFighter.exe`.

---

## 7. Run & Connect End-to-End

1. Start MySQL + server (§3, §4). Server listens `0.0.0.0:7000`, encryption ON, key `abcde`.
2. On the Windows client, edit `C:\Windows\System32\drivers\etc\hosts` (as Administrator) to reroute the OGPlanet hostnames to the server. Map `gss1 / nps1 / nps2 / gchat / guild.rf.ogplanet.com` → the server's IP **as reachable from the client** (its LAN IP, or a VM-network host address if the client runs in a VM). Source lines: `client/hosts-add.txt`. **The `10.0.2.2` in that file is only an example from the reference test environment (§Appendix), NOT a working default — replace it with your own server IP.** The client then connects to `gss1:7000`.
3. Ensure the patched `RumbleFighter.exe` (§6) + `gemnet_launch.exe` are installed together on the client.
4. Launch via `gemnet_launch.exe` (creates `slahslrtm`, starts the game).
5. **Verify** via the client-side `RumbleFighter.log` (ANSI/latin-1 — decode with `iconv -f latin-1`). This is the authoritative verification tool. On success the client sends version `0x32` + credential `0x14`, both accepted, and proceeds to loading/server-select.

---

## 8. Rendering (SOLVED in Parallels)

**Rendering works in Parallels Desktop** on Apple Silicon — the Parallels GPU adapter (WDDM) provides working DirectX 9/12 acceleration. The client renders the login screen, loading bar (1–100%), and transitions to the game lobby. No special configuration needed — 3D acceleration is enabled by default in Parallels.

**Note on AirPlay Receiver:** macOS AirPlay Receiver uses port 7000, conflicting with the server. **Disable it** in System Settings → General → AirDrop & Handoff → AirPlay Receiver before starting the server.

**Non-accelerated environments** (UTM, basic VMs without GPU passthrough) remain unsupported — the D3D9 surface never presents there.

---

## 9. Gotchas

- **CWD matters**: `settings.json` and `Data/Boxes` resolve relative to CWD. Always run from the nested project dir `Gemnet/` (or use `run-server.sh`, which `cd`s in).
- **Redundant nested solution file**: `Gemnet/Gemnet.sln` duplicates the root `Gemnet.sln`. This is harmless — `dotnet build -c Debug` and `dotnet run -c Debug` in the nested dir both work — but it's a cleanup candidate.
- **`run-server.sh` is macOS/Homebrew-specific**: hardcodes SDK at `$HOME/.dotnet` and Apple-Silicon Homebrew MySQL at `/opt/homebrew`; on any other layout run the plain `dotnet` commands (§3).
- **`run-server.sh` stale echo** says "plaintext, UseEncryption=false" — ignore it; real behavior = encryption ON per `settings.json`.
- **BCrypt column width** (real login path only): BCrypt.Net hashes are 60 chars; the `accounts.Password` DDL is `varchar(50)` and MUST be widened to `varchar(72)` or the real `CredentialCheck` silently breaks (§4). Irrelevant to the current stubbed v1.1.2 path.
- **`P2PPort 33343`**: configured but never bound in code; if the client expects a P2P/UDP listener there, this server does not provide it. Real PvP uses P2P RakNet which was patched OUT — actual fighting is separate future work.
- **`settings.json` is gitignored**: it won't show in diffs; recreate from §4 on a fresh clone if missing.
- **`client/` may be untracked**: confirm `git ls-files client/` returns the four tooling files; commit them if not (§2).

---

## 10. Next-Steps Checklist

1. [ ] Install the .NET 8 SDK; provision MySQL 8.0+: schema `rumblefighter` + user `gemnet`/`gemnet` (§4). (DB *connection* is all the current login path needs.)
2. [ ] `dotnet build Gemnet.csproj -c Debug` from the nested `Gemnet/` dir (or `dotnet build Gemnet.sln -c Debug` from root) → confirm EXIT=0.
3. [ ] First run to auto-create tables. (`ALTER TABLE accounts MODIFY Password varchar(72)` is OPTIONAL — only for the real `CredentialCheck` path.)
4. [ ] (OPTIONAL, real-DB-login only) Seed a test account (or register via client's CreateAccount flow), State=1 + ≥1 avatar. NOT required for the current v1.1.2 stubbed login.
5. [ ] Start server (`run-server.sh` or `dotnet run`), confirm listening on `0.0.0.0:7000`, encryption ON.
6. [ ] Supply your own copyrighted v1.1.2 client + apply the 4 patches (§6) + `gemnet_launch.exe` (needs mingw-w64 to build).
7. [ ] **Solve the rendering wall FIRST** (§8): a real x86 Windows PC / a host exposing working DX9 (e.g. Parallels on Apple Silicon, or GPU passthrough) / cloud GPU. Nothing downstream matters until DX9 renders.
8. [ ] Point the client's hosts file at the server, launch via `gemnet_launch.exe`, verify login + render via `RumbleFighter.log`.
9. [ ] **Reverse-engineer QUERY/0x36 response body format** (§5): the client sends this repeatedly but doesn't accept our response. The response IS sent (26 bytes encrypted) but the client's receive handler doesn't match it. Need to trace the client's packet receive dispatch for Type `0x40` to understand the matching logic and expected body format.
10. [ ] THEN implement full lobby → room → match flow.
11. [ ] Later: P2P RakNet for real fights. Near-term realistic target: "walk around the lobby."

---

## Appendix: Reference Test Environment (informational, NOT required)

The following describes **one contributor's** specific test setup on macOS/Apple Silicon. **None of it is a requirement** — a contributor on Linux, Windows, or any other host can ignore this entirely. It is preserved only as a worked example.

- **Host/SDK**: macOS/arm64, .NET SDK 8.0.422 (runtime 8.0.28, osx-arm64) installed under a user directory and prepended to `PATH`; MySQL 9.7.1 via Homebrew.
- **Client VM**: UTM ARM Windows VM. This is where the §8 rendering blocker surfaced — the emulated GPU had no working DX9 acceleration.
- **Guest control (`utmctl`)**: `utmctl exec` with `cmd.exe` and `curl` worked; PowerShell via `utmctl exec` did NOT. `utmctl file pull <path>` outputs to stdout. The guest agent runs in session 0 → cannot see interactive windows or screenshot; verification relied on `RumbleFighter.log`.
- **Networking**: UTM "Shared"/vmnet host↔guest TCP was broken; switching to **Emulated VLAN (SLIRP)** made the host reachable from the guest at **`10.0.2.2`**. Networking only worked after installing the **VirtIO NetKVM ARM64 driver** (from virtio-win.iso). This is the origin of the `10.0.2.2` example in `client/hosts-add.txt` — it is specific to this SLIRP setup and must be replaced with your own server IP.
- **File transfer**: a local HTTP server (`python3 -m http.server 8000 --bind 127.0.0.1`) on the host, reached from the guest at `10.0.2.2:8000` via `curl.exe --noproxy "*" -O http://10.0.2.2:8000/…`.
- **Live seed**: `test@test.com` / `test` (UUID=1, IGN `TestUser`, State=1, 10 avatars, 3 inventory).
- **Local test client**: a small host-side login-replay client (reusing `Gemnet/RC4.cs`) was used to replay the full login exchange without a VM round-trip.
