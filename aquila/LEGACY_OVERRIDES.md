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

The other ~60 same-type redefinitions in `aquila/` call `..()`, so they are already pre/post hooks.

## Core hooks added by the modularization pass

| Hook | Location | Feature |
|---|---|---|
| `on_drain(drained)` call | `code/game/objects/items/devices/powersink.dm`, `process()` | Aquila power sink APC draining and infiltrator objective |
| `dat += aquila_one_click_antag_links()` | `code/modules/admin/verbs/one_click_antag.dm` | Aquila "Create Antagonist" buttons |
| `ROLE_PARADOX_CLONE` + `antagonist_bannable_roles` entry | `code/__DEFINES/role_preferences.dm` | Paradox Clone (tgstation#71141 port); the define has to be in core because `aquila.dm` is included after the list |
| `ROLE_CHRONO_LEGIONNAIRE` + `antagonist_bannable_roles` entry | `code/__DEFINES/role_preferences.dm` | Chrono Legionnaire midround antagonist; same reason as `ROLE_PARADOX_CLONE` |
| `Destroy()` of `chrono_eraser`, chronosuit helmet and suit | `code/game/objects/items/chrono_eraser.dm`, `code/modules/clothing/spacesuits/chronosuit.dm` | Bugfix for the Chrono Legionnaire gear: they called `dropped()` without a user and runtimed on every delete |
| `ANTAG_HUD_PARADOX_CLONE` (33) + `GLOB.huds` entry | `code/__DEFINES/atom_hud.dm`, `code/datums/hud.dm` | Paradox Clone HUD; must stay the next index after `ANTAG_HUD_VAMPIRE` |
| `paradox_clone` icon state | `icons/mob/hud.dmi` | Paradox Clone HUD icon, copied from tgstation's `antag_hud.dmi` |

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
- **Job datums** (`jobs/job_types/*.dm`, `military_police.dm`, `subsystem/job.dm`). Outfits, implants, slots and exp requirements are mixed with hardened job-title and radio-channel constants. Left alone to avoid touching the job/config parsing hardening.

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
