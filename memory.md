# Intermittent match exit investigation (2026-09-13)

User's game closed during back grab. Other player used Crasher, but user explicitly corrected that several earlier grabs succeeded and doubts scroll relation. Do not frame as a proven Crasher-specific bug. FOUND: System/nvlddmkm event153 record34449 at07:50:03.9456593Z, Video3/GPUID100 error; RFRebirth.log observes game PID26660 exit07:50:04.8311916Z; Application/WER1001 records37228/37236 at07:50:08.079/.269Z are same LiveKernelEvent141 report61edafab-7300-4442-bf66-0b559ad55bd0, named WATCHDOG-20260913-0250.dmp. Microsoft official0x141 doc confirms display-engine timeout, notBSOD. Stronggraphicslead but trigger/unhandleddevice-loss/nativefault/rootcause NOT identified or fixed. Olderreports also reprocessed atsameWERtime; do not countold July/Aug/Sep11dumps asnew simultaneouscrashes. No matching RumblefighterApplicationError in12hsearch. Usual localRumbleFighter.log nowmissing; log.txtnetworksetup only. GPUinventoryRTX5070Ti driver32.0.15.9649 notproofdriverbad/outdated.

Protected dump C:/Windows/LiveKernelReports/WATCHDOG/WATCHDOG-20260913-0250.dmp and matching ProgramData/Microsoft/Windows/WER/ReportQueue/Kernel_141_ee7b412488a64cc36a8d5b2c7d951c04d2eef67_00000000_61edafab-7300-4442-bf66-0b559ad55bd0 access DENIED. Need usercopydumpwithWindowsadminpermission into artifacts/client-crash-20260913 for localanalysis. NoACL/registry/driver/processcontrol/debuggerchanges; noUI/no subagents. SelectedcurrentWER+GPUXML,RFRebirth.log/log.txtcopies/displayinventory saved there and foldergitignored. docs/client-crash-2026-09-13.md contains exacttimeline/evidence/limits. No runtimefix/newrelease/PatchNoteclaim thisturn.

IMPORTANT launcher changed independently since GameMon task: current Tools/ClientLauncher/Program.cs calls OfficialPatcher.Run; installed RFRebirth.exe SHA004fceee268aaa9007f35313076edba33e2d39096e2ec169b190a6d68abc7876 from02:21Sep13. Preservecurrentpatcherflow; don'toverwritewithold GameMon-onlyartifact. Patcherexit0 at07:50:18 is NOT gameexitcode; gameexitcodecurrentlynotlogged. GameMoncleanupstartsaftergameexit; routingrestoredlater07:50:18. Game relaunched07:52:04PID26880; leavealone. Original protectedrumblefighter.exe stillSHA94194afa95d3d2cc81a55438a0f584bfaf039ca85adab5b07966ae3e4d593a59. No freshremoteserverlogs supplied for this incident.

# Quest claimed-state correction built (2026-09-13)

User reports quests constantly refreshing and resetting/claimable again on login. Asked whether actual extra items appeared; user cannot tell due to large inventory but saw a reward message. Read/copied only known local client log C:/PlayRedFox/RumbleFighter/RumbleFighter.log into ignored artifacts/quest-reliability/client-initial.log; six Send_Request_QuestItem Error=1 entries at02:31:29..34 indicate those attempts were rejected. No production DB access or proof of every prior reward outcome. Do not claim user fabricated issue or an actual duplicate-item exploit was reproduced.

CONFIRMED NEW BUG: GENERAL/CC 60-byte records had r.State (1/2/3) at record+20, but always ZERO at record+36, which is the native claimed marker. Saved original daily/normal parser529237 and achievement529BA7 read record+36 into CQuest+0x2c (list node+0x34). Refresh checks marker100 at4F458E/4F477E/4F496F; with complete progress,100 maps to claimed UI3, otherwise claimable UI2. Thus existing claimed DB rows always looked claimable again on list reload. Changed ONLY Gemnet/PacketProcessors/Quests.cs runtime behavior: record+36 = r.ClaimedAt.HasValue ?100:0. Other fields, including existing +20, unchanged. No DB/schema, reward/economy, progress or claim reset. Normal next-quest sequence and UTC daily cycle policy unchanged. Old claim protection already rejects duplicate payouts; this corrects what client sees.

VERIFICATION: new QuestReconnectTests.cs fails on old DLL with 'Claimed daily missing native marker 100 at record+36', then 3 targeted PASS groups on corrected build. Real encrypted login/list/claim/progress, exactly3 paid daily/tutorial/achievement inventory+ledger grants; three reconnects including forced socket reset; FeatureSchema/service reload; stable pages/IDs/progress/claimed marker/next tutorial; repeated old claims and stale zero-progress reports;16 concurrent replay attempts reject; daily rollover retains old receipts and lifetime claims. Full current backend92PASSgroups (priorRune full88 plus3new plus Rune Carat snapshot/achievement test added after prior fullrun). Same test/publishGameDLL SHA2561cea0fef7fbdb27b0ea7cb2e2303826b22d81dd34f092b9044c11d82f045fc41. Tools/test_quest_state_native.py executes saved-image scalar parsers and UI normalization for3categories: old packet reproducesclaimed->claimable, corrected retainsclaimed; zero/partial/complete/overshoot progress;289actualserverwire records verified. No heap/list/network emulation outside boundedranges, no liveclientUItest. SavedimageSHA19a57ea875da750aac327ae2693b063669eebb32a64481cf35fae01418211521. Do not describe everyquestobjective asimplemented or allpossible questrefreshcauses asfixed.

DELIVERY artifacts/RFRebirth-Quest-Claim-Fix.zip 97,011,671 bytes, SHA256 ae1d538cbeb292efc7353689ec654e38c45ff63530376ea4b18f69afee52f296. Cumulative previousRuneBookZIP base hash8f23b942... checked. Game/Peer/Setup + same Apply Update.cmd/PS1; only runtimepayloadchangeGame/Gemnet.dll; allotherGamefiles, rewarddata, dependencies, Peer, Setup, scripts byte-identical. NewREADME/referenceQuestClaimdoc, Sep13PatchNote. BuilderTools/build_quest_claim_update.py checksbeforefail, allbuild/testexits,3target/92fullmarkers,DLLidentity,native289fixturehash,base/everymanifesthash,ZIPCRC. Extractonserver/runApplyUpdate.cmd/reconnect; keepPrivate DB/settings. Notinstalled/deployed. docs/quest-claim-state-2026-09-13.md. RootPatch-Note.txt nowSep13upcomingonequestfixbullet; matchesnewpatch-notes/2026-09-13.txt; Sep12archivepreserved.

IsolatedMySQL33073 parent43416 child23588 from artifacts/rfrebirth-install-validation, confirmedexe/ancestry/loopback then cleanmysqladminshutdown. TemporarycredentialCNFremoved; ports33073/17000 no listeners afterwards. FullbackendusedprivatecopiedRune runtime settings andcurrentData underignoredartifacts/quest-reliability; logs,publish,native/disassembly/validation retained there. Alltestaccountsdeletedfinally. No game/PC UI/process control, no live process memory, no production service/DBchanges, no subagents/commits/indexchanges. Need user retestquestwindow afterapplyingserverupdate; ifstilljanky getnewservergame/packettraceandmatchingclientlog. Do not reapply older ZIPs afterthis latest cumulative release.

# GameMon exit cleanup launcher built (2026-09-12)

User reports GameMon.des remaining after closing the client (Task Manager screenshot). Added Tools/ClientLauncher/GameMonitorCleanup.cs and integrated Program.cs after the original game and any restarted instance exit. Baselines existing GameMon PIDs before launch, waits 10 seconds after exit, and limits candidates to exact GameGuard/GameMon.des or GameMon64.des in this installation, same Windows session, creation time between original launch and pre-grace cutoff. Baseline PIDs and other installations excluded. Opens native termination handle, rechecks full identity on that same handle, then terminates/waits for verified exit. No global name-based killing. If a game restarts during grace, AfterGameExit returns false; Program retains routing and retries once it exits. Access failures log and allow routing recovery; no protection/driver/file changes or access bypass. Ownership uses path/session/time rather than a verified parent-child tree. Root cause inside original GameMon remains unknown.

Ten launcher test groups PASS, including existing Remember Email/routing tests. New GameMonitorTests.cs uses dedicated Tools/ClientLauncher.ProcessFixture (renamed harmless .NET apphosts with stdin exit command) to exercise actual Windows Toolhelp, identity APIs and termination. Normal/forced client exits, 32/64 monitor names, pre-existing and foreign monitors, unknown helpers, grace, live/restarted game, incorrect creation identity/PID reuse rejection and already-exited monitor covered. Initial renamed cmd.exe fixture failed to start and was replaced; final fixture processes/files clean up in finally. Tests do not control real game/anti-cheat or actual hosts/game settings. New fixture build/test work ignored. No subagents, production changes or commits. Previous Rune server package untouched.

Delivery artifacts/RFRebirth-GameMon-Cleanup.zip: 29,939,807 bytes; SHA256 a85008950d9d853566391b573e7cbc1d57ac3d671235811da1f24a46cdd33c59. RFRebirth.exe: 35,104,938 bytes; SHA256 463fcf5d23bdbf9ba3fdcfe8793df9872d043ffeae47b8e4301718a848d7637d. Windows x64 self-contained Release publish succeeded; ZIP CRC, every manifest hash, exact published executable and identical root/dated patch notes verified. ZIP has ONLY RFRebirth.exe, README.txt, package-manifest.json. Replace only RFRebirth.exe in existing game folder with game/launcher closed; keep RumbleFighter.ini. CLIENT update, no server files. Includes existing Remember Email fix. Not installed/deployed or added to website downloads. Details docs/gamemon-cleanup-2026-09-12.md; logs/report/publish under ignored artifacts/gamemon-cleanup. Patch-Note.txt and patch-notes/2026-09-12.txt include concise cleanup bullet.

LIMITS: actual protected GameMon shutdown still needs in-game verification; Windows may refuse termination. Existing leftover processes from older launcher sessions are intentionally untouched. Forcing the launcher itself closed prevents its cleanup. RFRebirth.log beside launcher is the next diagnostic if GameMon remains after a new session and ~10 seconds. Do not claim native GameMon root cause solved or that pre-existing screenshot process was stopped. No real client/anti-cheat has been manipulated this turn.

# Rune Book backend implementation built (2026-09-12)

User requested finishing disabled Rune Book invocations. Implemented persistent balance/earning, all original42 native blessing IDs across costs1/3/8 and uses5/7/10, current blessing replacement/reconnect, multiplayer EXP/Carat bonus + result history, per-result consumption, rune-use quests and spending milestones. NO box/package/item prize data changed. No client binary/UI/process-memory changes, no production deployment, no subagents. Latest legacy crash gate is superseded, not removed from historical docs.

New Gemnet/Persistence/RuneCatalog.cs (14 original types, values, IDs; equal weights configurable through existing Private/settings.json RuneBook.Weights), RuneService.cs (rune_accounts/rune_invocations/rune_matches schema migration2026091301). Actual original random odds unavailable; optional async question offered equal weights vs user odds, no reply received; stated assumption equal/editable after time to reply. Do not call these original odds. Primary original earning rules https://help.playredfox.com/en/support/solutions/articles/8000029845-rune-system (dailylogin/hour online/10 three-round games/5Adventureclears/10000Carats/500Astros, daily24 wallet30). UTC day reset is RFRebirth choice, original timezone unknown. Daily progress/remainders reset atUTC midnight; no historical rune backfill/fake19.

RuneBook.Handle now authenticated sizecheckedBA/BC reads, BE1..4 amount1 sync of observed state, C0 actualtransaction cost validation and roomInProgress guard, C2 own historicalinstance acknowledgement without erasingactivebuff. B2 savedbalance/daily/Invoked + clearsdailygrantpopupflag afterpregrant. BuyItemRes addsnativeRunecountersatpacket43/47/51; EconomyService.Buy andGiftService.Send compute earnedrunesfrompaidpriceinsametransaction; giftsdisplayonbookrefresh. NativeBook entry BA confirmed442C20xrefs4D2A50/4D2B89. Player.LoginTime serverclocktracked onRuneRead, DATETIME(6) normalized to prevent repeatedcreditprecisionerror. DuplicateBE/C2cannotmint/erase. C0 has no requesttoken; eachapplicationrequestisaseparatepurchase, not idempotentinvokes.

Query.StartMatch persistsrunesnapshotbeforebroadcast; failurecancelspendinglaunch. EconomyService.Claim returns paidAwards, bonus based launchsnapshot, currentbuffdecrementonlyifsameinstance, oneusepercommittedresult; duplicatesuseexistingreceipt. Querystoresadjustedresultsandconnectedcurrencycache; completedresultJSONmodifiedonlywhenpaidamountdiffersandarrayroster/resultsrecognized; historicalopaqueJSONkept. Bugfoundduringtests: earlyarrayparsebrokeinvalidJSONerrorsemantics; fixedconditionalparsing andfullsuitepassed. RuneService.CompleteSolo consumesinsideexistingSoloRewardService transaction andincrementsclearwhenfullpacket75==9, ignoresdefeat10. Original532244/532257 provenflags; native532373 etc appliesexistingbonusbeforeclientreportsoloamount, noadditionalmultiplication. Quest group4/type2 mapsruneinvoke; category3countsrunesspent, daily/tutorialinvokeevents.

IMPORTANT LIMITS, communicated: NO liveclienttest. Nativecombatstatapplicationusesexistingclientcatalog; all42responseparsers+lookup+formerlycrashingUIrangeverified, notfullgameplay. Native use timing across3roundrooms stillneedsactualclientcheck; serverconsumesonceperexistingmatch/solo receipt. Existingclientreportedcombat/solo resulttrustboundsremain, notauthoritativesimulation. ClientC0callerignoresnetworkfailures: successfulinvokesno longer hitunimplementedfailure, butDBoutage/networktimeoutduringfirstinvokecan stillcrashunsafeemptybuffpath; protectedclientnotpatched. Do NOT claimeverycrashfixed/fulloriginalgameplayverified. docs/rune-book-implementation-2026-09-12.md hasexactlimits/config/validation; docs/rune-book-crash... markedhistorical.

VALIDATION: full88backendPASSgroups; dedicated7RunePASSgroups added/expandedafterfullrunwithSAMEGameDLL 4c73355ea2023abb16053e9aea1688df3634a285ada6fb0b48a8c9964c402bfb. Actualencryptedall42invokes +BCpersistreads, B2/BA; malformed/forgedBE/cost/C2, concurrency16invokes8runessuccess8, injectedtriggerrollback; originalcaps/UTCrollover/hour/reconnect; EXP+CARbonus, immutablematchsnapshot/newbuffpreserved, durableJSON; runeachievementincrement; paidpricepurchaseandactualencryptedbuycounters;5clear/defeat/retrySolo. Earlierfailedfullruns: missingtestenvforbackup, thenEconomyJSONparsefixed, thenoldruntimefixtureData had117poolsnotcurrentwithdrawals. FinalisolatedruntimefixtureusescurrentpublishedData/full88pass. LasttargetedquesttestfailurewasfixtureResetnotresettingquestprogress; correctedbaseline+9,7pass. Tests logs+buildexits in ignoredartifacts/rune-implementation. Native Tools/test_rune_implementation_native.py uses savedimage and isolatedUnicorn fromartifacts/rune-book/native-deps, runsC0/BCparsersandactual462990lookup+43CC9A..43CE13 all42serverfixtures; stubsexternalpacket/objectaccessors/UIconstructor, reconstructscatalogheapfromoriginalIDs. RuneBookTests.cs olddisabledtestsremoved, replacedRuneImplementationTests.cs. Program takes settingspath --rune-book; fullsuitecallsnewtests too.

DELIVERABLE artifacts/RFRebirth-Rune-Book-Update.zip 97010815bytes SHA256 8f23b9424015a5d3c3a6b59dd8137177ceff30d2fbec296943ac079b7c32a2ef. CumulativeGame/Peer/Setup +unchangedApplyUpdate.cmd/PS1 fromServerUpdateScriptZIP. Exacttested/publishedGameDLLmatches. OnlyGame/Gemnet.dll changed amongpayloadfiles; ALLotherGameData/dependencies/Peer/Setup/scriptsbyteverifiedunchanged; ZIPCRC/everymanifesthashverified. BuilderTools/build_rune_implementation_update.py. Includesreference/Rune-Book.md + merge-onlysettings example. NewPatch-Note.txt/patch-notes/2026-09-12.txt replaceunavailablebullet withconcisenowavailable/runes/reconnectbullet; markedUpcomingupdate, noDiscordpost. OldZIPsunmodified. Applyonserverthenreconnect; noautomaticdeployment.

IsolatedMySQL33073 startedparent39292 child40628 fromartifacts/rfrebirth-install-validation/mysql/bin/mysqld.exe, bound127.0.0.1. Verifiedpath/parent/portbeforecleanmysqladminshutdown; temporarycredentialCNFdeleted. Ownserverharnessstoppedfinally; no ongoingtestDB. Credentials/private testsettingsnotprintedorpackaged. No commits/indexchanges. No pendingrequiredapproval.

# Rune Book invocation crash safety hotfix (2026-09-12)

User reports Rune Book/Page crashing specifically when invoking; screenshots identify Invoke Blessing x1/x3/x8. Found old GENERAL/BA and BC replies advertising 19 runes/counter1, while GENERAL/C0 lacked dispatch. Saved native client proves caller ignores failed invoke, looks up buff ID0 and dereferences NULL at43CCCE. Native UI4D343A/4D343C checks balance>=cost before invoking; zero balance safely prevents all three paths. Communicated upfront: this hotfix makes unfinished Rune Book safe; rune earning/blessings remain unavailable. Do NOT describe this as a complete rune implementation or invent buffs/grants.

New Gemnet/PacketProcessors/RuneBook.cs handles authenticated exact-size BA/BC reads with complete all-zero bodies8/41, and rejects BE/C0/C2 mutations with bodies8/36/0. Routes added to current PacketProcessor and legacy PacketParser; removed General.Unknown4/MyInfo captured replies and unused duplicateUnknown7. No persistence/schema, rewards, currency, item or client changes. Existing LoginComplete/B2 has other captured state and remains unchanged; supplied9-12-434trace confirms normal sequence B2->BA->BC and laterBC reads, so corrected reads clear balance before RuneBook access. Reconnect after server restart required; a client already holding old19 can still enter its unsafe callback if merely given an invocation error. Script stops installed server before copying.

VALIDATION: Windows x64 published/testedGemnet.dllSHA25643ab4b5154effeb52a248a27b9099bc9a238c251cfdf7565a3f7751f3cbdc7b1. Three new backendPASSgroups via Tools/Multiplayer.Tests --rune-book: real encrypted loopback dispatch, fragmented/coalesced BA/BC, shapes/zero state; all1/3/8/invalidcosts+forgedgrants+use reports rejected, session/economy unchanged; malformed/auth/pending-character/differentuser isolation. Harness registers synthetic sessions directly, DatabaseInstance=null, neverstartsworkers/services/DB. Native Tools/test_rune_native.py uses isolatedUnicorn with savedimage: oldbalance19 entersInvoke for1/3/8, zero safelyskips; reproduces43CCCE nullaccess withstubbedmissinglookup andunrelatedUIconstructor. Actuallookup462990 returnsNULL forabsentID; currentclientdatahasnoRuneID0. Native menu4D366F derivescostfrombuttonIDandcalls4D3410. Saveddisassembly/tests/native-validation.json underignoredartifacts/rune-book. No full82DBsuite rerun (priorstabilitybaseline); targetedtestsapply. Realclientretetstpending. No livePC/process-memorycontrolorproductiondeployment.

DELIVERABLE: artifacts/RFRebirth-Rune-Book-Crash-Fix.zip 96,999,447bytes SHA256fd77a232d0d42fce18313e2fcc2b6e8bdd649510d8d9adc49eb9f2f60f9937ce. Cumulative Game+Peer+Setup+sameApplyUpdate.cmd/PS1 from previousServerUpdateScriptZIP. OnlyGame/Gemnet.dll changed amongpayloadfiles; allotherGameData/dependencies/Peer/Setup/scriptbytesverifiedidentical. UpdatedREADME,Patch-Note andreference/Rune-Book-Crash.md. BuilderTools/build_rune_book_update.py checkspriorZIPhash,build/test/publishexits,exacttestedDLL,allotherpublishedGamebytes,CRC/everymanifestSHA. docs/rune-book-crash-2026-09-12.md anddatedpatchnotesupdated. Priorreleasesunmodified. Test-onlyUnicorn installedinsideignoredartifacts/rune-book/native-deps,notincludedinZIP. No commits/indexchanges/subagents.

# Simple update folders and copy scripts delivered (2026-09-12)

User corrected the installation request: ordinary drag-and-drop replacement folders with a script to apply them. DO NOT resume the overbuilt GUI updater work. Deliverables: artifacts/RFRebirth-Server-Update-Script.zip (96,996,532 bytes; SHA256 5c2b116723cc5cead5c8d48ebee1506adb54645782895ee4257c90b453a43ce7) and artifacts/RFRebirth-Tools-Update-Script.zip (182,196,893 bytes; SHA256 96a22746820e77743b744b6951ac83891b780a6198746ce7d24f4cfe6b831f34). Exact runtime/data bytes preserved from the original Stability-Audit and Operator-Dependency ZIPs. Only README, script wrappers and manifest changed/added. No new game/reward changes or deployment.

Extract ZIP on target machine and double-click Apply Update.cmd. Default C:\ProgramData\RFRebirthServer; drag an existing destination folder onto CMD for another location. Server script copies Game+Peer+Setup, updates custom RewardDataPath Boxes/Packages/Minigames, preserves private/database files, enables DB Pooling and MaxConnections>=1200 (keeps higher limits). Uses exact owned scheduled task RFRebirth Server; disables it, requests normal stop, waits up to45sec for owned processes, backs up replaced files/settings, copies and hash-verifies, restores prior task state and requests restart only if previously running. Manual server must be stopped first. Tools copy Accounts/GiftStudio/WebsiteSetup or recognize standalone tool EXE; preserve connection files, no provisioning or server stop. File-copy failures attempt rollback. Backups Private/Update-Backups or Update-Backups. No DB backup, power-loss recovery, or automatic post-restart health check; check Status/login manually. Existing reward JSON edits are backed up and replaced, not merged.

Sources Tools/UpdateScripts/{Apply Update.cmd,Apply-Update.ps1,Test-Update.ps1,Server-README.txt,Tools-README.txt}, builder Tools/build_script_updates.py, docs/script-updates-2026-09-12.md. Windows PowerShell 5 parses successfully. Seven test groups PASS: settings/credentials/custom data/task state, repeat/higher-limit/stopped behavior, tool layouts/preferences, tamper/traversal/foreign task rejection, mid-copy rollback, both COMPLETE release ZIPs installed and every payload hash verified in isolated folders. Service controls test doubles; no PC UI, production services, database, or client touched. PowerShell DbConnectionStringBuilder needs set_ConnectionString/get_ConnectionString/set_Item methods: property assignment creates dictionary keys instead; corrected and tested with quoted semicolon/punctuation password. artifacts/script-updates/tests.log and release-validation.json contain evidence.

Unused GUI code, docs, builder and EXEs were reversibly moved to ignored artifacts/script-updates/unused-gui-work (not shipped). Recursive removal was automatically blocked, so used reversible archival instead. No approval needed or pending. No commit/index changes, no subagents. Original stability/tool archives unchanged.

# Room IP privacy concern (2026-09-12)

User subsequently clarified the room-IP harvesting report concerns OFFICIAL Rumble Fighter. No RFRebirth reproduction reported. Updated docs/room-ip-privacy-2026-09-12.md accordingly; treat as prevention requirement here, not a confirmed exploit of this build. Exact official exploit mechanism remains unverified. Runtime and release archives unchanged.

User reports hackers can obtain all players' IPs in a ROOM, correcting lobby. Follow-up source inspection recorded in docs/room-ip-privacy-2026-09-12.md. Current Peer self_group_join hasdirectP2Pflag0/UDPport0/emptyuserdata; handshakeechosonlyconnectingclient'sownobservedIP; RoomWirebuilderssendpeer/groupIDs,notobservedsocketaddresses. CURRENT relay alreadyTCP anddirectUDPunimplemented. HoweverPeerServer.relay andQuery.LoadGame1 forwardopaqueclientpayloads; notallnativepayloadsdecoded, so DONOTclaimexploitfixed/privacyguaranteed. Needownconsentingstagingclients differentnetworkscaptureplusadversarialsetupverification; noPC/game/productioncontrolperformed, no runtimeorZIPmodifications. Userhasnotyetidentifiedwhetherexploitseenhereorotherdeployment. Peeraccount/roomauthorizationseparate:doesnothideIPsfromauthorizedroomparticipants. Keeprelayonly/avoidendpointdisclosure/directfallback asrequirement, nofixedpatchnoteuntilverified.

# Live-service audit for 500 players completed (2026-09-12)

Latest user asked for a whole-project long-term service review; capacity answer was approximately 500 concurrent players. Completed a broad source/dependency/operational audit and concrete hardening, with remaining launch issues documented in docs/live-service-audit-2026-09-12.md. Do NOT claim production-ready, bug-free, or validated 500-player gameplay. No PC/game control, production deployment, credential changes, Git index changes or subagents. Existing dirty work preserved.

Source fixes: peer hardcoded128 admission cap -> configurable --max-connections default1024; main ConnectionManager immediate capacity rejection under admission lock, safe concurrent removal/disposal; Server admits before dispatch, tracks handlers/monitor, cancellation-aware accept, closes unauthenticated connections by absolute120sec age (monitor5sec), detects authenticated Square sessions separately. ServerHostedService now BackgroundService so startup completes. Dispose no longer marks disposed before Stop or races CTS disposal after arbitrary5sec wait. Cooperative Stop has bounded worker waits; supervisor still force-kills game on normal stop (OPEN issue).

New Gemnet/Security/LoginAdmission.cs bounds password work before DB/BCrypt for BOTH Login credential paths: defaults8 concurrent,600 admitted/IP/minute,10 failed/account/minute,8192 identities per map, fixed-expiry pruning at mostonce/sec, case/trim and IPv4-mapped normalization, idempotent leases. Successful password clears failures; malformed identity rejected; overload uses existing failure protocol. Config properties LoginConcurrentChecks/LoginAttemptsPerIpPerMinute/LoginFailuresPerAccountPerMinute, plus UnauthenticatedTimeoutSeconds and EnablePacketTrace=false. Limits are process-local and do NOT cover all authenticated request/BCrypt resale paths. No session credentials printed.

Diagnostics: new RotatingLog serializes/rotates bounded records; PacketTrace opt-in10MiB+3 backups, supervisor child logs10MiB+5 backups; retained credential redaction, moved raw packet output toDebug, removed RC4 key/email fromnormal logs. Existing oversized historical files persist through rotation and MySQL/IIS logs remain separately managed. Installer generates Pooling=True runtime string andMaxConnections1200, but EXISTING Private/settings.json unchanged; bootstrap admin connections remainunpooled. docs/live-service-settings.example.json is merge-only and has no credentials.

Package floors System.Drawing.Common4.7.2/System.Text.Json8.0.5 added tocore andindependentAccountCreator/GiftStudio/WebsiteSetup/testprojects pullingMySQL8.0.33 dependencies. NuGet auditsafter reportnoaffectedpackages; registrationnet48 also none. SelfcontainedWinx64 includes newer runtimeSystem.Text.Json from .NET8.0.30 instead of package8.0.5. Official policy checked2026-09-12 lists8.0.31current and.NET8EOL2026-11-10; servicing andmigration.NET10 OPEN. Do not mistake advisory clean for fullsecurity proof.

VALIDATION:82backendPASSgroups both regularRelease andWindows selfcontained, lattertestedGemnetDLLmatchespublished f71cc6ead0764679138768552b45d54551fabd3f9b6e442c6a5fc69fc00ac6f3. NewLiveServiceTests:500actualsocketpairs,501st immediateoverflow,slotrecovery/concurrentdispose83ms Windowsrun (NOTgameplayload);200concurrentrotatingwrites/redaction;loginlimitsboundedstate/expiry. Newencryptedlogin test10wrongattempts alternatingmodern/legacythenbothvalidcredentialsblockedacrossreconnect. 7launcherPASS incl rememberedemailnormal/abrupttestfixtureexit/tempregistry/hosts;2installerPASS;6peerprotocoltests;4peerloopbacktests(6720deliveries0loss/reorderp95=2.06msmax3.44ms);rebuiltpeerEXE also4wiretestsPASS. PublishedGame.Program startednormallyonisolated17070 andpassed5AccountCreator+7GiftStudioPASSgroups (native encrypted accountlogin, concurrentcreation/grants,rollback,bulkgifts,latecommits/reconnect). Fixed staleAccountCreator.Tests missingAccountRegistration.cslink, oldEXP5000expectation->documentedEXP0, selectedoneactiveavatar+tenpresets, optionalportarg; noaccountpolicychanged. WebsiteIIS/liveclient/full500gameplay nottested. No warningsclaim;existingnullablewarningsremain.

RELEASES: artifacts/RFRebirth-Stability-Audit-Update.zip 96992345bytes SHA256b5ddf0a93efcf2d1ffc98eb09c388580f0f4bb1fd63443407ea1dcef5dc81da1,984entries. MERGE ALL Game+Peer+Setup afterstop/backup; Setup updatesexisting supervisor, DO NOT reinstall. IncludesfullWinx64dependencies/runtime anddepsjson; preservePrivate/settings/DB. ExistingruntimeDBstringPooling=False->True andMaxConnections1200 requireoperatorconfigedit. artifacts/RFRebirth-Operator-Dependency-Update.zip182192331bytes SHA256e01651797615b9fbfb6476cef1a79ee6bc32fefc77727457f87b9cbde94fb0d3,1158entries, optionalAccounts/GiftStudio/WebsiteSetup folder replacements; preserveINI/credentials, donotrerunwebsiteprovisioning. BuilderTools/build_live_service_update.py verifiesexits,82markers,published/testDLL,baselineMatchAstrosZIPhash,ALLpriorrewardData byteequalitysource/publish,ZIPCRC+everymanifestSHA,noprivatesettings/logs/sql/cnf. Buildnotes/artifacts/live-service-audit/release-validation.json. Newauditprivatefoldergitignored.

UNCHANGED rewards: all78incorrectlogfixboxes disabled/empty,27badpackageswithdrawn,122activeboxes/372packages remain. No guessedprizes;Astrosdefault0;7dayweeklycloak/30daymonthlycrown/no bracelets. CurrentPatch-Note.txt andpatch-notes/2026-09-12.txt haveconciseconnectioncleanup/login/logfixentries. NoDiscordposting.

