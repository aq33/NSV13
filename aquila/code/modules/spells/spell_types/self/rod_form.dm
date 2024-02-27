/// The base distance a wizard rod will go without upgrades.
#define BASE_WIZ_ROD_RANGE 13
/datum/action/cooldown/spell/rod_form
	name = "Rod Form"
	desc = "Take on the form of an immovable rod, destroying all in your path. \
		Purchasing this spell multiple times will also increase the rod's damage and travel range."
	button_icon_state = "immrod"

	school = SCHOOL_TRANSMUTATION
	cooldown_time = 25 SECONDS
	cooldown_reduction_per_rank = 3.75 SECONDS

	invocation = "CLANG!"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = SPELL_REQUIRES_WIZARD_GARB|SPELL_REQUIRES_NO_ANTIMAGIC|SPELL_REQUIRES_OFF_CENTCOM

	/// The extra distance we travel per additional spell level.
	var/distance_per_spell_rank = 3
	/// The extra damage we deal per additional spell level.
	var/damage_per_spell_rank = 20
	/// The max distance the rod goes on cast
	var/rod_max_distance = BASE_WIZ_ROD_RANGE
	/// The damage bonus applied to the rod on cast
	var/rod_damage_bonus = 0
/datum/action/cooldown/spell/rod_form/cast(atom/cast_on)
	. = ..()
	// The destination turf of the rod - just a bit over the max range we calculated, for safety
	var/turf/distant_turf = get_ranged_target_turf(get_turf(cast_on), cast_on.dir, (rod_max_distance + 2))

	new /obj/effect/immovablerod/wizard(
		get_turf(cast_on),
		distant_turf,
		null,
		FALSE,
		cast_on,
		rod_max_distance,
		rod_damage_bonus,
	)

/datum/action/cooldown/spell/rod_form/level_spell(bypass_cap = FALSE)
	. = ..()
	if(!.)
		return FALSE
	rod_max_distance += distance_per_spell_rank
	rod_damage_bonus += damage_per_spell_rank
	return TRUE

/datum/action/cooldown/spell/rod_form/delevel_spell()
	. = ..()
	if(!.)
		return FALSE

	rod_max_distance -= distance_per_spell_rank
	rod_damage_bonus -= damage_per_spell_rank
	return TRUE


/obj/effect/immovablerod/wizard/proc/set_wizard(mob/living/wizard)
	ADD_TRAIT(wizard, TRAIT_MAGICALLY_PHASED, REF(src))
	.=..()

#undef BASE_WIZ_ROD_RANGE
