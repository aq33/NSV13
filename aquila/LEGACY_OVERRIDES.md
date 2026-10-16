# Aquila legacy overrides: audit

This file tracks Aquila changes that still live outside `aquila/`: edits to core files and procs that `aquila/` overrides wholesale. Use it when merging upstream (Beestation/NSV13). Every entry here is a place where an upstream change can conflict, or worse, get silently shadowed.

Audited against the merge base with `upstream/master` (`69565b730f`, 2026-09-12). The modularization pass is on branch `modularize-legacy-aquila-overrides`.

Rule for this pass: **current gameplay behaviour is authoritative.** Anything that could not be shown to behave identically was left alone and is listed below with the reason.

## How to read the classes

| Class | Meaning |
|---|---|
| A | Safe to modularize: a self-contained addition or var value that can move to `aquila/` unchanged |
| B | Safe with a small core hook |
| C | Full-copy override: `aquila/` redefines a whole upstream proc |
| D | Localization only (Polish strings), left in place on purpose |
| E | Map-bound, not touched |
| F | Too risky or architectural; left unchanged |

## Full-copy overrides (class C)

These are same-type redefinitions in `aquila/` that do not call `..()`, so they silently replace the upstream proc. Find them with a scan for `aquila/` proc definitions that match a core `type/proc` and do not call `..()`.

| Proc | Status | Notes |
|---|---|---|
| `/obj/item/powersink/process()` | **Reduced** to the `on_drain()` hook | Core calls `on_drain(drained)` in place of its APC block (1 AQ EDIT line). APC draining and infiltrator tracking stay in `aquila/.../powersink.dm`. Includes the hardened `newavail()`/`add_delayedload()` drain. |
| `/datum/admins/one_click_antag()` | **Reduced** to the `aquila_one_click_antag_links()` hook | 1 AQ EDIT line appends the Aquila buttons; the HTML is byte-identical. |
| `/datum/surgery_step/extract_implant/success()` | Left (C) | The Aquila version calls `I.removed()` *before* the success message and branches on `QDELETED(I)` (yogs self-deleting implants). This reorders upstream side effects, so no pre/post hook can express it, and calling `removed()` twice is not idempotent (e.g. mindshield messages). Hardened (`removed()` + `return TRUE`), so do not touch. To modularize later, upstream would need a "remove implant" helper step. |
| `/datum/nanite_program/nanite_sting` (+ `spreading/active_effect`) | Left (C/F) | Core's copies are commented out (`/* AQUILA EDIT */`) and `aquila/` defines the whole type. The delta (`COMSIG_NANITE_SET_CLOUD` sent *between* `AddComponent` and `COMSIG_NANITE_SYNC`, cloud extra setting, trigger cost 50) is interleaved, so it can't be a post-hook. Part of the larger Aquila nanite rework. |
| `/obj/item/screwdriver/abductor/get_belt_overlay()` | Left (minimal) | A one-line resource swap; the override *is* the delta. |
| `/datum/species/ipc/post_death()` | Left (minimal) | A one-line no-op (keep the BSOD screen after death); the override *is* the delta. |
| `/obj/machinery/gravity_generator/part/get_status()` | Left (minimal) | A one-line null-safe `main_part?.get_status()`; the override *is* the delta. |
| `/datum/hud/human/update_locked_slots()` | Left (C) | BeeStation#13707 port (`aquila/code/_onclick/hud/locked_slots.dm`): dims every slot `can_equip()` would refuse (no jumpsuit, no suit, missing limbs or head, `no_glasses`), not just the species `no_equip` list. Upstream only checked `no_equip`, so the override replaces the whole loop. |

The other ~60 same-type redefinitions in `aquila/` call `..()`, so they are already pre/post hooks.

## Core hooks added by the modularization pass

