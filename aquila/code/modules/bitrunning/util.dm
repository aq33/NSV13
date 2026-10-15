/// Creates a digital effect around the target
/atom/proc/create_digital_aura()
	var/list/overlays = get_digital_overlays()
	if(!length(overlays))
		return

	add_overlay(overlays)
	alpha = 210
	set_light(2, 1, LIGHT_COLOR_RED)

/// Removes the digital effect around the target
/atom/proc/remove_digital_aura()
	var/list/overlays = get_digital_overlays()
	if(!length(overlays))
		return

	cut_overlay(overlays)
	alpha = 255
	set_light(0)

/// Returns a list of overlays to be used for the digital effect
/atom/proc/get_digital_overlays()
	var/icon/our_icon = icon(icon, icon_state)
	var/width = our_icon.Width()
	var/base_icon
	switch(width)
		if(32)
			base_icon = 'aquila/icons/effects/bitrunning.dmi'
		if(48)
			base_icon = 'aquila/icons/effects/bitrunning_48.dmi'
		if(64)
			base_icon = 'aquila/icons/effects/bitrunning_64.dmi'
		else
			return

	var/mutable_appearance/redshift = mutable_appearance(base_icon, "redshift")
	redshift.blend_mode = BLEND_MULTIPLY

	var/mutable_appearance/glitch_effect = mutable_appearance(base_icon, "glitch", MUTATIONS_LAYER)
	glitch_effect.alpha = 150

	return list(glitch_effect, redshift)

/// Gives the appearance of being an agent
/mob/living/carbon/human/proc/set_service_style()
	var/static/list/approved_hair_colors = list(
		"4B3D28",
		"000000",
		"8D4A43",
		"D2B48C",
	)

	var/static/list/approved_hairstyles = list(
		"Business Hair",
		"Business Hair 2",
		"Business Hair 3",
		"Business Hair 4",
		"Mulder",
	)

	facial_hair_style = "Shaved"
	hair_color = pick(approved_hair_colors)
	hair_style = pick(approved_hairstyles)
	update_hair()

/// Removes all the loot and achievements from megafauna for bitrunning related
/mob/living/simple_animal/hostile/megafauna/proc/make_virtual_megafauna()
	var/new_max = clamp(maxHealth * 0.5, 600, 1300)
	maxHealth = new_max
	health = new_max

	true_spawn = FALSE
	var/datum/component/gps/gps = GetComponent(/datum/component/gps)
	if(gps)
		qdel(gps)

	crusher_loot = list()
	loot = list(/obj/structure/closet/crate/secure/bitrunning/encrypted)
	butcher_results = list()
	guaranteed_butcher_results = list()

/// Removes all the "organic" traits from a mob, used for virtual antagonists
/mob/living/carbon/proc/make_virtual_mob()
	ADD_TRAIT(src, TRAIT_NOBREATH, BITRUNNING_TRAIT)
	ADD_TRAIT(src, TRAIT_NOHUNGER, BITRUNNING_TRAIT)
	ADD_TRAIT(src, TRAIT_RESISTCOLD, BITRUNNING_TRAIT)
	ADD_TRAIT(src, TRAIT_RESISTHIGHPRESSURE, BITRUNNING_TRAIT)
	ADD_TRAIT(src, TRAIT_RESISTLOWPRESSURE, BITRUNNING_TRAIT)
