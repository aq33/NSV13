#include "aquila\code\__DEFINES\keybinding.dm"
#include "aquila\code\__DEFINES\melee.dm"
#include "aquila\code\__DEFINES\nanites.dm"
#include "aquila\code\__DEFINES\say.dm"
#include "aquila\code\__DEFINES\traits.dm"
#include "aquila\code\controllers\subsystem\vote.dm"
#include "aquila\code\datums\components\nanites.dm"
#include "aquila\code\datums\emotes.dm"
#include "aquila\code\datums\keybinding\emote.dm"
#include "aquila\code\datums\keybinding\keybindings.dm"
#include "aquila\code\datums\keybinding\mob.dm"
#include "aquila\code\datums\martial\nanojutsu.dm"
#include "aquila\code\datums\saymode.dm"
#include "aquila\code\game\effects\decals\turfdecal\markings.dm"
#include "aquila\code\game\machinery\newscaster.dm"
#include "aquila\code\game\machinery\status_display.dm"
#include "aquila\code\game\machinery\doors\airlock_types.dm"
#include "aquila\code\game\machinery\doors\firedoor.dm"
#include "aquila\code\game\objects\effects\contraband.dm"
#include "aquila\code\game\objects\items\implants\implant_security.dm"
#include "aquila\code\game\objects\structures\barsigns.dm"
#include "aquila\code\game\objects\items\clown_items.dm"
#include "aquila\code\game\objects\items\manuals.dm"
#include "aquila\code\game\objects\structures\door_assembly_types.dm"
#include "aquila\code\game\objects\structures\signs\signs_departments.dm"
#include "aquila\code\game\objects\structures\signs\signs_maps.dm"
#include "aquila\code\game\objects\structures\signs\signs_warning.dm"
#include "aquila\code\modules\cargo\packs.dm"
#include "aquila\code\modules\client\preferences.dm"
#include "aquila\code\modules\client\preferences_toggles.dm"
#include "aquila\code\modules\clothing\spacesuits\hardsuit.dm"
#include "aquila\code\modules\food_and_drinks\drinks\drinks.dm"
#include "aquila\code\modules\food_and_drinks\food\snacks_pie.dm"
#include "aquila\code\modules\food_and_drinks\recipes\drinks_recipes.dm"
#include "aquila\code\modules\mob\living\carbon\human\species_types\IPC.dm"
#include "aquila\code\modules\mob\living\emote.dm"
#include "aquila\code\modules\projectiles\guns\energy\energy.dm"
#include "aquila\code\modules\projectiles\guns\energy\laser.dm"
#include "aquila\code\modules\projectiles\guns\energy\pulse.dm"
#include "aquila\code\modules\reagents\chemistry\reagents\alcohol_reagents.dm"
#include "aquila\code\modules\research\designs\medical_designs.dm"
#include "aquila\code\modules\research\designs\nanite_designs.dm"
#include "aquila\code\modules\research\designs\weapon_designs.dm"
#include "aquila\code\modules\research\nanites\nanite_misc_items.dm"
#include "aquila\code\modules\research\nanites\nanite_misc_mobs.dm"
#include "aquila\code\modules\research\nanites\nanite_programs.dm"
#include "aquila\code\modules\research\nanites\nanite_programs\buffing.dm"
#include "aquila\code\modules\research\nanites\nanite_programs\protocols.dm"
#include "aquila\code\modules\research\nanites\nanite_programs\sensor.dm"
#include "aquila\code\modules\research\nanites\nanite_programs\suppression.dm"
#include "aquila\code\modules\research\nanites\nanite_programs\utility.dm"
#include "aquila\code\modules\research\nanites\nanite_programs\weapon.dm"
#include "aquila\code\modules\research\nanites\program_disks.dm"
#include "aquila\code\modules\research\techweb\all_nodes.dm"
#include "aquila\code\modules\uplink\uplink_items.dm"
#include "aquila\code\modules\vending\boozeomat.dm"