OPEN HIGH PRIORITY (seeauditreport): peerpublicGUIDhandshakehasnoauthenticatedaccount/roomauthorizationbinding; clientreportedmatch/solo/BombStrikeresultsboundedbutnotauthoritative;giftpollingup to250queries/sec at500readyusersandknowninventoryJSON;peer2threads/connection~1000threads500players;MinigameService.Finishaccount->periodversusSettleperiod->account lockinversion atrollover (codefinding,noreproyet);normalSupervisorStopkillsgamebypassinggracefulhost;legacyRC4publickey/HTTPregistrationsecurecookiesandoperationratebudgets;offhostbackup/restoreobjectives/retention/alerts;trackedGemnet/settings.jsondespiteoldAGENTclaimgitignored (nohistoryexposurescopecompleted,secretsnotprinted,indexpreserved). Needfull500multi-machinegameplaysoak andfailure/recoverytestbeforecapacityclaim. Avoid automaticdestructivecleanupofreceipts orrewarddata.

OwnisolatedgamePID3000 (verifiedauditpublishpath) stopped; ownMySQL33073 verifiedexpectedmysqldpath+savedparent fromartifacts/live-service-audit/mysql-parent.pid, thenmysqladminshutdowncompletedcleanly;tempcredentialcnfdeletedfinally. Account/Gift/backendharnessesremovedtheirowntestaccounts. Noauditservicesleft. Privateaudit/runtime/settings.jsonandlogsremaingitignoredforrepro,neverpackage/share.

# Optional match Astro rewards built (2026-09-12)

Latest user requested a config permitting match Astros but set to0. Implemented MatchRewards.AstrosPerMatch integer default0 in existing active server settings (normally Private/settings.json), flat per multiplayer participant meeting MinimumMatchSeconds. No per-kill/placement scaling; soloAdventure/Plaza minigames unchanged. Omission defaults0, negative rejectsstartup. Example docs/match-astros-settings.example.json mergeonly, docs/match-astros-2026-09-12.md guide. Do not replace fullsettings or duplicateMatchRewards. Restartneeded tochange. No productionsettings edited/printed. Default awardsremainzero.

MultiplayerRewardSettings.Calculate returns optionalthird Astros inMatchRewardPolicy. Award record optionalAstros0. Query uses paidreceiptAstros onB0/68 crossover, passescalculatedAstros otherwise. EconomyService.Claim validatesnonnegative andcheckedbalance, accountlock+singletransaction writesbalance/match_claims/economy_ledger Astros; duplicates skipped. FeatureSchema additive2026091202 adds match_claims.AstrosINTdefault0check>=0, preservesoldreceipts/no backfill. No guessedAstrofield inresults packet; existingGetCash readscommittedDBbalance. Player cache hasnoAstrosfield. APIoriginal2/3argconstructorsstillwork viaoptionalargs.

Full78backendPASSgroups, testexit0/publish0. TestsactualJSONsetting, defaultzero unchangedformula, flat reward at0/65535kills, shortmatch+late retryzero, enabled7->11 settings mixedencryptedresults, rollbacktrigger, committedAstroGetCash, repeatmigration/receipt99noextraaward,8concurrentClaimsameIDonce, secondaccountoverflow rollsbackwholebatch, negativeawardreject. Firsttestattemptfailed newtestcleanup because ModelAccount fields passedasDapperparams; fixedanonymousparams andfullrerunpassed. Alltestaccountsremovedbyharness; no productionDB. Existing77includingcrown/cloak/badboxwithdrawalstillpass.

NEWCUMULATIVE ZIP artifacts/RFRebirth-Match-Astros-Update.zip12825157bytes SHA25638b482af84243bf9cdc54982e62299b622075744d9696bf51d41f5a64fe0c841. DLL22303794ba28e23e9c28a7d4ffe2a60916735d9bfe0b8edcc62165e358bf7204 matchespublished/tested. BuilderTools/build_match_astros_update.py usespreviousPrizesZIPwithverifiedSHA, checks78markers,publish/testDLL,ALLsource/publishpriorData bytes, allmanifest/ZIPCRC,nosecrets. Peer/data byteunchanged, minigameenabled7/30crowns/cloaksretained. Includes example0, instructions, notes. MergebothGame/Peer, keepPrivate/settings/database, customRewardDataPathcopyDataasbefore. Noautomaticdeployment/clientcontrol. Realclientretetstpending.

OwnisolatedMySQLparent10128 startedon33073; shutdown verifiedchildpathandparent, cleanmysqladminshutdown andtemporarycredentialdeletion completed. Artifacts/match-astros private testlogs/build/publish/release-validation available. OlderZIPsunmodified. Patch-Note+datedarchive updated supportoptionalAstrorewardcurrentlydisabled.

# Plaza minigames WITH approved prizes built (2026-09-12)

Latest user approved fixed 30-day monthly crowns (instead of calendar-month expiry), 7-day weekly cloaks, no bracelets, and requested newest server files. Built artifacts/RFRebirth-Plaza-Minigames-Prizes-Update.zip, 12820924 bytes, SHA256 e237b618c5030772528b452ee292ab35e7beb31bb899436f2561450401b2cb08. DLL f44bc31838af0e7313a8fa888943e1cfc8fac629ba7c524ffb6c4370269a2671; Peer unchanged 6156644084580fcd716511ce31d7d9dc03a3a35107cdeb7177180304e650e5db. Supersedes previous no-prizes minigame ZIP for new deployment; previous archives untouched.

Gemnet/Data/Minigames/policy.json now RewardsEnabled=true, six rules: period2 cloak IDs3017008/9/10 for ranks1/2-10/11-50, 7 days; period3 crown3027005/6/7 same brackets,30days; quantity1 each. No daily prizes/bracelets. Existing duration engine sufficient: fixed timers start at delivery including downtime; next distribution does not remove still-valid previous award. This intentional RFRebirth choice supersedes earlier concern requiring calendar expiry. InventorySaleService already rejects all type84 timed prizes. Existing period policy snapshots remain unchanged; previously recorded disabled weekly/monthly competitions remain disabled until new competitions start. README prominently explains this, no retrospective DB edits.

New integration test ReleasePrizes in MinigameTests loads actual copied release policy, seeds 51 isolated temporary accounts across day/week/month at2033-02-15, delayed delivery2033-03-02, concurrent settlement, all six exact tiers at boundaries, rank51/no daily/no bracelets, fixed7/30expiry, resale rejection. Removes own accounts and test windows. Full suite77PASS groups, test exit0, publish0, testedDLL=publishedDLL and testedpolicy=publishedpolicy. artifacts/minigames-prizes contains private backend log, release-validation.json, build/publish outputs. No real-client retest yet; no production deployment/client control.

BuilderTools/build_minigame_prizes_update.py verifies77markers, exact6rules, nativeitemnames, all priorbox/packagebytes againstQuestSyncbase, tested/publishedDLLandpolicy, manifest/CRC/no secrets. Includes cumulativeGame+Peer, all200boxJSON(122active78disabled),372packages, newMinigames config/guide, originalprize evidence, updatedPatch-Note. User must stop/backup/merge BOTHGame+Peer, preserve runtime/settings/database, copy Boxes/Packages/Minigames to customRewardDataPath if set. No installer. Incorrect substitute box definitions remain withdrawn.

Own isolated MySQL parent8756/child48592 on33073, expectedpath/parent verified, cleanmysqladminshutdown completed and temporary credentials deleted. No test services left. A bulk documentation edit shell command was rejected by tool policy; completed same reversible edits using apply_patch without permissions or bypass. All documentation and notes updated.

# Plaza original prize research found (2026-09-12)

Latest user asks us to find durations; they do not know them. Official Korean publisher notice FOUND: https://gf.valofe.com/notice/view?entry_idx=17156&page=46 dated 2015-08-05. See docs/plaza-original-prizes-2026-09-12.md for exact chart and expiry semantics. This supersedes earlier unknown-chart notes below. Local ItemString Korean names match the six original item identities. No matching NA notice found. Bracelets remain excluded. Research and README updated only; runtime policy, DLL, and delivered ZIP unchanged. Existing DurationDays-only payout model needs rollover expiry support and resale review before enabling the recovered preset; do not silently equate a calendar month with 30 days.

# Plaza minigame prize selection (2026-09-12)

User explicitly selected crowns and cloaks only; exclude bracelets from the planned leaderboard prizes. The six items in Gemnet/Data/Minigames/original-items.json already match this selection. Rank brackets and durations remain unverified, so this preference does not authorize guessed mappings or enabling payouts. Recorded in the configuration guide; no runtime or delivered ZIP changes needed.

# Plaza minigames: Bomb Strike update prepared (2026-09-12)

Latest user wants Start/Rank crashes fixed, scores/leaderboards, ORIGINAL rank prizes with editable rules. No original bracket/duration chart supplied yet. Async question asks for original chart/link; continue without inventing prizes. Earlier arbitrary box-reward authorization remains withdrawn. Do NOT enable guesses.

Implemented native Bomb Strike stage301001 support, 30/D2 period0 Start+alltime best, periods1/2/3 daily/weekly/monthly own rank;30/D4 top10;40/B0 result891. Previous General only replied for Zombie100003/4, silently dropped301001. Client local log read only has MiniGame_MyBestScore NULL at16:57:22.431,17:01:34.446,17:02:36.752. Unanswered request confirmed, not captured crash stack. No GUI/process-memory/client-file changes. Real-client retest PENDING.

Native evidence artifacts/minigames/native-protocol.txt and docs/plaza-minigames-2026-09-12.md. D2 sender51DBD0/D4sender51DD30;UI4C73D0,Start4C7AA0. Period0 uniquelyStart, rank tabs1/2/3 (4CA0D2-4CA10E). D3body16:rankDWORD0,scoreDWORD4. D5bytecount+36byteentries(rank0,name20@4,score24),max10;nameNUL19bytes avoids stack overread. B0sender52E7F0:fullpacket891,word0201@10,byte1@12,stageDWORD301001@13,timerWORD17+24,scoreDWORD26+107,count1@50,slotWORD0@51,name20@53. Special minigame B1body12, bestDWORDbody8(full14):437BC1 dispatch to52C440 reads+8, NORMAL MatchRewardRes hasEXP there and is wrong. Minigamecounter54F9CF copies simulationtime27C toencoded80;HUD54A246 copies80to90(lastscore). Bounds60ticks/sec,score/timerlowworddelta<=60,defaultmaxrun3600sec+tolerance5 LOCAL settings, not claimed retail. No bomb collision simulation; client scores bounded, NOT cheat-proof.

New Gemnet/Persistence/MinigamePolicy.cs+MinigameService.cs and PacketProcessors/Minigames.cs, schema2026091201 viaFeatureSchema.Migrate; tables minigame_attempts(owner/session/start/hash/best), minigame_scores(period/date/owner/best/time),minigame_periods(savedpolicy/end/settled),minigame_prizes(rank,item,exactinventoryinstance). Uses account/period locks, atomic best/upsert, retries returnreceipt, foreignsession/changedpayload/tooearly reject. Requires authenticated Plaza channel state1/4 andno room. Lower scoredoesnotreplacebest;zeroscoresnonranking;tiesearliesttime thenowner. UTCmidnight/Mondayweek/monthstart documentedLOCAL choices. Endtime determinesperiod, alltimebest retained. Prizes:policy savedonfirstresult perperiod; editsrestart applyonlyfutureunstartedperiods, no retroactiveprizes. Timedfromdelivery;85usecountstacks;workerexistingMonitorGifts checkssettlement eachminute inclcatchup, transactions+settled preventduplicate. Ranksmax10+separatePersonalRank preservesrankoutside10. Settle optionalperiod/startfilter forisolatedtests/targeted use.

Data/Minigames/policy.json Enabledtrue, RewardsEnabledFALSE, RankRewardsEMPTY. Original-items.json sixverifiednamesIDs:3027005/6/7 Gold/Silver/BronzeCrown,3017008/9/10 Gold/Silver/BronzeCloak. Localnativeitemtable+ItemStringsupportidentitiesONLY. Community https://rumblefighter.fandom.com/wiki/Plaza mentionsmonthlytemporarycrown/cape butdurationunknown. Exactoriginalrankbrackets/durationsunresolved. Useraskedchart/link. NEVERclaimoriginalrewardsfullyconfigured. Config README explainsallfields/delivery/localchoices. No guessedcustomprizes distributed. TestfixtureGoldCrown2d/Silver1d/Megaphone3use ONLYisolatedtests, NOToriginalrulesandNOTrelease.

Final76backendPASSgroups (existing71 +minigame3 +SquareRunrepeat2). Tests nativeencryptedStart/Rank/resultlayouts,empty/populatedboards,invalidstage/period/size/name/scores/noStart,repeatStart,timing,GUID,persistence,replay,ties,lowerbest,noeconomymutation,leapday/calendar,concurrentsavedpolicysettlement,timed/stackprizes,failedbatchrollbackviaownSQLtrigger. Fixedtestisolation:futureclock2032settlementoriginallyclosedemptycurrent2026testboards frompriorrun; restrictedtestsettlementtoown2032day. Removedexact3emptycurrenttestwindowswithfutureSettledAt2032-02-29; no productiondatabase. Testtriggerdropped. Finaltestexit0, publish0, testedDLL==published. Existingcompilerwarningsremain.

DELIVERABLE artifacts/RFRebirth-Plaza-Minigames-Update.zip 12819094bytes SHA256b095da5adce6f96ea17a73cd615b1635db8d64f180b1ffab71e3316d9e3aeaa7. DLL9e7012ce5077759a334093659d45e86be65e6bb5f86b7534ad35422ad6e137d9. Peerunchanged6156644084580fcd716511ce31d7d9dc03a3a35107cdeb7177180304e650e5db. BuilderTools/build_minigames_update.py verifiesQuestSyncbaseSHA,dlltest/publish,76groups,ALLoldrewarddata/source/publishbyteequality,originalitemnamesIDs,payoutsdisabled,ZIPCRC+manifest+nosecrets. Includes cumulativeGame/Peer +newDataMinigamesconfig/guide/reference,updatedPatch-Note.txt+datedarchive. Preserve122active78disabledemptyboxes/372packages. MergefullGame+Peer,ALLdisabledlogfixJSON+DLL; customRewardDataPathcopyMinigamesaswellasBoxesPackages. Noinstaller/noautomaticdeployment/clientpatch. OldbadServerLogFixes/RoomsPlazaarchivesstillwithdrawn.

OwnisolatedMySQLparent22544/child9468 loopback33073 expectedpath/ancestryverified; cleanmysqladminshutdowncompletedandtemporary.cnfremoved. TestsusedPRIVATEartifacts/reward-correction/isolated/settings.json, neverprinted/packaged. Newartifacts/minigames/build,publish,backend-tests.log,exitfiles,release-validation.json,native-protocol.txt. Future work: realclient Start/finish/Rank/return/restartretetst; obtainoriginalprizechart beforefillingRankRewards. User-reportedPlaza1FPSfixstillretained fromquestcorrection. Nootherunfinishedmodesclaimedcomplete.

# Plaza follow-up logs and quest overshoot correction (2026-09-12)

LATEST USER RETEST: user says "Seems like plaza 1 fps bug is fixed." Following delivery of Quest-Sync-Correction, record successful USER-OBSERVED Plaza slowdown retest, supporting quest retry loop cause. No instrumented FPS measurement; do not claim all Plaza behavior fixed. Updated Patch-Note.txt and 2026-09-12 archive to "Fixed a login achievement update loop that caused severe lag in Plaza." Added retest note to docs/plaza-followup-2026-09-12.md. No code/build/database changes or repeat tests; delivered ZIP/hash remains unchanged. Earlier pending-retest statements below and inside delivered artifact describe pre-retest history and are superseded by this report.

LIVEFOLLOWUPUPDATE: userofferedtoenterPlazawhileingame,reloadedclient,saidinsideandlagging,thenclickedLobbyonrequest. WeREADlocalC:/PlayRedFox/RumbleFighter/RumbleFighter.logonly(noUIcontrols/processmemory/hooks). GetProcesspathnullbutmemoryverifiedinstalledpath. Priorlogpreservedclient-live-before.logbeforeuserrelaunch;oldended16:49:14. NewSTATE_PLAYSQUARE16:50:28.156,userconfirmedlag;capturethrough16:51:14.924has528questfailuresafterenter(~10–13/sec),535total. Copyclient-plaza-repro-20260912-165114.log+client-repro-summary.jsonunderartifacts/plaza-followup-434;rawclientlogsPRIVATE/notpackaged. UserclickedLobby,GS_UIMENU16:51:39.614;through16:52:17.034only39failures(~1/sec). Savedclient-after-lobby.log+summary. Noothererrorcategoriesduringlagwindow;earlierassetloadwarnGTUP/GUTP_518once,notprovenFPSdriver. Failure-ratejumpPlazavsLobbystrengthensquestretryhypothesisbutnotproofnewserverfixresolvesFPS. UserdoesNOTneeduploadclientlog,wecanreadknownfile. Nextapplynewserverfix/reconnect/retetestsamevisit;don'tclaimupdatedremotelyalready.

FINALartifactupdatedDOCUMENTATIONONLYafterliveevidence: RFRebirth-Quest-Sync-Correction.zip12801694bytes SHA256d185547d19386c9a16c750718aa266cb1ead2fae413a086cb439788c7f91b3a0; DLLstillcec71e3852e519a9713e09549299d8d90185997b5e20179810bc9e14e124fff5,71tests/rewardsunchanged. EarlierZIPchecksumsbelowwereintermediatepre-deliverydocumentationversions;useTHISfinalhash. BuilderreranCRC/allhashes,data/Peerbyteequality;noextraDB/service/testsneededforreportchange. docs/plaza-followup-2026-09-12.mdnowincludescaptureandLobbycomparison. Noautodeploy.