| Hook | Location | Feature |
|---|---|---|
| `QDEL_IN(src, 20)` in `/obj/effect/particle_effect/sparks/Initialize()` | `code/game/objects/effects/effect_system/effects_sparks.dm` | Sparks are cleaned up even if their `LateInitialize()` never runs |
| `late_loaders` swapped for a fresh list before the late init loop | `code/controllers/subsystem/atoms.dm`, `InitializeAtoms()` | Overlapping map loads no longer wipe each other's late loaders (stuck sparks and other lateload atoms) |
| `exit_push()` pushes along `pushed.dir` | `code/modules/security/genpop.dm` | Turnstiles on our maps have the free direction pointing out of the brig |
| Opt-in role preferences (`role_preference_enabled()`, the old prefs toggle, no drafting in `get_players_for_role()`) | `code/__DEFINES/role_preferences.dm`, `code/modules/client/preferences.dm`, `code/game/gamemodes/game_mode.dm` | Antagonist roles are off unless the player enables them (`aquila/.../preferences_menu/middleware.dm` matches) |
| `on_drain(drained)` call | `code/game/objects/items/devices/powersink.dm`, `process()` | Aquila power sink APC draining and infiltrator objective |
| `dat += aquila_one_click_antag_links()` | `code/modules/admin/verbs/one_click_antag.dm` | Aquila "Create Antagonist" buttons |
| `ROLE_PARADOX_CLONE` + `antagonist_bannable_roles` entry | `code/__DEFINES/role_preferences.dm` | Paradox Clone (tgstation#71141 port); the define has to be in core because `aquila.dm` is included after the list |
| `ROLE_CHRONO_LEGIONNAIRE` + `antagonist_bannable_roles` entry | `code/__DEFINES/role_preferences.dm` | Chrono Legionnaire midround antagonist; same reason as `ROLE_PARADOX_CLONE` |
| `Destroy()` of `chrono_eraser`, chronosuit helmet and suit | `code/game/objects/items/chrono_eraser.dm`, `code/modules/clothing/spacesuits/chronosuit.dm` | Bugfix for the Chrono Legionnaire gear: they called `dropped()` without a user and runtimed on every delete |
| `ANTAG_HUD_PARADOX_CLONE` (33) + `GLOB.huds` entry | `code/__DEFINES/atom_hud.dm`, `code/datums/hud.dm` | Paradox Clone HUD; must stay the next index after `ANTAG_HUD_VAMPIRE` |
| `paradox_clone` icon state | `icons/mob/hud.dmi` | Paradox Clone HUD icon, copied from tgstation's `antag_hud.dmi` |
| `GAS_MIASMA` define | `code/__DEFINES/atmospherics.dm` | Miasma (restores what BeeStation-Hornet#6445 removed, reworked around `SSmiasma`); in core because the core gas lists below use it |
| `GAS_MIASMA` list entries | `code/modules/atmospherics/machinery/airalarm.dm` (3 TLV lists, scrubbing/contaminated/refill filters), `components/unary_devices/vent_scrubber.dm` (default `filter_types`), `portable/canister.dm` (label list), `mob/living/simple_animal/bot/atmosbot.dm` (gases to scrub) | Miasma alarms, scrubbing and canister relabelling. Scrubbers filter it by default so it doesn't build up |
| `handle_miasma_breath()` call | `code/modules/surgery/organs/lungs.dm`, `check_breath()` | Miasma breath effects (`aquila/code/modules/miasma/miasma_breath.dm`); the only breath path that handles miasma |
| `ROLE_THIEF` + `antagonist_bannable_roles` entry | `code/__DEFINES/role_preferences.dm` | Thief (tgstation#64144 port); same reason as `ROLE_PARADOX_CLONE` |
| `ANTAG_HUD_THIEF` (34) + `GLOB.huds` entry | `code/__DEFINES/atom_hud.dm`, `code/datums/hud.dm` | Thief HUD; must stay the next index after `ANTAG_HUD_PARADOX_CLONE` |
| `ROLE_HORROR` + `antagonist_bannable_roles` entry, `ishorror()` | `code/__DEFINES/role_preferences.dm`, `code/__DEFINES/is_helpers.dm` | Eldritch Horror (Yogstation#13033 port); in core for the same reason as `ROLE_PARADOX_CLONE`, and `ishorror()` is used by `death.dm` |
| Horror hooks (`has_horror_inside()` checks) | `scanners.dm` (`healthscan()`, advanced), `suicide.dm` (`canSuicide()`), `death.dm` (`gib()`), `brain_item.dm` (`Remove()`), `human.dm` (`get_stat_tab_status()`), `transform_procs.dm` (`monkeyize()`), `gun.dm` (`handle_suicide()`), `organ_manipulation.dm` (`preop()`/`success()` extract), `changeling/powers/headcrab.dm`, `changeling/powers/panacea.dm` | Eldritch Horror: detection, surgical removal, no suicide/self-shot/monkeyize while infested, eject on brain removal, headslug and panacea |
| `/mob/living/simple_animal/horror`, `/obj/item/horrortentacle` in phobia typecaches | `code/controllers/subsystem/traumas.dm` | Eldritch Horror ("the supernatural" mobs and objects, "anime" objects) |
| `horror.txt` | `strings/names/` | Eldritch Horror names (`GLOB.horror_names`); in core `strings/` for the same reason as `thief_flavor.json` |
| `amount` var on `/datum/objective/steal_five_of_type` | `code/game/gamemodes/objective.dm` | Replaces the hardcoded 5 in both `check_completion()`s (default stays 5), so the thief guns/organs objectives can ask for a different count |
| `thief`, `hoard`, `hoarder_circle` icon states | `icons/mob/hud.dmi`, `icons/mob/actions/actions_minor_antag.dmi`, `icons/mob/telegraphing/telegraph.dmi` | Thief HUD icon, "declare hoard" action and hoard marker, copied from tgstation |
| `thief_flavor.json` | `strings/` | Thief flavor texts; lives in core `strings/` because `tools/deploy.sh` only ships that folder and `strings()` strips `/` from file names |
| `spy_objective.json` | `strings/` | Spy objective flavor texts (port of tgstation `strings/antagonist_flavor/spy_objective.json`); core `strings/` for the same reason as `thief_flavor.json` |
| `standing += H.get_tears_overlays()` / `add_overlay(get_tears_overlays())` | `code/modules/mob/living/carbon/human/species.dm` (`handle_body()`), `code/modules/mob/living/carbon/human/update_icons.dm` (`update_body_parts_head_only()`) | Łzy po `*cry` (Yogstation#15690 port), drawn right after the eyes overlay |
| Custom landing link in `ui_interact()` + `designate` branch in `Topic()` | `nsv13/code/modules/shuttle/computer.dm` | Custom shuttle / bluespace pod landing spot; the var and procs are in `aquila/code/modules/shuttle/computer.dm` |
| `TRAIT_EAT_MORE`, `TRAIT_GENELESS` defines; `TRAIT_GENELESS` check in `add_mutation()`; `TRAIT_EAT_MORE` hunger multiplier | `code/__DEFINES/traits.dm`, `code/datums/dna.dm`, `code/modules/mob/living/carbon/human/species.dm` | Sinful demons (Yogstation sync); the defines are in core because core procs use them |
| `aquila_monkey_spat()`, `aquila_monkey_sucked()`, `aquila_potion_spat()` calls, `balloon_alert()`s | `code/modules/research/xenobiology/xenobio_camera.dm` (actions and click handlers, each path twice) | Xenobio tubes and HUD (tgstation#90775 port). The "now has N monkeys" chat lines were replaced by the HUD. Slime pickup/place needs no hook: `aquila/.../xenobio_tubes.dm` reacts in `Entered()`/`Exited()` |
| `aquila_shell_hidden()` call in the Windows branch of `world.shelleo()` | `code/__HELPERS/shell.dm` | Runs shell commands through a hidden `wscript` launcher so the host doesn't get a cmd window (e.g. jukebox yt-dlp calls); falls back to plain `shell()`. The proc is in `aquila/code/__HELPERS/shell.dm` |
| `audio/setMusicGain` message + `gain` multiplier (`volume` option of `audio/playMusic`) | `tgui/packages/tgui-panel/audio/{player,middleware}.js` | Jukebox YouTube music gets quieter with distance; DM side is `/datum/tgui_panel/proc/set_music_gain()` in `aquila/code/modules/tgui_panel/audio.dm` |
| Health HUD without stamina (`if(..())` instead of `min(health, maxHealth - getStaminaLoss())`) | `code/modules/mob/living/carbon/human/human.dm`, `update_health_hud()` | Stamina HUD (BeeStation#11521 port, `aquila/code/_onclick/hud/stamina.dm`); stamina has its own indicator now |
| Chat message cleanup in `/atom/Destroy()` (AQ EDIT block) + `code/datums/chatmessage.dm` brought to BeeStation#12193 (grouped, non-sleeping runechat) | `code/game/atoms.dm`, `code/datums/chatmessage.dm` | Runechat grouping port. `chatmessage.dm` is patched as a whole, without markers; when syncing with upstream, diff it against BeeStation's version of that PR instead of the NSV13 one |
| `CHAT_DISABLE_LOOC_RUNECHAT` (chat_toggles bit 13), LOOC runechat block in `/client/verb/looc()`, `looc` prefix in `/datum/chatmessage/proc/generate_image()` | `code/__DEFINES/preferences.dm`, `code/modules/client/verbs/looc.dm`, `code/datums/chatmessage.dm` | LOOC above heads (BeeStation#12918 port); the toggle verb is `toggle_looc_runechat()` in `aquila/code/modules/client/preferences_toggles.dm` |
| Screentips (BeeStation#11938 port, `aquila/code/modules/screentips/`): `..()` in `MouseEntered()` overrides that skipped it; `PREFTOGGLE_2_DISABLE_SCREENTIPS` (last free toggles2 bit); `COMSIG_ATOM_ADD_CONTEXT`; `screentip_verb` on `/datum/element/processable`; `.small-icon` and bigger `.reallybig`/`.extremelybig` in the map style | `code/game/objects/items.dm`, `code/_onclick/hud/{action_button,alert,blob_overmind,ghost,screen_objects}.dm`, `code/__DEFINES/preferences.dm`, `code/__DEFINES/dcs/signals/signals_atom.dm`, `code/datums/elements/food/processable.dm` (+ uncommented `screentip_verb` in `items/food/*.dm`), `interface/skin.dmf` | `/atom/MouseEntered()` itself lives in `aquila/code/modules/screentips/atom_extensions.dm` |
| Ghost role polls through `SSpolling` (BeeStation#12738/#13722 port): `pollGhostCandidates()`/`pollCandidates()`/`pollCandidatesForMob(s)()` rewritten as wrappers and `showCandidatePollWindow()` removed (AQ EDIT block); `timeout_override`/`no_anim` on `throw_alert()`; `POLL_AUTO_ADD_*` defines | `code/__HELPERS/game.dm`, `code/_onclick/hud/alert.dm`, `code/__DEFINES/role_preferences.dm` | Subsystem, poll datums and the alert live in `aquila/code/controllers/subsystem/polling.dm`, `aquila/code/datums/polls/`, `aquila/code/_onclick/hud/poll_alert.dm`. Old call signatures are kept, so the 67 existing callers did not change |
| TGUI on React (BeeStation#12204 and the TGUI updates around it): `tgui/` is BeeStation's tree with our interfaces converted from Inferno, `code/modules/tgui/tgui.dm` and `tgui_window.dm` taken from BeeStation (layout prefs, `tgui_lock` pref, `icon_ref_map` and batched spritesheets left out), `SStgui` injects `tgui-setup` helpers instead of polyfills, `tgui_max_chunk_count` config entry, flat `large_buttons`/`swapped_buttons` in the input modals | `code/modules/tgui/`, `code/controllers/subsystem/tgui.dm`, `code/__DEFINES/tgui.dm`, `code/controllers/configuration/entries/general.dm`, `code/modules/tgui_input/{alert,list,number,text}.dm`, `tgui/`, `tools/bootstrap/node*`, `dependencies.sh` (Node 22) | Our tgui changes kept on top of BeeStation's: jukebox player (`tgui-panel/audio/player.js`, `audio/setMusicGain`), chat storage throttling on 516, longer asset retries in `tgui-setup/helpers.js`, themes `dominion`/`hackeros`, NSV components `Map`/`StarButton` and the deprecated `Grid`, curried `common/collections` helpers. When syncing tgui with BeeStation, re-apply these |
| Chat reliability from BeeStation: every chat message is a `/datum/chat_payload` with a sequence number (the React chat panel drops anything else) and the panel asks for missing ones with `chat/resend`; the first sequence starts at 0 instead of Bee's null | `code/controllers/subsystem/chat.dm`, `code/modules/tgchat/to_chat.dm`, `code/__DEFINES/chat.dm`, `code/modules/tgui_panel/tgui_panel.dm`, `aquila/code/datums/chat_payload.dm` | Chat panel message types also keep our old radio/admin log classes, since our server does not add Bee's `srt_*` classes (`tgui-panel/chat/constants.ts`) |
| Chat panel DM side from BeeStation: admin music sends duration/artist/album/upload date for the Now Playing widget and hides them on "No" (#9249); stat panel groups the same items on a tile with tags for sorting, admin buttons check rights, tickets get a Claim button (#9655); time to reboot in the Status tab (#13727, Reboot() still sleeps, it only records `reboot_at`); blood brother and carp wavespeak chat use theme classes instead of hex colors (#9908); cult colors in the old stylesheet (#12325) | `code/modules/admin/verbs/playsound.dm`, `code/modules/mob/mob_stat.dm`, `code/modules/admin/verbs/adminhelp.dm`, `code/controllers/subsystem/ticker.dm`, `code/__DEFINES/colors.dm`, `code/game/objects/items/implants/implant_bb.dm`, `code/modules/antagonists/brother/brother.dm`, `code/modules/mob/living/simple_animal/hostile/space_dragon.dm`, `interface/stylesheet.dm` | New procs in `aquila/code/modules/mob/mob_stat.dm`; the panel frontend for these came with the BeeStation `tgui/` tree |
| Orbit panel from BeeStation #9034: collapsible sections, antag HUD icons, team names, generic theme; refreshes when the target is gone | `code/modules/mob/dead/observer/orbit.dm`, `tgui/packages/tgui/interfaces/Orbit.jsx` | `antag-hud` spritesheet in `aquila/code/modules/mob/dead/observer/orbit.dm` (cropped from our `icons/mob/hud.dmi`) |
| Crew manifest in TGUI from BeeStation #9836: lobby, ghost and silicon manifest open the `CrewManifest` window instead of an HTML table; `get_manifest()` entries carry the job HUD icon | `code/datums/datacore.dm`, `code/modules/mob/dead/new_player/new_player.dm`, `code/modules/mob/dead/observer/observer.dm`, `code/modules/mob/living/silicon/silicon.dm`, `tgui/packages/tgui/interfaces/CrewManifest.tsx`, `tgui/packages/tgui/styles/colors.scss` (Munitions color) | `/datum/crew_manifest` in `aquila/code/modules/mob/dead/crew_manifest.dm` builds Bee's data from our department HUD lists; `get_manifest_html()` stays for NtOS printing |
| Latejoin job selection in TGUI: `LateChoices()` opens the `JobSelection` window (departments, slots, job HUD icons, greyed-out roles with the reason) instead of the yogs HTML table; `close_spawn_windows()` closes it | `code/modules/mob/dead/new_player/new_player.dm` | `/datum/latejoin_menu` in `aquila/code/modules/mob/dead/new_player/latejoin_menu.dm`; picking a job goes through the old `SelectedJob` Topic branch, so queue and popcap checks are unchanged |
| Station goals without the intercept report: one combined announcement and one printed report instead of a separate announcement per goal | `code/game/gamemodes/game_mode.dm` (`post_setup()`) | `send_station_goals_report()` in `aquila/code/game/gamemodes/station_goals.dm` |
| Language menu window from BeeStation #13895 (only the UI, not the random names or station trait): one list of all languages with `can_speak`/`could_speak`/`can_understand`, the window hides unknown ones outside admin mode | `code/modules/language/language_menu.dm` (`ui_data`), `tgui/packages/tgui/interfaces/LanguageMenu.tsx` | Language icons come through `icon_ref_map` |
| Antag info windows from BeeStation #9205: every antag gets an "Informacje o roli" action that opens its window, opened on gain (not when silent); default `ui_name` is `AntagInfoGeneric`; traitor's HTML tips replaced by the window, codewords stay in chat and notes | `code/modules/antagonists/_common/antag_datum.dm` (`ui_name`, `info_button_ref`, `on_gain`, `on_body_transfer`, `on_removal`, `optional` in objectives), `code/modules/antagonists/traitor/datum_traitor.dm` (`show_tips`), `tgui/packages/tgui/interfaces/AntagInfo*.tsx` | Action and per-antag data in `aquila/code/modules/antagonists/_common/antag_info.dm` and `antag_info_windows.dm` (sets `tips = null` for antags with their own window); extra pictures in `aquila/html/img` |
| TGUI changelog from BeeStation #12236: the Changelog verb opens the `Changelog` window, which loads `html/changelogs/archive/YYYY-MM.yml`; `ss13_genchangelog.py` now also writes those monthly files from `.all_changelog.yml` (CI already commits `html/changelogs`); `tools/deploy.sh` ships the monthly files; header shows our project instead of BeeStation | `interface/interface.dm`, `tools/changelog/ss13_genchangelog.py`, `tools/deploy.sh`, `html/changelogs/archive/`, `tgui/packages/tgui/interfaces/Changelog.tsx` | `/datum/changelog` and `/datum/asset/changelog_item` in `aquila/code/datums/changelog/changelog.dm`; `changelog.html` stays for `GLOB.changelog_hash` |
| `icon_ref_map` from BeeStation: every TGUI window gets a JSON map of .dmi paths to resource refs, used by the `DmIcon` component | `code/modules/tgui/tgui.dm` (`send_assets`) | `/datum/asset/json` and `/datum/asset/json/icon_ref_map` in `aquila/code/modules/asset_cache/json.dm`; stage 4 test in `aquila/code/modules/unit_tests/aquila_bee_windows.dm` |
| Vending window from BeeStation #13072: grid/list layout, categories (Produkty, Premium, Contraband), item icons through DmIcon, stock as objects; our same-department discount added to the Bee window; grid/list choice remembered per session until Preferences Redux | `code/modules/vending/_vending.dm` (`ui_static_data`, `ui_data`, custom vendor `image`), `code/modules/tgui/tgui.dm` (`layout`), `code/modules/tgui/external.dm` (`change_ui_state`), `tgui/packages/tgui/interfaces/Vending.tsx`, `tgui/packages/tgui/interfaces/common/LayoutToggle.tsx` | `layout_prefs_used` and the session store in `aquila/code/modules/tgui/layout.dm` |
| Smartfridge sprites and window from BeeStation #13072 (no weld-down/frame mechanics, our type paths kept): new `smartfridge.dmi` with contents levels per fridge type, glass, light and broken states, new drying rack sprite; `SmartVend` window with grid/list and item icons, items released by a type-name key | `code/modules/food_and_drinks/kitchen_machinery/smartfridge.dm` (icons, `update_icon_state`/`update_overlays`, `ui_data`, `ui_act`), `tgui/packages/tgui/interfaces/SmartVend.tsx` | Sprite file in `aquila/icons/obj/smartfridge.dmi`; the stormdrive prop and survival pod storage keep their own icons |
| Holopad from BeeStation #14515, built on our older holopad code: TGUI `Holopad` window replaces the HTML menu and `Topic()`; heads of staff (keycard auth access) connect to other pads without them answering; `/obj/machinery/holopad/secure` refuses that, its board toggles with a multitool; head of staff offices, MAA office and AI areas on our maps got secure pads | `code/game/machinery/hologram.dm`, `code/datums/holocall.dm` (`head_call`), `code/game/objects/items/circuitboards/machine_circuitboards.dm`, `_maps/` (95 pads), `tgui/packages/tgui/interfaces/Holopad.tsx` | Bee's full rewrite was not taken, it needs newer APIs (combat mode, `span_*`, `set_anchored`, prefs) |
| Votes from BeeStation #13247: `SSvote` rewritten around `/datum/vote` singletons and the `VotePanel` window (admins can end votes early, reset the cooldown, toggle dead votes, call custom single/multi choice votes); our restart, transfer, gamemode, map, round extension and hardmode votes keep their non-voter rules; the map vote keeps the NSV13 `MapVote` window, preferred maps and map vote bans (no persistent tallies from Bee) | `code/controllers/subsystem/vote.dm`, `code/__DEFINES/subsystems.dm`, `code/controllers/subsystem/autotransfer.dm`, `code/controllers/subsystem/shuttle.dm`, `code/__HELPERS/roundend.dm`, `nsv13/code/controllers/subsystem/overmap_mode.dm`, `nsv13/code/controllers/subsystem/map_vote.dm`, `tgui/packages/tgui/interfaces/VotePanel.tsx`, `MapVote.tsx` | Vote datums in `aquila/code/datums/votes/`, sounds in `aquila/code/controllers/subsystem/vote.dm`, test `aquila_votes` |
| Techfab/protolathe/circuit imprinter window from BeeStation #14723: the `Fabricator` window with Bee's design browser (category tree, search, material bar, reagent bar), orders up to x50; our design categories are kept as they are (Bee also re-categorized every design) | `code/modules/research/machinery/_production.dm`, `tgui/packages/tgui/interfaces/Fabricator.tsx`, `tgui/packages/tgui/interfaces/Fabrication/`, removed `TechFab` window | Design and material data in `aquila/code/modules/research/fabricator_ui.dm` |
| Autolathe and exosuit fabricator windows from BeeStation #14723: `ModularFabricator` (design browser + queue, security panel, data disk) and `ExosuitFabricator` (one row per queued item, Queue All per category) on our modular fabricator; new queue actions (`build`, `build_queue`, `stop_queue`, `del_queue_part`, `remove_mat`); our exosuit fabricator keeps its R&D sync, as a button added to the Bee window | `code/game/machinery/fabricators/modular_fabricator.dm`, `code/game/machinery/fabricators/exosuit_fab.dm`, `tgui/packages/tgui/interfaces/ModularFabricator.tsx`, `ExosuitFabricator.tsx` | Shared helpers in `aquila/code/modules/research/fabricator_ui.dm` |
| Newscaster from BeeStation #7779 (current BeeStation version): TGUI `PhysicalNewscaster`/`NtosNewscaster` windows with the bounty board, TGUI admin newscaster, newscaster NtOS program on the job disk; the old `code/game/machinery/newscaster.dm` and the HTML admin newscaster (`access_news_network` in admin.dm, `ac_*` hrefs in topic.dm, `admincaster_*` vars in holder2.dm) are gone; `news_network` procs renamed (`submit_article`, `create_feed_channel`, `/datum/feed_*`); map paths `directional/*` and `security_unit/*` kept | `code/modules/admin/admin.dm`, `code/modules/admin/topic.dm`, `code/modules/admin/holder2.dm`, `code/__HELPERS/roundend.dm`, `code/__HELPERS/priority_announce.dm`, `code/game/machinery/requests_console.dm`, `code/modules/crew_objectives/civilian_objectives.dm`, `code/modules/library/lib_machines.dm`, `code/modules/modular_computers/hardware/job_disk.dm`, `code/__DEFINES/devices.dm` (`DISK_NEWSCASTER`), `nsv13.dme`, `tgui/packages/tgui/interfaces/{Newscaster,PhysicalNewscaster,NtosNewscaster,BountyBoard}.jsx` | The newscaster code itself lives in `aquila/code/game/machinery/newscaster/`, `aquila/code/modules/admin/verbs/admin_newscaster.dm` and `aquila/code/modules/modular_computers/file_system/programs/newscaster.dm`, translated to our API |
| Crafting menu from BeeStation #12485: the personal crafting component moved to aquila/ (BeeStation version: crafting and cooking modes, "Can Make", mass crafting, required tools/machines/structures, guide recipes and food from chemical reactions); our recipe files are unchanged, `aquila_setup()` maps old two-level categories, `tools` and `always_available` to the new fields; stack recipes (sheets, rods, wood...) are listed in the menu too; `CAT_ROBOT` is "Robotics" | removed `code/datums/components/crafting/crafting.dm` from `nsv13.dme`, `code/__HELPERS/global_lists.dm` (`aquila_init_crafting_recipes()`), `code/__DEFINES/construction.dm`, `code/__DEFINES/misc.dm` (`STACK_CHECK_*` as bitflags), `tgui/packages/tgui/interfaces/PersonalCrafting.tsx` | `aquila/code/datums/components/crafting/` (component, recipes_bee.dm, recipes_guide.dm), `aquila/code/__DEFINES/crafting.dm`; the drinking glass appearance part of the PR (takes_reagent_appearance) was not taken |
| Preferences window from BeeStation #8776 (Preferences Redux): the TGUI `PreferencesMenu` (character page with preview and icon buttons, occupations with a Munitions department, loadout shop, antagonists, quirks, game settings, keybindings) replaces the HTML `ShowChoices` menu. Storage is unchanged: every `/datum/preference` reads and writes our existing vars (`active_character`, `features`, `toggles`/`toggles2`/`chat_toggles` bits, `/datum/preferences` vars), saving is still `active_character.save()` and `save_preferences()`; no new database tables or migration | `code/modules/mob/dead/new_player/new_player.dm` (lobby "Setup Character" opens `open_character_menu()`), `code/modules/client/preferences_toggles.dm` (`setup_character` verb opens `open_game_menu()`), `tgui/packages/tgui/interfaces/PreferencesMenu/` | `aquila/code/modules/client/preferences_menu/`, `aquila/code/__DEFINES/preferences_menu.dm`; the old `ShowChoices`/`process_link` code in `code/modules/client/preferences.dm` is left in place but no longer opened |
| `NtosJukeboxBroadcast` interface | `tgui/packages/tgui/interfaces/NtosJukeboxBroadcast.tsx` | UI of the shipwide PA program (`aquila/code/modules/modular_computers/file_system/programs/jukebox_broadcast.dm`); tgui interfaces can only live in the core tgui package |
| `/obj/machinery/jukebox/nukie` placed in the ready room, tile (9,18) | `_maps/shuttles/infiltrator/infiltrator_basic.dmm` | Syndicate speaker for nuke ops (`aquila/code/game/machinery/jukebox_nukie.dm`) |
| Samouczek (rdzeń z cmss13-devs/cmss13#5030, `aquila/code/modules/tutorial/`): `aquila_tutorial_first_connection()` przy pierwszym połączeniu w `client/New()`; `PREFERENCE_TAG_COMPLETED_TUTORIALS` ("30") z odczytem i zapisem JSON w `preferences2.dm` | `code/modules/client/client_procs.dm`, `code/__DEFINES/preferences.dm`, `code/modules/client/preferences2/preferences2.dm` | Tag 30 jest nasz (29 zajął wybór modsuitu); przy merge'u z upstreamem sprawdzić, czy Bee nie zajął tego numeru. Przycisk „Samouczek” jest w oknie `LobbyMenu.tsx` (akcja `tutorial` obsłużona w `aquila/code/modules/tutorial/lobby.dm`), menu, propozycja i zmienna `completed_tutorials` są w `aquila/` |
| Działo Gaussa: werb „Access gun camera” zamieniony na proc `show_view(user)`, a kamera i wyjście z działa to przyciski akcji strzelca „Kamera działa” i „Wyjdź z działa” (`aquila/code/modules/munitions/gauss_gunner_actions.dm`, nadpisania `set_gunner()`/`remove_gunner()` z `..()`); werb „Access internal computer” przetłumaczony na „Panel działa”. Okno konsoli działa (`MunitionsComputer`) i automatu składu (`SquadVendor`) oraz nazwy i opisy zestawów składu przetłumaczone | `nsv13/code/modules/munitions/ship_weapons/ballistic_weapons/gauss_gun.dm`, `nsv13/code/modules/squads/squad_vendor.dm`, `tgui/packages/tgui/interfaces/MunitionsComputer.tsx`, `tgui/packages/tgui/interfaces/SquadVendor.tsx` | Prośba przy samouczku (lekcja Alarm bojowy używa przycisków akcji); tłumaczenie to klasa D |
| `auxmos_cleanup()` calls in `/world/Reboot()` and `/world/Del()`; `/proc/__auxmos_reset()` binding | `code/game/world.dm`, `code/__DEFINES/bindings.dm` | Patched `auxmos.dll` that survives soft reboots; the proc is in `aquila/code/game/world.dm`, the DLL patch in `tools/auxmos/` |
| `return aquila_random_unique_name()` | `code/__HELPERS/mobs.dm`, `random_unique_name()` | Random names with a surname matching the gender (global procs can't be overridden in DM); proc in `aquila/code/__HELPERS/names.dm` |
| `laser_eyes/on_ranged_attack()` signature + eye damage (AQ EDIT block) | `code/datums/mutations/sight.dm` | Laser Eyes received the click params instead of the target and runtimed (aq33/AquilaStation#461) |
| Hydration check lets `TRAIT_NOTHIRST` mobs regenerate blood | `code/modules/mob/living/blood.dm`, inside the existing AQ EDIT block | Thirst (aq33/AquilaStation#461) |
| Hitsplatter `GoTo()` through `INVOKE_ASYNC`, no debug `message_admins` | `code/modules/mob/living/carbon/human/species.dm` (existing AQ EDIT block), `code/modules/projectiles/projectile/bullets.dm` | Blood splatter doesn't sleep in the attack chain (aq33/AquilaStation#461) |
| Exploding implants don't merge a non-engineering implant into `/obj/item/implant/explosive/engineering` | `code/game/objects/items/implants/implant_explosive.dm`, `implant()` | CE punishment implant keeps a traitor's microbomb separate (aq33/AquilaStation#461) |
| `COMSIG_GLOB_STROMDRIVE_EXPLOSION` sends the reactor | `nsv13/code/modules/power/stormdrive.dm`, `code/__DEFINES/dcs/signals/signals_global.dm` | CE implant only reacts to its own ship's stormdrive (aq33/AquilaStation#461) |
| `return` after handing out a non-nullrod holy weapon | `code/game/objects/items/holy_weapons.dm` | Exorcist shotgun has no `reskinned` var (aq33/AquilaStation#461) |
| RD suit storage unit holds the HEV suit instead of the research MODsuit | `code/game/machinery/suit_storage_unit.dm` | HEV from the 2024 changelog (aq33/AquilaStation#461) |
| Deck technician job card uses the `munitech` state | `code/game/objects/items/cards_ids.dm` | `decktechnician` state doesn't exist in `nsv13/icons/obj/card.dmi` |

Pre-existing single-call hooks that stay in core: `parts += mouse_report()` (`roundend.dm`) and `/datum/admins/proc/reloadwhitelist` in the admin verb list (`admin_verbs.dm`).

## Moved out of core by the modularization pass (class A)

| From | To | What |
|---|---|---|
| `items/tanks/jetpack.dm`, `crates_lockers/closets.dm`, `closets/bodybag.dm`, `closets/cardboardbox.dm` | `aquila/code/game/objects/items/tanks/jetpack.dm`, `aquila/code/game/objects/structures/crate_lockers/closets.dm` | `Moved()` dragging/thruster sounds |
| `items/cards_ids.dm` | `aquila/code/game/objects/items/cards_ids.dm` | Budget card withdrawal config gate |
| `client/verbs/ooc.dm` | `aquila/code/modules/client/verbs/ooc.dm` | "Zabij TGUI" verb |
| `admin/admin.dm`, `admin/verbs/pray.dm` | `aquila/code/modules/admin/admin.dm`, `aquila/code/modules/admin/verbs/pray.dm` | Whitelist reload verb, `ert_request()` |
| `__HELPERS/roundend.dm` | `aquila/code/__HELPERS/roundend.dm` | `mouse_report()` |
| `reagents/.../alcohol_reagents.dm` | `aquila/.../alcohol_reagents.dm` | Ethanol `get_hydration_factor()` |
| `power/rtg.dm` | `aquila/code/modules/power/rtg.dm` | Movable RTG (var, `wrench_act()`, network step of `process()`). The `if(anchored)` in `Initialize()` stays as an AQ EDIT. |
| `projectiles/guns/energy/laser.dm`, `projectiles/projectile/beams.dm`, `projectiles/guns/ballistic/automatic.dm` | `aquila/code/modules/projectiles/...` | Hitscan laser balance var values |
| `subsystem/processing/turf_fire.dm`, `effects/turf_fire.dm`, `icons/effects/turf_fire.dmi`, `sound/weapons/flamethrower{1,2,3,_empty}.ogg` | same paths under `aquila/` | Turf fires (Yogstation #19738): the fire effect and its subsystem |
| `LINDA_fire.dm` (`IgniteTurf()`, ignition in `temperature_expose()`), `LINDA_turf_tile.dm` (`flammability`), `fancy_floor.dm`, `mineral_floor.dm`, `reinf_floor.dm`, `grille.dm`, `tank_types.dm`, `beams.dm` / `_incendiary.dm` (`on_hit()` ignition), `reagents.dm` / `holder.dm` and five reagent files (`accelerant_quality`) | `aquila/code/modules/atmospherics/environmental/LINDA_fire.dm`, `aquila/code/game/turfs/open/floor/turf_fire_flammability.dm`, `aquila/code/game/objects/structures/grille.dm`, `aquila/code/game/objects/items/tanks/tank_types.dm`, `aquila/code/modules/projectiles/projectile/{beams,bullets/_incendiary}.dm`, `aquila/code/modules/reagents/chemistry/accelerants.dm` | Turf fires: var values, new procs and post-`..()` additions |
| `antagonists/morph/morph.dm`, `morph_antag.dm` | `aquila/code/modules/antagonists/morph/morph_objectives.dm` | Morph objectives (Yogstation #13996); counting hooks in through an `eat()` override |
| `nsv13/.../clothing/masks/_masks.dm` | `aquila/code/modules/clothing/masks/gasmask.dm` | Gas mask breathing sound only on internals |

## Remaining core edits, by kind

### Left on purpose: interleaved logic (F unless noted)

These change lines *inside* upstream procs. Moving them would mean copying whole procs into `aquila/` (new full copies) or adding speculative hooks.

- **Thirst / defecation systems** (`species.dm`, `carbon.dm`, `blood.dm`, `food_reagents.dm`, `drink_reagents.dm`, `alcohol_reagents.dm` var, `watercloset.dm`, `cleanable.dm`, `cleanable/humans.dm`, `_shoes.dm`, `__DEFINES/misc.dm`, `__DEFINES/mobs.dm`, species `inherent_traits` lists). Spread across core metabolism procs; architectural.
- **RP filter** (`configuration.dm`, `mob/living/say.dm`, `__DEFINES/say.dm`). Interleaved in `say()`; would need a new say signal.
- **Radio say keybind (Y)** (`subsystem/input.dm`, `client/verbs/input_box.dm`). Data inside core lists.
- **Admin metacoins panel / topic** (`admin.dm`, `topic.dm`). The `modmetacoins` branch sits *after* core `Topic()`'s owner and `CheckAdminHref()` checks. The existing Aquila `Topic()` override runs *before* those checks, so moving the branch there would weaken security. Left in core.
- **Communications console ERT** (`communications.dm`, `requests/request.dm`). Inside `ui_data`/`ui_act`.
- **Holy weapons list** (`holy_weapons.dm`), **compile_monkey_icon multi-state** (`storage.dm`, `_head.dm`, `_masks.dm`, `_under.dm`), **vampire biting** (`human_defense.dm`), **monkey antag check** (`mob_helpers.dm`), **devil/sintouched lust** (`contracts.dm`, `devil/objectives.dm`, `sintouched.dm`, `spell_types/devil.dm`), **sentient disease channels** (`advance.dm`), **nuke challenge TC** (`nuclear_challenge.dm`, `shuttle/syndicate.dm`), **cargo battery export** (`exports.dm`), **looping machine sounds** (`_computer.dm`, `modular_fabricator.dm`, `_production.dm`, `generator.dm`, `lore_terminal.dm`, FTL `drive.dm`).
- **Recent fixes and ports kept inline** (do not move): `stasis.dm` null guard, `implant_storage.dm` deleted-implantee path, `roomspawner.dm` late-load fix, `heal.dm` teratoma loot chance, `macrophage.dm` skin init.
- **Monkey-like trait rename** (`TRAIT_MONKEYLIKE` → `TRAIT_DISCOORDINATED`: `traits.dm`, `_globalvars/traits.dm`, `severe.dm`, `human_helpers.dm`, `status_composers.dm`, `bloody_eye.dm`). A rename across core uses.
- **Nanites rework** (`components/nanites.dm`, `nanite_programs.dm`, `nanite_programs/utility.dm` incl. the Aquila-only `cloud_change` program, `__DEFINES/nanites.dm`, `all_nodes.dm` commented nodes).
- **Turf fires port, interleaved part** (Yogstation #19738): `flamethrower.dm` (fuel and ignition rewrite), `firealarm.dm` (`temperature_expose()` condition), `change_turf.dm` (fire carried over on `ChangeTurf()`), `anomalies.dm` (pyroclastic anomaly), `bottle.dm` (molotov). Everything else of the port is in `aquila/`.
- **Emote update port, interleaved part** (BeeStation #11617): `EMOTE_*` bitflags and `ALWAYS_SHOW_SELF_MESSAGE` (`__DEFINES/say.dm`; `EMOTE_VISIBLE` stays 1 so `emote("me", 1, ...)` callers keep meaning "visible"), `run_emote()` rewrite (`datums/emotes.dm`), self-message runechat and `show_message()` return value (`mob.dm`), custom say emote (`mob/say.dm`, `living/say.dm`), `emote_type` on every emote (core emote files, plus `EMOTE_VISIBLE` on the Aquila/NSV13 emotes that relied on the old default), deathgasp mask sound, moth flutter and whistle sound (`living/emote.dm`). New emotes, animations, the mask var and the emote panel are in `aquila/`.
- **Job datums** (`jobs/job_types/*.dm`, `military_police.dm`, `subsystem/job.dm`). Outfits, implants, slots and exp requirements are mixed with hardened job-title and radio-channel constants. Left alone to avoid touching the job/config parsing hardening.

### Voices and sounds (`dzwieki` branch)

One-line hooks; everything else is in `aquila/code/modules/mob/voice.dm`, the Aquila emote files and the mirrored machine files.

- `code/game/sound.dm`: `playsound()` accepts a prepared `/sound` (muffled voices) and rolls `vary` once for all listeners; `get_rand_frequency()` returns a playback multiplier instead of Hz (sample-rate independent); extra `get_sfx()` keys in the AQ EDIT block.
- `code/datums/emotes.dm`: `run_emote()` calls `play_emote_sound()` (voice pitch of vocal emotes).
- `code/datums/looping_sounds/_looping_sound.dm`: `play()` passed `extra_range` as `vary`; it also passes `vary`, falloff and `ignore_walls` (vars added in `aquila/code/datums/looping_sounds/machinery_sounds.dm`).
- `code/game/objects/items.dm`: `equip_sound` only when worn (`slot_flags & slot`), not when picked up.
- `code/game/turfs/turf.dm`: `handle_fall()` also thuds, more quietly, when lying down on purpose.
- `code/modules/client/preferences.dm`, `preferences2/character_save.dm`: voice pitch row, its input/random handlers, sanitizing and randomising `features["voice_pitch"]`.
- `code/game/machinery/telecomms/broadcasting.dm`: the receive beep goes to the listener only (`play_radio_receive_sound()`), it used to be a positional sound everyone around heard.
- `code/game/objects/items/devices/radio/radio.dm`: `talk_into_impl()` plays `play_radio_talk_sound()`, audible next to the speaker.

### Smartwires port (BeeStation/BeeStation-Hornet#14275, F)

The power cable system is replaced in core, at the same paths as in BeeStation, so a later upstream sync of smartwires lands on the same files. Merging upstream power code needs care here.

- **Rewritten:** `code/modules/power/cable.dm` (whole file), new `code/modules/power/cable_coil.dm`. NSV13 differences against Bee: cables still hide with `level`/`hide(intact)` (we have no `undertile` element), the `/obj/structure/cable/multiz` mapping subtype (our maps link decks on plain floor), a cable computes its own node on `reform_connections()` and counts linked directions with `!!` (Bee summed the bit values, so only north-ending cables got a node), `clear_connections()` also resets the cable's own links (shuttle moves), player-laid open space cables are multi-z, coil keeps the robotic limb repair, cyborg subtype and `novariants = TRUE`.
- **Changed procs:** `power.dm` (`WANTS_POWER_NODE`, `get_powernet()`, new `get_bridged_cables()`, `get_cable_node()` uses `has_power_node`, old propagation procs removed; `lateShuttleMove()` kept), `powernet.dm` (`dirty`, `mark_dirty()`, `repropogate_cables()` which also walks multi-z cables and `get_bridged_cables()`), `subsystem/machines.dm` (dirty powernet queue), `multiz.dm` (deck relays bridge through `get_bridged_cables()`, `break_connections()` marks the net dirty), `turf.dm` (`attackby` lays cable with `place_on_turf()`).
- **Removed:** RCL (`items/RCL.dm`, crafting recipe) and the mech cable layer (`work_tools.dm`); coloured coil subtypes (code and maps repathed); `GLOB.powernets`; cable procs in `on_move.dm` and `shuttle_rotate.dm`; noose stack recipe (now a crafting recipe in `recipes.dm`).
- **Hooks:** `WANTS_POWER_NODE` define in `__DEFINES/machines.dm`, cable colours in `__DEFINES/colors.dm`, `WANTS_POWER_NODE` lines in `grille.dm` and `shieldgen.dm`, two map lints in `tools/ci/check_grep.sh`. NSV13 machines that feed from the cable under them get their `WANTS_POWER_NODE` in `aquila/code/modules/power/smartwires.dm`.
- **Maps:** converted with `tools/smartwires/convert.py`, which keeps every old powernet as exactly one powernet. Run it on maps from older branches before merging them.

### Combat mode port (BeeStation/BeeStation-Hornet#11899, F)

Combat mode and right-click actions are ported in core, at the same paths as in BeeStation, so later Bee click/attack code lands on the same procs. Post-merge Bee fixes included: #12301 (F key), #12324 (a pull survives a misclick next to the grabbed mob), #13404, #13406 (combat mode always hits borgs), the adjacent-shot part of #13155, #14313 (`inverted_rotation`). Merging upstream click, attack, martial arts and HUD code needs care here.

- **Rewritten like Bee:** `_onclick/click.dm`, `_onclick/item_attack.dm`, `_onclick/other_mobs.dm` (secondary attack chain, `tool_act` with `is_right_clicking`), `datums/components/rotation.dm` (Bee API, Alt+LMB/RMB), martial arts (`cqc`, `karate`, `plasma_fist`, `psychotic_brawl`, `sleeping_carp`, `tribal_claw`, `boxing`, `_martial.dm` combos and info button), syringes (LMB injects, RMB draws), airlock/door tool acts, tables, windows, stacks, RCD, closets/chairs/filing cabinets (wrench on RMB).
- **Kept from NSV13 on purpose:** `a_intent`/`possible_a_intents` and the `INTENT_*` defines (the legacy mode needs them), our `can_inject()` signature (Bee's `try_inject`/`INJECT_*` refactor not ported), `RemoveComponent()` (not renamed), `spec_unarmedattacked()`, the devil soul counter, the recycler, sprays, teleprod, stun baton (NSV hard stun), krav maga/wrestling/mushpunch. `apply_martial_art()` only runs human vs human, because our martial arts expect `dna`/species on both sides.
- **Legacy mode:** everything lives in `aquila/code/_onclick/legacy_intents.dm`. Core hooks: `translate_legacy_intent_click()` in `ClickOn()`, `combat_mode_intent_change()`/`legacy_intent_changed()` in `a_intent_change()`, `sync_intent_with_combat_mode()` in `/mob/living/set_combat_mode()`, `update_shift_context_menu()` in `keyDown`/`keyUp`. The old selector types (`/atom/movable/screen/act_intent*`) moved to the same file.
- **Defines and prefs:** `CHAT_LEGACY_INTENTS`, `CHAT_DISABLE_COMBATMODE_SOUND`, `CHAT_INVERTED_ROTATION` (`chat_toggles`, because `toggles2` is full), `COMSIG_KB_LIVING_TOGGLE_COMBAT_DOWN`, `COMSIG_LIVING_UNARMED_ATTACK`, the secondary attack signals at the end of `signals_atom.dm` (`COMSIG_ITEM_ATTACK_SECONDARY` uses its own string, Bee reused the primary one), `ui_combat_toggle`/`ui_combo`, `NO_DEXTERITY` alias, `ISADVANCEDTOOLUSER()` wrapping our `IsAdvancedToolUser()`. `aquila/code/__DEFINES/span.dm` is included early in `nsv13.dme`, because Bee hunks in core use `span_*`.
- **NSV13 code converted by hand:** KNPC AI (combat mode, sometimes a right-click shove), jujitsu grab, hugbot tipping (RMB), mech clamp arm ripping (RMB), ethereal APC charging (RMB = give power), overmap F key (special weapon action wins over the combat toggle at the helm or guns).
- **Assets:** `combat`/`combat_off` states in every `icons/mob/screen_*.dmi` style plus alien and cyborg, `combo*` states in `screen_gen.dmi`, `icons/effects/mouse_pointers/examine_pointer.dmi`, `sound/misc/ui_togglecombat.ogg`, `ui_toggleoffcombat.ogg`, `sound/effects/glassbash.ogg`, all from Bee.

### Bleeding port (BeeStation/BeeStation-Hornet#10372, F)

Bleeding is a status effect (`/datum/status_effect/bleeding` in `mob/living/blood.dm`), ported in core at Bee paths. Post-merge Bee fixes included by hand: #13797 (no blood drop on `add_bleeding()`, dead bodies bleed slower), #13913/#14239 (no blood on groundless turfs or inside containers), #13827 (the cauterise message goes to the victim), #11057 (medbots bandage, rewritten for our tend-wounds medbot). Left out: the blood anomaly event and reactive bleed armour (not medical, needs Bee projectile paths), #11614 self-tend (needs Bee metabolites), #12130 (our operating table does not buckle).

- **`blood.dm` is the Bee file** with our edits on top: the hydration check in blood regeneration (`AQ EDIT`), `DISEASE_SPREAD_FALTERED`, quirks in blood data, `add_bloodiness()`, Polish texts.
- **Kept from NSV13:** the `armor` lists with string keys (`"bleed"` was added to `/datum/armor` next to our `overmap_*` fields), our medical stacks (only the bleeding check and the `stop_bleeding` values changed), our human `attack_animal()` (bleeding added there instead of Bee's carbon version), blood splatter on hits in `spec_attacked_by()` (Aquila hit splatter), the optable bleeding trait on resting.
- **Values:** `bleed_force` and the `"bleed"` armour were copied from Bee by type path (Bee paths mapped to ours, e.g. `/obj/projectile` to `/obj/item/projectile`). NSV13/Aquila clothing got the value of its nearest parent, or 50 for armoured clothes (melee or bullet 20+), same as `/obj/item/clothing/suit/armor`.
- **Assets:** `aquila/icons/hud/screen_alert_bleeding.dmi` (bleeding alerts), `aquila/icons/obj/bleeding.dmi` (pressure offhand), `aquila/sound/surgery/blood_wound.ogg`, all from Bee #10372 (CC-BY-SA 3.0).

### Blood types and species blood colours (BeeStation/BeeStation-Hornet#13410, F)

`code/datums/blood_type.dm` (Bee path) defines `/datum/blood_type` with colour, compatibility and glow. Unlike Bee, `dna.blood_type` and blood DNA lists still hold the type **name** (`"A+"`, `"L"`, `"X*"`), looked up with `get_blood_type()`, so records, cloning, the DNA console, injectors and NSV13 blood freight are untouched. `get_safe_blood()` now reads the datums.

- **Colour:** human blood sprites in `icons/effects/blood.dmi`, `footprints.dmi` and `icons/mob/dam_mob.dmi` were replaced with Bee's greyscale versions; our own states (`trails_*`, `ltrails_*`, Aquila `hitsplatter*`) were greyscaled the same way. Blood decals, drag trails, splatters, item stains, clothing overlays, bloody hands and brute overlays are tinted with `get_blood_dna_color()`/`get_blood_color()`. Non-blood footprints (oil, xeno, feces) clear the colour.
- **Species:** IPCs bleed `Coolant` (light grey) instead of oil, ethereals bleed glowing `E` blood instead of liquid electricity, lizards stay `L` (teal). `species.blood_color` was removed. Blood packs: `E` and `Coolant` added, the old liquid electricity `LE` pack is now an `E` pack.
- **Left out from Bee:** datum values in DNA lists, `blush_color`, the inventory slot guards, the `trail_holder` rename (ours was already a child of blood).

### Small tgstation medical ports

- **Hearts regenerate blood (tgstation#96129):** `aquila/code/modules/surgery/organs/heart_blood.dm`; core hook: the multiplier in the `AQ EDIT` block of `/mob/living/carbon/human/handle_blood()` (`mob/living/blood.dm`).
- **Cause of death (tgstation#95655):** `AQ EDIT` lines in `machinery/computer/medical.dm` (shown and editable only for `*Deceased*`, wiped on any other status, printed on the record). Stored in the general record as `fields["cause_of_death"]`.
- **IV drip tube (tgstation#88217):** `aquila/code/game/machinery/iv_drip_beam.dm` and `aquila/code/datums/components/tug_towards.dm`, synced from `update_icon()`, no core edit. Our old `/datum/beam` has no colour or origin offset, so the tube is a silver `/obj/effect/ebeam/iv_tube` drawn from the drip's centre.
- **Defibrillation without a time limit (tgstation style):** `aquila/code/game/objects/items/defib_reasons.dm` (`is_defib_possible()`, `has_dnr()`, med HUD refresh when a dead heart or brain decays). Core hooks marked `AQ EDIT`: `shockpaddles/can_defib()` and the DNR reason in `do_help()` (`items/defib.dm`), the defib-able HUD icon (`data_huds.dm`), the analyzer line (`scanners.dm`), the stethoscope (`clothing/neck/_neck.dm`). `DEFIB_TIME_LIMIT` is now only used by the old HUD refresh timer in `living/death.dm`.
- **BeeStation surgeries:** stomach pump (`aquila/code/modules/surgery/stomach_pump.dm`) and identity recalibration (`identity_recalibration.dm`, robotic chests, BeeStation #12856), both on our step-based surgery. Our `vomit()` has no `purge_ratio`, so the pump removes 67% of the patient's reagents itself; the rename uses `fully_replace_character_name()` instead of only `real_name`.
- **Vitals monitor (tgstation#94704):** `aquila/code/game/machinery/vitals_reader.dm`, icon `aquila/icons/obj/machines/vitals_monitor.dmi` (tgstation, MrMelbert, CC-BY-SA 3.0). Built from a protolathe frame (biotech / advanced biotech nodes), connects with a multitool to an operating table, stasis bed, sleeper, cryo cell, DNA scanner or autodoc within 3 tiles. Our machines have no occupant signal, so it polls the machine each process tick. Core hook: `tochat = FALSE` in `healthscan()`/`chemscan()` (`scanners.dm`, `AQ EDIT`) returns the text for examine. Not placed on maps.
- **Autopsy (tgstation coroner, #75065/#77386/#89094):** `aquila/code/modules/surgery/autopsy.dm`, the step-based version from before the tg surgery rework, plus the autopsy scanner (2 in every NanoMed Plus, protolathe design in biotech). Uses its own `autopsied` trait (removed on revive) instead of `TRAIT_DISSECTED`, so experimental dissection still works; no "surgically analyzed" bonus, morbid mood or experiment. Icons from tgstation (CC-BY-SA 3.0): `aquila/icons/obj/autopsy_scanner.dmi`, `aquila/icons/mob/inhands/autopsy_scanner_*.dmi`, `aquila/icons/mob/autopsy_scanner_belt.dmi`.
- **Recovered Crew and Thanatorenasia (tgstation#87072, #87491, #95469):** `aquila/code/modules/lost_crew/`. Cargo crate "Odzyskana załoga" (medical, 2000 kr) with a body bag holding a dead crewmember (random look, job and cause of death, decayed organs, maybe a lost limb). Revived without a player, the body polls ghosts (`/datum/component/ghostrole_on_revive`, mob only, through SSpolling, takeover like `offer_control()`); the new player gets the job via `SSjob.EquipRank()` and the manifest, and medbay gets 3000 kr if they live 3 minutes. Simplified from tg: our own seven causes of death, no mind lockbox, no brain-removal bomb, no spawner menu entry or soul eyes. Thanatorenasia is a 0-point quirk: choosing DNR adds the component. Core hook: `on_dnr()` in the ghost DNR verb (`observer.dm`, `AQ EDIT`); `has_dnr()` ignores bodies with the component. Event "Recovered Crew Delivery" (`lost_crew_delivery.dm`, subtype of the stray cargo pod) drops a free body bag in the cargo bay up to twice a round; every bag holds a card with step-by-step revival instructions.
- **Radial surgery menu (UX of tgstation#93697):** `aquila/code/datums/components/surgery_radial.dm` overrides `surgery_initiator/ui_interact()` to show a radial menu around the patient instead of the `SurgeryInitiator` TGUI window; each surgery's picture is the tool of its first non-generic step. The step-based surgeries themselves are unchanged (the full tg operations rework was not ported).
- **Medical records console in TGUI:** `aquila/code/game/machinery/computer/medical_records_ui.dm` + `MedicalRecordsConsole.tsx`, same approach as the security console: buttons send the old link parameters through `Topic()`, so logging, access checks and printing stay in `medical.dm`. Record statuses stay in English in the records (HUDs read them) and are translated in the window only.
- **tgstation sutures and regenerative mesh:** `aquila/code/game/objects/items/stacks/medical_tg.dm`, sprites in `aquila/icons/obj/medical/stack_medical.dmi`. They replace bruise packs and ointment (`AQ EDIT`) in `firstaid.dm`, `boxes.dm`, crafting `recipes.dm`, `ghost_role_spawners.dm`, `warping.dm`, the ruin generator `mapping.dm` and `maintenance_loot.dm`, and are sold by both NanoMeds (`vending/medical.dm`, `medical_wall.dm`). Gauze still stops bleeding. Bruise packs and ointment remain as types (map placements).
- **tgstation medkit sprites:** `aquila/icons/obj/medical/medkit.dmi` and `aquila/icons/mob/inhands/equipment/medkit_*hand.dmi`; `firstaid.dm` icon states (`AQ EDIT`, no random alternate sprites any more); radiation and mystery kits keep the old Aquila sprites, the gang medkit (`gang_items.dm`) uses `oldbezerk`.
- **Light wounds (tgstation wounds, simplified):** `aquila/code/modules/wounds/`, defines in `aquila/code/__DEFINES/wounds.dm`. Rolled in `human/attacked_by()` and `human/bullet_act()` overrides from the damage each limb really took (snapshot before and after `..()`), so no core hit code changes. Blunt (dislocation, fracture, compound fracture), slash on top of Bee bleeding (deep cut, torn artery), burn (second and third degree with infection). Treatment: help intent with an empty hand resets dislocations, gauze splints fractures, sutures close cuts, mesh or ointment dresses burns; surgeries "nastawienie kości" and "usunięcie martwej tkanki", and the cauterization surgery closes cuts. Core hook: wound lines in `healthscan()` (`scanners.dm`, `AQ EDIT`). No scars, wound armor or per-weapon wound bonus; `WOUND_THRESHOLD_MULTIPLIER` tunes how often they happen.
- **Health analyzer window (PowerfulBacon-2/AuriStation#15):** `aquila/code/game/objects/items/devices/health_analyzer_ui.dm`, `HealthAnalyzer.tsx`, `components/ScrollingChart.tsx` and two stylesheets. Health mode on carbons opens the window (body outline, injuries per limb, pulse/oxygen/blood/damage charts, reagents); chemical mode, simple mobs and clumsy users keep the chat scan, and the window has a button to print the old scan to chat. Auri's pain, consciousness and injury trees are not ported, the data comes from our damage, wounds, bleeding, organs, traumas and diseases.
- **Surgery pain messages (tgstation#61252):** `aquila/code/modules/surgery/surgery_pain.dm`. Instead of a `display_pain()` call in every `preop()`, each step has a `pain_message` var shown from a `play_preop_sound()` override (it runs right after `preop()` for every step); conscious patients scream 30% of the time, robotic steps only describe the sensation, sleep or morphine spares the patient. Autopsy reports also list wounds.
- **Vitals monitors over stasis beds and next surgery step:** every stasis bed on Atlas, Snake and Serendipity has a wall vitals monitor paired by `id_tag` (`aq_vitals_<map>_<x>_<y>`), so it never links to a neighbouring operating table; wall items that sat in that spot were moved to a free wall spot in the same room (Atlas brig and medbay fire alarms, light switch and intercom; Snake defibrillator mount; Serendipity status display, camera and poster). The advanced health analyzer (window and chat) shows each ongoing surgery's next step and the best tools (`aquila/code/modules/surgery/surgery_progress.dm`, chat line in `healthscan()`, `AQ EDIT`).

### Data tweaks left in core lists (D-like)

Vending product lists (`wardrobes.dm`, `clothesmate.dm`, `autodrobe.dm`, `plasmaresearch.dm`, `munitions_machinery.dm`), loot lists (`lootdrop.dm`, `mailspawner.dm`, `uplink_kits.dm`, `boxes.dm`, `cargo/packs.dm`, `security.dm` closet), techweb `design_ids` (`all_nodes.dm`), `poll_ignore.dm`, ambience lists. Overriding a whole list in `aquila/` would silently hide upstream additions, which is worse than a visible merge conflict.

### Sound and resource swaps (D-like)

About 40 single-line `playsound`/`sound =`/`icon =` swaps to `aquila/sound` or `aquila/icons` inside upstream procs (mecha, robots, bots, medbot voice lines, cat/dog, hydroponics, chem dispenser, pour sounds, megaphone, lightswitch, newscaster, particle accelerator, ORM, title music volume, ...). Each is a one-line change in the middle of an upstream proc.

### Map-bound (E)

`mapping/random_rooms.dm` (Aquila room templates), `effects/spawners/roomspawner.dm` (gulag/atlas spawners), `nsv13/.../munitions_trolley.dm` dummy, `datums/map_config.dm` (`has_gulag`), area definitions in `game/area/*` and `nsv13/code/game/area/*` (Polish names; maps reference these types), `controllers/subsystem/mapping.dm`. Not touched.

Known pre-existing issue: the gulag random room `sk_rdm_glg_06` (Syndicate Listening Post) has stacked pipes. When the spawner rolls it, two runtimes fire during `SSair` template setup (`set_pipenet` index out of bounds). This makes CI runs randomly unclean, on master as well.

### Aquila feature ports living at upstream paths (F)

The heretic rework (`antagonists/heretic/**`, replacing `eldritch_cult/**`), space dragon rework (`space_dragon/**`, `gravity_aura`), `snacks_cheese.dm`, `gastrectomy.dm`, `cortex_folding.dm`/`cortex_imprint.dm`, `void_storm.dm` and their unit tests. These are BeeStation ports kept at BeeStation paths so later BeeStation cherry-picks apply cleanly. Moving them into `aquila/` would also change `typesof()`/`subtypesof()` order (surgery menu order, knowledge lists), so it is not behaviour-neutral.

### Localization only (D)

String-only changes (Polish translations) in core: see the generated list below. Kept in place; moving thousands of strings would only make merges worse. `__DEFINES/radio.dm` (Polish radio channel names) and `__DEFINES/jobs.dm` (Polish job titles) are string-only but are load-bearing for the hardening fixes (channel constants, job title lookups). Never move or retranslate them independently.

### Other notes

- `aquila/code/modules/food_and_drinks/recipes/tablecraft/recipes_pie.dm` exists but is not included in `aquila.dm`. It is dead on master; including it would change crafting, so it was left alone.
- The Aquila `/datum/admins/Topic()` override (`aquila/code/modules/admin/topic.dm`) handles `makeAntag` before core's `CheckAdminHref()` validation. It does call `check_rights(R_ADMIN)`. Worth hardening separately.

## Generated inventory (core files differing from the upstream merge base)

Produced by comparing every changed line with string literals, `'resource'` literals and comments masked out.

| Kind | Files |
|---|---|
| Logic changes (incl. string changes) | 420 |
| Localization only | 111 |
| Localization and resource swaps only | 9 |
| Comment/whitespace only (or binary) | 30 |
| Added by Aquila | 60 |
| Deleted by Aquila | 13 |

Of the logic files, 182 contain an AQ/AQUILA marker or an `aquila/` resource; the other 238 are unmarked (mostly older Aquila ports and translations mixed with code).

<details><summary>Localization only (111)</summary>

- `code/__DEFINES/jobs.dm`
- `code/__DEFINES/radio.dm`
- `code/__HELPERS/priority_announce.dm`
- `code/controllers/subsystem/nightshift.dm`
- `code/datums/ai/dog/dog_controller.dm`
- `code/datums/ai_laws.dm`
- `code/datums/components/aiming.dm`
- `code/datums/weather/weather_types/ash_storm.dm`
- `code/datums/weather/weather_types/radiation_storm.dm`
- `code/game/area/Space_Station_13_areas.dm`
- `code/game/area/ai_monitored.dm`
- `code/game/gamemodes/brother/traitor_bro.dm`
- `code/game/gamemodes/events.dm`
- `code/game/gamemodes/events/event.dm`
- `code/game/gamemodes/gangs/gangs.dm`
- `code/game/gamemodes/incursion/incursion.dm`
- `code/game/gamemodes/objective.dm`
- `code/game/gamemodes/objective_items.dm`
- `code/game/gamemodes/overthrow/overthrow.dm`
- `code/game/machinery/announcement_system.dm`
- `code/game/machinery/computer/security.dm`
- `code/game/machinery/doppler_array.dm`
- `code/game/objects/items/cardboard_cutouts.dm`
- `code/game/objects/items/religion.dm`
- `code/game/objects/items/storage/backpack.dm`
- `code/modules/antagonists/blob/blob.dm`
- `code/modules/antagonists/blob/blob_mobs.dm`
- `code/modules/antagonists/blob/blobstrains/_blobstrain.dm`
- `code/modules/antagonists/blob/blobstrains/blazing_oil.dm`
- `code/modules/antagonists/blob/blobstrains/cryogenic_poison.dm`
- `code/modules/antagonists/blob/blobstrains/electromagnetic_web.dm`
- `code/modules/antagonists/blob/blobstrains/energized_jelly.dm`
- `code/modules/antagonists/blob/blobstrains/explosive_lattice.dm`
- `code/modules/antagonists/blob/blobstrains/networked_fibers.dm`
- `code/modules/antagonists/blob/blobstrains/pressurized_slime.dm`
- `code/modules/antagonists/blob/blobstrains/reactive_spines.dm`
- `code/modules/antagonists/blob/blobstrains/regenerative_materia.dm`
- `code/modules/antagonists/blob/blobstrains/replicating_foam.dm`
- `code/modules/antagonists/blob/blobstrains/shifting_fragments.dm`
- `code/modules/antagonists/blob/blobstrains/synchronous_mesh.dm`
- `code/modules/antagonists/blob/blobstrains/zombifying_pods.dm`
- `code/modules/antagonists/blob/overmind.dm`
- `code/modules/antagonists/blob/structures/_blob.dm`
- `code/modules/antagonists/blob/structures/core.dm`
- `code/modules/antagonists/blob/structures/factory.dm`
- `code/modules/antagonists/blob/structures/node.dm`
- `code/modules/antagonists/blob/structures/resource.dm`
- `code/modules/antagonists/blob/structures/shield.dm`
- `code/modules/antagonists/official/official.dm`
- `code/modules/atmospherics/machinery/components/unary_devices/cryo.dm`
- `code/modules/cargo/orderconsole.dm`
- `code/modules/client/preferences2/character_save.dm`
- `code/modules/clothing/masks/hailer.dm`
- `code/modules/crew_objectives/_crew_objectives.dm`
- `code/modules/crew_objectives/cargo_objectives.dm`
- `code/modules/crew_objectives/command_objectives.dm`
- `code/modules/crew_objectives/engineering_objectives.dm`
- `code/modules/crew_objectives/medical_objectives.dm`
- `code/modules/crew_objectives/security_objectives.dm`
- `code/modules/events/grid_check.dm`
- `code/modules/events/shuttle_loan.dm`
- `code/modules/mob/living/carbon/emote.dm`
- `code/modules/mob/living/emote.dm`
- `code/modules/mob/living/simple_animal/friendly/drone/_drone.dm`
- `code/modules/mob/living/simple_animal/friendly/drone/drones_as_items.dm`
- `code/modules/mob/living/simple_animal/friendly/drone/extra_drone_types.dm`
- `code/modules/mob/living/simple_animal/hostile/retaliate/ghost.dm`
- `code/modules/modular_computers/computers/item/role_tablet_presets.dm`
- `code/modules/projectiles/boxes_magazines/external/rifle.dm`
- `code/modules/reagents/chemistry/machinery/pandemic.dm`
- `code/modules/shuttle/emergency.dm`
- `code/modules/vending/_vending.dm`
- `code/modules/vending/boozeomat.dm`
- `code/modules/vending/cigarette.dm`
- `code/modules/vending/coffee.dm`
- `code/modules/vending/cola.dm`
- `code/modules/vending/drinnerware.dm`
- `code/modules/vending/games.dm`
- `code/modules/vending/liberation_toy.dm`
- `code/modules/vending/magivend.dm`
- `code/modules/vending/medical.dm`
- `code/modules/vending/megaseed.dm`
- `code/modules/vending/mining.dm`
- `code/modules/vending/modularpc.dm`
- `code/modules/vending/nutrimax.dm`
- `code/modules/vending/security.dm`
- `code/modules/vending/snack.dm`
- `code/modules/vending/sovietsoda.dm`
- `code/modules/vending/sustenance.dm`
- `code/modules/vending/toys.dm`
- `nsv13/code/controllers/subsystem/overmap_mode.dm`
- `nsv13/code/game/area/aetherwhisp.dm`
- `nsv13/code/game/area/areas.dm`
- `nsv13/code/game/area/boarding_areas.dm`
- `nsv13/code/game/area/hammerhead.dm`
- `nsv13/code/game/area/hammurabi.dm`
- `nsv13/code/game/area/pegasus.dm`
- `nsv13/code/game/gamemodes/overmap/courier.dm`
- `nsv13/code/game/gamemodes/overmap/shakedown.dm`
- `nsv13/code/game/objects/items/custom_guns.dm`
- `nsv13/code/modules/antagonists/simple_teamchat.dm`
- `nsv13/code/modules/mob/living/carbon/human/species_types/catgirl.dm`
- `nsv13/code/modules/mob/living/carbon/human/species_types/other_knpc.dm`
- `nsv13/code/modules/mob/living/carbon/human/species_types/spacepirate_knpc.dm`
- `nsv13/code/modules/mob/living/carbon/human/species_types/syndicate_knpc.dm`
- `nsv13/code/modules/mob/living/simple_animal/bot/catmed.dm`
- `nsv13/code/modules/overmap/FTL/ftl_jump.dm`
- `nsv13/code/modules/overmap/factions.dm`
- `nsv13/code/modules/overmap/fleet_combat/combat_handling.dm`
- `nsv13/code/modules/overmap/overmap.dm`
- `nsv13/code/modules/overmap/weapons/damage.dm`

</details>

<details><summary>Localization and resource swaps only (9)</summary>

- `code/controllers/subsystem/communications.dm`
- `code/datums/brain_damage/special.dm`
- `code/game/objects/items/devices/scanners.dm`
- `code/modules/antagonists/traitor/equipment/Malf_Modules.dm`
- `code/modules/flufftext/Hallucination.dm`
- `code/modules/mob/living/silicon/robot/emote.dm`
- `code/modules/mob/living/simple_animal/bot/SuperBeepsky.dm`
- `code/modules/mob/living/simple_animal/bot/secbot.dm`
- `code/modules/mob/living/simple_animal/hostile/netherworld.dm`

</details>

<details><summary>Added by Aquila (60)</summary>

- `code/controllers/subsystem/processing/gravity_aura.dm`
- `code/datums/components/gravity_aura.dm`
- `code/datums/weather/weather_types/void_storm.dm`
- `code/modules/antagonists/heretic/heretic_antag.dm`
- `code/modules/antagonists/heretic/heretic_focus.dm`
- `code/modules/antagonists/heretic/heretic_knowledge.dm`
- `code/modules/antagonists/heretic/heretic_living_heart.dm`
- `code/modules/antagonists/heretic/heretic_monsters.dm`
- `code/modules/antagonists/heretic/influences.dm`
- `code/modules/antagonists/heretic/items/crucifix.dm`
- `code/modules/antagonists/heretic/items/eldritch_flask.dm`
- `code/modules/antagonists/heretic/items/forbidden_book.dm`
- `code/modules/antagonists/heretic/items/heretic_armor.dm`
- `code/modules/antagonists/heretic/items/heretic_blades.dm`
- `code/modules/antagonists/heretic/items/heretic_necks.dm`
- `code/modules/antagonists/heretic/items/madness_mask.dm`
- `code/modules/antagonists/heretic/knowledge/ash_lore.dm`
- `code/modules/antagonists/heretic/knowledge/flesh_lore.dm`
- `code/modules/antagonists/heretic/knowledge/general_side.dm`
- `code/modules/antagonists/heretic/knowledge/rust_lore.dm`
- `code/modules/antagonists/heretic/knowledge/sacrifice_knowledge/sacrifice_buff.dm`
- `code/modules/antagonists/heretic/knowledge/sacrifice_knowledge/sacrifice_knowledge.dm`
- `code/modules/antagonists/heretic/knowledge/sacrifice_knowledge/sacrifice_map.dm`
- `code/modules/antagonists/heretic/knowledge/sacrifice_knowledge/sacrifice_moodlets.dm`
- `code/modules/antagonists/heretic/knowledge/side_ash_flesh.dm`
- `code/modules/antagonists/heretic/knowledge/side_flesh_void.dm`
- `code/modules/antagonists/heretic/knowledge/side_rust_ash.dm`
- `code/modules/antagonists/heretic/knowledge/side_void_rust.dm`
- `code/modules/antagonists/heretic/knowledge/starting_lore.dm`
- `code/modules/antagonists/heretic/knowledge/void_lore.dm`
- `code/modules/antagonists/heretic/magic/aggressive_spread.dm`
- `code/modules/antagonists/heretic/magic/ash_ascension.dm`
- `code/modules/antagonists/heretic/magic/ash_jaunt.dm`
- `code/modules/antagonists/heretic/magic/blood_cleave.dm`
- `code/modules/antagonists/heretic/magic/blood_siphon.dm`
- `code/modules/antagonists/heretic/magic/eldritch_blind.dm`
- `code/modules/antagonists/heretic/magic/eldritch_emplosion.dm`
- `code/modules/antagonists/heretic/magic/eldritch_shapeshift.dm`
- `code/modules/antagonists/heretic/magic/eldritch_telepathy.dm`
- `code/modules/antagonists/heretic/magic/flesh_ascension.dm`
- `code/modules/antagonists/heretic/magic/madness_touch.dm`
- `code/modules/antagonists/heretic/magic/manse_link.dm`
- `code/modules/antagonists/heretic/magic/mansus_grasp.dm`
- `code/modules/antagonists/heretic/magic/nightwatcher_rebirth.dm`
- `code/modules/antagonists/heretic/magic/rust_wave.dm`
- `code/modules/antagonists/heretic/magic/void_phase.dm`
- `code/modules/antagonists/heretic/magic/void_pull.dm`
- `code/modules/antagonists/heretic/rust_effect.dm`
- `code/modules/antagonists/heretic/structures/carving_knife.dm`
- `code/modules/antagonists/heretic/structures/mawed_crucible.dm`
- `code/modules/antagonists/heretic/transmutation_rune.dm`
- `code/modules/antagonists/space_dragon/carp_rift.dm`
- `code/modules/food_and_drinks/food/snacks_cheese.dm`
- `code/modules/mob/living/simple_animal/heretic_monsters.dm`
- `code/modules/mob/living/simple_animal/hostile/space_dragon.dm`
- `code/modules/surgery/advanced/bioware/cortex_folding.dm`
- `code/modules/surgery/advanced/bioware/cortex_imprint.dm`
- `code/modules/surgery/gastrectomy.dm`
- `code/modules/unit_tests/heretic_knowledge.dm`
- `code/modules/unit_tests/heretic_rituals.dm`

</details>

<details><summary>Deleted by Aquila (13)</summary>

- `code/game/machinery/dance_machine.dm`
- `code/modules/antagonists/disease/disease_abilities.dm`
- `code/modules/antagonists/eldritch_cult/eldritch_antag.dm`
- `code/modules/antagonists/eldritch_cult/eldritch_book.dm`
- `code/modules/antagonists/eldritch_cult/eldritch_effects.dm`
- `code/modules/antagonists/eldritch_cult/eldritch_items.dm`
- `code/modules/antagonists/eldritch_cult/eldritch_knowledge.dm`
- `code/modules/antagonists/eldritch_cult/eldritch_magic.dm`
- `code/modules/antagonists/eldritch_cult/eldritch_monster_antag.dm`
- `code/modules/antagonists/eldritch_cult/knowledge/ash_lore.dm`
- `code/modules/antagonists/eldritch_cult/knowledge/flesh_lore.dm`
- `code/modules/antagonists/eldritch_cult/knowledge/rust_lore.dm`
- `code/modules/mob/living/simple_animal/eldritch_demons.dm`

</details>

<details><summary>Logic changes with AQ markers (182)</summary>

- `code/__DEFINES/DNA.dm`
- `code/__DEFINES/contracts.dm`
- `code/__DEFINES/dcs/signals/signals_global.dm`
- `code/__DEFINES/misc.dm`
- `code/__DEFINES/mobs.dm`
- `code/__DEFINES/nanites.dm`
- `code/__DEFINES/preferences.dm`
- `code/__DEFINES/role_preferences.dm`
- `code/__DEFINES/say.dm`
- `code/__DEFINES/sound.dm`
- `code/__DEFINES/traits.dm`
- `code/__HELPERS/global_lists.dm`
- `code/__HELPERS/names.dm`
- `code/__HELPERS/roundend.dm`
- `code/__HELPERS/text.dm`
- `code/_globalvars/lists/ambience.dm`
- `code/_globalvars/lists/flavor_misc.dm`
- `code/_globalvars/lists/names.dm`
- `code/_globalvars/lists/poll_ignore.dm`
- `code/_globalvars/traits.dm`
- `code/controllers/configuration/configuration.dm`
- `code/controllers/subsystem/fire_burning.dm`
- `code/controllers/subsystem/input.dm`
- `code/controllers/subsystem/job.dm`
- `code/controllers/subsystem/mapping.dm`
- `code/datums/brain_damage/severe.dm`
- `code/datums/brain_damage/split_personality.dm`
- `code/datums/components/nanites.dm`
- `code/datums/diseases/advance/advance.dm`
- `code/datums/diseases/advance/symptoms/heal.dm`
- `code/datums/diseases/advance/symptoms/macrophage.dm`
- `code/datums/hud.dm`
- `code/datums/keybinding/_defines.dm`
- `code/datums/map_config.dm`
- `code/datums/mutations/speech.dm`
- `code/game/atoms_movable.dm`
- `code/game/gamemodes/devil/objectives.dm`
- `code/game/machinery/computer/_computer.dm`
- `code/game/machinery/computer/communications.dm`
- `code/game/machinery/computer/prisoner/gulag_teleporter.dm`
- `code/game/machinery/fabricators/modular_fabricator.dm`
- `code/game/machinery/lightswitch.dm`
- `code/game/machinery/newscaster.dm`
- `code/game/machinery/stasis.dm`
- `code/game/machinery/suit_storage_unit.dm`
- `code/game/machinery/telecomms/broadcasting.dm`
- `code/game/mecha/mecha.dm`
- `code/game/objects/effects/contraband.dm`
- `code/game/objects/effects/decals/cleanable.dm`
- `code/game/objects/effects/decals/cleanable/humans.dm`
- `code/game/objects/effects/decals/misc.dm`
- `code/game/objects/effects/spawners/lootdrop.dm`
- `code/game/objects/effects/spawners/mailspawner.dm`
- `code/game/objects/effects/spawners/roomspawner.dm`
- `code/game/objects/items.dm`
- `code/game/objects/items/cards_ids.dm`
- `code/game/objects/items/crayons.dm`
- `code/game/objects/items/devices/megaphone.dm`
- `code/game/objects/items/devices/powersink.dm`
- `code/game/objects/items/dna_injector.dm`
- `code/game/objects/items/flamethrower.dm`
- `code/game/objects/items/holy_weapons.dm`
- `code/game/objects/items/implants/implant_storage.dm`
- `code/game/objects/items/stacks/medical.dm`
- `code/game/objects/items/storage/boxes.dm`
- `code/game/objects/items/storage/firstaid.dm`
- `code/game/objects/items/storage/storage.dm`
- `code/game/objects/items/storage/uplink_kits.dm`
- `code/game/objects/obj_defense.dm`
- `code/game/objects/structures/aliens.dm`
- `code/game/objects/structures/crates_lockers/closets/secure/security.dm`
- `code/game/objects/structures/watercloset.dm`
- `code/game/sound.dm`
- `code/game/turfs/closed/walls.dm`
- `code/modules/admin/admin.dm`
- `code/modules/admin/admin_verbs.dm`
- `code/modules/admin/topic.dm`
- `code/modules/admin/verbs/one_click_antag.dm`
- `code/modules/antagonists/cult/runes.dm`
- `code/modules/antagonists/devil/sintouched/sintouched.dm`
- `code/modules/antagonists/hivemind/hivemind.dm`
- `code/modules/antagonists/nukeop/equipment/nuclear_challenge.dm`
- `code/modules/assembly/mousetrap.dm`
- `code/modules/cargo/exports.dm`
- `code/modules/cargo/packs.dm`
- `code/modules/client/verbs/input_box.dm`
- `code/modules/clothing/head/_head.dm`
- `code/modules/clothing/masks/_masks.dm`
- `code/modules/clothing/shoes/_shoes.dm`
- `code/modules/clothing/spacesuits/hardsuit.dm`
- `code/modules/clothing/under/_under.dm`
- `code/modules/food_and_drinks/drinks/drinks.dm`
- `code/modules/food_and_drinks/food/snacks.dm`
- `code/modules/food_and_drinks/food/snacks_pastry.dm`
- `code/modules/food_and_drinks/kitchen_machinery/processor.dm`
- `code/modules/hydroponics/hydroponics.dm`
- `code/modules/hydroponics/plant_genes.dm`
- `code/modules/jobs/job_types/brig_physician.dm`
- `code/modules/jobs/job_types/captain.dm`
- `code/modules/jobs/job_types/head_of_security.dm`
- `code/modules/jobs/job_types/research_director.dm`
- `code/modules/jobs/job_types/scientist.dm`
- `code/modules/jobs/job_types/security_officer.dm`
- `code/modules/jobs/job_types/warden.dm`
- `code/modules/language/language_holder.dm`
- `code/modules/mapping/random_rooms.dm`
- `code/modules/mining/machine_redemption.dm`
- `code/modules/mob/camera/camera.dm`
- `code/modules/mob/dead/observer/observer.dm`
- `code/modules/mob/emote.dm`
- `code/modules/mob/living/blood.dm`
- `code/modules/mob/living/carbon/carbon.dm`
- `code/modules/mob/living/carbon/carbon_movement.dm`
- `code/modules/mob/living/carbon/human/emote.dm`
- `code/modules/mob/living/carbon/human/examine.dm`
- `code/modules/mob/living/carbon/human/human.dm`
- `code/modules/mob/living/carbon/human/human_defense.dm`
- `code/modules/mob/living/carbon/human/human_defines.dm`
- `code/modules/mob/living/carbon/human/human_helpers.dm`
- `code/modules/mob/living/carbon/human/physiology.dm`
- `code/modules/mob/living/carbon/human/species.dm`
- `code/modules/mob/living/carbon/human/species_types/IPC.dm`
- `code/modules/mob/living/carbon/human/species_types/abductors.dm`
- `code/modules/mob/living/carbon/human/species_types/android.dm`
- `code/modules/mob/living/carbon/human/species_types/dullahan.dm`
- `code/modules/mob/living/carbon/human/species_types/ethereal.dm`
- `code/modules/mob/living/carbon/human/species_types/plasmamen.dm`
- `code/modules/mob/living/carbon/human/species_types/skeletons.dm`
- `code/modules/mob/living/carbon/human/species_types/supersoldier.dm`
- `code/modules/mob/living/carbon/human/species_types/zombies.dm`
- `code/modules/mob/living/carbon/monkey/monkey.dm`
- `code/modules/mob/living/say.dm`
- `code/modules/mob/living/silicon/robot/robot.dm`
- `code/modules/mob/living/silicon/robot/robot_modules.dm`
- `code/modules/mob/living/silicon/silicon.dm`
- `code/modules/mob/living/simple_animal/bot/medbot.dm`
- `code/modules/mob/living/simple_animal/friendly/cat.dm`
- `code/modules/mob/living/simple_animal/friendly/dog.dm`
- `code/modules/mob/living/simple_animal/friendly/mouse.dm`
- `code/modules/mob/living/simple_animal/hostile/alien.dm`
- `code/modules/mob/living/simple_animal/hostile/megafauna/bubblegum.dm`
- `code/modules/mob/mob.dm`
- `code/modules/mob/mob_helpers.dm`
- `code/modules/power/generator.dm`
- `code/modules/power/rtg.dm`
- `code/modules/power/singularity/particle_accelerator/particle_control.dm`
- `code/modules/projectiles/projectile/bullets.dm`
- `code/modules/projectiles/projectile/energy/stun.dm`
- `code/modules/projectiles/projectile/special/hallucination.dm`
- `code/modules/reagents/chemistry/machinery/chem_dispenser.dm`
- `code/modules/reagents/chemistry/machinery/smoke_machine.dm`
- `code/modules/reagents/chemistry/reagents/alcohol_reagents.dm`
- `code/modules/reagents/chemistry/reagents/drink_reagents.dm`
- `code/modules/reagents/chemistry/reagents/food_reagents.dm`
- `code/modules/reagents/reagent_containers/glass.dm`
- `code/modules/reagents/reagent_containers/pill.dm`
- `code/modules/requests/request.dm`
- `code/modules/research/machinery/_production.dm`
- `code/modules/research/nanites/nanite_programs.dm`
- `code/modules/research/nanites/nanite_programs/utility.dm`
- `code/modules/research/techweb/all_nodes.dm`
- `code/modules/security_levels/security_levels.dm`
- `code/modules/shuttle/syndicate.dm`
- `code/modules/spells/spell_types/devil.dm`
- `code/modules/spells/spell_types/voice_of_god.dm`
- `code/modules/surgery/organs/tongue.dm`
- `code/modules/tgui/status_composers.dm`
- `code/modules/vending/autodrobe.dm`
- `code/modules/vending/clothesmate.dm`
- `code/modules/vending/plasmaresearch.dm`
- `code/modules/vending/wardrobes.dm`
- `nsv13/code/game/machinery/dance_machine.dm`
- `nsv13/code/game/machinery/lore_terminal.dm`
- `nsv13/code/game/machinery/munitions_machinery.dm`
- `nsv13/code/game/objects/items/bloody_eye.dm`
- `nsv13/code/modules/clothing/masks/_masks.dm`
- `nsv13/code/modules/jobs/job_types/marine/military_police.dm`
- `nsv13/code/modules/jobs/security/weapons.dm`
- `nsv13/code/modules/munitions/munitions_trolley.dm`
- `nsv13/code/modules/overmap/FTL/components/drive.dm`
- `nsv13/code/modules/power/stormdrive.dm`
- `nsv13/code/modules/research/astrometrics.dm`

</details>