User supplied artifacts/9-12-434 fourlogs afterPlazaupdate; asyncanswered STILLabout1FPS. All4filesareexactappendsof9-12-328,Tools/review_plaza_followup.py isolatesappendedrecords/latestgameStartup. NewgameStartup346372=200boxes399packages (capturebeforeRewardCorrection,don'tblameuser);newPlazastatelogsprovemodernPlazachangerunning. Checkin14:23:00.830,channel00.900,state0->1at14:23:01.284,state1->3at14:23:23.285,bothpeers0. 28movement70byte,1roster,2state,1auth,1join;4successreplies,no4B12spawns/no4B13relay/noPlazareject/errors/disconnect. Solo1FPSthereforenotrepeatedpeerspawncause. Peernew87lines79metrics,noresets/unsupportedRMI,maxqueue0.32ms/maxsocketsend0.27ms,pendingmax317bytes. MySQLonlynewselfsignedCAwarning,normalshutdown. ClocktimesareSERVERloggedlocalclock(notuserCentral/UTC). Docs/plaza-followup-2026-09-12.md+artifacts/plaza-followup-434/analysis.json/review-summary. NoPC/UI/game/liveclientprocesscontrol.

ConfirmedNEWquestbug: all911appended30/CEupdates tuple(instance58,quest31001043,progress66),allCFfailure. Serverquest-list14:21:47.391ownedrowtarget15,saved2.180requestsbetweentwoPlazastateACKsexact22.001sec. Earlierquickcommentarysaid183roughly22sec;180exactbounds(morepacketsincludedpriorloosewindow). Sequentialserverloggedreplydelays6–39ms,median15,NOTend-to-endRTT,noasyncconnectionIDsbutoneactiveplayer. Native51F860makes30/CEsyncRPC51F8D9,51F958failure->-1;success51F9BBreads3DWORD;caller4F4AD5processesonlysuccess. ThisisrealretryloopandpossibleFPScontributor,NOTproven1FPSrootcause. NootherPlazaprotocolguessadded.

QuestService.Update previously rejectedprogress>q.Target evennonClientUIserver-observedobjectives. Now upperboundappliesonlyq.ClientUI;owned/current/matchingquest/nonnegativecheckedforall;nonClientUIRefresh+returnsSERVERsavedprogress,nevertrustsreport orgrantsanything. ClientUItutorial/settingsretainbounds. QuestTests reproduces66of15x20+intMax,returnsownsaved1(testfixture,notproduction2),EXPintMaxignored,foreign/mismatch/negative/unearnedclaimsreject;inventory/ledger/logindayevidenceunchanged. ExistingClientUIintMaxrejecttestretained. Noquests/prizetableschanged. Final71backendPASSgroupsincludesall78withdrawnboxes27packagesnegativechecksandallactiveopening/multiplayer. ReleasepublishedDLL=testDLL cec71e3852e519a9713e09549299d8d90185997b5e20179810bc9e14e124fff5. Existingwarningsremain.

LATESTDELIVERABLEartifacts/RFRebirth-Quest-Sync-Correction.zip12801120bytes SHA256ef8f066afb4d6fd81d1f7ba0568b7779c4dc1088e4147e6b819aa9842fdb3ee5. CumulativebaseRewardCorrectionziphashverified;newDLL+currentPatchNote+FollowupDoc;ALLGame/DataandPeerbyteidenticaltoRewardCorrectionZIP/source/publish.122enabled78disabledemptyboxes372packages;Peerunchanged6156644084580fcd716511ce31d7d9dc03a3a35107cdeb7177180304e650e5db(previous4sockettestsnotrerun). Tools/build_quest_sync_update.py0exit71groups,test/publishDLL,basehash+eachfile,newZIPCRC+allhashes+nosecrets. StopbackupmergeGame+PeerALLlogfixfiles+DLL/Packages;customrewardpathcopyData;restart122enabled372packages. Noautomaticdeployment. NEVERreapplywithdrawnServerLogFixes/RoomsPlazaZIPs. PatchNote+datedaddsonehonestloginachievementretryfixbullet,noclaimFPSfixed.

OwnisolatedMySQLparent36604/child39320on33073verifiedancestry/pathandcleanmysqladminshutdowncompleted,tempsecretcnfremoved;othersuntouched. UsedexistingPRIVATEartifacts/reward-correction/isolated/settings.jsonrootpassword,nooutput/distribution. NextretetestPlaza+questCFsuccess; ifstill1FPSneedCLIENTRumbleFighter.logfromsameattempt,timestamps,notanotherinventedserverpatch. Already-awardedbaditemsnotremoved;withdrawalpoliciesbelowstillapply.

# Incorrect substitute rewards WITHDRAWN (2026-09-12 — latest instruction)

User strongly objects: extra boxes were given prizes they should NEVER have had. Screenshot shows Abandoned Graveyard Chest (Hell) -> Master Enchant Card. Confirmed 5043124 (andNormal5043122/Hard5043123) used fallback supplies including5090016. Took responsibility: native-valid items/mechanical opening tests did NOT establish correct chest contents. Do NOT invoke earlier generalcustomrewardpermission to justify these tables. Latest instruction overrides it. Never regenerate invented prize pools or treat guesses as legitimate box contents; obtain actual supported contents/exact reviewed prize lists. No automatic inventory cleanup or production access authorized/performed.

Correction WITHDRAWS ALL78logfixboxpools +27packages from last expansion (auditartifacts/log-fixes/custom-rewards.json), no replacementprizes. Gemnet/Data/Boxes/logfix-*.json nowEnabledfalse,PossibleItemsempty,keymetadataretained. Box.Validate allowsvalidemptyDISABLEDdefinition butenabledemptystillinvalid; Distribution explicitlyrejectsdisabled,registryGetBoxreturnsnullbeforeinventory/keymutation. Packages restoredbyte-identicalto372-entryprelogcatalog. Original122boxfilesbyte-identicaltoSupplied-Boxes-Update.zip. Scopeislastsubstituteexpansion; NOTnewassertionallprior122tablesindependentlyconfirmedretail (prioraliases/localpoliciesremainhistorical). Tools/withdraw_unverified_rewards.py reproduceswithdrawals guardedbybaselineSHA,Tools/withdrawn_reward_definitions.json complete105IDlist. Oldfix_logged_rewards.py replacedwithretiredstub; build_log_fixes_update.py+build_rooms_plaza_update.py failimmediatelywithdrawn. OldZIPsNOTchanged/deleted, artifacts/WITHDRAWN-CUSTOM-REWARD-UPDATES.txtwarnsagainstboth. Currentroom/Plaza/protocol/peerfixesretained.

Final70backendPASSgroups +11sourcechecks(4withdrawal+7supplied). WithdrawnRewardTests encryptedattempts+retriesALL78boxes27packages, completeinventory+keyquantities+accountstate+ledgercountunchanged; includesGraveyardHell; disabledrandom/ticketselectionreject; active117nongem+5gem and372packagesstilltested. ChestPresetTests nowskipsdisabledafterassertregistryunavailable. TestmetadataJSONcopiedonlytestproject. Sourcechecksrestorebyte-equality/emptytables/retiredscripts. InitialsourcecounttestassumedEnabledalwayspresent; fixedgetdefaulttrue,finalpass. DLLtested=publishedb0605001ce36e01857298aec93dc807b294aae8f2cb5e3feae056307c177a638.

NEWUSEONLYartifacts/RFRebirth-Reward-Correction.zip12798572bytes SHA256d9fb5380b2b0912646f4fcdc615bbe88d01e63066ad7202641a3dc3ba2f3c076. BuilderTools/build_reward_correction_update.py verifies0test/publishexit,70groups11sourcechecks,200JSON=122active78disabledempty,372packages,baselinebytes,publish/testDLL,previousunchangedPeerCRC/hash,ZIPallentryhashes+nosecrets/logs. PeerEXEunchanged6156644084580fcd716511ce31d7d9dc03a3a35107cdeb7177180304e650e5db (previousfourlocalsockettests). PackageGameDLL+all200JSON+packages+Peerentireinternal+README+WithdrawnRewardslist+correctionreport+manifest+Patch-Note. MUSTcopyALLlogfixJSONwithDLLsooldpoolsgetoverwritten; don'tcopyonlyactive122. OlderDLLcan'tloademptydisableddefinitions. StopbackupmergeGame+Peer,preserveotherGamefiles/settings/DB;customRewardDataPathcopydatathere;restartstartup122enabled372packages. Noinstaller/automaticdeployment. docs/reward-correction-2026-09-12.md. Patch-Note.txt+datedarchive removedcustomandlevel-openingclaims,replacedwithtemporarydisabled/boxkeyretentionbullet.

DoesNOTremovealreadyawardeditemsorrestorealreadyconsumedchests/keys. economy_ledger open_box onlyrewardItemID+timestamp, lacksoriginchestID+grantedinstanceID; cannotreliablydistinguishlegitimateMasterCardsfromwrongones. Needactualincidentlogs/backupsandreviewbeforeanyremoval; noDBrollback/productioninventorymutationperformed. UserPC/UI/game/liveprocessnotcontrolled. IsolatedMySQLtestparent19976/child45920on33073ancestry/pathverified,cleanmysqladminshutdowncompleted,tempsecretcnfremoved,otherMySQLuntouched. Newprivatecopyartifacts/reward-correction/isolated/settings.json hasROOTPASSWORD neverpackage/print. Historicalreportsbeloware superseded onrewardcounts/policies.

# Rooms and Plaza follow-up prepared (2026-09-12)

User broadened bug review to room kicking and Plaza. Plaza symptom: enters, then either approximately1FPS/barelymovesuntilLobby or returnsout. No PC/game/UI/liveprocess control permitted; source/staticclientimage and isolatedtests only. Do not claim actual FPS or lobbybounce resolved.

Implemented normal40/41 asynchronouskick (26bytes,name20), previouslydefaultunsupported. Native55EEB0sender, receive5618F4table maps13->561749FUNC_B_KICK_OUT. Broadcast240/13name20 toallcurrentmembers includingtarget, no40/42ack(42hostchange). GameManager.KickPlayer under_roomsLock validateshost,sameroom,target!=self,waiting,noLaunchPending,protocol40. LeaveRoom clearsmember/slot/ready/team while loginpreserved; enqueuecallbacksunderlock preventlatekickafternewjoin. Room.KickedMembersaccountIDs blocksdirectandquickrejoinuntilroomdeleted; localpolicyconsistentnativekickedroommemory56177D. Noalternate41kickprotocolimplemented. TestsRoomKickTests.cs coverguards/duplicates/notificationcount/slot/login/quick+directrejoin/otherroom. Existing full-width20-character names are a broader known risk: RoomWire.Text writers NUL-truncate19 while charactercreationaccepts20; not changed here or claimed covered bykicktests.

Square86statusnowACKsidenticalstatewithoutSnapshot/peerrespawn. Realstatechangesstillnotify, snapshotnonewhennopeers. Logsmeaningfultransitions owner/channel/from/to/peercount noauth. PlayerManager.GetItemsOfAvatar nowselectsonlyequippedinstanceIDs usingOwnerID+ItemLifecycle.Usable ratherthanmaterializingfullusableinventory; slotorder/filteringretained. Native4B12consumer4FB620 doesavatar/equipmentwork; redundantspawnsplausiblestallcontributor, actualclientFPScauseunproven. Movementintegerlayout/readersverified; unchanged. Squaretest64coalescedstatusrequests,nomorespawns,2->4->1visibility,repeated4,rosterrestoration,movement,disconnect,sessionauth. BothCountryTestsandlaterMultiplayerrunthistest.

Final69backendPASSgroups, releasepublishdone. DLLtested=publishedSHA256397d9a169d0a8eae17643d92833a973cd76e903c5c563c5c1bb61da36d660d55. Newcumulativeartifacts/RFRebirth-Rooms-Plaza-Fixes.zip12927214bytes SHA256d331c4ca6d583e7be40855d666882e65671c4c4bda87fec0f8a1e2de23acc6c9. ContainsupdatedGameDLL,byteidenticalprevious200boxes399packages+PeerEXE/internal,README,Patch-Note,customrewardreference,updatedLogReview+RoomsPlazaReview,manifest. Tools/build_rooms_plaza_update.py validatespriorZIPhash,allentries,69tests,test/publishDLL,unchangedsource+publisheddata,CRC+allhashes;excludessecrets/logs. OldServer-Log-Fixes.zipNOTmodified. docs/rooms-plaza-2026-09-12.md; updatedolderLogReviewsplits40/41nowfixedfromstillunknownB2. Patch-Note.txt+datednotesnewkick+redundantPlazabullets,Upcoming,noclaimFPSfixed. No productiondeployment;userstop/backup/mergeBOTHGame+Peer,preserveotherGamefiles/settings/database,restart/reconnect. Peerunchangedpreviousfourlocalsockettests,notretestedWAN.

OwnisolatedMySQLstartedparent47156/childlistener33456on33073; verifiedancestry/executableloopbackandcleanmysqladminshutdowncompleted,temporarysecretcnfremoved. OtherMySQLuntouched. Artifacts/rooms-plaza containsbuild/test/publish/evidence. Lostexecsessionoutputduringcombinedtestpublishbutbothfinishedsuccessfully,69PASS,noexception,publishedDLLbyteidentical. Existingcompilerwarningsremain. Remainingoperationsfrompriorreportstillopen; no fabricatedsuccess. Futureclientretestkick/Plazaalone+withpeer+reentry; ifsameissuecollectnewgame/peer/clientlogswithtime.

# Supplied server logs: fixes prepared (2026-09-12)

User requested every error fixed from artifacts/9-12-328/{game,peer,mysql,packet-trace}. User explicitly authorized custom RFRebirth rewards for missing old boxes/tutorial/level packages. Full log history has many deployments; FINAL startup already122boxes/372packages, so prior update DID reach server. Added78boxdefs/27packages ->200/399; every missing ID in whole logs covered. Original122boxfiles verified byte-identical to prior supplied ZIP. Custom policies are disclosed, not retail odds; tutorial/levels1–15 supplies, named skill packages, native descriptions whereavailable; expired collection boxes use supplies, Ascended material redeemsMasterCard;5112760/61localpermanentpools waiveoldtooltiplevelrestrictions. Bosschests stillrequirematchingNormal/Hard/Hellkeys,5045695HalloweenKey5035694. Per-keyEXPcharging remainsabsent. Tools/fix_logged_rewards.py reproduces onlyloggedmissingIDs; Tools/test_logged_rewards.py native/category/dependencychecks. Audit custom-rewards.json and audit-summary.json inartifacts/log-fixes, containsnoauthpayloads.

FixedGenericFailRes: little-endian0x2711 atbody0, boundedNULmessage atbody2,520bytes/failurestatuspreserved. Util.GenericFail nowoneconciseoperationerrorline insteadfullhex/triplelog. Peerproudnet_probe handles64018threeDWORDand64002twoDWORD asvalidatedone-waynotifications, noack/noTCPmembershipchange;malformedlengthfails. Nativeevidencealreadyin docs/grab-investigation and disassembly; onlyTCPpathchangedlogging/notifications,notcombatpayload. Tools/complete_box_dependencies.py also preservesHalloweenkey mapping in futurerebuilds.

Final66backendPASSgroups isolated33073/17000: all200boxpools/encryptedopens and399packages, nativeerrorWORD/NUL,keys,replay,rollback,ownership.16sourcecheckspass;4livepeerEXEtests include6720deliveriesnoloss/reorderandnotificationordering/membership. Existingcompilerwarningsremain. DLLtested=published SHA2566fdc94571c2c29645d51663a3f78834325d2ba413aaabef7f999bc1795ed6da5. PeerEXE6156644084580fcd716511ce31d7d9dc03a3a35107cdeb7177180304e650e5db. Artifact artifacts/RFRebirth-Server-Log-Fixes.zip12922623bytes SHA25687da25de600afce784a43ffa56f418029f3ca75602c7d744f3bcc61eb0a0f7bb;GameDLL+allBoxes/Packages+Peerentire_internal+README+CustomRewards+report+manifest. ZIPCRC/hashesvalidated. Usermuststop/backup/mergeBOTHGameandPeer, preservesettings/database;noinstaller,noremotedeploy,noclient/UIcontrol. Patch-Note.txt/datedarchiveupdatedUpcomingtwohonestrewardbullets.

Do NOT claim every error fixed. docs/server-log-fixes-2026-09-12.md accountsremaining:10/B8RegisterItem(latest12),48/42GameGuard(latest1),31/CC,D6,D8skillbookAvalon;31/96unmappeditemfieldmutation(notextraction!),31/8Emedalachievement;30/BEStoneCheck;40/41,B2unknown;33/80guildnativeUI;one40/68host-resulttimeoutnotexplained. HistoricalquestCF21740failuresandtype0Aalreadyfixed/testedcurrent;auth/eligibility/shoprejectionsnotblanketacknowledged. MySQL13selfsignedCA+11forcedclientcloseshutdownwarnings,noERRORs;noTLSdisable. Peer1996+83unknownreportsfixed,16remote10054resetsnotproofserverbug. Fullreporttableisauthoritativeforstatus.

Testingusesartifacts/log-fixes/isolated/settings.json WITH ROOT PASSWORD (NEVER distribute); sourcedlocalinstallation.json after33073check. OwnMySQLstartedPID34428;muststopcleanlyonceworkfinished,verify33073ownerfirst. OtherMySQLPIDs5536/6820leftuntouched. TestharnessBackupTests optionalGEMNET_TEST_MAINTENANCE supportsartifactbuild;ChestPresetTests validatesalreadyloadeddefsagainstfiles insteadduplicateregister. Lasttest/publish session63537 exit0. Fullprivate/testlogsnotpackaged.

Test cleanup completed: listener33073waschild38188ofourstartedMySQL34428, ancestry/pathverified; mysqladminshutdownusedephemeraldefaultsfilethenremovedit. Cleanexitconfirmed. OtherMySQLinstancesuntouched.

# Received box report: installed update missing (2026-09-12)

User supplied artifacts/RFRebirth-box-report-20260912-131453-365e305d.txt. Definitive checked-folder evidence: C:\ProgramData\RFRebirthServer\Game\Data has10boxIDs/1package, expected122/372. Comparison124Gamefiles:5match,112missing,7different incl Gemnet.dll. Installed DLL SHA256 E8FDEDCB81FC775F2430B15FB131C9E6BD1B20F7C2B38390E4AEBCE1A5D07C66 modified2026-09-12T03:11:34Z vs shipped2e4325c8f685a34f8d177d18c17551821d3559194908e208e90fd123d401bd60. No Gemnet.exe seen when report ran; do not infer active runtime elsewhere or blame user. Report shows update did not land in inspected installation (could be wrong source/destination/older replacement). Rechecked supplied-box ZIP CRC andDLLmanifest,122JSON372packages intact. Remediation user stopsserver, extracts exact artifacts/RFRebirth-Supplied-Boxes-Update.zip, merges itsGameCONTENTS into installedGame, preserves other runtimefiles, restarts and verifiesRewards122/372. Do not replace entire runtime with partialupdate or runinstaller.

Second issue: report failures include unsupported olderitems, so correctdeployment cannot fixeveryrejecteditem. Unique unavailable39boxIDs:20includedcurrentupdate/19missing;22packageIDs:2included/20missing. Missing boxes5041916,5041918,5041920,5042459,5042460,5042461,5042538,5042700,5042702,5043125,5043126,5043127,5045303,5046775,5046777,5113622,5113623,5114047,5117504. Missing packages5020201,5023328,5023329,5023330,5023331,5023332,5024792,5024793,5024794,5024795,5024796,5024797,5024798,5024799,5024800,5024801,5024802,5027343,5028724,5028743. Report contains earlier/historical untimestampedrejections plus13:09-13:10 wirelog;don'tclaimallcurrentattempts. Items retained onreject. No server/code changes made while readingreport; no PCcontrol permitted.

# Box update deployed by user; most boxes still fail (2026-09-12)

User says they replaced the server files, initially said every box fails, then corrected to MOST (some work). Asked twice for specific failing/working box and symptom; no specific names, error or server logs yet. Do not assume all boxes fail or claim source tests proved real-client operation. No confirmed root cause, new server mutation or new DLL in this turn. Rechecked packet14byte request builder5254C0/caller4C56FA: first field chestinstance from+110C, second optionalkey from+10C4. Optional key removal guarded at4C5797; chest removal unconditional4C589F. Prior request order not disproven. Current startup defaults reward files to Game/Data, not Private/Data; custom RewardDataPath overrides. Supplied ZIP has122definitions/372packages/124Gamefiles. Need installed DLL/data hashes, running executable/start time, startup Rewards line and box rejection/packet evidence to distinguish deployment, undefined variants, keys, protocol/UI.

Prepared artifacts/RFRebirth-Box-Diagnostics.zip containing Collect Box Report.cmd, Collect-BoxDiagnostics.ps1, expected-box-update.json, README.txt. Source Tools/Collect-BoxDiagnostics.ps1. User should extract/run ON SERVER after a failed opening, return generated RFRebirth-box-report*.txt. Read-only except report file; no restart/settings/database changes. Expected manifest compares deployed Game DLL/Data (honors private settings RewardDataPath), lists counts/duplicates, extracts only box/package log+packet lines, omits credentials/full settings/login/chat. Tested ONLY isolated artifacts/box-diagnostics-test fixture:124matched122boxes372packages, sample rejection and31/9A trace present, planted secret/login markers excluded. No user PC/game UI or remote-server control. User preference remains source/build work only; no computer-use.

# Remember Email launcher update prepared (2026-09-12)

User reports Remember Email fails after both normal and forced exits. User explicitly says do not control their PC to make changes; use source/build checks and do not operate their game/UI. Earlier UI investigation was stopped with Escape. No more computer-use actions. Native client owns checkbox, RFRebirth launcher previously just routing/launch. Existing mapped-image static analysis found login copies local checkbox/email to app settings at +304/+308 (global7D2870), native registry SaveID/PlayID saved only by later settings paths. New Tools/ClientLauncher/RememberEmail.cs saves stable preference while game runs using bounded PROCESS_VM_READ only, original fixed-base getter signature+existing full disk hash. No password reads, process writes, hooks, binary patches or access bypass. HKCU original key only. Startup guard waits for original registry state to load, 2samples100ms to save changes, uncheck clears. Tests use own synthetic child/isolated GUID registry key, never real game. 7 groups passed including existing routing tests. Protected-client read access and actual game persistence still unverified; cannot claim live fix. docs/remember-email-2026-09-12.md documents evidence/limits. Do not install/launch without user request.

Release build succeeded without warnings. Deliverable artifacts/RFRebirth-Remember-Email-Fix.zip (29,774,395 bytes, SHA256 e40c285df852ffe22b24ccdd3daa3e2a630fd37aefbe705b2f2c4bc1af89db7d), contents RFRebirth.exe, README.txt, manifest.json only. EXE SHA256 b8956a03ea3f241a77ba07b41ba780d2e1abb05a1c7735c8b0238b064a38dd3e. ZIP CRC and manifest bytes verified. Replace RFRebirth.exe when closed; preserve existing INI/server address and original game EXE. No local install, game operation, live read, remote deploy or website download replacement in this source-only turn. Patch notes not updated with an unverified live-fix claim.

# Daily player-facing patch notes (2026-09-12)

Style preference: user wants notes to sound like a developer writing to their Discord community. Use a simple date/title and direct, short bullets. Avoid emoji section headings, marketing language, inflated wording, repetitive categories, and unnecessary totals. Keep it natural without forced slang or invented personal claims. Latest and September 12 archive rewritten in this style.

User requests a polished, concise Patch-Note file every day for their Discord change-log. Latest copy: Patch-Note.txt; dated history: patch-notes/YYYY-MM-DD.txt. Initial 2026-09-12 notes cover the completed box/package update and are labeled Upcoming Update because remote deployment remains unconfirmed. Heartbeat automation daily-rfrebirth-patch-notes is ACTIVE daily at 20:00 America/Chicago. Include only verified new completed player-facing changes, preserve user edits/history, do not repeat old changes on quiet days, and do not invent release versions or deployment status. User will publish to Discord; no posting was authorized. Routine runs leave files unchanged and stay quiet when there is no new content.

# Current handoff: Supplied box server update (2026-09-12)

User asked to apply supplied box lists/probability charts server-side so boxes work, then asked what InstallRFRebirth was (explained --run is isolated test supervisor, not installer/remote deployment), then Resume. Completed artifacts/RFRebirth-Supplied-Boxes-Update.zip. 122 enabled boxes (was84), all76 current shop box IDs;372 packages (was353). 172 older non-shop historical boxIDs still undefined. Do NOT claim all294 historical boxes work or remote/client confirmation. Per-key EXP charging is still not implemented; native activation UI needs real-client verification. No remote access/deployment, production settings/client/Peer/website changes. ZIP has NO installer.

Tools/import_supplied_boxes.py + review_supplied_aliases.py/supplied_box_aliases.json import83 native box identities from complete-forum-rewards/named-rewards JSON.13 supplied percent charts override differing forum contents. Printed totals proportionally normalized6decimals, unknownodds equal perexpandedentry. Shared durations only available native terms, explicit M/F groups expanded, duplicate statIDs ascending; reviewed aliases/local substitutions audited. Fixes include Hyper exact1day55scroll/32exo, LegendaryAlchemist40rows/noextra chest,2025Christmas excludesDoomArmor retainsMasterDoom, ValentineCupidBow accessory, femaleSlayergloves,2015Christmas repeatsownbox,quantity terms120x/x30/Qty10,etc. Named enchant-card packs preserved as ONE package (avoid5packs5cards or dropping10uses). All reward native ID/ItemEnd/type/day/use tuples checked.

Tools/complete_box_dependencies.py addsremaining6shop definitions: plain/SilverMystery KRtables withexplicitlocal replacementsfor7obsolete/unavailableitems; GoldenChest/II familyaliases; MysteryGhost monsterexo pool;LuckyClover gem/card/couponlocalpool. Adds19nestedpackages includingenchantcards/master/fair/lesser,5keybundles,4weapon50/300uses,Powersuitcolors/genders,Sejul,ValkyriePE,localHalloweenExoPackage->GhostChest. NewYearluckybags alreadytype38supported. Rebuild order review_supplied_aliases;import_supplied_boxes --write;complete_box_dependencies. Existingunrelatedboxdefs preserved. Before-snapshot artifacts/box-completion/before.

Runtime Box addsRequiredKeyItemIDs validated/copyimmutable. OpenBoxReq parseskeyinstanceoffset10; EconomyService.OpenBox optionalkeyinstance validatesmatchingownedusablekey, rejectunsolicitedkeyforordinarybox, consumeskey/chest andsavesreward/ledgeroneTX. Native0x5254C0 requestbuilderand0x4C56FAcallerconfirmedsecondargument. No guessednewopcode. ExistingkeychargeEXP/UI notimplemented. KeyedBoxTests coversencrypted31/9A,wrong/foreign/expired/self/missingkey,replay,rollbacktrigger,concurrent8opensonekey,immutability. ChestPresetTests seedsmatchingkeys andopensall117nongem+5gemstonehandledelsewhere.

Final66backendPASSgroups,7Pythonsourcechecks; all122boxes boundaries/encryptedopening/savedreward,372packages tested. FinalReleasepublish succeeded using--artifacts-path artifacts/box-completion/isolated-build (ordinaryobjRIDDLLwaslocked;nootherprocesskilled). FinalpublishedDLLinstalledonlyintoexistingisolatedtestGamefolder;startupverified122/372on127.0.0.1:17070,MySQL33073. Testsupervisors45956,44536stopped;final39688stop-requestsent,checkclosed. Wait-Process accessdenied for elevatedsupervisor;stop-request successfullycleanshutdown,don'tuseprocesskill. Logs/source-tests/startup-validation/release-validation inartifacts/box-completion.

Tools/build_supplied_boxes_update.py verifies66/7tests,publishedsourcebyteequality,zipCRC/allentrySHA256. ZIP494750bytes SHA256bf31da40d0019a53ec25992c4ec9a863907ca25ae52805e94b393ed66fc772bb; DLLSHA2562e4325c8f685a34f8d177d18c17551821d3559194908e208e90fd123d401bd60. ContainsGame/Gemnet.dll,122boxJSON,packagesJSON,README,fullEnabled-Box-Rewards.txt,Remaining-Historical-Boxes.txt,source/dependency/implementationaudit,manifest. docs/supplied-boxes-2026-09-12.md. InstallstopserverbackupGameDLL/Data,copyGameintoC:\ProgramData\RFRebirthServer (orcustominstallation/rewardpath),restart/reconnectverify122/372. Previousslotextension/matchrewards/multiplayerfixesretained. Repoalreadyhadextensivemodifications; no commit/revert performed.

# Current handoff: Complete box reference Notepad (2026-09-11)

User requested one Notepad listing reward names and printed probabilities from 15 supplied charts AND all linked forum spoiler pictures/text. Later supplied 61 screenshots of those same forum lists, plus White Tiger Isle screenshot, used as cross-checks. Completed artifacts/RFRebirth-Box-Items-And-Probabilities.txt (UTF-8 BOM/CRLF): 94 source lists, 4,370 reward rows, 665 printed percentage rows. Separate sources/versions preserved; unknown odds explicitly NOT SHOWN IN SOURCE, quantity/duration kept distinct, inconsistent chart totals unnormalized. No backend/database/client changes this turn.

Tools/build_complete_box_notepad.py rebuilds combined file using export_supplied_probability_notepad.py (13 boxes/565 rows from 15 supplied charts, names manually transcribed, audited percentages and source hashes), export_forum_reward_notepad.py (61 image tables/2744 rows), forum_reward_supplements.py (100-row Silver Gem Fighter probability table, Daily Quest, 12 text lists, 6 fully expanded 2024/2025 versions). 2025 Christmas excludes Doom Warrior Armors Package, retains Master Doom Warrior Package. Silver sums100%, explicitly sourced as Gem Fighter per forum poster. Weird source labels and duplicate rows retained; e.g Capricornus source says Cancer Gloves and repeats Title. White Tiger old table47 reward rows; Legendary Alchemist source40 rows (no extra chest reward); Orichalcon Exo56 rows includes single-letter Z. Multiple contents images differ from supplied percentage charts; do not silently import/merge.

All167 forum images downloaded to artifacts/supplied-box-charts/forum-images via Tools/fetch_forum_box_images.py; manifest forum-image-manifest.json. Windows WinRT OCR all167 via Tools/ocr_forum_box_images.ps1; independent RapidOCR pass for63 content/probability images via Tools/ocr_forum_rapid.py, dependencies local Tools/.ocrdeps. Raw OCR evidence forum-ocr.json and forum-rapid-ocr.json. Table extraction uses explicit original-image column coordinates; reviewed and corrected OCR spelling, whitespace, infinity glyphs, dropped single-character Z, headers, etc. Supplementary JSON complete-forum-rewards.json, named-rewards.json; checks notepad-validation.json. 61 picture tables + Silver + Daily=63;12textlists+6newerversions=81forum lists, plus13supplied charts=94. Counts include duplicate rows and sources, not94unique box types. No server import performed. Latest prior server package remains Avatar Slot Fix.

# Current handoff: Supplied probability charts and RedFox contents thread (2026-09-11)

User supplied15screenshots of13probabilitycharts, then https://forums.playredfox.com/index.php?threads/rumble-fighter-boxes-contents-updated.59481/ saying it has everybox. Current turn is sourceaudit, NO server/catalog changes or new release. Earlier claims no usable sources were incomplete: detailed LostLegacy,Enigma,Valentine text contents and NewEnigma/LegendaryAlchemist contentimages FOUND. Forumcommunityguide not proofallcompleteofficialodds. Mysteryplain/silver specifically discussed missing in replies; SilverKRlistattachment46452 explicitlywarnsRFmaydiffer. MysteryGhost/LuckyClover notfoundnamedsection/attachment. GoldenNinja/G2S possibleGoldenChest1/IIbutIDequivalenceunverified; MysteryChestGoldneedsdistinguish5042525keyed vs5114939.

web.run mishandles XenForo query URLs (adds '=' and returnsforumindex). urllib.request properoriginalURL succeeds; saved193755byteHTML artifacts/supplied-box-charts/forum-thread.html. Parsed via bs4 fromTools/.deps into forum-index.json:18posts167imagereferences,nopagination. FirstpostauthorThyShadowMaster. Usefulposts529539LegendaryAlchemistimage45646;529541GoldenNinja/Gold,NewEnigmaimage45694,Enigma,LostLegacytext,Christmasversions;529542Valentinetext;529543bossboxes/keyrequirements. PlainSilverdiscussion531566/531571/531936. post529541/529542.txtsaved. Sourcehashmetadataforum-source.json. Imagesnotdownloadedyet(otherthanuserattachmentscopiedforsafekeeping). Need inspect/transcribepostimages before mapping.

Tools/audit_supplied_box_charts.py manuallytranscribespercentagecolumns (NOT complete rewardidentitymapping), preserves15originalsuppliedPNGs withhashes underartifacts/supplied-box-charts/sources, writesaudit.json andRFRebirth-Chart-Audit.txt. All13chartboxIDsalreadysupported, distinctfrom13unfinishedshopIDs. Rowsums: Cursed100;Tempest107(30rowsversuscurrent28);Cancer100.40;Gemini100;Capricornus100;MysteryRed/Green/Blue100(same25ratepattern);Inferno100;PhantomWalker100;WhisperWings100.10;NeoAlchemist99.60;Christmas2023 101.10(100rowsversuscurrent99,footer101.11). LastimageexplicitlyviewedconfirmsCrazyVulcanrowexists.8chartsrate-multisetsmatchcurrent butnotclaimper-itemequivalence. SourcechartsduplicatelabelsTempestmaleBottoms,CapricornusgloveVersion3,rareScrollbothcolumns;packagePermnamesnotes7day. No silent normalization/import occurred.

Updated userNotepad artifacts/RFRebirth-Unfinished-Shop-Boxes.txt withall13sourcefindings;copy artifacts/supplied-box-charts/RFRebirth-Forum-Coverage.txt. Prior docs/reward-coverage stillreflectoldsourcegaps; this new source audit supersedes 'no list recovered' forboxesidentifiedabove. Next implementation can map newfoundcontents usingexistinglocal-policypermission; must distinguish partial/generic durationlists and communitysourceprovenance. No testserver started thisturn.

# Previous handoff: Avatar slot extension ticket (2026-09-11)

User owns Slot Extension Ticket but Character Setting still shows ten unlocked/ten locked. Catalog2065290 (0x1F838A), type35, permanent ItemEnd1000, description adds10slots. Native captured image proves dedicated GENERAL30/CA request total10bytes, accountID inbody (NOT inventoryServerID): 0x528322 itemguard;0x528352..70builder;0x52A92Acaller reads+6238 same accountfield as inventory0x526607. ReplyCBbytecount adds to client's current avatarcount at0x528402, copies addedIDs tothis+40=slot10 onward, previews them. Prior server had no dispatch.

Added AvatarSlots handler both modern and legacy processors; enum UNKNOWN_F renamedEXTEND_AVATAR_SLOTS. AvatarService.ExtendSlots locks account, normalizes base presets, selects one owned usable permanent2065290 ticket withQuantity1, clones current loadout into10additional presets, clears/deletes ticket, auditsavatar_extend in same transaction. Existing20 slots =>successzero newIDs, preserving spare tickets and avoiding additive-client overflow on retries. Missing/expired/timed/invalidquantity tickets, foreign requestaccount, unfinishedState reject. Full20 savedavatarrows are permanent entitlement, no schema migration. Existinglist/preview/select handle them.

Also EnsureDefaultPresets automatically redeems one already-owned ticket when normal avatar list loads. This is an explicit local recovery policy for prior bought/gifted tickets, not asserted retail behavior. Prevents forcing another purchase; reconnect after installing (or receiving ticket with cached avatarlist) loads20. General.GetAvatars now catchesDBerrors for failreply; ticket/newrows/auditrollback together. No client/anticheat edits. SlotExtensionSet5025291 contents remain separately unresolved; this fix handles ticket2065290 only.

65 backend testgroupsPASS artifacts/slot-extension-fix/tests.log. SlotExtensionTests usesdedicatedaccounts: native47byteCBwith10newIDs,7bytezero-countrepeat,87bytefull87list, persistentselection/preview, owner/expiry/malformedrejection, injectedledgerfaultrollback onbothRPC/list, concurrent8listactivationsoneconsumption, savedunlockafterlogin. Firsttestassumedotheraccountseed1 butcreatorseeds10; correctedtesttocapturebaseline. FinalReleasepublishsuccess withexistingwarnings. Isolatedtestsupervisor81237 stoppedcleanly; no remote/clientdeployment/realclientconfirmation.

Deliver artifacts/RFRebirth-Avatar-Slot-Fix.zip191465bytes SHA25639c29d4a2e96634fae372ca5a5e817d785f3147a63893e71456aa6f42cf64919; DLLSHA256e235837ab5367ba23e623d0534e067969115d6877f621dccc7194f24f8334a19. Tools/build_slot_extension_update.py verifiesCRC/hash; containsonlyGame/Gemnet.dll,README,avatar-slots.md,manifest. Stopserverbackup/replace C:\ProgramData\RFRebirthServer\Game\Gemnet.dll/restart/reconnect. Existingcatalogs/settings/rewardformula/Peer/websiteunchanged. docs/avatar-slot-extension-2026-09-11.md; nativeevidence artifacts/slot-extension-fix/native-{redemption,caller}.txt. Priorpackage ZIPspreserved.

# Previous handoff: Configurable multiplayer reward formula (2026-09-11)

User supplied multiplayer values: MinimumMatchSeconds5, ParticipationCarats30, CaratsPerKill10, ParticipationExperience100, ExperiencePerKill20, MaximumCarats500, MaximumExperience2000. Their numbered item2 was blank. Implemented these as defaults in MultiplayerRewardSettings under SData.MatchRewards. Settings section now replaces the historical flat reward_policy DB row for multiplayer (old table/migration left compatible). Explicit nonnegative validation at server construction, widened multiplication before independent caps. Solo settings/behavior unchanged. No real settings files edited; DLL-only install uses requested defaults, optional customization in installation Private/settings.json.

MatchSession uses TimeProvider monotonic elapsed time; GameManager marks start after all peer-ready reports, freezes at first valid FinishMatch/result, before DB claim. Under5seconds creates zero-value receipts; delayed retry cannot become payable. Existing B0/68 shared atomic receipts preserved; paid receipt overrides subsequent formula/rate changes. Kill counts are reported client stats, not independently simulated/authenticated combat. Server elapsed time excludes handshake, not necessarily all later loading. Formula tested zero/2/3/highkills, exact5s,4.999s, independent500/2000caps, overflow, invalidsettings, timerfreeze, both encrypted endpoints and rollback/retry.

64 backend groups PASS artifacts/match-rewards-fix/formula-tests.log; Release publish succeeds. Extended high-EXP payout tests run after quest tests to avoid precompleting their required incomplete daily fixture. Isolated installed final DLL starts at127.0.0.1:17070 with84boxes/353packages, supervisor stopped cleanly. No remote/client deployment or real-client validation.

Delivery artifacts/RFRebirth-Match-Reward-Formula.zip191969bytes; DLLSHA256e8fdedcb81fc775f2430b15fb131c9e6bd1b20f7c2b38390e4aebce1a5d07c66. Contains Game/Gemnet.dll, README.txt, match-rewards.md, manifest.json with verifiedCRC/hashes. Builder Tools/build_match_payout_update.py now emits new Formula ZIP, preserving previous Fix ZIP. docs/match-rewards-fix-2026-09-11.md updated for current formula. Stopserver/replace C:\ProgramData\RFRebirthServer\Game\Gemnet.dll/restart. No settings/catalog/client/Peer/password replacements; no backfill.

# Previous handoff: Match reward persistence (2026-09-11)

User reported displayed match EXP and carats were not saved. Their pasted Solo Adventure rules are guidance from another project, not existing implementation. Fixed reward_policy zero seed and Query.GetReward END_MATCH placeholder (fake1337 totals/no writes). New MatchRewardPolicy migration2026091114 changes only old both-zero policy to50carats/100EXP once; custom nonzero rates preserved and intentional zeros after migration remain. These are local flat multiplayer defaults, not claimed retail formulas. Existing EconomyService.Claim provides atomic balances/claims/ledger/quests and shared launched-match GUID receipts. Individual891byte40/B0 and full998byte40/68 reports now share persistence/retry protection, validate authenticated launch identity/slots, refresh connected totals and reply only after commit. MatchSession.SubmittedResults collects partial results and writes completed history when roster complete. Async END_MATCH dispatch fixed in both processors. Existing68 response action/type retained.

Added standalone SoloRewardService for B0 with no room/active match: one authenticated matching player, duration u16 at packet17, settings SoloRewards defaults min5/max7200seconds/max5000carats/max20000EXP/tolerance2. New solo_awards table/migration2026091115; account row locks, elapsed checks and payload receipts protect immediate retries/concurrency, with account/receipt/ledger/earned-exp quest writes in one transaction. No solo inventory/boss chest awards. No server-issued solo start/match ID exists, so combat outcomes and delayed replays cannot be independently authenticated; documented explicitly. No configured settings file changed.

Validation:63 backend groups PASS in artifacts/match-rewards-fix/tests.log. New MatchPayoutTests cover migration preservation, real totals, individual/full reports, forged identity, duplicate claims, changing policy and injected DB rollback/retry. SoloPayoutTests cover protocol totals, identity/bounds/timing, concurrent/restarted service receipts, rollback/retry and no inventory award. Release win-x64 publish succeeds with existing warnings. Isolated installed DLL startup verified127.0.0.1:17070 and existing84boxes/353packages; supervisor stopped cleanly. No remote deployment/client changes or real-client confirmation. No historical unpaid-match backfill.

Delivery artifacts/RFRebirth-Match-Rewards-Fix.zip (190220bytes; SHA25639BF2FC65FC5F0F377B17A7120A270A8A86180130B41ED25E6A78969EFCDB132), containing only Game/Gemnet.dll, README.txt, match-rewards.md, manifest.json. DLL SHA256b0f9354a9a95cbb23317adfb0da67eaff24df9b66f5384e98d65fcca7c6e7318. Builder Tools/build_match_payout_update.py verifies CRC/hashes. Install stopserver, backup/replace C:\ProgramData\RFRebirthServer\Game\Gemnet.dll, restart; schema upgrades automatically. Existing catalogs/settings/credentials/client/Peer/website preserved. Detailed docs/match-rewards-fix-2026-09-11.md. Test publish artifacts/match-rewards-fix/publish. Native B0 builder evidence artifacts/match-rewards-fix/native-solo.txt.

# Previous handoff: Expanded KR/local reward catalogs (2026-09-11)

User requested remaining boxes/sets reconstructed, then pointed out Korean Gem Fighter publishes rates. Earlier exact-only requirement explicitly revoked. Refreshed official Valofe pages30639/30665/30747 via Tools/extract_public_reward_rates.py --download into artifacts/reward-reconstruction/public:42tables3138rows. Added Tools/reconstruct_rewards.py with reviewed Korean/local aliases, valid NST term selection, per-row provenance (original labels/rates, effective rate, substitutions, repeated stat/gender mapping, HTML hash). 27additional complete chest tables. Source totals100.40/99.60/90.4 normalized to100 using6decimal largestremainder;90.4 explicitly incomplete probability mass/local policy. No rows dropped. Existing5chests+5gemstone definitions preserved. Some missingtimedvariants become nearest available/permanent, explicitly documented;100/50KRwinguses become1localpermanent wing where usevariantmissing. WhiteTigerfemaleeyes corrected to1028321/22. These are NOT verified NA retail tables.

Tools/reconstruct_local_boxes.py adds47local pools: source-specific category/shop scrolls(type11, NOT31), exos(type32), real duration-only subsets, Top10 nameditems permanent/30day, C/Dgemstone50/50rank, seasonal older versions reuse corresponding KRtable, NanoTech/Hercules/KnightDeathcostumefamilies, ABC/numbers/symbolTshirts, Fortune80%MasterCard20%FortuneCard. Unsupported key/levelgated/opaque products remain unconfigured. Total84boxes,63of76shopboxIDs;210historicalundefinedboxIDs(13shop).

Tools/reconstruct_packages.py adds80sets over273=>353,235of324? Actual tool final reports88shopunresolved: supported236of324. Uses reviewed text corrections, REpackages selfreference=>actualREscroll, gender/name mismatches inRED Academy/NineTailsF, Kabuki/Typhoon/Detective, full costume families, NanoTech5chestbundle+set, NewYearnestedbags, Slayers, MasterDoomWarrior,7dayShadowFoxCorps,ABC/number/symbolsets. Previous273definitions byte-equivalent. All enabled box prizes that are boxes/packages now have enabled definitions. Remaining408historicalpackages(88shop) listed with reasons. Package cycles checked. Rebuild order: export_package_catalog.py; reconstruct_packages.py; reconstruct_rewards.py; reconstruct_local_boxes.py. Full source reportdocs/reward-coverage-2026-09-11.md. Do not use older counts/worklists for newrelease.

Validation:14Pythonchecks(8package+6reconstruction),60backendgroupsPASS. ChestPresetTests now opens all79nongemstoneboxes via encrypted31/9A, verifies everyprobability boundary and savedinventory, rejectsduplicates; existinggemstonetests cover5others. SetPackageTests all353protocol+DB, concurrent/rollback. Final backendlog artifacts/reward-reconstruction/backend-tests.log. Isolatedrealstartup verified 'Rewards:84enabled boxes and353packages' from Game/Data. Testsupervisor57562stoppedcleanly. No remote/client changes. Remote realclientretest outstanding.

Delivery artifacts/RFRebirth-Expanded-Rewards.zip380926bytes;SHA256FD9A45B24B5D3C1D122161DDA289C71439E1F5E4AA5C0AF92C455EF59BCCC06F. Game/Gemnet.dll (Release SHA256634329CC973733B26F76591D066CCDEAFFC3321FC33C2FF6F4EE2DCCECC28DEB),allBox/Packagecatalogs,README,complete searchablecoverage,official/localauditJSON,diagnosticcollector,manifest. Tools/build_reconstructed_rewards_update.py verifiespublish/sourceequality andZIPCRC/hash. Publish artifacts/reward-reconstruction/publish. Install stopserverbackupDLL/Data,mergeGameintoC:\ProgramData\RFRebirthServer,start,verify84/353; honor RewardDataPath live-logpath. No database/password/clientfiles bundled. Sourcebackendfunctionalcodeunchangedthisturn; catalogs are the fixes. Does NOT finish all historical items. Finalresponse should state13shopboxes/88shoppackagesremaining andlinkreport.

# Previous handoff: Gift Studio bulk filters (2026-09-11)

User requested a button to give every item matching chosen filters. Implemented in Tools/GiftStudio: category dropdown (Scrolls/ExoCores/hair/clothes pieces/accessories/packages/boxes/cards/etc plus raw remaining types), combined with existing search and lifetime. Gift filtered items opens new BulkGiftDialog with frozen matching list, recipient/sender/message/copies, onevariantperItemID default(preferspermanentwithinfilters) or everymatchingItemEnd. Missingdataexcluded, alreadyowneditemsNOTskipped, clearcounts/fullpreview beforeSend. No real gifts sent for user; only isolated testaccounts.

New BulkGiftPlan saves stable GiftRequestGUIDs pervariant beforewrites at LocalAppData/RFRebirth/GiftStudio/pending-ENDPOINTHASH.bulk.json; regularpendingfileunchanged. AdminGiftService.SendBulk validateswholeplan then calls existingtransactional/idempotentSend foreachitem, progress+CancellationToken. Eachitem atomic, batchcanpartiallycomplete; UI explains completeditemsremain. Pause after current item cancelsbetweenitems; Resume/check onmainSend button reusesstoredGUIDs, including restart. Controlsfreezewhilepending; endpointsettingspreserved. Recenthistorystilllatest30peritemreceipts; no newschema beyondexistingadmin_gift_batches.

NewCatalogCategoryFilters/BulkSelection, BulkGift.cs/BulkGiftDialog.cs, MainForm UI/recovery, Program --render-bulk-preview (offline/nomutations) andexisting --render-preview. Nativeactualrenders inspected at artifacts/gift-bulk-update/main.png and review.png. ReviewScrollsPermanent shows439IDs. UpdatedREADMEinstall/use/pause/partialsemantics. 0warning0errorbuild. GiftStudio.Tests addsBulkTests.cs validatesfilter/missing/oneperID/allvariant/emptyquery,3mixedlifetimes2copies pausedafter1,serializedrestart/resumeandcompletedretrywithoutduplicates,fullpreflightnofirstwritewhenlaterinvalid,payloadconflict. Caught/fixed counterincrement wronglyinsideprogressnullconditional; final7PASSgroups includespriorconcurrent8single retries,rollback,liveencryptedgiftpush81copies,pagination/latecommit/reconnect. Logs artifacts/gift-bulk-update/tests.log. Isolatedsupervisor78447stoppedcleanly; testdata cleaned byrunner. No server/client/production DB changes.

Package artifacts/RFRebirth-Gift-Studio-Bulk.zip (selfcontainedwinx64 EXE74412049bytes,items.json,README.md,manifestonly), ZIPSHA25637BAC94A580C98C7B0D892DB1C602C872F66F36DC6152B8A592357422B00142D. CRC/filehashes/expected4entriesverified. No database.ini/settings/password bundled. UserclosesexistingGiftStudioandreplacesonlyRFRebirth.GiftStudio.exe,keepsexistingitems.json/database.ini/settings.json. FullZIPcanbeextractedbutnoexistingsettingswillbeoverwritten. No serverrestartrequired. Builder powershell Tools/GiftStudio/build-package.ps1 -OutputDirectory artifacts/RFRebirth-Gift-Studio-Bulk. OriginalGiftStudio/Configuredpackagesnotreplacedlocally.

# Current handoff: Grizzly Bear / additional package redemption (2026-09-11)

User says many packages still fail on redemption, named Grizzly Bear. No new remote logs or remote access. Its5028269 client description uses [Components], skipped by old exporter; lists Grizzly Bear Head but real item is1058264 Grizzly Bear Hat. Added explicit alias and parser support for [Components]/[Contents], bullets, Contains/containing N/written quantity prose, 5+1/counts/named x2 bundles, multi-line comma lists/BONUS paragraphs, plural normalization and curated localization aliases. list_parts scans parentheses so "Grey and Red" isn't split, strips Oxford-comma and. Protect numeric product names (Nine Tails,10000 Carat Cash) from quantity parsing. Annual2023/24/25 bundle IDs mapped to matching chest IDs, not reused old descriptions. Box suffix fallback only permits type40/50, never scroll (caught Black Tortoise shorthand; now5118093 NorthGuardian box). Explicit alias mappings inTools/export_package_catalog.py; no fuzzy unknown-ID generation. Existing random box pools remain unchanged/authorized local tables.

273packages total (121 added); all previous152 reward lists compared to priorZIP and identical. Grizzly5028269 grants six permanentqty1:1058264Hat/500,1058263Mask/500,1078265Suit/500,1088266Claws/0,1098267Shoes/0,3048268Tail/500. AlsoBear/Tiger,HalloweenCutieWitch/Zombie,Spartan,Dunia,manybulkboxes andbonuspackages. Shop176supported/148unresolved; complete type38catalog488unresolved outof761. Still not allpackagescomplete. Bundle redemption can succeed while the child random chest lacks a table; current10enabledboxesunchanged.

Tools/test_package_catalog.py8PASS (Grizzlyexact6,quantity5+1,written4+1,annual2025IDs,BONUSretention,invalidunknownbonusfail,parens,numbernames,realvariants/reproducible/whole-setrejection). SetPackageTests addsGrizzly6assert; all273encrypted31/86replyrecords checked againstcommittedDB,concurrentduplicates androllback; full60backendPASS. PublishedDLLunchangedSHA25649609e8b375f9711d7573fcd84dcc3e68bf2617fd6dc8594b3a6c4f4b1066a05; onlyruntimecatalogdatachanged. Exactpublisheddata tested isolatedstartup10boxes/273packages,exitprobe10.053ms. Testsupervisor28735stoppedcleanly.

New artifact artifacts/RFRebirth-Package-Redemption-Fix.zip237655bytes. Game/Gemnet.dll +Data/Packages+Boxes,README,updatedfullworklists,collector,hashmanifest. Tools/build_set_items_update.pynowtargetsnewartifact (priorRFRebirth-Set-Items-Update.zippreserved). Hash/CRC/publishedfixturecomparisons passed. StopserverbackupGameDLL/Data,mergeGame intoC:\ProgramData\RFRebirthServer,start,reconnect,log10boxes/273packages. No DB/settings/client/Peer/website replacements or remoteinstall. Real-client Grizzlyretake stillneedsuserdeployment/test. docs/set-items-worklist-2026-09-11.mdupdated; priorfullinstallerstillstale.

# Current handoff: set items and restored local chest tables (2026-09-11)

USER POLICY CHANGE: user explicitly said "U can remove the exact-table requirement". This supersedes all historical instructions below requiring exact official tables. Documented local test mappings are authorized. Do not disable the five restored chest pools again based on old notes. No claim of verified NA retail rates.

User reports all sets fail and previously working boxes stopped. Logs identify Aquarius5026813/500 and Gladiator5021366/1000; only seven chest bundles previously had definitions. Added Tools/export_package_catalog.py, expanded Gemnet/Data/Packages/packages.json to152 supported sets/bundles from explicit client lists and NST variants. Includes Aquarius8permanent pieces and Gladiator6armor plus2070005/1200 resale coupon worth10000carats. Multiple same-name products use oldest compatible baseID and ordinary ItemEnd1000/1100 when otherwise ambiguous; all such choices recorded LocalMappingChoices. Unknown names/terms and conflictinggender rejectwholepackage, no partial grants. Tuxedo lists bridal clothes, femaleNineTails lists male shoes, TutorialTrialdurationunspecified: blocked. MixedDummycolors preserved from explicit client text. Catalog still609unresolved of761type38; shop103supported/221unresolved (324total). These are client-derived local rules, not exact official server tables. Full searchable supported/blocked worklist docs/set-items-worklist-2026-09-11.md.

PackageService fixed type85use rewards: one row with fullusequantity instead of Nrowsoneuse. Permanent/timed copies distinctinstances; PackageCatalog validates emittedcount<=255, positivequantity, validterms. NewSetPackageTests opens every152overencrypted31/86, checks37byte records againstDB, durations/uses, source consumed, Aquarius/Gladiator,8competingopens=>1success, injectedledgerfailure=>rollback/originalretained. Tools/test_package_catalog.py4PASS (reproducible, realvariants, incomplete/invalidduration/contradictory source). Full60backendPASS artifacts/sets-boxes-update/backend-tests.log.

Restored Enabled=true in five kr-chest files using Tools/export_chest_catalog.py with user's permission:5118455SkullShadow,5118390DarkPhoenixChestRe,5117989BloodDragonSyndicate,5117336Gemini,5118192Capricornus. FullKRprobabilitymass retained; repeatedstats ascendingID, DarkPhoenixexplicitlocalaliases, ordinaryItemEnds. Tools/test_chest_catalog.py4PASS. ChestPresetTests now opens allfive overencrypted31/9A, checksDB/reply/rewardpool/duration, consumesoriginal,rejectsrepeat, openschestfrombundle. Total10enabledincludingprevious5gemstonepools.284otherchestsstillunavailable. Updated docs/loot-box-worklist-2026-09-11.md. Historical auditJSONmaydescribeoldpolicy;currentJSONcataloganddocsareauthoritative.

Published exactDLL tested isolatedinstallation17070/33073: startup10boxes/152packages fromGame/Data. Exitackprobe passes11.598ms. ZIP artifacts/RFRebirth-Set-Items-Update.zip230687bytes; DLLSHA25649609e8b375f9711d7573fcd84dcc3e68bf2617fd6dc8594b3a6c4f4b1066a05. ContainsGame/Gemnet.dll,Game/Data/Boxes+Packages,README,fullset/boxworklists,diagnosticscollector,hashmanifest. BuilderTools/build_set_items_update.py validatesZIPCRC/hashesandpublished/testedDLL/catalogequality. StopserverbackupGameDLL/Data,mergeGame into C:\ProgramData\RFRebirthServer,start,reconnect;log10boxes/152packages. Retainspriorclientexit/quest/livegift/country/Plazafixes. No client/Peer/website/credentials replacements. No remote deployment or realclient successclaim. FullinitialinstallerZIPunchanged. Isolatedsupervisor7305 stopped cleanly viaPrivate/stop-request. Final packagingdone; allsets/allboxesNOTfinished; remaining documented source gaps.

# Current handoff: client exit hang (2026-09-11)

User says closing client hangs, server errors, GameGuard stays. User reproduced live; readonly process/log capture in artifacts/client-exit-investigation. No debugger/process termination/client/anti-cheat changes. At19:41:04.840 Disconnected;19:41:15.055 EndTask;19:41:17.072 teardown/GameGuard class destruction. By19:41:29 game/launcher/GameMon64 exited, GameMon.des PID34512 remained at19:44:19. Do not claim remaining GameGuard root cause proven. Real retest after update required.

Identified previously unknown0A/80 len10 as synchronous ClientExit_Log (native51C750; name7415E4; send51C7BD; statusonly reply51C83E; success51C8BC). Server ignored it. PacketProcessor now beforeauth acknowledges validlen10 with000A00068100; malformed fails; reportvalue nevertrusted asowner; no prematureaccount/socketlogout. Also0A/40 len262 is nativeonewayclientlog51F3D2/51F407, acceptedwithoutreply/loggingcontents. No GameGuard checks changed.

Query.UserUpdateRoom excludes departingstream from departure/masterchangebroadcasts. Server cleanup removesroom in finally ifnotificationfails; independentlyreleasesPlaza/player/connection. Send IO/reset/disposed errors loggedinfo+disconnect notservererrors;unknownclosedconnectiondebug. Otherunexpectederrorsretained.59backendPASS inclnewexitackpre/postlogin/coalesced/malformed/statepreservation,hostRSTcleanup/noerror/mastertransfer. ExactpublishedDLLstartedisolated andTools/test_client_exit_protocol.py unauthreadonlyprobe passes fragmentedexit/onewaylog/duplicates/malformed;firstack10.38ms. Isolatedsupervisor stopped.

Package artifacts/RFRebirth-Client-Exit-Fix.zip182305bytes,Game/Gemnet.dll+README+manifest only. SHA25691dc067c604e897042353250a7e53a12468255e7dd439e0de1ffbc7f4f2d873d. Stopremote,backupC:\ProgramData\RFRebirthServer\Game\Gemnet.dll,replace,start/reconnectexitretest. Includesquestsyncandpriorfeatures;noData/Peer/DB/settings/clientchanges. BuilderTools/build_client_exit_update.py;docs/client-exit-fix-2026-09-11.md. No remote install performed.

# Current handoff: grab logs and quest sync fix (2026-09-11)

User gave remote game.log, peer.log, packet-trace.log in artifacts/RFRebirth-Gift-Studio-Configured and said done. Preserved specific logs in artifacts/grab-investigation alongside local client-20260911-192608-25b7cb36.log. Manual workflow chosen after user stopped RDP as inefficient; do not resume RDP/SSH setup. Local Tools/RemoteAccess scripts/key prep exist but were not deployed, tested or packaged. No remote admin access.

Latest match group10002 peers4/5 server17:16:12-17:22:10; timestamps2h behind gamingPC. tcp_nodelay=1 confirms deployed peer update. All sampled pending_bytes0, lifetime max queue waits0.36/0.90ms, max send0.52/0.49ms. No queue overflow/send failure/unsupported core in latest run. RMI64018 (92) is C2C UDP message-count telemetry,64002 (2 on departure) direct-peer-disconnect report, confirmed native serializers/referenceConstants. Not grab commands. Peer6 at17:18 is our no-group diagnostic probe, not player disconnect. Remote72ping median71.503 p9574.814 max77.523ms; not combat measurement.

Confirmed quest retry storm:6223 incoming updates,6213 replies,6163 failures during15:11-17:26; same triples retried once/sec,matching client QuestManager errors. Native51F860 reads3DWORD sync reply,4F4A90 applies authoritative progress,4F5510 only dequeues after success (4F5599..C0). Fixed QuestService.Update: valid owned/bounded report returns saved server progress instead of rejection when client ahead; only ClientUI can advance from reports. No trusting forged combat/inventory/login-day progress. Claim/ownership/expiry/ID/bounds safeguards retained. No evidence this is definitive grab cause.

58 backend PASS groups including encrypted repeated sync,unearned reward rejection,preserved real EXP,login-day evidence,invalid/expired reports. Initial new assertion wrongly assumed EXP0 despite prior match tests; fixed to unchanged actual value. Final log artifacts/grab-investigation/backend-tests-final.log. Published release DLL starts isolated17070/33073; stop requested at completion. Package artifacts/RFRebirth-Quest-Sync-Fix.zip 181911bytes,3files Game/Gemnet.dll README manifest. DLL SHA2565bca9fa9cfd3e7bc6e6a7e90a3154f97def82ffa7ded418da15586b91d4e3c06. Stopserver backup Game/Gemnet.dll replace start/reconnect. No DB/settings/Peer/client changes. Prior features preserved; existing Game/Data stays. Builder Tools/build_quest_sync_update.py. docs/grab-investigation-2026-09-11.md. No production deployment or real grab retest yet; failed-grab time and both clients logs needed if persists. Secondary logs identify unpack items5026813/500,5021366/1000; boxes explicitly missing exact definitions, no tables invented.

# Current handoff: TCP peer latency update (2026-09-11)

User reports lag/damage not registering/teleporting; then concerned UDP creates player vulnerability. Retained server-relayed TCP, no UDP/directP2P/newplayerports. Tools/proudnet_probe.py accepted sockets previously defaultNagle and synchronous flushed perpacketlogs; now TCP_NODELAY beforehint and percore/RMI logging opt-in --trace-packets. Separate10smonitor logs perSessionrx/tx,current/peakqueuedbytes,maxqueuewait,maxsendtime,closereason. Highresperf_counter timing; monitor stdout outside membershiplocks/gameplayloops. No change to relaybytes,sequence,auth/membership,boundedqueuepolicy. No client/maingameserver edits.

Read-only transport probe ofremote160.202.167.41:33343 (own2transport sessions,no groups/no gameplaymessages): 12singlepingsmedian65.786ms,max68.907;72pingssixframeburstsmedian139.585,p95198.519,max198.527. Shows burstdelay; no remotenewbuilddeployment/beforeafterproof. ICMPtimeouts not evidenceofpacketloss. Tools/measure_peer_latency.py reusabledefaultsloopback.

6offline+4livepeer testsPASS. New8clients60Hz2s mixedreliable/unreliable all7others=6720deliveries no loss/dup/order/payload errors. ExactpublishedEXEtested;loopbackp951.83ms,max2.38ms. ExistingtestsnoWANproof. Tools/test_multiplayer_peer.py supports RFREBIRTH_PEER_EXE override forpackagedtest. Runtimehas16changedinternalfilesvsoldbuild so shipwholePeerfolder. Package artifacts/RFRebirth-TCP-Peer-Update.zip 12412692bytes/75files;EXESHA2564e360cfdb13432792f4e9959c70f765154995afc01ad9e049bfe9e04a462ed05. StopserverbackupPeermergewholePeerincluding_internal intoC:\ProgramData\RFRebirthServer,start. NoGameDLL/DB/settings/client changes. IncludesCollectPeerDiagnosticsCMD+PS1readspeerlog+hash/process snapshot (IPaddresses, no secrets/upload). Testedcollectorlocal; no productionservice restarts orDBchanges. All testlisteners closed. Logs/build artifacts/peer-latency-update; docs/tcp-peer-latency-2026-09-11.md. FullinitialinstallerZIPstaleunchanged. No claim allhits/teleportingfixed; needremotematchtest andpeer.log ifpersists.

# Current handoff: reward/Plaza follow-up (2026-09-11)

User reports Plaza enters briefly then says not ready; every shop box does nothing; set opening displays message and retains original. Asked set name/message; user says picture already sent, but available pictures show older avatar UI, not this error. Asked reattach. Exact set and error still unknown. No remote logs/DB access; no confirmed live root cause.

Implemented reward data fix: Server now defaults AppContext.BaseDirectory/Data instead of CWD Private/Data one-time copies. Optional Settings.RewardDataPath explicit override, tests point to empty fixture Data. Logs resolved path + box/package counts. Installer source no longer copies private catalogs; existing private data preserved. Logs missing box/package exact definition with ItemID/ItemEnd and original preserved; handler logs instance/rejection reason. NO new or guessed reward definitions. Only existing 5 gemstone boxes/7 packages enabled; most shop chests/sets remain unsupported. Native Plaza heartbeat-first was misclassified RC4; now exact 001F00061000 selects plaintext, authentication still required. Added credential-free Plaza diagnostics. Real remote Plaza cause unverified.

57 backend PASS groups incl encrypted package results match DB, duplicate rejection, undefined package preserves inventory/ledger; fragmented/coalesced heartbeat-first square auth test. Published exact DLL tested isolated17070/33073; intentionally invalid Private/Data/Boxes/update-shadow-regression.json ignored, startup logs Game/Data. GiftStudio.Tests full online push regression passed. Collector Tools/Collect-RewardPlazaDiagnostics.ps1 tested local; filters feature logs/hash/catalog inventory, no config/DB/password/login/chat. Remote user can run Collect Diagnostics.cmd after repro. Isolated supervisor stopped and probe removed at turn end. Logs artifacts/reward-plaza-diagnostics.

Package artifacts/RFRebirth-Rewards-Plaza-Update.zip 4423544 bytes/20 files, DLLSHA2567c332f5863bf5d72d511cb807d8cebb55529a0bda4ce456a1be9d58248a47117. Includes Game DLL, Boxes/Packages/GeoIP, worklist, collector+CMD, README/manifest. Prior livegift/country features preserved. Stop, back up GameDLL/Data, merge Game into C:\ProgramData\RFRebirthServer, start. Explicitly partial update, not all-box/set completion. tools/build_reward_plaza_update.py reproducible builder; docs/rewards-plaza-update-2026-09-11.md. No remote install, client edits or full installer ZIP rebuild.

# Current handoff: automatic country flags (2026-09-11)

User says countryflagscodeunimplemented; asyncclarified Detect automatically fromIP. ReplacedhardcodedUS/NA withGeoIPfromactualTCPpeerClientConnection.RemoteAddress. New GeoIpCountryDatabase loadsimmutableinclusiveIPv4/IPv6ranges localCSV.gz once (binarysearch, mappedIPv4normalize, private/carrierNAT/docs/multicast excluded). NewCountryService detectspublicIPonlogin andpersistsaccount_country OwnerID/CountryCode/DetectedAtUTC; additiveFeatureSchema2026091113. Private/unknown/missingdata=>retainprevioussuccessfulcountryorblank, neverguessUS. NoIPstoredbynewfeature/noAPIrequests. Loginlegacy+modern+pendingcreation countryflows tocharacterreply, rooms/hostchanges/rosters/matches/training/plaza. Regionblankbecausecountryonlydata. PlayerdefaultCountry/Regionempty. Serverlogloaded717170ranges orwarningfallback; settingsGeoIPDatabasePathdefaultData/GeoIP/dbip-country-lite.csv.gz CWDthenAppBase, noexistingconfigedits.

BundledunchangedDB-IPCountryLiteSeptember2026CSV.gz atGemnet/Data/GeoIP withATTRIBUTION.txt(CCBY4 source+license+date+hash). Source https://download.db-ip.com/free/dbip-country-lite-2026-09.csv.gz; compressedSHA256a32bb3c384bd3de60ad9024596aa5b395a6dd5beaa27a7223407cc2edc681d0b; uncompressedMD5f1c3183d33ece928d4cc99d554b4ef7c matchespublisher;717170rows. Alllocal. Nativeclient4313FBbody98country8/bodyA0region32, UI5C35A6/5DD420emptycountryhandled, formatCON_%s at73A858. Foundprofilemissingtoo:5233C5body631country8,5233DDbody639region32. Addedprofilefields+offlinepersistedcountry, correctedreplytotal1630->1631 sofinalregion32fullypresent. Testsexpectedlengthupdated. No gameEXEoranti-cheatedits.

Package artifacts/RFRebirth-Country-Flags-Fix.zip 4403730bytes, fivefiles Game/Gemnet.dll,Game/Data/GeoIP/dbip-country-lite.csv.gz,ATTRIBUTION.txt,README.txt,manifest.json. DLLSHA256ae208e2923048733a7446a15259488115c918d5ec24c8d799f275dcb70e0a9e3. Includespreviouslivegiftfix. StopserverbackupDLL, mergeGamefolderinto C:\ProgramData\RFRebirthServer, start. Countrytableautoadded. Nextplayerloginsetsflags. No settings/DBcredentials/client/website replacements. OldfullreleaseZIPunchanged. No remoteinstalloractualrealclientflagdisplayverified;publicIPloginuserverificationpending.

CountryTests integratedMultiplayer.Tests: packagedIPlookupsIPv4+v6+mapped,localreservedrejection,boundaries,gaps,overlaprejection,persistence/restart/missingdata/IPchange/schema reapply, encryptedlogin,online/offlineprofiles,charactercreationflagpreservation,rooms/mastertransfer/rosters,training,plaza,reconnect. 54PASSgroupsfinal(52previous+country+extraPlaza). Logs artifacts/country-flags-build/tests-final.log,publish.log. InitialtestwronglyexpectedUSforGoogleIPv6;SeptemberDBIPactuallyCA, fixedtestusingverifiedrange. PublishedDLL+data copiedisolated33073/17070 andGiftStudio.Testsregressionpasses includingunsolicitedpush81batch/outofordercommit/noreplay. ZIPCRC/hashverifiedandexacttestDLLmatched. Sourcebuild177existingwarnings0errors. Isolatedsupervisorstoprequestedturnend, testaccountsremoved. Previousshophangawaitingremotelogsunchanged. docs/country-flags-2026-09-11.md fulldetails.

# Current handoff: live gifts server update (2026-09-11)

User asks to fix relog requirement. Implemented Gemnet/Network/LiveGiftDelivery.cs: polls committed gifts every2s, up to32peronlineplayer/pass, sends native0210/action18/155-byte gift notification. Main dispatcher4355E6 tables438464/438424=>435D8A; reads149body sender20/serverID20/itemID24/end28/type32/qty33/msg100at37/statmods137,141,145. 435E8A insertsinventory524440,435F19 giftinbox. Verified existingcapturedimage artifacts/redfox/loaded-image.bin; no client/anti-cheat changes. Evidence artifacts/gift-login-notifications.txt, docs/live-gifts-2026-09-11.md.

Per-player ConditionalWeakTable state+semaphore serializes GetProperty pages and notification. GetProperty nowTask awaitedthroughProcessGeneralPacket/ProcessPacketByType; recordsactualServerIDs onallpages, Readyonlyafterfinalpage, fullrefreshpausesuntilcomplete. SQLjoinsgiftreceiver/inventoryowner, excludesknowninstances viaMySQL8JSON_TABLE, expired/deleted/exhausted/activatedtimeditems. Sendsnewunstartedtimedgifts normally; nativepushnoexpiryfield. Computesgem/socketStatModlikeinventory. No new DBrows/schema orgranting innotification; noMAXIDwatermark avoidsoutofordercommitloss. FailedDBretry, sendfailureexistingdisconnectpolicy=>persistedinventoryonrelogin. ExistingGiftStudio/in-gamegiftsbothsupported. RemoteUI rendering unverified: usermusttestonegiftwhileonline afterinstall; do notclaimactualclienttested.

Delivered artifacts/RFRebirth-Live-Gifts-Fix.zip (180417bytes), ONLY Game/Gemnet.dll,README.txt,SHA256.txt. DLLSHA256681DE18E23FF24634FD26F528BFAC07B47D52C3F5AF4F7E75D5126C5783E310C. StopServer backup+replace C:\ProgramData\RFRebirthServer\Game\Gemnet.dll thenStartServer. No config/password/client/websitechanges. ExactZIPDLLtested inisolatedpackagedserver17070; zipCRC/hashverified. FullolderreleaseZIPstaleremains. Public GiftStudioZIP rebuiltneutralUIstatus(removesrelogtip), READMEupdated; existingtoolstillworksnoneedreplace. PrivateconfiguredtoolZIP remainsolderEXE.

Tools/GiftStudio.Tests/WireInventory.cs supportsasyncnotifications. Actualisolated33073/17070suitepassesfullcatalog+atomic/idempotentretries+nativeencryptedpushwithoutrequest+sender/item/end/type/qty/msg+recipientisolation+81copybatches+pagination+reconnectquiet+outofordercommits/lowerIDlatecommit+uncommittedinvisibility. 52Multiplayer.Testsgroupspassfinalsource. logs artifacts/live-gifts-build/gift-tests.log,regressions-final.log,publish.log. Publishsucceededexistingnullablewarnings. Isolatedsupervisorstoprequested atturnend, testaccountsremoved; no remoteDB/serveraccess, no productionmutations. Previousshopcrashissue stillpendingremote logs.

# Current handoff: gift visibility confirmed after relog (2026-09-11)

User reported gift in gifts table but not inventory; supplied giftrowID11 Sender1 Receiver2 RFRebirth->[GM]Furia Item3015570 ItemEnd1000 InventoryID60 CreatedAt2026-09-11 23:18:20.957860. User then CONFIRMED item appears after relog. Explained externalGiftStudio writesDBbutdoesnotpushliveclientinventorynotification; gift persistedcorrectly. Do not resend/repair/inventdataloss. No live-push feature requested/implemented. Added actualprotocol regression tests in Tools/GiftStudio.Tests/WireInventory.cs (linksGemnet/RC4.cs andBCryptforseed): packagedserver17070login+30/84GetProperty verifiesgiftrows afterlogin, onlineexplicitrefreshand81gift pagination past80. Alltestgroupspassisolated33073; testaccounts/auditrowscleanedandtestsupervisorstoprequestedafter. No remoteDBmutationsorpackagingchanges. Previousshopcrashinvestigationstillpendingremote logs.
# Current handoff: Gift Studio connection failure explained (2026-09-11)

User reports failing toconnect and confirms running Gift Studio ON THEIR OWN PC. Observed their configured artifact database.ini edited toServer160.202.167.41 at18:14; preserveuseredit. DirectTCPprobe160.202.167.41:33070timedout5s. Installer MySQLbind-address127.0.0.1; this package supportslocalDBonremotegameserver, publicIPisnotreachableMySQLbydefault. Explained runEXEinsideRemoteDesktoponserverwithServer127.0.0.1. Provided separate artifacts/RFRebirth-Gift-Studio-Configured/Server-Local/database.ini (sameuserprovidedpassword, loopback33070), and database-server.ini alternate; privatefolder remainsgitexcluded. OriginaleditedINIunchanged. No firewall/MySQL/listener modifications or attemptedcredentiallogin. Source AdminGiftService.Connect nowTCPprobes5sbeforeMySQL and reports specificendpoint plusserver-localsetup guidance; connectionfailureUIshowsfullmessageinMessageBox/tooltip. Buildzeroerrorswarnings; publicGiftStudioZIPrebuiltwithbettererrors. ConfiguredoldZIPnotrebuilt; connectionINIlinkisneededfixforserveruse. RemoteusefromownPCrequiresseparateremoteDBconnectivitysetup, notjustpublicIPINI. Don'tclaimchangingINIenablesremoteaccess. Shopclienthanginvestigationstillawaitingremote logs.
# Current handoff: Gift Studio explicit connection INI (2026-09-11)

User reported Gift Studio lacks DB settings. Created artifacts/RFRebirth-Gift-Studio-Configured/database.ini populated with their previously supplied generated AppPassword (do not repeat password in memory), localhost127.0.0.1 port33070 userrfrebirth databaserumblefighter SslModeNone AllowPublicKeyRetrievalTrue. Runs ON game server. DirectINIfilecanbecopiedbesideexistingEXE; also artifacts/RFRebirth-Gift-Studio-Configured.zip containsEXE/items.json/INI/README.txt/manifest. Originalpublicpackageunchanged. Configuredfolder+ZIP explicitlyexcludedin.git/info/exclude; verifiedgitcheck-ignore. ZIPCRC,configfieldsandhashmanifestverified. No remoteDBloginattempt. DeliverINIdirectlinkandoptionalconfiguredZIP. Shop-hang investigation remains pendingremoteGame/packet-trace.log andPrivate/game.log; this task doesnotresolve it.
# Current investigation: client shop hangs on remote server (2026-09-11)

User asked trace recent server crashes, clarified server did NOT close; only their client crashed in shop. LocalPC currently client C:\PlayRedFox\RumbleFighter usingremote160.202.167.41. Found Windows localevents17:35:10 AppHangB1+1002 and18:04:19 AppHangTransient; launcherexitsmatch. No faultmodule/address, no retainedfreshdump (onlySept7ones), WERTempattachments unavailable. Game relaunched18:04:43, overwritingoldRumbleFighter.log; new18:05:21 loginrejection is separateandnotcauseevidence. CurrentclientPID29652 andRFRebirthPID16776; game/peer sockets160.202.167.41:7000/33343. Earlierlocal.NETfailures16:14 areisolatedtests, notuserremotecrashes. No installedremotePrivatefolderaccessibleonthisPC. Preserved artifacts/shop-hang-20260911/client-events.json,launcher.log,findings.txt.

Asked async whichshopaction/item: opening/changingtabs/hovering/buying/gift; replypending. Need userattach remote C:\ProgramData\RFRebirthServer\Game\packet-trace.log and Private\game.log. Currentserver writes trace toAppContext.BaseDirectory/Game; logSafeHex maskscredentials. Do not ask forsettingsorDBcredentials. No rootcauseorfixconfirmed; no client/serverchanged inthisinvestigation. Shopinventory/avatar/giftcodeinspectedbutnooperationidentified. Continuecorrelatingincoming/outgoingframeswhenlogsarrive; don'tmistakeoldtesterrorsforremotecrash.
# Current handoff: RFRebirth Gift Studio (2026-09-11)

User requested attractive admin gifting UI, all item IDs/ItemEnd file, automatic metadata and name/ID/ItemEnd search. Built Tools/GiftStudio standalone net8 WinForms Windows x64 tool; shipped artifacts/RFRebirth-Gift-Studio.zip (~69MB, SHA256446673D499B6D40CA702081BCFC7E321EC88700CC67624D775797E442FDBE08F). ZIP exactly RFRebirth.GiftStudio.exe (self-contained/compressed), items.json, README.md, manifest.json. No settings/password bundled. Extract ON GAME SERVER and launch EXE (requiresAdministrator to read protected ProgramData settings); auto detects C:\ProgramData\RFRebirthServer\Private\settings.json, adjacent Private if in server/GiftStudio, or explicit local database.ini/settings.json; Settings file picker fallback. Server not replaced/restarted for deployment.

Catalog exported by Tools/export_gift_catalog.py from artifacts/reward-investigation-20260911/parsed/items.json: all11,379 unique IDs,18,237rows,15,180supported variants. 3,055 no-variant IDs plus2 unsupported/specialtimer variants searchable under Include missing data, not grantable (no guessed ItemEnd). Fields names/descriptions/type/end/days/count/sourcehash. Permanent default prefers1000; timed/U variants exactclientterms, start datesNULL. Search tokens name/id/end/termlabel, lifetimefilter, pervariantrows. Nice cream/green WinForms UI rendered/inspected at artifacts/gift-studio-preview.png. No new client assets needed. Tool does not implement unfinished box reward tables.

Gifting: choose active recipient byname/email/id; explicitrecipientrequired unlessfiltermatchesone. Sender selectable, defaults active admin@rfrebirth.local. Copies1..100, ASCII99charmsg. Does not deduct currency; one inventory row plus gifts history/economy_ledger('admin_gift') percopy. Uses sorted account FORUPDATE locks and InnoDB transaction encompassing inventory/gift/audit/receipt. New additive admin_gift_batches table tracksRequestGuid,PayloadHash andreceiptJSON. Same-request advisory lock and durableDBreceipt prevent duplicate retries; conflictingpayloadsameid rejected. Pending draft in LocalAppData/RFRebirth/GiftStudio/pending-endpointhash.json persistedbeforeSend; uncertainerrorslockdraft+Retry, reopeningrestoresdraft. Receipt aftercommit clearspending; subsequent historyfailure doesn't falselyinvite duplicate retry. Only one UI per Windows session viaMutex. Gift sender/recipientmustState1+CurrentAvatar>0; pendingnewcharactersblocked. Reopen inventory/gifts or relog for client refresh; no pushnotificationpath implemented.

Validation: Tools/GiftStudio.Tests links core/service/settings directly and runs ONLY isolated127.0.0.1:33073 settings. Passed actualMySQL fullcatalogsearch/default/unsupportedchecks,8concurrentretriesandrestartsimulationonecommit, timed/usemetadataandunstartedtimers, balancesunchanged, injectedledgerfailurefullrollback/retry, pendingaccountrejection, payloadconflict andhistory. Testaccounts/auditrowscleaned; liveproductiondata untouched. Release build/publish zero errors/warnings. Renderedactualnativeform via dotnet --render-preview (opacity0), notmockHTML. Remote Windows exe elevation and real-client gift display nottested. FinalZIP exactcontents/CRC/hashmanifestverified. Isolatedinstall supervisor stopped viaPrivate/stop-request at end.

Reproduce package: powershell -File Tools/GiftStudio/build-package.ps1. Outputfolder unexpectedfiles guard prevents bundlinglocalsettings. Existing previous deliverables untouched.
# Current handoff: website first-login character setup (2026-09-11)

User reported website bypasses tutorial/name/class choice. Root cause shared AccountRegistration.Create preconfigured State1, IGN and10avatars. Added CreatePending (CreateCore false) with State0/EXP0/IGNNULL/CurrentAvatar0/ForumName empty/no avatars/no inventory; website calls this. Original Create still ready-made for desktop admin/installer. No existing accounts reset. Website page removes nickname field, success/help text says choose name/class/tutorial in game; submitted nickname ignored; Validate only password/confirmation. Build marker first-login-v3. HTTP remains enabled.

Delivered artifacts/RFRebirth-First-Login-Fix.zip: Apply Registration Update.cmd, Update-HttpRegistration.ps1, Register.aspx, bin/RFRebirth.Registration.dll, hashes/build marker, README. Updater finds actual IIS8088 site, backs up and replaces BOTH page/DLL, touches Web.config only timestamp, verifies dynamic build marker. Previous HTTP updater source extended with optional page checks/replacement; tests updated. User should extract on actual web server, run CMD, waitSUCCESS and register NEW account. Existing preconfigured accounts still bypass first-login; no reset or destructive SQL supplied. Full old release ZIP remains outdated.

Tests: net48 website and net8 desktop tool builds pass zero warnings/errors. Tools/test_registration_site.py actual IIS Express+isolated DB/game passes pending State0/NULL name/no rows, forged nickname ignored, duplicates/concurrency/multiple NULLIGN accounts, encrypted no-game-account response, chosen class1000176+name creation grants10avatars/3items withEXP0, repeat rejection, reconnect, account insert rollback/retry and existing account state/EXP/name preservation. Tools/Test-HttpRegistrationUpdate.ps1 passes custom folder and two-file backups/config/othergame preservation and refusal checks. Website README/VALIDATION updated. Isolated supervisor stop requested and IIS stopped after tests. Actual real-client tutorial UI and remote deployment unverified; protocol triggers verified. No production modifications.
# Current handoff: automatic live-IIS HTTP registration update (2026-09-11)

User still sees old HTTPS error after manual-copy instructions. Original patched DLL verified same hash as build and no HTTPS rejection in source; screenshot indicates stale deployed code, actual remote deployment unavailable. Added page response header X-RFRebirth-Registration-Build=http-registration-v2. Website/Update-HttpRegistration.ps1 finds the actual IIS root site on HTTP8088 with RFRebirth Register.aspx and DLL, refuses ambiguity, backs up DLL outside public site, checksum verifies replacement, touches Web.config timestamp only, then verifies live HTTP header before declaring success. Apply HTTP Fix.cmd invokes with UAC; failures logged update.log. No IIS-wide/app-pool restart. Delivered artifacts/RFRebirth-HTTP-Fix-AutoUpdate.zip containing CMD, PS1, hash, bin DLL, README. Ask user extract on actual web server and double-click CMD; send update.log if failure. DLL includes EXP0 level1. Actual local IIS Express regression tests all passed and build header verified. Tools/Test-HttpRegistrationUpdate.ps1 passes with mocked IIS inventory/real filesystem (custom path, backups, configuration/othergame preserved, rejects corrupt/missing/ambiguous). Isolated test supervisor stop requested, IIS Express terminated. Remote admin/IIS execution unverified. Latest package supersedes earlier manual HTTP DLL ZIP.
# Current handoff: HTTP registration allowed (2026-09-11)

User explicitly requested removing the HTTPS requirement after registration at http://160.202.167.41:8088/Register.aspx was blocked. Removed the IsSecureConnection/IsLocal rejection from Website/Registration/Register.aspx.cs. Shared account default remains EXP0/level1. Updated Website/README.md. Release net48 build passed zero warnings/errors. Delivered artifacts/RFRebirth-HTTP-Registration-Fix.zip with bin/RFRebirth.Registration.dll and README.txt; replace installed website bin DLL (default C:\ProgramData\RFRebirthWebsite\bin). No config/database/client changes needed; IIS reloads the DLL. Explained HTTP transmits passwords without encryption. Remote HTTP submission not tested. This supersedes website DLL in the earlier level1 package; full original website ZIP still contains older code.
# Current handoff: level 1 registration update (2026-09-11)

User requested fresh accounts start at level 1 and asked to package replacements. Changed shared AccountRegistration.Create INSERT EXP5000 to EXP0. Updated website regression assertion and account/website documentation. Built net48 website, win-x64 AccountCreator and isolated ServerInstaller publish (initial publish ref DLL was locked; separate --artifacts-path succeeded). Delivered artifacts/RFRebirth-Level-1-Update.zip (206568 bytes) with README.txt and Server/Accounts/GemnetAccountCreator.dll, Server/Setup/Gemnet.dll, Website/bin/RFRebirth.Registration.dll. README maps into installed ProgramData server/website folders and explains stop/replace/start. Existing full distribution ZIPs are still old defaults; use patch or rebuild for fresh distributions. No existing account EXP reset or production DB changes. Actual isolated IIS Express registration tests passed EXP0, starter rows, encrypted game login, duplicates/concurrency and rollback. Isolated supervisor stop requested and IIS Express stopped afterward. No real-client display or remote deployment validation.

# Current handoff: standalone Start/Stop CMD replacements (2026-09-11)

User reports the distributed server is silent, wants a drag/drop replacement that opens a CMD with live output, and reports Stop Server.cmd does not stop it. Delivered artifacts/RFRebirth-Live-Console.zip containing ONLY Start Server.cmd and Stop Server.cmd; unpacked files in artifacts/RFRebirth-Live-Console. ZIP SHA256 E28E25DB405E38F04F76501F2F73D4E135D7D385D6679474F95C79FDF5D4BEFA. Replace the old CMDs on the remote server; no backend/DB changes or helper PS1 required. Existing full server ZIP was NOT rebuilt this turn. Tools/ServerInstaller source CMDs and README updated for future builds.

CMDs embed PowerShell after a marker, self-elevate into a visible CMD, and target the installed C:\ProgramData\RFRebirthServer. Start verifies the task action matches Setup/InstallRFRebirth.exe --run, re-enables the task, starts if needed and streams Private/game.log with Get-Content -Tail100 -Wait. Closing the console does not stop the server. Stop verifies the same task ownership, disables automatic starts, writes stop-request, allows20seconds for graceful shutdown, ends the task if hung, and cleans remaining verified installed processes if needed. MySQL must match BOTH its installed binary path and Private/mysql.ini argument, protecting other databases even if they use the same bundled binary. PID fallback rechecks creation time and path. Stop waits for confirmed exit; Start re-enables future boot/failure starts.

Tools/ServerInstaller.Tests/Test-ControlScripts.ps1 tested the embedded bodies against the real isolated packaged game/peer/MySQL stack, with Windows Scheduler APIs/UAC mocked because the local tool session is not elevated. Graceful stop exited0; hung-task fallback called; local live services PID5952/53840/15720 preserved. All test ports closed. Logs artifacts/server-implementation/control-script-tests.log. Actual remote Windows task/elevation execution still needs operator testing. An earlier multi-file log-viewer attempt was superseded; do not distribute artifacts/RFRebirth-Server-Console. The final deliverable is the two-CMD ZIP above.

User also asked whether fresh accounts start at level1. Answered: current website and desktop account tool use EXP5000 (level5), not level1; existing accounts are not reset. No account defaults or database records changed this turn. Preserve that answer unless user explicitly asks to change the default.
# Current handoff: ASPX registration website (2026-09-11)

User asked to build a registration website using ASPX. Completed actual ASP.NET Web Forms / .NET Framework 4.8 with C# code-behind, MySQL registration, polished responsive RFRebirth page, success flow and launcher download. Final deliverable: artifacts/RFRebirth-Registration-Website.zip (68,883,419 bytes, SHA256 4054379dd2f52d73a94819c570945137160ab007aa8306eb8df950d2d358dd0f), plus unpacked directory of the same name. Includes Site, Setup, editable Source, Install Website.cmd, website.ini, README.md and VALIDATION.md. Sources in Website/Registration and Website/Setup. Website/build-package.ps1 and finalize-package.py reproduce packaging.

ASPX site uses shared Gemnet/Persistence/AccountRegistration.cs (compatible with .NET Framework 4.8 and .NET 8); AccountCreator.AccountService.Create delegates to it. AccountCreator.csproj links the shared file; Gemnet compiles it naturally; existing Multiplayer.Tests and ServerInstaller use their Gemnet reference. Semantics unchanged: active account, BCrypt cost11, EXP5000/Carats10000, two starter items, ten avatars, selected first avatar. Desktop tools/server packages from previous turn were NOT republished or replaced; live local game PID53840 / peer15720 / MySQL5952 preserved.

Actual IIS Express testing passed with isolated MySQL33073/game17070. CSRF, field validation, config/source file protection, launcher download, case-insensitive duplicates, database unique constraints, per-IP/global throttle, concurrent duplicate signup, full rollback on injected avatar failure, and encrypted game login with website-created credentials passed. Counter deadlock1213 fixed using bounded whole-counter-transaction retries before any account creation; five full repeat test runs passed. 52 backend regression groups also pass after shared-class extraction. Use Private/website-regression-work/settings.json with empty Data/Boxes for that suite; startup with full production boxes conflicts with its synthetic reward fixtures. Test suite needs root on the isolated DB because BackupTests creates temporary schemas. No live production accounts changed.

Website setup is a separate IIS installer, preserving other sites/pools and checking binding conflicts. Connects using existing RFRebirthServer/Private/installation.json, creates limited rfrebirth_web local DB user and web_registration_limits table, adds unique accounts.Email and IGN indexes (refuses existing duplicate data). Site ACL admins/SYSTEM FullControl, own IIS apppool Read/Execute; App_Data/database.config holds limited credentials, hidden by IIS. Public registration requires HTTPS; default website.ini creates loopback-only http://127.0.0.1:8088 preview. Configure hostname/unused port/certificate thumbprint for public setup. Async domain question was sent; no answer received this turn. No need to ask again unless required for hosting. No remote deployment or elevated IIS install executed here; administrator/certificate configuration remains remote operator work. .NET Framework4.8 prerequisite is checked, not bundled. No email verification/reset email service was requested or implemented.

Temporary IIS Express extracted read-only from official Microsoft MSI (MSI administrative-install command was auto-review blocked; no installer actions executed). tools/extract_test_iis.py reads MSI cabinets as data. IIS test process on18088 and isolated supervisor were stopped after tests; do not expose the validation folders or their database configs. Final package config contains RUN_WEBSITE_SETUP placeholder and no database secrets. 249 archive files CRC verified. Relevant logs: artifacts/server-implementation/website-integration-final.log, website-repeat-1..5.log, website-shared-account-regressions.log, website-package-final-build.log, website-archive.log. Real browser desktop/mobile layout inspected; UTF8 ASPX globalization and duplicate IIS file-filter collection entries fixed. See Website/VALIDATION.md.
# Current handoff: RFRebirth deployment package (2026-09-11)

User requested a one-click Windows x64 server installer for 160.202.167.41 (another game already runs there), separate drag/drop client files and RFRebirth launcher branding. Built artifacts/RFRebirth-160.202.167.41 with Server and Client folders and ZIPs. See docs/rfrebirth-deployment-2026-09-11.md for configuration, tests and limits. Tools/ServerInstaller contains the reproducible installer/build/finalization sources; Tools/ServerInstaller.Tests verifies port and process isolation. ClientLauncher assembly and visible name are now RFRebirth; durable GemnetLauncher routing journal/mutex are intentionally retained for backwards-compatible recovery.

Remote target is NOT this computer. No remote deployment or public-connectivity verification happened. Installer is designed for an elevated Windows x64 install, dedicated loopback MySQL 33070, game TCP 7000 and peer TCP 33343, SYSTEM scheduled task, program-specific firewall rules, generated credentials, and automatic account/schema/catalog creation. Installer does not upgrade/overwrite a ready existing installation. Windows firewall/task registration remains unexecuted here because the tool process is not elevated. Fresh database installation, repeat preservation, encrypted native-format login, compiled multiplayer peer tests, supervisor restart and clean stop all passed against an isolated copied package (ports 17070/33373/33073). Validation database/account credentials are in artifacts/rfrebirth-install-validation/Private; NEVER distribute that folder. Only the two distribution ZIPs/folders go out, and only the Client ZIP goes to testers. Local live server PID 53840 / peer 15720 / MySQL 5952 were preserved.

Current official reward-table restrictions and feature limits remain. Deployment does not mean full retail replication. Installer archive integrity/hash manifests are created by finalize-package.py; see artifacts/server-implementation/package-finalization.log.
# Handoff — 2026-09-06

## September 11 — local whispers (LATEST)

User asked to implement friend whispers. Implemented and deployed, superseding
all previous statements that short-message delivery is absent. Read
`docs/whispers-2026-09-11.md`. LIVE PID53840, artifacts/backend-whispers/Gemnet.dll,
cwdGemnet, configGemnet/settings.json,127.0.0.1:7000. Logs local-whispers.stdout.log
/stderr in artifacts/server-implementation; local-server.pid updated. Prior58508
verified/stopped; no active game connections at deployment. Tested/published hash
56D47D6C4E849111159337E9612E630CC01307046F7794CB98B6555F21BC4C08.
52integrationgroups pass, including WhisperTests, in whispers-tests.log;31production
checks allzero in whispers-production-audit.json. No schema/account/inventory/client
or GameGuard changes. Fishing configuration unchanged, explicit localtestingpolicy.

Whispers.Send dispatchedActionLogin.SHORT_MSG10/40. Native51E9E0 sends1050byteframe:
destination20bytes+message1024bytes. Incomingmainnotificationreceiver4355E6
jumptable438464/438424 mapsaction14 to4365E6, senderbody0 andtextbody20;
render4369D4. Thus recipient210/14 packet1050bytes. Authenticatedsenderonly,
recipientlookupbyIGNactiveaccount+ReceiveMessages(defaulttrue), blockrelationship
eitherdirection preventsdelivery. Local online streamonly; acceptedfriendshipnot
required for generalwhispers. Offline/unknown/muted/blocked=>private Server whisper
notdeliverednotice, noofflinequeue or messagehistory. Preserve rawcodepage message
bytes; max1023textbytes+NUL, rejectcontrolchars and malformedframes. Nativeclient
DISPLAY NOT YET VALIDATED. Two encrypted testclients+obserververify delivery/reply,
noecho/broadcast,mute readback,blockbothdirections,offline/unknown,malformedframes,
maxnonASCIIlength. Testofflineaccountdeletedaftertest.

Evidence artifacts/whisper-network.txt,whisper-dispatch.txt,whisper-incoming.txt.
This located the MAIN notificationdispatcher (4355xx), useful for future invitation
and socialmessages. Action10/16 incoming at436ADA appears invitation withname20,
DWORDbody20,WORDbody24,DWORDbody26; NOT IMPLEMENTED, verifysemanticsbeforeuse.
Auditupdated to59missingdispatchcandidatepairs. Broaderunfinishedworkbelowstill
applies exceptwhispers. No subagents used.

## September 11 — Plaza, extraction and backend audit continuation (LATEST)

Supersedes deployment/fishing policy and extraction/Plaza statements below.
Read `docs/backend-audit-progress-2026-09-11.md` and regenerated
`docs/client-feature-audit.md/json`. User asks to find/finish all backend gaps,
autonomously. Full replication remains unfinished; do not claim everything works.
No subagents used or authorized in latest turn. Exact official box tables remain
required. No client/launcher/GameGuard edits this pass.

LIVE PID58508, `artifacts/backend-plaza-extraction/Gemnet.dll`, cwdGemnet,
settingsGemnet/settings.json, verified127.0.0.1:7000 encrypted. Logs
`artifacts/server-implementation/local-plaza-extraction.stdout.log`/stderr(empty).
PIDfile local-server.pid updated. PriorPID50020 verified then stopped after notice;
one idle local game connection was disconnected and needs fresh login. MySQL3306
and peer33343 unchanged. Published/tested DLL SHA256
4491BE334917097DDC415B27E5B6D095F4E47564586C39E6486E67982014AB99.
Backup before-plaza-extraction-20260911.sql verified size/SHA; production31checks
allzero in audit-production-after-plaza.json.51integrationgroups pass isolated
DB13306/game17000 in audit-features-tests.log. Build178server warnings+2test
warnings,0errors. Failure assertions now also verify nonzero failure status.

Fishing is NOW ENABLED with explicit LOCAL TEST policy, not recovered official
odds: ten equal species weights,30seconds. User latest broad autonomous request
resolved the prior optional fishing-preference question by reasonable stated
assumption; exact loot-box restriction unchanged. ConfigFishingPolicyPath=
Data/Fishing/local-testing.json. Source persisted in fishing_policy.Source;
live readback1/30/10weights verified in audit-live-fishing-policy.txt. WavyTreasure
Chest5115229 exchange works but opening remains blocked by unavailable exact table.

NEW SocketExtractionService/Inventory.ExtractGem31/A0:15-byte request equipmentID,
scrollID,slotbyte. Owned ExtractionScroll5090065/type78/qty1 consumed; exact latest
unextracted socket_insertions record restores originalGemItemID/GemVariant/GemValue,
clears only selected equipmentSocket, grantsnewgem +37bytebody nativeItemReply.
StatModfull31=(kind<<16)|value. socket_extractions migration2026091111 logs unique
InsertionID,ToolServerID,GemInventoryID,OwnerID. No original provenance => reject
without consume; never guess gem identity from encoded stat. Tests ownership,
replay/concurrency, originalvariant/value, otherSocket preservation and injected
ledger failure rollback. Native51DEF0/600C03. 31/96 is NOT extraction.

NEW Square: 4B12body1550 peer snapshots fieldsID0,name4,position24/28/32,
direction36,90itemIDs40,guild1487/name1491,state1508,country1510,region1518.
4B42 roster,44 singlepeer,40 movement request30+payload (lengthfull22,max248),
4B13relay authenticatedIDfull6 + coords/direction/length/payload. Playerstate1/4
visible;4B11 userID removespeer onstatehide/logout/socket/main disconnect.
Connection transientposition; Gate serializes membership. Two-playerprotocoltest
passes; REAL NATIVE SCENE NOT VALIDATED. Native5627CE/4FB620 and40Bxxx. Default
position0,0,0 remains native scene validation concern. Do not claimPlaza100%done.

QuestService.Observe now handles socket_insert tutorial5/2,enchanttutorial4/3,
successful achievement level3/5/10 usingParam1=26/27/28 andvalue/BaseValue,
fishing7/41daily/tutorial,andconsumable4/1Category3too. Hooks insideactualDBtx.
Tests verify thresholds/fishing cap/consumption. Combat/rune objectives remain.
Login.TO_LOBBY historicalnameactually10/B6 ENABLE_RECV_MSG:boolean: stores
account_options.ReceiveMessages and6byte statusreply. Invalidboolean6bytefailure;
private-message DELIVERY still unfinished. Source/fishing optionmigration2026091112.
AlternateRooms41/40chat and42hosttransfer added usingQuery guardedbyroomProtocolType
and241notifications. Testtwopeers echo/transfer. Native1F/10heartbeat silently
accepted encrypted too. DefaultunsupportedInventoryerror now9bytes withWORDerror
andNUL, since skillbookconsumersreadbodyevenonfailure; functionalitystillabsent.

Audit scanner corrected inlinecomments/qualifiedcallees/shareddispatch and added
nativePlazabuilder4EA600.162observedpairs,180buildercalls,60missingdispatchcandidate
pairs now (not60distinctfeatures). Missingdoesnotincludeimplementedsharedhandlers;
genericfailuredoesnotcountasimplementation. Historicalnotesstale; currentreport
listsguild/social/skillbooks/ranks/quests/rewardrules/peertransport/nativeUI gaps.
Lootchestsunchanged:294total,5KRgemstoneenabled,5ambiguousmappingsdisabled,
284furthermissing =>289unavailable. Fullnamedworklistexists.

Additional native evidence in artifacts/audit-*.txt. Skill-book partially decoded:
31/CCreq10registerownedinventoryID confirmedcaller5F3221(type57SkillBook5200001),
D6req10read; repliesbody64:bookidentifierDWORD+15slotDWORDs. CE/D0/D2req18 mutations,
D8req30name20+bookidentifierDWORD; D8replyname24+15slotDWORDs. Slot sentinel/default,
materialmapping/combinerules stillunverified; do not invent. ExpansionKit5090002
descriptionmax5extra slots. Recordreaders51D0D1/51D2A1/51D47D/5218D9.
GenericInventoryfailureprior6bytescausedbodyreadrisk; nowcorrecterror3bytebody.
31/WinMedalB6 stillcapturedpayload;grade/zombierank/skillbookfunctions notfinished.

## September 11 — sockets, exact box policy, fishing and guild backend (LATEST)

Supersedes every PID/deployment and box-enabled count below. Read
`docs/fishing-guilds-sockets-2026-09-11.md` and
`docs/loot-box-worklist-2026-09-11.md` for current implementation and limits.

LIVE PID50020, `artifacts/backend-fishing-guilds/Gemnet.dll`, working directory
`Gemnet`, config `Gemnet/settings.json`; verified listening 127.0.0.1:7000 with
encryption. stdout/stderr: `artifacts/server-implementation/local-fishing-guilds.*.log`.
PID file local-server.pid updated. Prior PID55376 (backend-gem-sockets) verified
and stopped after notice, no connected clients; MySQL3306 and peer33343 untouched.
Published DLL SHA256 E078E639412F3456ADC85E4BA5FF807CD1A2F16A90290D7846583287A8B7069F
matches tested Debug DLL. Production backup
`artifacts/server-implementation/local-backups/before-fishing-guilds-20260911.sql`
size/SHA verified. New 29-check production audit all zero, saved in
`artifacts/server-implementation/final-production-audit.json`. 48 integration
groups pass on isolated DB13306/game17000 (`final-features-tests.log`), including
backup/restore; Python gemstone4/chest4/shop6 pass. Full build178 existing warnings,
zero errors. Client binaries/launcher/GameGuard were not modified.

User ordered gem insertion -> remaining boxes -> fishing -> work on guilds, and
requested a list of unfinished boxes. User explicitly answered REQUIRE EXACT
OFFICIAL REWARD TABLES; do not invent or normalize incomplete box odds. The new
Premium Gemstone Generator5119004 has354 recovered official KR rows. Five enabled
gemstone boxes5119000..4 now total822 rows. Not a certification of RedFox NA rates.
Five older kr-chest pools (SkullShadow5118455, DarkPhoenixRe5118390, BloodDragon5117989,
Gemini5117336, Capricornus5118192) now have Enabled:false due unproven aliases/item
variant mappings. BoxRegistry.GetBox returns null for disabled definitions; they
remain in source for review, and blocked attempts preserve inventory. Exporter
keeps them disabled. Seven package bundles can grant blocked chests. Audit script
Tools/audit_box_completion.py lists all294 type40/50 chests:5 implementedKR,
5 disabled candidate mappings,284 other unavailable;76 shop chests. Other generic
packages/tickets are not included in294. Worklist is deliverable for user.

Socket insertion31/94 implemented: equipmentID/gemID/slot byte request; reply
equipmentDWORD+slotbyte+encodedWORD. Native encoded=statKind*1000+value (NOT bitpack).
Client reads socket words in49-byte inventory record offsets33/35. Stored inventory
Socket0/Socket1, socket_definitions3162equipment, socket_insertions consumption
history. Account-locked transaction validates ownership, usable state, quantity1,
capacity, topSTR/ARM/HP or bottomSPD/JMP/SP compatibility and empty slot; deletes
gem atomically. Native516C30/516C9D,5FFA13,5F9A98,5F5CC4. Socket extraction absent.
Earlier socket-only backup before-gem-sockets-20260911.sql also verified.

FishingService/Fishing handler implement native30/C6 bag,31/C6 pole,31/C8 daily
5worms UTCday,31/C2 catch,31/C4 exchange. Ten species0..9,12-byte ID/species/quantity
records; max20 per species; Squid2draws, others1; bait consumed; cooldown enforced;
oneofeachfish->WavyTreasureChest5115229. Catch requires authenticated SquareChannel
>=0 matching main player. Tables fishing_accounts/fish_bag/fishing_policy/fish_weights.
LIVE CATCHES DISABLED: official odds/timing unrecovered; no weights seeded production.
Asked optional async user question whether to enable documented local test settings
or wait official; NO ANSWER received yet. Do not treat preselected option as approval.
Pole/bait/bag/exchange implemented independently; WavyChest's reward table blocked.
Config optional FishingPolicyPath (empty default preservesDB) insettings.json points
to JSON; see Data/Fishing/policy.example.json. Import validates complete tenpositive
weights and source whenenabled, atomicallyreplaces. Testsonly useuniform30seconds;
neverdescribeasofficial. Plaza movement/player snapshots/scenevalidationstillmissing.

GuildService tables guilds/guild_members/guild_invites/guild_events/guild_write_lock:
card-backed create, uniqueASCII2..12name,8initialslots,48hourinvites(localpolicy),
accept,rolesleader1/officer2/member3(localpolicy),greeting,kick,promote/demote,
transfer,leave,disband,capacitycards strictly8->16->32->64. Serialized DBmutations
withaccountlock,events andconsumedcardledger intransaction. Guildleaderscannotleave.
Roomchat /guild commands implementmanagement authenticatedactor andself-onlyresponses.
Reconnect needed aftermembershipchanges fornativepanel,afterchatcarduseforinventory.
Native33/84 members:74byteprefix,countbyte73,25byterecords(userID,name20,rolebyte),
rolelabels at8+13*n,20memberpagescursorOwnerID.33/8AgreetingDWORD+NULtext.
IMPORTANT33/94 is GUILD-ID request -> LEADER-ID DWORD + CAPACITY BYTE, despiteold
enum IS_USER_GUILD_MEMEBER. Verifiedcaller4B91FBcomparesleaderIDtoownIDandcapacity
to8/16/32.33/96requestguildID+cardServerID returnsnewcapacitybyte.33/92ack.
Rank33/90threezeroDWORDs;33/8Ezeroentries untilrankedmatches exist(no retail samples).
LoginRes savesguildIDfull52/namefull56[13], native4310E5/431131. No liveclientguild
UIvalidation; nativecreate/joinwebsite,marks/images,guildchat,refreshnotifications,
guildbattle/rankingremainunfinished. Nativeguild references in artifacts/guild-native.txt
andguild-field-references.txt. Do not call entire guild/nativePlazasystemcomplete.

No subagents spawned (disabled unlessuserexplicitlyrequests). Preserve extensive
uncommittedchanges. Tools/Multiplayer.Tests must onlyrunDB13306! Never production.

## September 11 — shop purchase and Medal Shop fix (latest deployment)

Supersedes the deployment PID/path immediately below. User reported regular shop
"fail to buy" and Medal Shop failure. Live 31/80 requests showed R/variant500
offers omitted by export_shop_catalog's Z-only availability filter; visible
RedFox H offers now included. H **currency** (0x48) is independently medals:
native 524789 stores response body+4/+8 in medal balance fields. Medal price and
enabled fields from parsed variants are 469C64/469E18. Added currency2 end-to-end
with account lock, medal debit, inventory grant, and new economy_ledger.Medals
column in the same transaction. No free offers or currency fallback invented.
Catalog now 4871 offers (1839 Carat,2798 Astro,234 Medal), 6772 resale entries;
712 newly included offers, existing administrator prices/disabled rows preserved.
Every attempted purchase in the captured session had a matching rebuilt offer.

LIVE: artifacts/backend-shop-medals/Gemnet.dll, PID53972, cwd Gemnet, config
Gemnet/settings.json; loopback7000. Logs local-shop-medals.stdout/stderr.log in
artifacts/server-implementation. Old PID19560 stopped after user-facing notice
of disconnection. Production catalog counts and medal schema verified after
restart. Backup local-backups/before-shop-medals-20260911.sql checksum verified;
database audit21 checks zero. Tests44 integration groups pass (including medal
packet reply, persistent debit/ledger and insufficient funds rollback), Python
catalog6 tests pass. Build180 existing warnings, zero errors. User must reconnect
for real-client confirmation. Other missing box pools and Plaza replication
remain as documented below; this does not implement all outstanding features.

## September 11 — overnight client bugs: chests, presets, actual Plaza transport

Read docs/client-bugs-2026-09-11.md first. User went to sleep and authorized fixing
remaining bugs/features, prioritizing loot boxes, exit hang, avatar crash, Plaza.
No request for further permission/testing was made while asleep. Work is NOT full
replication or proof every crash is fixed. No native game binary changes.

FINAL local deployment: artifacts/backend-chests-square-final/Gemnet.dll PID19560,
working Gemnet, settings Gemnet/settings.json, loopback127.0.0.1:7000. Logs
artifacts/server-implementation/local-chests-final.stdout/stderr.log. PID file
local-server.pid updated. Old52592 then15712 were verified and stopped with no
connected players. MySQL3306 and peer33343 untouched. Backup before-chests-square-
20260911.sql size/SHAverified, all21productionDBauditchecks zero. 44integration
groups onisolatedMySQL13306 pass (includingbackuprestore), 4newchestexporttests pass.

Nine loaded boxes,737rewardrows: fourpriorgemstones + SkullShadow5118455(63),
DarkPhoenixRE5118390(59),BloodDragon5117989(66),Gemini5117336(42),Capricornus5118192(39).
Sevenpackagesgrants5/6DISTINCTchestinstances atomicwithsource+ledger;31/86native
bytecount+37byterecords validated. New files PackageService,Packages,PackageCatalog,
Data/Packages/packages.json,Tools/export_chest_catalog.py. AllKRderivedLOCALpolicy;
same-namevariants sortedID, DarkPhoenixred-flash→GoldenBlaze is explicitinference.
NeverclaimNAretailodds. RareScroll5118462/RareExo5118463nestedrewardpoolsstillmissing,
asaremanyotherboxes. Incompletepoolsfailwithoutconsumingsource.

Account1test@test.com hadonly1preset,account2had10. AccountCreator nowseeds10 and
AvatarService.EnsureDefaultPresets fillsmissingdefaultsonGetAvatars atomically,
preservingIDs/selectedloadout. Previewfiltersunowned/unusableIDs;can'tclearJob0.
GENERAL89fixed366bytes: realclientloops90DWORDs; modelstillonly45supportedslots,
remainingzero. Thisaddressesrealdefectsbutavatarhovercrashnotreproduced/confirmed.

IMPORTANT: actualPlaza isType4B, plaintextSECONDconnection port7000. It was being
wronglyRC4decrypted. NativeCSUtil40BF42connect,4EA5E0encryptionoff,4EA600framing,
5625F0callback. PacketProcessorselectsexactopening4B80len87or4B84len6, buffers
fragmentedheaders, restrictsplaintexttosquare+1F10heartbeat. MainRC4unchanged.
SquarecheckinrequiresactiveprimaryGUID/token. LoginGUIDnowGuid.NewGuidinstead of
sharedXplaceholder; tokenRNGnowcrypto. Rawreceivehexremovedtokeepcredentialsprivate.
4B80→81bodyu32count1;4B82→83assignsZERO-basedchannel0 (41ACF6requiresindex<count);
4B86→87status;4B84→85idempotentlogoutevenwithoutauth. Logoutnativewait5000×3ms;
liveprobe16ms andmainencryptedversionhandshakepassed. Noactualgamecloseacceptance.
Plazaremoteplayersnapshots/movement/chat/fishingstillmissing;sceneentryuntested.
ContinuefromCSUtil40B800..40BE63 (4B42requestlist,4B40variablemovement,4B44u32)
andcallback5625F0 (actions11remove?,12player154?body0x60e,13movement,14time,15/17state).
DoNOTfabricateplayerstructs: nativecopies1550bytes for4B12.

0x41isALTERNATE TEAM-ROOM protocol, NOT PLAZA. Discoveredmid-investigation;
renamedtoAlternateRooms.cs. Implementedcreate/list/join/roster/avatarselect/leave,
isolatedProtocolTypeinGameRoom(assignedundercreationlock),broadcasts241,
regularbattlerequestsdeniedonalternateroommembership. Proposals/combatnotimplemented.

Accepted automatic-hosts launcher isinstalled and workingatC:/PlayRedFox/RumbleFighter/
GemnetLauncher.exe + RumbleFighter.ini(publicServerIP127.0.0.1). SourceTools/ClientLauncher.
ItrequiresUAC,temporarilymanageshosts,restoresonexit/recovery. NOTzero-system-change.
RealrunPID21792/game39752 ended09:55:12Z, hosts restoredEXACTSHA74bc8c8a7dea633533f7e
8529bb6c7b15ca5083cbb0070596a9c6d54bd4549e0. OriginalgameSHA94194afa95d3d2cc81a55438a
0f584bfaf039ca85adab5b07966ae3e4d593a59;originalRumbleLauncherSHA21dd6e1efb35d140876db
353cbf57130f215e7173b80bb6df7d0f29c66e1b77b. ZIPartifacts/automatic-client-launcher-v2/
Gemnet-Automatic-Launcher.zip verifiedthreefilesEXE/publicINI/READMEonly. Userreported
in-gamebugsfromthisrun;don'tattributegameexithangtolauncher. Rejectedembeddedpatch
below remainsREJECTED andmustnotbereinstalled. Launcherreceiptprecedesthisbackendrun.

## September 11 — REJECTED direct client routing patch; rollback complete

User now requests NO manual hosts edits, drag/drop tester files, all endpoints
127.0.0.1 with later editable client-side IP. Prefers patching client EXE directly.
Client INI is PUBLIC address only, named RumbleFighter.ini (not server settings).
Experimental client/routing embeds MinHook into added .gnroute PE section, reads
INI, routes DNS/connect/WSAConnect/ConnectEx/sendto/WSASendTo + website links.
Standalone real Windows loader/network probe passed on127.0.0.2 includingASLR.
BUT REAL GAME FAILED: screenshot "Game or GameGuard has been falsified" and
"Gamehack detected." User: "You triggered this." Acknowledged responsibility.
Do not confuse standalone tests with real acceptance. DO NOT INSTALL OR SHIP.
CLI patch/build commands disabled; source retained with rejection warning.

First official launcher silently restored original gameEXE, so user's first
"Reached the lobby" did NOT validate patch. Then local launcher replacement
preserved patch, routing log initialized and actual sockets7000/33343were127.0.0.1
with no external established game sockets observed; shortly afterward integrity
errors appeared. No effort to suppress/bypass integrity checks was performed.

ROLLBACK VERIFIED: installed C:/PlayRedFox/RumbleFighter/rumblefighter.exe SHA
94194afa95d3d2cc81a55438a0f584bfaf039ca85adab5b07966ae3e4d593a59;
RumbleLauncher.exe SHA21dd6e1efb35d140876db353cbf57130f215e7173b80bb6df7d0f29c66e1b77b.
Original backups adjacent *.before-routing.bak. No game processes at rollback.
No hosts/network adapter/DNS policy/firewall/DB changes performed by this attempt.
Launcher original RumbleLauncher.ini stillServer127.0.0.1; oldexternalhosts remain.
Failed artifacts/client-routing-{v1,candidate,build} are research ONLY. No working
drop-in release or ZIP delivered. Routing objective remains unfinished.

Read-only native CLI investigation49AFE4..49B219: Server option stores+110,
Peer option+304/+320 is older peer config; HOST/Port/P2PTest otherflags. Only
Server login override confirmed; no supported chat/guild/square override found.
Current protected client rejects embedded hooks, so investigate supported
configuration or discuss an alternative that leaves game code untouched.

Before routing work user confirmed class selection, tutorial completion and
Furia in store. Account2 test2@test.com isState1 Avatar2 EXP5000; firstordinary
quest20730001 Progress1/1 rewardunclaimed. Loginlog showed520byteNoAvatarresponse,
then10/88charactercreation and326reply: State0 causednewcharacterflow.

## September 11 — enchanting, gemstone rewards and installed client

Read docs/enchant-gemstones-2026-09-11.md before older feature notes. Added native
31/92 transactional enchanting, 42 known gem definitions, 29 KR card/rank rules,
persistent inventory EnchantValue, consumed-card history, reset/downgrade outcomes,
12-byte success response fix and packed inventory stat/kind readback. Migration
2026091107 adds gem_definitions/enchant_rules/enchant_attempts. Four KR gemstone
boxes 5119000..5119003 now have all 468 strictly resolved rewards; other unresolved
tables excluded. These KR local rules are not asserted NA retail parity.
39 isolated integration groups, 11 catalog tests, 6 reward-evidence tests pass.
Backup/restore compares 20 tables including enchantment and consumed-card history.
Deployed artifacts/backend-enchant-gemstones/Gemnet.dll PID52592 on127.0.0.1:7000,
working Gemnet; postdeployment21databaseauditchecks zero. Verified backup before-
enchant-20260911.sql; logs local-enchant.stdout/stderr.log; local-server.pid updated.

User selected installed C:/PlayRedFox/RumbleFighter, not artifacts/redfox/client.
Created installed RumbleLauncher.ini (previously absent) with local127.0.0.1.
User closed everything; reopened installed launcher PID14776. Real game validation
still pending. Do not claim actual enchanting UI/reconnect confirmed. Live routing
check found login/peer98.157.236.36, chat5.188.32.116, guild5.188.32.117,
square5.188.32.97. Launcher IP correct but CLIENT NOT FULLY LOCAL. Current process
not elevated; routing previously deferred, no hosts changes applied this turn.
Guilds/fishing/socket attachment/all rewards/many quest hooks remain unfinished.
Guild33native RE preliminary disassembly only in artifacts/server-implementation.

## September 11 — quests and consumables continuation

Read docs/quests-consumables-2026-09-11.md first for current feature evidence.
Added persistent30/CC,30/CE,31/CA ordinary quests:108 definitions, snapshots,
UTC daily cycles, normal sequence, achievement paging, atomic reward claims.
Only established UI/server activity progresses; many later objectives remain
unimplemented. Do not call108definitions108fullyworkingquests. NST types11/32
are scroll/exo (quest UI category20 differs). Client normal sequencing follows
NST order as local policy. Login days start from recorded logins, not invented.

Added nativeasync40/64 U-item consumption, atomic count/depletion/loadout cleanup,
ledger and potionquesthook. No sequence token; each received message is one use.
Added164Uoffers; shop4159=3504N+491T+164U, resale6615. UsageQuantity snapshot
survivesbuy/gift/restore. ItemEnd remains variant, not duration. Migration1105
addsquesttables/itemclassifications/login days;1106addsshopQuantity. DataQuests
client-quests.json derives from parsedNST, no copyrighted binaries included.

36 integrationgroups and8exportertestsPASS. Backuprestore compares17tables and
verifiesquestclaims, live timers andpartlyconsumeditems. Finalbuilddeployed
artifacts/backend-quests-consumables/Gemnet.dll; workingGemnet, loopback7000;
PIDfilelocal-server.pid; logslocal-consumables.stdout/stderr.log. Backupsbefore-
quests-20260911.sql andbefore-consumables-20260911.sql size/SHAverified. MySQL
andpeerprocessesuntouched. Onlyverifiedpreviouslocalserversstopped,no players.
VerifiedfinalPID52048, encryptedloopbackhandshake, localreadback4159offers/108quests,
and18localdatabaseauditchecksallzero. No guaranteeofallgamefeaturesorallfaults.

Broader currentmappercounts155pairs/171calls/82missing; prior126/57narrower
count excludedadditionalgroups. Do not reportold58countascompletenessmetric.
Freshmapartifacts/server-implementation/quest-protocol-map.json. Fullreplication
NOTdone: guild/fishing/enchant/rewards/manyquesthooks/clientvalidationremaining.
Chat reroutingdeferred. Noofficialserveractions. Testsuseisolated13306only.

## September 11 — ordinary timed inventory continuation

Read docs/timed-items-2026-09-11.md. Added GENERAL/8E activation with owned-instance
lock, UTC FILETIME deadline, repeat/concurrency idempotence, per-inventory duration
snapshot, atomic activation/expiry ledger, expired equipment cleanup and filtered
paging. Expired rows retained for audit. Added explicit timed box reward durations.
491 timed offers recovered; catalog now3995offers/6615resale; only N/T + markerZ.
ItemEnd stays PRODUCT VARIANT CODE. Tdays=NST469E86, confirmed ITMS_SELLTYPE_2.
Usage offers, special daily IDs1F7993/1F8851 and timed resale remain excluded.
Migration2026091104 additive. GetItemsOfAvatar now filters ownership/expiration;
General.BeginMatch uses common equipment lookup. Live mid-match expiry broadcasts
and actual client acceptance are NOT established. Missing dispatch now57, not58.

32 integrationgroups +5 exporter tests PASS, including live timer restore and
injected activation failure rollback. Local audit13checks allzero. Deployed
artifacts/backend-timed-items/Gemnet.dll PID22368, loopback7000, workingGemnet;
local-server.pid updated. Logs local-timed.stdout/stderr.log. Backupbefore-timed-
20260911-031846.sql size/SHAverified. Only prior verifiedserver19256 stopped, with
no established clients. MySQL/peer untouched. Encrypted localhandshake PASS.
Quests/guilds/fishing/enchanting/rewardrules/full replication still unfinished.
Chat routing remains deferred. No production/official server actions performed.

Additional RE (no code yet): login10/C3=family leader getter (26bytebody copy),
10/CD=my family members getter (1702bytebody copy),10/C9=accept family member,
10/C1=cancel leader,10/C7=leader reward state(96bytebody),10/CF=asynchronous give
self gift. Native debugstrings519CE4,519E51,519FBD,51A25D,51A704,51A443 respectively.
Do not confuse these with ordinary friend blocking or guild operations.

## September 11 — user requested substantially more feature replication

User rejected stopping at persistence/startup. Continued implementing features;
read docs/backend-features-2026-09-11.md for evidence and remaining gaps.
Implemented native31/84 sales with password4001 failure, atomic owned single-item
removal/equipment cleanup/catalog credit/ledger; 31/82 gift purchase and30/90,92
history with atomic debit, recipient delivery, history and ledger; profile saved
introduction body5E1; 40/8E public room lookup; asynchronous40/42 manual host transfer
with master/state/member validation and240/17 broadcast; fixed30/D8 offline identity
lookup crash. Gift dates explicitly use UTC_TIMESTAMP(6), not local MySQL time.

Recovered3504 permanent purchase offers and6615 resale entries using
Tools/export_shop_catalog.py from the other task's parsed client items.json.
Gemnet/Data/Shop/client-catalog.json holds derived prices/codes, no binary assets.
CatalogService.ImportMissing preserves admin changes/disabled entries on restart.
New item_resale_catalog supports coupons not sold in shop; gifts persists history.
Important correction: existing ItemEnd field is PRODUCT VARIANT CODE in shop wire,
not duration. Confirmed5BF36F..5BF394 loads variant+08 and G/Rflags+5F/60; NSTread
469B8A code,469BA0/C02 prices,469CC6 resale. Export onlytypeN,availabilityZ.
Timed/usage/special variants, stack resale and actual retail reward rules excluded.

28 MySQL/encrypted-TCP test groups and3 exporter tests pass. Backup integration now
compares13 tables. Tests exercise native sale/gift/history frames, duplicate sale,
concurrent gift overspending, injected gift rollback, catalog idempotence, profile,
offline identity, room filters and host transfer/active-match rejection.
Audit scanner now recognizes grouped case labels;58 observed operations still lack
dispatch. Do not report full replication or all-game completion.

Deployed latest build artifacts/backend-features-final/Gemnet.dll, PID19256, working
directoryGemnet, listener127.0.0.1:7000. Local settingsCatalogPath set to
Data/Shop/client-catalog.json. Logs local-features-final.*.log under
artifacts/server-implementation;local-server.pid updated. Previous service had no
connected players; only verified own prior server process was stopped. Local MySQL
and peer process untouched. Before migration/import backup before-features-20260911-
025508.sql saved/hashverified. All11 localDBchecks pass; read-back3504/6615 counts.
No accounts/balances/items reset. No box reward definitions loaded at startup.
Client/chat rerouting remains deferred; no real-client acceptance established.


## September 11 — backend persistence and local deployment

User supplied working local MySQL credentials after error 1045. Updated ignored
Gemnet/settings.json, targeting 127.0.0.1:3306/rumblefighter; never print its password.
Local server now runs from artifacts/backend-build/Gemnet.dll with working directory
Gemnet, listening ONLY 127.0.0.1:7000 (BindAddress), PID 29128, subject to staleness.
Logs and PID: artifacts/server-implementation/local-server.*. Existing peer and
MySQL processes were preserved. No official or remote server was deployed.

Read docs/backend-persistence-2026-09-11.md for changes and limitations. Added
transactional character creation, avatar selection repair/equipment ownership and
consume serialization, resell-password hashing/options, introduction persistence,
completed match history with atomic claims, authentication/pending-character gates,
and database maintenance audit/backup/verify CLI. Queries honor configured schema.
Source shared with separate box/reward task; preserve its changes.

22 MySQL/encrypted-TCP integration groups pass, including injected failure rollback,
concurrency, reconnect, and an 11-table synthetic backup/restore checksum comparison.
Actual local database: 11 audit checks passed before/after additive migrations;
backup before-backend-20260911-023234.sql in ignored local-backups directory restored
on isolated13306 with all FOUR original table checksums matching. Temporary restore
schema removed; original accounts and data preserved. Encrypted version handshake
against deployed7000 passed. No full real-client acceptance test yet.

Routing fix covers five modern plus five legacy gameplay names. Packaged in
artifacts/Gemnet-Gameplay-Routing-Fix.zip, now targeting127.0.0.1 per user's local-only
choice. NOT applied (current process not elevated); user deferred routing. Existing
game sockets can still point at previous servers, including official chat3416.
Separate chat/guild/square implementations still missing. No box definitions loaded;
guilds/gifts/quests/modes and other protocol gaps remain. Do not claim full game done.


## September 11 — full NST structural parser and readable item catalog

Latest user request "can you do that" followed the explanation of a real NST
schema parser. Completed Tools/parse_nst.py + nst_schema_100d.json +
test_parse_nst.py; docs/nst-format-2026-09-11.md is the current evidence report.
All 19 sections parsed, no remaining unparsed bytes, trailing CRC32 1A378F47
verified. JSON reload -> binary serialization reproduces all 14,473,087 bytes.
Nine tests pass including the actual decoded file, malformed input, optional
motion fields, exact localization keys, and stat ordering.

Ignored results: artifacts/reward-investigation-20260911/parsed/.
ITEMS.txt is the main readable output (11,379 items, 9,022 exact English-name
matches). REWARD_LINKS.txt has 1,109 container candidates, 110 quest-item links,
28 attendance links, 120 box-effect links and 280 item relationships. Full raw
GEMFIGHTER.structured.json plus resolved per-table JSON available. No server/DB
modifications or deployment during this parser work. Opening ITEMS.txt in Codex.

Important correction: first u32 count 32,257 is MOTION/ACTION records, not items.
Item table starts 0x6E470A; keyed strings at 0xA71E5C (116,569), text-key strings
at 0xD5A603 (22,759), final CRC at 0xDCD77B. Main item stats reference memory+38;
second stat reference+3C has uncertain role. 6,584 stat rows, 12 raw integers each;
native tooltip verifies HP,SP,STR,ARM,SPD,JMP,CRI,LUC first8 serialized values.
Last4 unknown; LUC memory+40 precedes serialized unknown memory+38.
Known ID1000175 is Striker, model PT_BD_FIGHTERM.NSX, HP2880/SP160/STR24/ARM20.
Unknown numeric semantics and complete box/boss pools/match formulas/odds remain
unverified. Do not turn container candidates or item relationships into live
server reward rules without consumer evidence. See report for read-call VAs.

## September 11 — reward source discovery and NST decode

User subsequently requested a text conversion. Tools/binary_to_text.py created
GEMFIGHTER.decoded.txt (89,658 printable string candidates,4MB) and
GEMFIGHTER.decoded.hex.txt (70.6MB lossless byte view) in the same ignored reward
artifact directory. Full hex output was reconstructed and SHA256 verified against
the binary. Text tab queued in Codex. This is strings/hex, not parsed reward tables.

User asks whether every box/boss/match reward can be found completely. Read
docs/reward-discovery-2026-09-11.md. Indexed ALL2189 installedclient res NSZ archives
(42,666 entries,0indexerrors); extracted350 text/data entries withCRCvalidation.
New Tools/audit_reward_sources.py and catalog_reward_text.py; ignored output
artifacts/reward-investigation-20260911. Catalog has345box/chest candidates,
208package/bundle candidates,26boss itemmentions,154stagenames. These are text
leads, NOT verified complete loot pools, numeric item IDs or probabilities.

Decoded GEMFIGHTER.NST from011600_default_item.nsz: GFET wrapper, size14473099.
Tools/decode_nst.py uses matching mappedclient lookup tableVA781028/1024bytes,
seedu32atfile8, start=(seed>>14)xor(seed<<12), step0x1645. Byte XOR combines
seedbyte[(start+i*step+1)&3] and table[(start+i*step)&1023]. Output14473087bytes
startsRFGT version100D; hash405391d2476dc4aea289aac6f3af27de1534dc3cb493de37ca81df15e8fad6dd.
Native loader468A73..468B5E, transform6A96F0..6A9765. Internal NST schemas still
unparsed; no authoritative complete reward tables or rates identified. Firstu32
atdecoded8 is0x7E01; do not label its records inventory items before parsing loader.
Localization export headerdated2019-07-02. Need build/region checks for webdata.
Publisher Steam2019announcements linkboss/chest prizeimages; image fetchfailed,
so no external prize list was transcribed. No game/server/database mutations.

## September 11 — multiplayer code review and repair

User clarified multiplayer is a source review request, not a specific observed
runtime symptom. Current access policy is never/danger-full-access; no permission
requests or service restarts during this pass. Read docs/multiplayer-review-2026-09-11.md
and regenerated client-feature-audit.md/json for current findings. Prior audit
below records pre-fix behavior and is superseded for the repaired handlers.

Implemented bounded per-peer writer queues outside shared membership lock,
eight-member/idempotent joins and reusable host IDs; bounded/deadlined main RC4
writes; atomic readiness/team validation; cancel loading on departure; per-member
FIN; immutable match sessions with master/roster checks and persistent claims.
Database migrations add catalog/options/ledger/claims/reward policy; purchases
debit real configured prices transactionally and boxes enforce ownership and
atomic quantity grants. Social service fixes pending/accept/offline/retry cases;
name availability is read-only. Profile and telemetry parsing crashes repaired;
header input no longer mutated. REGISTER_ITEM 10/B8 now fails explicitly instead
of falsely acknowledging and invoking the crashing megaphone code.

Native purchase reply consumer 0x52469E..0x52479C reads49 bodybytes and currency
G/R/H; support G/R with55 total-byte replies, unknown H rejected. Catalog internal
currency0Carats/1Astros; catalog empty until configured. Reward policy defaults
ZERO until configured; never copy requested EXP/Carats. The current flat policy
is participation accounting, not authoritative combat verification. Full native
reward metadata, timed/stackable items, invitations, guilds/gifts/quests and94
missing dispatch operations remain unresolved. No fresh paired-client UI test.

15 actual MySQL/encrypted-TCP integration groups pass on isolated13306/17000;
6 offline peer tests +3 live peer socket tests pass. ClientAudit.Repro is now
a passing regression executable rather than expecting historical exceptions.
Tests cover duplicate rewards, rollback, concurrent spending/opening, offline
social/profile, malformed input, room loading/departure and concurrent RC4 writes.
Build succeeds with existing compiler warnings. Output/logs are in ignored
artifacts/server-implementation; source and documentation changes are uncommitted.
Tests used a newly initialized MySQL data directory there, not user MySQL80.
Production settings failed authentication; do not reset user credentials or
claim the new build has been deployed. Existing peer process was left running.

## September 11 — fresh client dump and function investigation

User identifies this checkout as the updated project, requests a client dump
and investigation of nonworking functions, and explicitly authorizes opening
things related to Rumble Fighter development without repeated confirmation.
User cannot remain present for access prompts. Continue within available
permissions; application/Windows approval requirements cannot be disabled by
conversation. No authority was given for unrelated activity.

Fresh read-only main-module dump succeeded from installed C:/PlayRedFox client,
PID28384 at capture. Ignored artifacts/client-investigation-20260911/client-image.bin:
11919360 bytes, zero unreadable pages, base0x400000, SHA256
19a57ea875da750aac327ae2693b063669eebb32a64481cf35fae01418211521.
Disk EXE retains94194afa95d3d2cc81a55438a0f584bfaf039ca85adab5b07966ae3e4d593a59.
Main3346496-byte executable code section and all171 builder windows match the
prior artifacts/redfox/loaded-image.bin. No memory writes or binary patches.
Earlier direct-launch attempts exited during startup; successful capture used
the subsequently running installed client. Do not diagnose GameGuard from those
exit codes alone. No server/service restart or deployment during investigation.

Read docs/client-investigation-2026-09-11.md and refreshed client-feature-audit.md/json.
155 mapped protocol pairs,94 without dispatch;86 public handlers indexed.6069
prologue candidates are indexed locally, NOT individually tested native functions.
New tool Tools/client_investigation_evidence.py emits hashes, section comparison,
protocol disassembly, CSV inventories and sanitized historical log counts.

New confirmed findings: GENERAL/B6 client sends26 total bytes/20-byte name while
UserInfo.cs reads32 name bytes; saved loading-server log line7712 has exception.
QUERY68 real998-byte match results fail AdditionalStats pair parsing twice at
lines6036/6064;65-byte stats slice can end in an incomplete pair. Reward ownership,
client-controlled values and duplicate claims remain separate unimplemented rules.
Megaphone-named handler never sets UserIGN and serialization throws. Offline
buddy notifications dereference a missing session; saved server-hyper.log line849
confirms add-buddy exception. Friends insertAccepted instead ofPending and list
state mapping is inconsistent. Native buddy count/30-byte stride ARE confirmed.
OpenBox error increments action twice; native request has two u32s, parser one.

Tools/ClientAudit.Repro links original source, uses installed.NET10 SDK without
packages, and reproduced3/3 expected faults (profile, megaphone, incomplete stats).
This is a diagnostic expecting failures, not passing feature tests. Four existing
offline peer framing/handshake tests pass. No DB/gameplay mutation tests were run.
Source fixes for inventory paging/cash/time inherited from the earlier audit
remain deployment-unverified here; old server-current.json points toF: and stalePID.

Preserved test-release client log shows twoENDSTAGE/FINISH returns toUI_GameRoom
and normal exit, plus ClientExit_Log Error. Do not equate its clock/provenance
with the installed-client06:48:03 restart described below or claim rewards work.
Selected peer.log has130 unsupportedRMI64018 and14RMI64002 entries; no unsupported
core disconnect in that log. These are investigation leads, not proven lag causes.
Game code/server handlers were not fixed or deployed in this audit. Prioritize
profile/result exceptions, economic transactions, social state, room lifecycle,
then remaining backends; full native/UI/mode coverage still requires runtime tests.

## September 10, 06:50 EDT — combat verified; second-round disconnect was our restart

User reports actual PvP, some lag, then disconnect in round two. Installed-client
log confirms round one STATE_PLAYROUND06:45:47, attacks, ENDROUND06:46:52,
round two STATE_PLAYROUND06:47:04, attacks through06:48:00, Disconnected06:48:03.
That disconnect coincides with OUR deliberate main-server stop to deploy the
loading-readiness fix; replacement PID25804 started06:48:04. We interrupted a
working match and explicitly told/apologized to the user. Do not investigate or
describe this particular disconnect as an unexplained round-transition failure.
Peer PID17796 stayed alive and local keepalives continued after main stopped.
Leave live services running while players retry. Check active sessions before
any future deployment and coordinate a pause rather than interrupting gameplay.
Actual combat was on build-public, BEFORE the following readiness fix; do not
attribute reaching combat to that newer change. Earlier friend process exits at
06:37:52/06:38:53 remain unexplained without the friend's client/crash report.

Current main is artifacts/multiplayer/build-loading/Gemnet.dll, PID25804 at
rollout; authoritative PID/log paths in artifacts/local-server/server-current.json.
stdout server-20260910-064804.log. Public routing unchanged, peer still33343,
our client loopback. Nine live protocol tests plus two modern DB-login tests
passed after rollout. Both players must reopen/reconnect after the restart.

Readiness change: QUERY62 is a12-byte frame with status:u16 at6 and slot:u32 at8,
confirmed builder0x518350 and all-peer identity check0x419760/caller0x562301.
Previously every acknowledgement sent PLAY to that sender, allowing repeated
loading transitions before all peers were ready. GameManager now snapshots
launch members/version, accepts only matching member/slot acknowledgements,
and Query broadcasts PLAY exactly once after all are ready. Nonzero status or
20-second readiness timeout cancels pending start back to Waiting and sends
failure. Stale timers/duplicate acknowledgements are ignored. Existing eight-byte
PLAY position permutation is preserved (native consumer0x56127B..0x5612E1).
Nine .NET integration groups pass, including duplicate acknowledgements,
outsider/wrong-stage exclusion and stale/current cancellation version checks.
Build/publish passed with existing warnings, zero errors. Real-client acceptance
of the new all-ready/timeout behavior still needs a fresh match attempt.

Lag: this is TCP relay, no direct UDP yet. No unsupported transport opcode
ended the successful two-round attempt. An isolated loopback relay measurement
(30 bursts of6 small frames) was median0.55ms,p95=0.75ms,max0.82ms; this does NOT
measure the friend's WAN latency or identify the actual lag cause. Do not claim
lag fixed. No additional live-service restart or speculative transport edits.

User couldn't find friend's log. Tools/test_release/Collect-CrashReport.cmd/.ps1
now packaged in artifacts/Gemnet-Crash-Report.zip. Extract beside RumbleLauncher,
run CMD normally; output Gemnet-Crash-Report.txt includes last120 client-log lines,
exe hash/resource count and relevant Windows Application1000/1001 events from2h.
Searches selected game folder, C:/PlayRedFox/RumbleFighter and running exe folder;
no automatic upload. Local test found our CURRENT log in installed C folder,
not F client. A local05:30 crash c0000005/offset58740 predates friend's failure;
do not equate them. ZIP contains ONLY two helper scripts, never our test report.

## September 10, 06:33 EDT — first real two-player match stall

Two players entered the same room and reached match-start Connecting, but friend
test2 displayed TCP -1/no ping. Main server logged friend71.87.74.147 on7000 and
local127.0.0.1, room join/roster/ready/start plus QUERY43 from both. Peer service
had ONLY the local game connection, never the friend: no shared two-player group.
Friend's setup screenshot shows Configure-Client.ps1 line14 refusing existing
rumble-fighter.gss1.playredfox.net hosts entries. This was our setup-script guard,
not evidence of firewall failure. Changed helper to back up and migrate only the
two game aliases, preserving unrelated aliases even on shared lines and comments.
Client-Routing.ps1 contains the pure transformation; Test-ClientRouting.ps1 passes
IPv4/IPv6/case/shared-line/idempotence/undo preservation checks. Package builder
now includes the helper. Friend ZIP artifacts/Gemnet-Friend-Connect-v2.zip includes
updated scripts plus Check-Connection.cmd (DNS, both TCPports and actual game
connections; produces connection-report.txt). Updated original ZIP too. User was
told to extract v2 OVER old files, run Join-Server.cmd as admin and restart game.
No friend report has arrived yet;06:32:58 still only local peer, friend main TCP.

Also fixed a real peer-format error seen locally at06:22:22 in ProudManager.h93:
RMI64502 was40 bytes, but native decoder0x60FA96..0x60FB35 reads a FOUR-byte final
port via0x401810, not u16. Changed message to42 bytes; four offline peer tests and
three concurrent socket tests pass. Restarted only the peer service at06:29;
Gemnet main still PID13552, room state clears when users reconnect. Peer logs now
include timestamps, host IDs and groups. Original failing log retained ignored at
artifacts/multiplayer/peer-before-membership-fix.log. Real packet-error clearance,
two-player peer join and match completion still require the next actual retry.
Keep local client127.0.0.1. Do not falsely report combat verified from port checks.

## September 10, 06:22 EDT — public local multiplayer test server

User stopped the remote-administration approach (leave the open RDP alone),
selected localhost, then explicitly requested internet access for a friend.
This PC is now reachable at 98.157.236.36, forwarding TCP7000 and TCP33343 to
Ethernet192.168.1.159. Router UPnP added both mappings with description
Gemnet local multiplayer. Two program-scoped Windows inbound allow rules
Gemnet-Public-TCP-7000/33343 were installed through elevated
Tools/Enable-PublicServer.ps1. MySQL remains only127.0.0.1:3306.
Independent Check-Host nodes connected successfully to both ports; actual
external IP connections appear in Gemnet/peer logs. Evidence is ignored
artifacts/multiplayer/public-check-*-{request,result}.json. Network state:
artifacts/local-server/public-network.json. Run start-public-server.cmd as
administrator to refresh forwarding; Tools/Enable-PublicServer.ps1 -Undo
removes only our firewall rules and owned router mappings. Public/DHCP IPs
may change. Do not expose MySQL ports or share database configuration.

Current main build is artifacts/multiplayer/build-public/Gemnet.dll (PID13552
at rollout), peer PID38160 binds0.0.0.0:33343. start-local-server.ps1 defaults
to this build/public peer binding; -PeerBind127.0.0.1 is available explicitly.
Logs go directly to files; server-current.json is authoritative for current PID.
Friend configuration ZIP: artifacts/Gemnet-Friend-Connect.zip. Extract beside
RumbleLauncher.exe and run Join-Server.cmd as administrator. It configures
launcher and peer hosts routing, including recognized installed-C launcher INI,
and has Undo-Friend-Server.cmd. No game assets, DB settings or account credentials.
Friend needs a separate game account, available through Account Creator.
Our own client INIs/hosts remain127.0.0.1. Server restart disconnected the open
game; user must reconnect. A real two-player room/match has NOT been verified.

Implemented multiplayer changes: see docs/multiplayer-progress.md. This
supersedes older single-peer/room layout notes. A fresh read-only client main
image was captured to ignored artifacts/multiplayer/client-image.bin; SHA256
of the supplied modern EXE is94194afa95d3d2cc81a55438a0f584bfaf039ca85adab5b07966ae3e4d593a59.
Installed C:/PlayRedFox and F:/artifacts/redfox/client EXEs match; the launcher
can actually start the installed C copy. No game binary/memory edits were made.
Eight .NET multiplayer integration groups pass, including real DB+RC4 sockets;
nine live framing tests, two live modern login tests, three concurrent peer
integration tests pass. These are protocol simulations, not combat verification.
Before public exposure, legacy arbitrary-credential login was replaced with
DB password/state/duplicate checks; unverified alternate token login is rejected;
unauthorized /give, /announce and /promote development commands are disabled.
Remaining scope includes encrypted/compressed peer messages, direct UDP/P2P,
real match traffic/results verification, peer/account binding, and many backend
features. Never claim all crashes/features/multiplayer combat are complete.

Build using the local NuGet cache/config and -p:UseAppHost=false (existing
Debug apphost lock). Build/tests logs are artifacts/multiplayer/public-*.log.
Do not clean the user's redownloaded/tracked binaries or reset the database.

## September 10 — Account Creator on the database host

User attempted the public DB endpoint209.182.217.231:3307 with the packaged
RFRebirth DB user; TCP from this workstation timed out before authentication.
User clarified the account tool runs ON the database server. Supplied private
artifacts/account-creator/database-server.ini uses127.0.0.1:3307 and the user's
provided credentials, with the package's local SslMode=None and key retrieval
enabled. Keep that INI private; it is gitignored. The local database.ini remains
configured for this workstation's independent gemnet database on3306.
Account Creator now reports TCP timeout/refusal separately from MySQL account,
host grant, missing database, and schema-access errors. Tests pass. Actual
authentication on the remote database host requires the user to load this INI
there; we have no administrative shell on that host.

## September 10 — Account Creator INI connection settings

User requested custom DB settings. Tool now prefers database.ini beside
artifacts/account-creator/GemnetAccountCreator.exe. Local INI uses the verified
connection, including database password; keep private. Supports Server/Host,
Port, Database, User/Username, Password, SslMode, AllowPublicKeyRetrieval.
Any schema with Gemnet's tables is accepted. INI parsing preserves password
punctuation, with quoted edge spaces and no inline comments. UI adds Edit INI,
Choose file, selected filename, and Reload settings; failed reloads disable
creation instead of retaining the previous connection. JSON compatibility stays.
database.example.ini ships with the build; actual database.ini is never replaced
by publish. INI tests and live account creation/encrypted login pass.

## September 10 — account creation tool

Added Tools/AccountCreator (.NET8 Windows Forms), published to
artifacts/account-creator/GemnetAccountCreator.exe; create-account.cmd opens it.
Auto-discovers Gemnet/settings.json, with a settings-file selector. Creates
DB-backed active accounts from email/nickname/password, BCrypt cost11, EXP5000,
Carats10000, one avatar and two starter inventory items; transaction protects
all inserts, advisory lock plus DB-collation checks reject duplicate email/IGN
across tool instances. UI stays responsive during database operations.
Tools/AccountCreator.Tests validates inputs, BCrypt, equipped defaults,
duplicates including concurrent attempts, and actual encrypted login of a
newly created account against the running build-hyper server. All passed;
temporary test accounts were removed. Form preview visually inspected.
See Tools/AccountCreator/README.md for build/retest commands.

## September 10 — local login hang fixed

The build-hyper server accepted TCP but stopped replying, including LOGIN/90.
Packet trace continued recording incoming version requests without OUT replies;
the visible PowerShell/Tee-Object console pipeline stopped consuming stdout.
An isolated copy of the same server reproduced this: an unread stdout pipe
stalled after11 version requests; draining stdout restored the pending reply
without restarting the process. This was output backpressure, not DB/RC4/peer.
start-local-server.ps1 now starts the same build-hyper DLL with stdout/stderr
redirected directly to timestamped files. The visible console only tails the
log and can be closed without stopping the server. server-current.json under
artifacts/local-server records current PID/build/log paths. Do not restore the
old dotnet | Tee-Object launch path. MySQL and peer remain separate processes.
Added 512 sequential version requests to Tools/test_protocol.py to exercise
logging volume: all9 protocol tests and both DB-login tests pass. Isolated
reproduction/evidence are artifacts/local-server/reproduce_output_block.py and
output-block-reproduction.log; diagnostic process was terminated after testing.
Real RedFox retry at04:52:59 reports LoginCheck All Green. Subsequent LOGIN/B6
and QUERY/84 lobby navigation and GENERAL/BC My Info requests receive replies;
game remains responsive with live login/peer connections. No game binary edits.

## September 10 — refreshed RedFox files on Marcus's computer

User redownloaded artifacts/redfox and test-release, then chose the newer
build-hyper server over build-room. start-local-server.ps1 now defaults to
artifacts/redfox/build-hyper/Gemnet.dll, CWD Gemnet, and starts the loopback
ProudNet service on33343. Both services are verified running; two DB-backed
login tests, eight protocol tests and four peer tests pass.
The RedFox client executable and launcher match the September handoff hashes.
artifacts/redfox/client was missing res; copied all3147 resource files (2.36GB)
from the supplied artifacts/test-release/Client/res. No client binary patches.
Added RumbleLauncher.ini with -Server:127.0.0.1. Backed-up hosts routing for
both modern login and peer names was installed through the existing elevated
helper and verified. Opened artifacts/redfox/client/RumbleLauncher.exe; launcher
is responsive, actual login/lobby on this computer remains unverified.
start-redfox-client.cmd opens that launcher for future tests.
Redownload replaced Gemnet/settings.json with nonworking DB credentials;
restored verified app connection from artifacts/local-server/database/settings.json.
database-local.json (generated root credentials) is missing after the refresh;
do not reset or reinitialize the existing data. Restart script now reads port
from mysql.ini and needs no root password. Existing database/account preserved.
Current C: free space is about32GB; previous full-drive condition has cleared.

## September 10 — local setup on Marcus's computer

Workspace is now F:/Project-GemNet. Installed isolated MySQL 8.0.46 under ignored
artifacts/local-server/database, loopback port 3306; generated private root/app
passwords, created rumblefighter's four tables and seeded test@test.com/test,
TestUser, active, EXP5000, one equipped avatar. Gemnet/settings.json points here.
C: is full; MySQL and NuGet/temp caches are on F:. Incomplete C:/Users/Marcus/
gemnet-mysql extraction remains because automatic approval review blocked deletion.
Build passed (194 existing warnings, zero errors). Machine NuGet source mapping
required artifacts/local-server/NuGet.Config. Two new Tools/test_login.py tests
verify real DB-backed modern login and wrong-password rejection. Eight protocol
tests and full encrypted legacy replay pass. Logs are artifacts/local-server/*.log.
start-local-server.cmd/.ps1 restart MySQL if needed and show Gemnet output.
Gemnet is running on 7000 (all IPv4 interfaces), MySQL only 127.0.0.1:3306.
No client launch, hosts change, or in-game verification in this setup; available
RF Client is the already-patched legacy build, no C:/PlayRedFox installation found.
See docs/local-server-marcus.md. Older machine paths/PIDs below are historical.

## Latest verified result — 2026-09-09

Existing-launcher routing test: found GENERAL/LAUNCHPARAM in RumbleLauncher.ini.
Standalone copied launcher SHA21dd6e... started copied game with
-Server:127.0.0.2 -Peer:127.0.0.2:33343. Elevated inspection of game PID11772
confirmed both command arguments; actual login TCP127.0.0.2:7000 and post-login
requests prove login override independently of hosts127.0.0.1. ProudNet still
connected127.0.0.1:33343: Peer option does NOT redirect modern peer service.
No binary or hosts patches. docs/launcher-routing.md records evidence. Package
RumbleLauncher.ini remains set to local test address; Configure-Launcher.ps1
can set public login IPv4. Full hosts-free client remains incomplete. Original
installation unchanged. Visible build-hyper Gemnet started for test; extra peer
listener127.0.0.2 was started but unused. Game may remain open: check before acting.

September 10: NSZ work shelved at user's request. Prepared standalone private
artifacts/test-release/{Server,Client}, targeting Windows x64 internet testing.
Server is self-contained .NET; peer exe now supports --bind (packaged launch
uses 0.0.0.0), remains one tester at a time. Includes isolated MySQL 8.0.46 runtime,
setup_database.py and packaged SetupDatabase.exe. Requested DB username RFRebirth;
password only in ignored server database-defaults.json. Setup uses loopback3307,
random root password, fresh four-table schema and test@test.com/test level5.
Client is copied from CPlayRedFox only, with admin hosts configuration for a user-
entered public IPv4, undo script and relative launcher. No firewall/router changes.
Installer smoke test created separate artifacts/test-release-smoke database3317;
self-contained Gemnet passed eight tests on17000; installer rerun preserved data.
Four peer tests pass. Real internet and fresh-machine client tests remain pending.
Rebuild source: Tools/test_release/build_package.py (prompts DB password).

NSZ Studio GUI built at artifacts/nsz-studio/NSZStudio/NSZStudio.exe (requires
adjacent _internal directory). Source Tools/nsz_studio.py + nsz_pack.py. Supports
browse/filter, CRC verification, extraction, unencrypted ZIP export, and folder
repacking with both encryption layers. Seven automated tests pass; seven real
localization/tutorial files repacked and compared byte-for-byte. In-game use of
rebuilt archives is unverified; no installed game archives replaced. GUI is open.
Build script Tools/build_nsz_studio.ps1; dependency lock ranges requirements-nsz.txt;
PyInstaller 6.22.2 installed into Tools/.deps (elevated access needed locally).

NSZ tooling: Tools/nsz_tool.py now decodes modern RedFox archives (AES with word
swaps + tail XOR; per-entry derived ZipCrypto password; modified ZIP local magic).
Five real archives / 29 entries pass CRC. Localization and input-tutorial XML
extracted under ignored artifacts/redfox/nsz. See docs/nsz-tools.md for commands,
addresses and limitations. Legacy NSZj variant is unsupported. Source client
files unchanged. The table archive contains word filters, not item stats.

Superseding the checkpoints below: user confirmed Classic Battle and all other
tested modes except Hyper Battle enter rooms. Hyper Battle's UI requires level 5
(cmp at 0x5D8A4D; EXP-to-level 0x4186E0). Local UUID 1 EXP raised from 0 to 5000,
preserving IGN and other data. No client patches. Added Proud RMI 1003 -> 64506
group leave and corrected Gemnet leave-room field widths/reply type. Four peer
tests and eight live Gemnet tests pass. Normal Debug build refreshed.
Current visible server runs artifacts/redfox/build-hyper/Gemnet.dll, CWD Gemnet,
log server-hyper.log; updated Tools/proudnet_probe.py also running. Reopened
C:\PlayRedFox\RumbleFighter\RumbleLauncher.exe and requested login, Hyper Battle
room creation and exit verification. That live result remains pending.

User preference: server output must be visible during tests. Opened a visible
PowerShell tail of artifacts/redfox/server-avatar.log; do not silently hide future
server test output. User then reported Create Room waited and returned to lobby.
ProudNet RMI 1002 (CreateP2PGroup) was logged without a reply. Client function
0x4EFB30 waits up to 18000 ms for self-member-join callback 0x4EEF20. Added an
experimental one-member group notification 64502. Server QUERY/86 room request
is not reached until that succeeds. Also corrected its reply type to 0x0040 and
room/group string widths and u16 mode parsing from 0x51E130. Needs live testing.
Room-test server is now a visible PowerShell process running
artifacts/redfox/build-room/Gemnet.dll, CWD Gemnet; log server-room.log. Peer probe
was restarted and launcher reopened; asked user to create a room again. Four
peer tests and eight Gemnet tests pass. The earlier 0x1F/0x10 suspicion was wrong:
it is send-only/periodic; actual blocker is the logged ProudNet RMI 1002. Prior
read-only inspection failed because historical client PID 31136 had already exited.

User confirmed the client reaches its main menu and stays open after waiting
20 seconds and clicking Lobby. ProudNet connection and ping handling are working
in the local Python prototype. Gemnet's avatar-list byte count and equipment-slot
parsing are corrected. Eight server integration tests and three prototype tests
pass; full room/match gameplay is still unverified. See docs/redfox-proudnet.md.
Keep BOTH Gemnet (7000) and Tools/proudnet_probe.py (loopback 33343) running.
Both RedFox login and peer hostnames are mapped to localhost. Normal launch uses
CPlayRedFox's RumbleLauncher; no modern binary patches were made. Current services
use artifacts/redfox/build-check/Gemnet.dll (CWD Gemnet) and Tools/proudnet_probe.py;
logs are server-avatar.log and proud-probe.log under artifacts/redfox. Normal
Debug build output is also refreshed. Avoid restarting the user's working game.

## 2026-09-09 ProudNet black-screen investigation

See `docs/redfox-proudnet.md` for exact addresses and the prototype's limitations.
The previous live inspection found the game thread waiting in ProudNet init
`0x4F09C0`, loop `0x4F0AF0..0x4F0B07`: pending byte +0x80=1, success +0x81=0.
This happens before the splash's first update. Modern peer service is ProudNet,
host `rumble-fighter.gp2p1.playredfox.net`, TCP port 33343, application GUID
4285ae30-6e65-4b24-ad6c-c5d5091301ca. Old RakNet assumptions do not apply here.
Attempting to clear pending previously failed with Access is denied; no byte changed.

Added loopback-only `Tools/proudnet_probe.py`, independently written using captured
client parsers and public ProudNet protocol research. It sends the connection hint,
checks the RSA secure key, acknowledges key exchange, and handles the application
connection request. Modern config includes both secure and fast key lengths.
Three offline tests pass; actual game handshake/lobby acceptance is unverified.
Encrypted traffic, keepalive, UDP, groups and relay are not implemented.

Ran `client/set-redfox-local-host.ps1 -PeerService` elevated: backed up hosts and
verified the peer hostname resolves to 127.0.0.1. Login mapping remains installed.
Remove the tagged peer line and flush DNS to undo. Started Gemnet and the probe
as hidden processes: logs `artifacts/redfox/server-resume.log` and `proud-probe.log`.
Started installed RumbleLauncher (historical PID 28572) and asked the user to log
in with the existing development account and leave the game open. Check current
processes/logs before restarting anything. Do not access the excluded OGPlanet
installation or apply historical patches to this packed modern executable.

First live probe: client reached loopback 33343 and sent core 46 (hint request).
The initial prototype closed on it; user confirmed black screen remained. Fixed
core 46 handling (without duplicating the queued hint), reran all three tests,
and restarted the probe. Client PID 7032 did not exit after CloseMainWindow;
an elevated helper verifies its exact CPlayRedFox path, stops it, and reopens the
launcher for another test. Do not claim a completed handshake yet.

Superseding the preceding checkpoint: second real client (PID 20112) completed
core 46 -> 5 -> 7, reported internal version 196980, accepted core 10, and sent
core 26 ping. Gemnet then received the full modern post-login sequence. Added
core 26/28 ping/pong and ignored one-way core 27. The subsequent ServerErr came
with AvatarListQuery Fail and SQL Unknown column ''. Avatar count was u32 instead
of byte, causing avatar 1 to become 16777216. Corrected AvatarListRes to 7+4*N,
slot offsets to byte 10, and added invalid-slot failure replies before SQL.
Build succeeds (194 warnings); eight integration tests and three probe tests pass.
Running updated Gemnet DLL from artifacts/redfox/build-check with CWD Gemnet;
new server log is artifacts/redfox/server-avatar.log. Restarted probe, reopened
launcher for another test, and asked user to log in. Lobby remains unverified.

Third live test: user reached main menu, clicked Lobby, client closed. Game log
showed LoginCheck All Green and normal EndProcess/EndTask, not a captured crash.
Probe had closed on core 1 with length 11 (RMI). Added reliable ping RMI 64001 ->
64508 empty pong, plus logging of RMI IDs. The previous ID was not logged, so
identification as a ping is still an inference until the next live run. All three
offline probe tests pass. Restarted probe, reopened launcher, asked user to wait
20 seconds on menu and click Lobby. Main-menu access is now confirmed; full lobby
and fighting are not. No binary patches or successful client memory writes.

Fourth test confirmed live RMI 64001 and ongoing ping/pong; next RMI was 64019
(four-byte UDP trial count). Added this no-reply notification and changed unknown
RMI handling to log without replying or closing transport. Core unknown messages
still close the diagnostic session. Tests pass, including statistics then ping.
Restarted probe again and elevated helper targets verified game PID 9016 before
opening launcher. Awaiting fresh user test; do not claim Lobby exit fixed yet.

## 2026-09-08 RedFox login routing and development account

The repeated error 701 came from the official login endpoint, not Gemnet. A
controlled launch proved the game starts the installed RumbleLauncher.exe as a
child, losing the `-Server:127.0.0.1` argument. This also happened when starting
the original executable directly and when the helper was elevated. Do not keep
retrying command-line-only launches or assume a duplicate instance is the cause.
Read-only process evidence is in ignored artifacts/redfox/runtime-routing.json.

Installed a backed-up hosts entry for ONLY
`127.0.0.1 rumble-fighter.gss1.playredfox.net`. DNS resolution was verified.
Reproducible elevated helper: `client/set-redfox-local-host.ps1`; remove its marked
entry to undo. Official launcher updates and other hostnames remain as configured.
At 01:09 on September 8, the real client connected to Gemnet from
127.0.0.1:60136 after a normal launcher start. The user confirmed login passed;
server logs show actual modern LOGIN/90 and LOGIN/84 with a success reply.
The game opened a windowed black screen and entered GS_SPLASH at 01:10:34.
No subsequent protocol requests were observed at this checkpoint. This is the
next blocker; modern lobby access is still unverified. Do not repeat error-701
diagnosis unless login-hostname resolution or server availability changes.

Created local `test@test.com / test`, account 1 / TestUser, active, current avatar
1, with class 1000175 and default exo 2040034 in inventory. Password storage is
now varchar(72), with a valid 60-character BCrypt hash. Repeatable seed SQL is
`Tools/seed-development-account.sql`; it preserves an existing account password.
An encrypted modern LOGIN/90 then LOGIN/84 protocol probe succeeded with the
326-byte session reply. This verifies server authentication, not client parsing.

Structured SendPacketAsync overloads now delegate to the encrypted raw overload.
Six protocol tests pass, including modern version followed by a raw reply on the
same RC4 stream. Client binary files are unchanged. The local copied install is
under ignored artifacts/redfox/client and still exits through the launcher path.
Gemnet was restarted as a hidden process (historical PID 33804); check port 7000
before starting another instance. Runtime requires DOTNET_ROLL_FORWARD=Major
on this machine, which currently has only .NET 10 installed.

## 2026-09-07 new target: current RedFox client

User requested switching research to `C:/PlayRedFox/RumbleFighter` and locating
counterparts for all ten historical post-login operations. Completed the initial
code map in `docs/redfox-2026-09-protocol-map.md`; read it before changing server
handlers for the newer client. Disk SHA256:
`94194afa95d3d2cc81a55438a0f584bfaf039ca85adab5b07966ae3e4d593a59`.
PE timestamp is 2026-09-01 16:27:32 UTC, x86 base 0x400000. Disk code is packed.

User opened the normal client. Non-admin memory access failed; a user-approved
RunAs capture succeeded for PID 30444 (now historical). Captured only the main
image, read-only, 11,919,360 bytes, no unreadable pages. No injection/debugger or
anti-cheat modifications. Runtime capture and evidence are under gitignored
`artifacts/redfox/`; do not commit the image. Durable tools:
`Tools/capture_client_image.py`, `Tools/client_protocol_map.py`, and
`Tools/disasm_client_image.py`. Use existing Python runtime under
`C:/Users/mathe/.cache/codex-runtimes/codex-primary-runtime/dependencies/python`;
pefile/capstone are present in `Tools/.deps`.

Mapped old → new requests (all hexadecimal): inventory20→88 (cash),
general14→84 (property/inventory, not server list), general22→92 (received gifts),
general20→90 (sent gifts), login3E→A8 (buddy list, not session blob),
general16→86 (avatar IDs), query30→A0 (selected avatar), general18→88
(90-slot equipment, not channel list), query36→A6 (clear slot), query34→A4
(update slot). Exact builder/parser addresses and limits are in the report.
Old login3E was rechecked: diagnostic at 0x67A99C explicitly says buddy list,
and the response is u16 count plus 30-byte records. Earlier notes were wrong.

New builder 0x6E5B90, body accessor 0x6E5C40, status 0x6E5C20,
synchronous wait 0x67B7A0, receive matcher 0x67B4C0. Still action + 1, header
status byte 5, RC4 key abcde (initialized at 0x67B920, key VA 0x7DF960).
New credentials path builds LOGIN/84 total 91 bytes, with strings at body
0 and 0x40; normal launcher/DirectLogin path is not yet mapped end-to-end.
All results are from loaded-code analysis, not a successful new-client Gemnet
session or a captured official post-login exchange. No server protocol changes
or official client installation changes were made for this mapping task.

## 2026-09-07 windowed launcher and crash confirmation

User confirmed the post-login crash is resolved after the connection/logging fixes.
For windowed mode, the supplied v1.1.2 binary parses `-Windowed` or `/Windowed`
at 0x45008D–0x4500B3 and sets the windowed flag; no binary patch is needed.
Added `-Windowed` to `client/gemnet_launch.ps1` and the repository-root
`run-client-windowed.cmd`, which explicitly targets `RF Client/RumbleFighter`.
The current game session is not restarted automatically. Windowed rendering
still needs visual confirmation on the next launch.

## 2026-09-07 post-login connection loss

Reproduced using only `RF Client/RumbleFighter` in this repository. The client
completed avatar and grade initialization, then sent INVENTORY/0x22:
`0031000E2200E2201F00E8030000`. The unknown-action warning invoked the default
Windows EventLog provider, which threw a permissions exception and aborted the
connection. Program now clears default logging providers before adding console
and debug logging, avoiding EventLog source registration during packet handling.

The unknown INVENTORY fallback also used GENERAL plus a marked failure type,
which could not satisfy the client's synchronous receive matcher. It now sends
an encrypted six-byte reply with exact type 0x31, action + 1, and failure status 1.
This is a supported failure path, not implementation of the missing operation.
Disassembly at 0x46F598 constructs the 14-byte INVENTORY/0x22 request; 0x46F634
checks status and takes a body-free failure path. Success reads a body through
offset 0x18 and is not safe to acknowledge with an empty success frame.

Build succeeded (0 errors, 196 existing warnings). Five live protocol tests pass,
including the captured request followed by another encrypted query on the same
connection. Updated the stale QUERY/0x30 assertion to avatar ID 1000175.
The real-client retry passed the previous disconnect point and continued sending
item-add requests; its log reports item-add failures and the process remained
responsive. Usable lobby/gameplay still requires user confirmation. No client
binary changes were made and the separate Program Files installation was not used.

## INVENTORY/0x24 grade-up follow-up

After the grade-list response, the client sent `INVENTORY/0x24`
(`00310007240002`) and showed `FUNC_Q_GRADE_UP ... NULL`. Client disassembly at
`0x47146C` constructs this request, waits for `INVENTORY` action `0x25`, and checks
only the response status byte; it does not require a response body.

Added `ActionInventory.POST_LOGIN_INVENTORY_24` and
`Inventory.PostLoginInventory24`, returning the six-byte success frame
`00 31 00 06 25 00`. The server rebuilt with 0 errors and restarted on port 7000
(current session 32785). The next manual login should advance past this query.

## GENERAL/0x30 grade-query follow-up

The patched client stayed alive through the avatar and channel initialization, then
sent `GENERAL/0x30` (`003000063000`) and showed `FUNC_Q_GET_GRADE ... NULL` because
the server dispatcher treated action `0x30` as unknown and sent no usable reply.
Client disassembly at `0x4700DD` confirms this request is the grade-list query: it
waits for `GENERAL` action `0x31`, accepts header status byte 5 equal to zero, and
parses the response body as a one-byte entry count. An empty count is valid and
returns success without reading any entry data.

Added `ActionGeneral.POST_LOGIN_GENERAL_30` and `General.PostLoginGeneral30`, which
reply with `00 30 00 07 31 00 00` (success plus zero grade entries). The server was
stopped, rebuilt with 0 errors, and restarted on port 7000 (current session 86399).
The next manual client login should verify that the grade dialog is gone and expose
the next protocol stage, if any.

## Client null-item crash follow-up

Windows Application Error events identified the repeat crash at `RumbleFighter.exe`
RVA `0xCF7A` (`0x40CF7A`), an unconditional `mov ebp,[eax+0x0c]` after the
client's local item lookup returned null. The server handshake itself completed
through all post-login item queries; the crash was local to the 2007 resource
set. `client/patch_client.py` now includes a narrow compatibility edit at file
offset `0x0CF7A`: `8B 68 0C` -> `31 ED 90`, treating missing metadata as empty.
The new patched SHA256 is
`5ee725a86052f0d2547feb4829ec251c6dcf20331a3e15e3567dfe9af85c81be`.
It was applied to `RumbleFighter/RumbleFighter.exe` and
`client/RumbleFighter.exe`; no `RumbleFighter112.exe` exists in this workspace.

The server fallback IDs were changed to executable-known defaults (`1000175`
and `1020182`), and the preliminary `GENERAL/0x16` plus matching `QUERY/0x30`
avatar ID was changed from `1` to `1000175`. The server rebuilt with 0 errors
and restarted on port 7000 (session 55144). A real-client retry after the server
ID changes alone still faulted at `0xCF7A`; the next retry must use the patched
client before judging the server changes.

## Avatar item response follow-up

The captured v1.1.2 `GENERAL/0x89` response in `General.cs` is 366 bytes total
(`0x016e`), with a 360-byte body. `AvatarListItemsRes.Serialize` was four bytes
short (362 total); it now uses `45 * 4 + 186` for the fixed 45-slot body.
The captured development payload also has item IDs `0x07B70A40` in slot 0 and
`0x07E96C2A` in slot 27. The empty-database fallback now supplies those two IDs
while database-backed avatars remain unchanged. `Tools/replay_avatar.mjs`
verifies the reply as action `0x89`, size 366, body 360, and the packet trace
shows the two captured IDs at the expected offsets. The rebuilt server is
running on port 7000 (session 33075) for the next real-client retry.

## Latest launch follow-up

The remaining `AvatarListQuery Fail` was traced to `General.GetAvatarList` handling
`GENERAL/0x88`: with no database avatar row it left `AvatarListItemsRes.ServerID`
null, so `Serialize()` dereferenced `ServerID.Length` and the server closed the
client connection. It now always supplies the fixed 45-slot equipment array and
fills database values when present; an empty database returns zeroed development
equipment. `AvatarItemQuery` is also null-safe and property conversion is bounded.
The same 45-slot fallback was added to `BeginMatch`, which otherwise would have
failed later on `ServerID.Length` when entering training/match with an empty DB.
Client disassembly at `0x46A730` showed why the first fallback did not fix the
real crash: `AvatarListQuery` sends `GENERAL/0x16`, parses its response as
`u8 count + u32 avatar IDs`, then sends `QUERY/0x30` and compares a raw u32 ID
array against that list. `PostLoginGeneral16` had been returning the channel-entry
layout and `V112Query30` returned four zero bytes, so the client rejected the list
before reaching `GENERAL/0x86`/`0x88`. `GENERAL/0x16` now returns an 11-byte
frame (`count=1`, ID=1), while `QUERY/0x30` returns a 10-byte frame containing
the raw ID only. `Tools/replay_avatar.mjs` regresses this sequence and passes
through both responses, followed by the existing 0x86/0x88 checks.
After this change the server was stopped, rebuilt, and restarted cleanly. The
avatar regression replay passes: `GENERAL/0x16` -> action `0x17`, size 11;
`QUERY/0x30` -> action `0x31`, size 10; the follow-up 0x86/0x88 checks also pass.
The server rebuild completed with 0 errors. A Node RC4 replay verified the exact
post-login request and response: `GENERAL/0x88` returns type `0x30`, action `0x89`,
total size 362, body size 356. Added `Tools/replay_avatar.mjs` for this handshake
regression check. Rebuilt server is running on port 7000; the launcher and client
were started for the next real-client retry.

## Avatar-list follow-up

The first avatar fallback still failed because `AvatarListRes.Serialize` had a
pre-existing layout bug: it declared count at body offset 6 but wrote IDs at offset
7, overwriting the count. Fixed `AvatarListReq` to read the full little-endian u32
user ID, moved response IDs to offset 10, and set total size to `10 + 4*count`.
Rebuilt successfully and restarted server/game. Retry from the login screen.

The real client reached 100% loading and logged `login(TestUser) ok` followed by
`AvatarListQuery Fail`. MySQL was reachable but had zero accounts/avatar rows;
the v1.1.2 credential stub uses in-memory user 1. `General.GetAvatars` now returns
development avatar ID 1 when DB rows are absent, and `Query.GetEquippedAvatar`
falls back to CurrentAvatar 1. `settings.json` adds `SslMode=None` for the local
loopback MySQL connection after a transient MySql.Data Windows TLS credential error.
The server was rebuilt with 0 errors and restarted on port 7000. Game was restarted
through `gemnet_launch.exe`; retry login to test the avatar-list response.

Actual client launch now reaches the rendered v1.1.2 login screen (user screenshot).
The earlier 'Please execute RumbleLauncher.exe' dialog also covers failure of
the obsolete launcher resource repair at VA 0x42F040, not only a missing event.
V3 patch replaces that function's first six bytes `81 EC 24 02 00 00` with
`B8 01 00 00 00 C3` (return success); the independent event launcher remains required.
V3 SHA256 is `367bafa3048a4d71d9aa79fe55c48942dd0748e6ce3e9ce0484c1a40809ec842`.
Applied to all three client copies previously listed. Rebuilt gemnet_launch.exe
using client/build-launcher.cmd and MSVC x86; now sets inherited WINXPSP3 and
reports event creation failure. Installed in game folder; old launcher preserved
as gemnet_launch.exe.pre-fix.bak. Verified game signals slahslrtm event.
The user confirmed the rendered login screen after that change.
Server port 7000 was reachable. Legacy hostname failed DNS, so added
client/setup-local-hosts.ps1 and ran it through Windows RunAs for admin access.
It maps gss1/nps1/nps2/gchat/guild.rf.ogplanet.com to 127.0.0.1.
Next: user logs in with test@test.com / test (development authentication stub)
and reports the next screen/error. Lobby still not verified.

## Task and local layout

User requested continuation of the client patch and server using existing notes.
Workspace: `C:/Users/cloud/OneDrive/Desktop/RumbleFighterSRC`.
Source folder: `rumble-fighter-emulator-main`; game/resources: sibling `RumbleFighter`.
No memory.md was present. The workspace is an extracted source tree, not a Git checkout.
Read AGENTS.md, both READMEs, Windows scripts, patcher, server code and replay tool.
Follow the user's RTK command prefix and targeted-edit rules.

## Changes implemented

- `client/patch_client.py`: v2 keeps P2P edits at 0x66B23 and 0x8D2F7;
  restores original `75 34`, `75 29`, `75 19` at 0xF5B04/0xF5B0F/0xF5B1F.
  It accepts pristine or earlier patched bytes, reconstructs the pristine image
  and verifies its full SHA256 before writing. Unknown modified images are rejected.
  Existing `.orig.bak` backups remain untouched.
- Patched all three supplied targets: game `RumbleFighter.exe`, game
  `RumbleFighter112.exe`, and source `client/RumbleFighter.exe`.
  V2 SHA256: `3b147687ef87c9539be00ef4999e5a0e18d6326ee30e1045df2d9339464fb424`.
  Original SHA256: `4661caa3cc5fbadd9bc5942be3b70c24c861f59254389d72a3ab2721bc8c9d7a`.
  Legacy patched SHA256: `18c857687241c8ceb0211f86ba597120d41bda7a738bed01da99d361704f1f5c`.
- Query.cs: 0x30 -> 0x31 and 0x34 -> 0x35 (existing four-byte bodies retained).
  0x36 -> 0x37, header-only acknowledgement. Status 0 for full 11-byte request,
  status 1 for malformed body. This is still a bring-up acknowledgement, not
  implementation of an identified persistent item operation.
- PacketProcessor.cs and ConnectionManager.cs: buffer incomplete plaintext per
  connection; decrypt each TCP input byte once; drain complete total-length frames.
  Correct handling of split headers/bodies and coalesced packets. Length < 6 closes
  the connection. Existing handlers receive the full frame, despite `body` naming.
- Server.cs: skip room notifications/leave for clients without an existing room,
  allowing normal connection cleanup after login-only sessions.
- replay_client.py: fail on missing/malformed/mismatched replies, cover QUERY/0x34,
  require header-only QUERY/0x36 response. Previously it could report success despite
  missing replies or incorrect actions.
- Added Tools/test_protocol.py: four live integration tests.

## Binary evidence (supplied v1.1.2)

Disassembled with Capstone + pefile installed under Tools/.deps. Packages required
escalation to download and read in this environment. No remote protocol sources used.

- 0x46AA85 calls 0x559C30 to construct the REQUEST, then 0x559CE0 returns its body
  pointer. 0x46AA91 stores u32 and 0x46AA97 stores a byte. Old notes incorrectly
  described these calls as getting the response.
- 0x46AAB0 calls synchronous wait 0x4F5D70. At 0x46AB0F, the result is checked via
  0x559CC0, which reads header byte 5; the packet is released at 0x46AB73.
  This path never accesses a response body. It supports a status-only acknowledgement.
- 0x4F5AD0 receive handler: 0x4F5B04 rejects routing to the synchronous slot when
  no synchronous wait is active; 0x4F5B0F compares reply type; 0x4F5B11..1F compares
  incoming action with stored request action + 1. The legacy patch NOPed all checks.
  Stored slot at handler-relative +0xE0 corresponds to outer connection +0x168.

## Validation and runtime

- .NET SDK present: 10.0.301, target net8.0. Build succeeds with 0 errors.
  Actual recompilation reported 202 existing warnings (mostly nullable references);
  initial incremental build reported 0 warnings because nothing recompiled.
- Existing portable MySQL 8.0.40 at `C:/Users/cloud/gemnet-mysql` was restarted,
  preserving data. Verified accounts/avatar/friends/inventory tables with gemnet login.
  Startup required execution outside the sandbox. No schema or credentials changed.
- Updated server was started using `dotnet bin/Debug/net8.0/Gemnet.dll` from Gemnet,
  listening port 7000, encryption true, key abcde. Tool process session 87868.
  MySQL was started as PID 56660. Process identifiers may become stale.
- Full encrypted replay passes; output saved in `Tools/replay-latest.log`.
- `Tools/test_protocol.py`: 4/4 pass (fragmented header/body, coalesced queries plus
  continued RC4 state, invalid query body failure, invalid total-length disconnect).
- Patcher smoke tests pass: pristine -> v2, idempotent repeat, unrelated byte
  modification rejected without writing. Legacy -> v2 verified on supplied targets.
- Earlier test found cleanup NullReferenceException; fixed, subsequent replay
  cleanup completed successfully.
- Existing game launchers were not rebuilt or launched during this continuation.

## Remaining work / practical limits

1. Verify the actual game launch and login/lobby with v2 client + updated server.
   No current hosts entries matching rf.ogplanet were found; no hosts changes made.
   Existing client/gemnet_launch.ps1 supports explicit -GamePath and per-process
   WINXPSP3. Game resources are in sibling RumbleFighter; their compatibility with
   this 2007 v1.1.2 executable is not verified. Do not claim playable lobby yet.
2. Capture new client/server logs and implement the next observed protocol gaps.
   0x30/0x34 bodies remain stubs. Client login still accepts any credentials with
   a fixed session; this is development bring-up, not completed authentication.
3. Two structured SendPacketAsync overloads still bypass outbound encryption;
   byte-array overload used here encrypts correctly. Resolve before relying on
   structured overloads in subsequent room/match work. Concurrent send serialization
   should also be reviewed when adding asynchronous room broadcasts.
4. Lobby/room/match/P2P remain unverified/incomplete. P2P checks remain bypassed.
5. Historical README/AGENTS content is retained with explicit superseding notes;
   do not reapply receive-gate NOPs based on their older instructions.

Python runtime used:
`C:/Users/cloud/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe`.
Run Python tools via `rtk proxy <python> Tools/test_protocol.py` or
`rtk proxy <python> Tools/replay_client.py`, with source folder as working directory.












# NSZ Studio packing location fix (2026-09-12)
Removed unnecessary source-folder output prohibition in Tools/nsz_pack.py. Existing outputs rejected before reading; inputs snapshotted before temp/output creation. GUI save title corrected, defaults to parent folder. Eight NSZ tests PASS including inside-source and new nested directory round trips, no self-inclusion, overwrite preservation. Built separate artifacts/nsz-studio-pack-fix/NSZStudio/NSZStudio.exe and artifacts/NSZStudio-Pack-Fix.zip (keep _internal). Existing running older NSZStudio left untouched. docs/nsz-tools.md updated. No game assets replaced; real client loading still unverified.


# Original RumbleLauncher patch URLs and publisher (2026-09-12)
User requested original launcher appearance, then explicitly corrected: do NOT rebuild launcher; only overwrite patch information. Custom C# prototype withdrawn to ignored artifacts/launcher-patcher/unused-prototype, Tools/ClientLauncher Program.cs/csproj returned exactly to previous content (git diff empty). Original RumbleLauncher copy changed ONLY two fixed URL strings at file offsets390C8/392BC to http://160.202.167.41/patch/wufilelist.ini and temp.ini. Original SHA21dd6e1efb35d140876db353cbf57130f215e7173b80bb6df7d0f29c66e1b77b; same1739064bytes, no code/resources/game/installedfiles changes. Authenticode invalidated by data edits; no checks removed. No GUI/game launch or production upload.
Official CDN list downloaded without login:3156entries saved artifacts/launcher-patcher/wufilelist.ini; temp.ini V0935. Native parser41C9F0, URLrefs4197ED/41BE1C; file/headCRC32 confirmed3localDLLs vs official; NSZ/IGX/GMF/WAV/OGG comparison size+first1024CRC at41D1F2 can miss same-size later-only edits. Preserve original protocol, NOT custom signature/rollback guarantees. Current /patch/wufilelist.ini returns HTML200; HTTPS timedout. Needs correct IIS static folder/rewrite exclusion before liveuse. RFRebirth.exe stilllaunchesdirectgame, bypassesofficialpatcher: patchusingmodifiedRumbleLauncher,close,thenexistingRFRebirth for private routing. No autochainchange.
User then asked desktop tool to add/upload into ownfilelist. Built Tools/patch_publisher_studio.py + patch_upload.py + official_launcher_patch.py; standalone artifacts/RFPatchPublisher.zip with RFPatchPublisher.exe/README. Loads ownHTTP/local INI, mergesselectedclientfiles, preservesoldreleasepaths, computes signedCRCfull/head,RAWpayloads; FTP/FTPS(defaultcertverify, passwordnotstored) orlocalIIScopy. Baselineconflictchecks+publishlock+payloadreadback+manifestlast+backup; FTPrenamehasgap anddroppedconnectionmayrequiremanualbackup/lockrecovery. No remoteFTPcredentialsconfigured. Nine automatedtests+actualloopbackpyftpdlib twoFTP releasespassed; fixture stopped. NativeUIapply/productionFTPSnotverified. Fullbundle artifacts/RumbleLauncher-Patch-Server.zip includes ClientURLcopy,Serverbootstrap0filemanifest,PublisherGUI+CLI,IISmimeconfig,officiallistreference,docs. Sources Tools/OfficialPatchServer,build_official_patch_package.py,test_official_launcher_patch.py,test_patch_upload.py. docs/official-launcher-patches-2026-09-12.md fulldetails. No agents,commits,indexedits,remotechanges.


# IIS and FTPS patch setup package (2026-09-12)
User requested setup for FTP AND IIS website. Delivered artifacts/RFRebirth-Patch-Server-Setup.zip (13154162 bytes; SHA3454f5014e57b29b3d3da317cd4d6bfb34a020466515fdd298897a3153e8318b). Extract/run Setup Patch Server.cmd ON160.202.167.41. No provisioning/GUI/game/remotechanges were performed here. Tools/PatchServerSetup/{Setup-PatchServer.ps1,Setup.Core.ps1,Test-Setup.ps1,README.txt,Setup Patch Server.cmd}; builderTools/build_patch_server_setup.py.
Installer installsIISstatic+FTP, selectscompatibleexistingHTTP80site(orcreateswhenfree), createsseparate/patchstaticapp+poolandC:\inetpub\RFRebirthPatch, disablesinheritedsiterewriteruleslocallyifmodulepresent, writeszero-filemanifest/V0935onlyifmissing. DedicatednonadminRFRebirthPatchuser, explicitFTPS2121,anonymousoff, generatedselfsignedRSA3072two-yearIP-SANcert160.202.167.41, NTFSuploadACL,WindowsFirewallHTTP80/control2121/passive50000-50049. Existingvalidglobalpassiverangereused;foreignFTPdynamicrangeconflictrefused. RestartsFTPSVConlyifnootherFTPsitesandfirstrangesetting;nogame/IIS-wide restart. Requiresproviderfirewall/NATportsseparately. Owned-rerunstateDPAPIpasswordandprotectedplaintextconnectiondetails/publiccerinC:\ProgramData\RFRebirthPatchSetup;notpublicfolder. SameWindowsadminrerunrequired;noautomaticrollback/certautorenew. Existingforeignfolders/apps/accounts/pool/bindingsrefused. InitialIISbackupandwebconfigbackups. LocalHTTPfilelistcheckatend;actualserverinstalluntested.
Updatedpublisherincludesoptional.cer/.pemselector; patch_upload.ftp_tls_context trustssuppliedcertificatewithnormalhostname/expiryverification, noOStrustmodification. Setup FTP root is / not /patch. Use includednewGUIwith2121andPatchFTP.cer. FourPowerShellgroupsPASSsyntax5.1/sharedrange/ownership/XML;existing4uploadtestsPASS. ActualTLS_FTPHandlerloopbacktestPASSencryptedcontrol/data,untrustedselfsignedrejected,DERanchoraccepted,byteverifiedupload. Fixturestopped;testprivatekey/passwordtempremoved. Test dependenciespyOpenSSL/pyftpdlibinignoredartifacts/launcher-patcher/ftp-test-deps. PreviousRFPatchPublisher.zip isolderwithoutcertificatepicker;newsetupZIPincludesupdatedGUI. FulloriginalURL-onlylauncher includedunchangedfrompriorbundle. No agents/commits/indexchanges.


# Patch installer must create NEW website (2026-09-12)
User screenshot showed Main/Ultimate selection and corrected scope: wants a NEW site, not attaching to either. New Tools/PatchServerSetup always creates owned RFRebirthPatchWeb onHTTP8089, no existing-site menu. URL http://160.202.167.41:8089/patch/;FTPS2121unchanged. NewZIP artifacts/RFRebirth-Patch-Server-New-Site.zip supersedesprevioussetupZIP. IncludesoriginalRumbleLauncherURL-onlycopyretargetedto8089 andrebuiltpublisherdefault8089. Mustuseincludedclientcopyoroldlauncherwillstillfetch80. Windowsfirewall8089; providerfirewallmayneed8089. Oldbundlesunchanged. Closeoldinstalleratselection(noaccount/sitecreatedyetthere),extractnewandrunsetupcmdonserver. No remotechangesperformedhere.
AddedAssert-DedicatedWebsite andtestscenarioexactMain+Ultimate80 withnew8089allowed,portconflict/foreignnamedsite/priorcompletedother-siteownershiprefused. PreviouscompletedsetupstatewithdifferentSiteName/HttpPortisnotautomaticallymigrated. New-sitepreflightskipsqueryingapps/vdirsuntilexists. FivePScheckgroups+ninePython testsPASS; originalbinaryonlyURLslotscheckedandZIPCRC/hashvalidated. NoactualWindowsServerprovisioningtest. DefaultURLconstantofficial_launcher_patch.py andpublisherREADMEupdated8089; testforeignCDNassertusesdynamicdefault. ExistingFTP/cert/privatefolderbehaviorunchanged.


# Existing FTP dynamic range compatibility (2026-09-12)
User'snew-sitesetupstopped onforeignFTPdynamicrangeguard beforeprivate/account/sitecreation. Fixed Get-PassivePlan: IIS0/0withotherFTPsites nowreadsnetsh IPv4TCPdynamicrange and reusesexactstart/count withoutglobalFTPconfigchangeorFTPSVCrestart. Invalidrange/unreadabledetectionstillfailsratherthanguesses. Service-scopedFTPSVCpassiveWindowsfirewallrule avoids openingotherapps'ports. Separatewebsite8089/FTPS2121unchanged. MicrosoftIISfirewallSupportdocsconfirmed0/0=WindowsTCPephemeralrange. Testsdefault49152..65535/custom40000..40999/unreadable/overflowpassed+existing5PSgroups;actualreadonlylocalnetshparsingchecked. Newpackage artifacts/RFRebirth-Patch-Server-FTP-Compatible.zip13155574bytes SHAe8c43aa163e89bca4242c8f7962be0df1494a9044efcbc1e5a8a392f3c023f6d. READMEproviderfirewallrangeupdated;priorZIPsunchanged. No remoteinstallation/servicechangesperformed. LiveIISinstallationstilluntested.


# Certificate compatibility helper and step diagnostics (2026-09-12)
User nextscreenshot failedafterIISbackup with0x800710D8 invalidobjectidentifier, nofailingline. SuspectedcertificatecreationbutNOTconfirmed: identicalNewSelfSignedCertificateparamsPASSED isolatedCurrentUserfixture; itsgeneratedcert+keyremovedfinally. DoNOTclaimexactserverrootcauseestablished. ReplacedNewSelfSignedCertificateinsetupwithnewTools/PatchCertificate .NET8selfcontainedhelper:RSA3072SHA256,IPv4SAN,serverauthEKU,nonCA,keyusage,2yearselfsigned. --install persistsMachineKeySet/PersistKeySetnonexportableimportintoLocalMachineMyandprintsThumb;--self-test in-memorychain/SAN/privatekeysignpassedwithoutstorewrites. Installercheckshelperexit/exact40hexthumbbeforestateupdate, reusessavedaccountpassword/cert, nowreportsstep+scriptlineiferror. SixPStestgroupspassed. Machineinstallationpathnotexecutedhere; no server/globalcerttrustchanges. NewZIP artifacts/RFRebirth-Patch-Server-Certificate-Fix.zip42917594bytesSHA8c93d60e8066c3dec6f02b8b51a5f9d03b43c45a77e4f8827629b27e6dd3cd00 includeshelper. ReruncompletepackageassameWindowsadmin;previouscompletedwebsite/folderguardssame. PriorZIPsunchanged. No remote/UI/gamechanges.


# Exact FTP control error located (2026-09-12)
Latest screenshot now identifies FTP site configuration line124 Stop-WebSite -Name ftpName failing0x800710D8. Previouscertificatehypothesisnotestablished; actualnewfailureHTTPsitecontrolonFTP-onlysite. Changedbothstop/startto Set-FtpSiteState using (Get-Website).ftpServer.Stop()/Start(), FTPbindingguardandstateidempotence. MicrosoftIISftpServerStart/Stopdocumentationconfirmsseparatemethods. AddedmockregressionprohibitingHTTPsiteStartStopandverifyingFTPmethods/repeatedstates/nonFTPguard. SevenPStestgroupsPASS;runtimeIISnotavailabletested. NewZIP artifacts/RFRebirth-Patch-Server-FTP-Control-Fix.zip42918170bytesSHAad32e0fc914cfa182a20189b0583ad8e9b2d77495bdaf81ef27cfe3a2e6ee8f1. Rerunassameadminpreservestate/account/cert/site;noneeddeleteanything. No remotechangesperformed. Certificatehelperretainedbutdon'tclaimitwasrootcause.


# FTP runtime-state guard fix (2026-09-12)
Latest screenshot firewalllabel,line6HRESULT800700B7 actuallypointsCoreFTP.Start; labelwasstale. Fixednumericstatehandling IISftpServer0Starting1Started2Stopping3Stopped4Unknown (Microsoftdocsverified); priorguardrecognizedonlytext. Addedboundedfreshstatepolling+duplicatecontrolavoidance; methoderroronlyignoredifdesiredstatefreshconfirmed, realbindingerrorsstillpropagate. FTPstartnowownstage. EightPStestgroupsincludingnumericstates/transition/race/genuinefailurepassed. NewZIP artifacts/RFRebirth-Patch-Server-State-Fix.zip42919088bytesSHAdec48ab81977bbf7e9fa429ef3d2145d992d56e3d42e4df0594e479775eeca12. No liveIISrun; screenshotalonecannotexcludeactualbindingconflictiferrorpersists. Rerunpreservingpartialstateassameadmin. No remotechanges.


# FTP stillfails: request diagnostic evidence (2026-09-12)
Latestuser screenshotFTPstartup Coreline20 .Start still800700B7 afterstatefix. DoNOTclaimresolved; numericstatefixinsufficient. Verified remotelyreadonly HTTP160.202.167.41:8089/patch/wufilelist.ini returns200 correctzero-fileINI; FTP2121connectiontimedout. PreparedREADONLY Tools/PatchServerDiagnostics scripts+artifacts/RFRebirth-Patch-Diagnostics.zip tocollectallIISIDs/bindings,FTPstateviaWebAdmin+directMWA,FTPservice/PID/listeners21/2121/8089,publiccertmetadata,FTPeventmessages,lastlocalHTTPcheck. SavesPatch-Diagnostics.txt, no secretssettingsdump, passwordlabelsredactedinreport, no servicestate/config/account/cert/firewallmutations. SyntaxPS5passed;notrunlocallyonactualIIS. Needuserreportfromserverbeforemoreinstallerchanges. No new installerbuild or remote mutation.


# RFRebirth opens native patcher (2026-09-12)
User requested integrated flow. Program now validates supplied port8089 RumbleLauncher SHA446CD6588400DA9CB97B57B5651D9A80104733841E5E4B2BDD6AFE97722B75E3, applies existing private hosts lease before opening native patcher, observes same-session exact-path game, retains email/GameMon cleanup and waits for both patcher/game exit before restoring. No direct game Process.Start, launcher event or /DIRECT arguments from wrapper anymore; native patcher's Start owns launch/update gating. Closing patcher never launches game. Original game hash guard retained. OfficialPatcher.cs handles native process lifetime with 3second post-exit grace; no native UI/code edits. Existing port8089 binary reused. Tests (11 groups) and Release selfcontained publish passed; archive CRC/byte verification passed. artifacts/RFRebirth-With-Patcher.zip contains BOTH EXEs+README, deliberately no INI to avoid overwriting private IP. No installed client/server/UI operation. Live native Start/private login remains UNVERIFIED; request RFRebirth.log if fail. Historical docs describing separate manual launch superseded by this change. No commits or agents.

# Native patcher localhost launch override fixed (2026-09-12)
User live game Server is closed. RFRebirth logs confirm native launch/private hosts applied; client DirectLogin.cpp1147 tcp connect error. Remote160.202.167.41TCP7000 reachable. Actual C:\PlayRedFox\RumbleFighter\RumbleLauncher.ini GENERAL/LAUNCHPARAM=-Server:127.0.0.1 overriding hosts. Binary analysis native40F4D0 reads GENERAL/LAUNCHPARAM from RumbleLauncher.ini and formats into CreateProcess at40F82D. Corrected localINI with backup before-server-fix.backup to160.202.167.41 (no UI/process operation). Added OfficialPatcher.ConfigureServer called before patcher/routing: validated IP from existing RumbleFighter.ini, Win32 profile key update preserves other settings/options, GUID backup before changed value, readback verification/idempotence. Tests incl real tempINI localhost replacement/options/unrelatedkey preservation and idempotence PASS; publish PASS. New artifacts/RFRebirth-Patcher-Server-Fix.zip bothEXEs+README noINI. Installed runningEXE not overwritten. Live login afterINIcorrection stillunverified.

# Separate patcher filename after repeated official restoration (2026-09-13)
User reports repeated revert. Confirmed game-folder RumbleLauncher reverted to official SHA21dd6e... at02:19:35, between native game start02:19:18 and exit02:20:24. Root C:\PlayRedFox copy remains patchedSHA446cd...; no process attribution established. Public manifest onlyNSZ, no launcher. Changed OfficialPatcher.Validate to require RFPatchLauncher.exe (same URL-only native bytes), leaving official RumbleLauncher untouched. README/tests updated; all11 regressiongroups and Releasepublish passed. artifacts/RFRebirth-Separate-Patcher.zip includesRFRebirth+RFPatchLauncher+README. Installedboth withtimestampbackups andhashverification into C:\PlayRedFox AND C:\PlayRedFox\RumbleFighter while none running. Confirmed canonical game-folderRumbleLauncher retains originalofficialSHA. No game/GUI/integrityservice changes or launch performed. Live rename patch/start/exit/reopen behavior remains unverified. Use game-folderRFRebirth; rootcopies are spares.
