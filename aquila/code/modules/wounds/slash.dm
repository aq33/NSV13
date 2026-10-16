// AQUILA - slash and pierce wounds on top of Bee bleeding: gauze only holds them for a while, sutures close them

/datum/wound/slash
	wound_type = WOUND_SLASH
	/// Bleeding added when the wound appears
	var/initial_bleed = BLEED_CUT
	/// The wound reopens this often while not sutured
	var/reopen_interval = 45 SECONDS
	/// Bleeding added each time it reopens
	var/reopen_bleed = BLEED_SURFACE
	var/reopen_progress = 0
	/// Wound left after one suture, null closes it
	var/sutured_into

/datum/wound/slash/on_apply()
	victim.add_bleeding(initial_bleed)

/datum/wound/slash/wound_effects(delta_time)
	reopen_progress += delta_time SECONDS
	if(reopen_progress < reopen_interval)
		return
	reopen_progress = 0
	if(HAS_TRAIT(victim, TRAIT_BLEED_HELD))
		return
	to_chat(victim, "<span class='danger'>Rana ([limb.name]) znów się otwiera!</span>")
	victim.add_bleeding(reopen_bleed)

/datum/wound/slash/can_treat_with(obj/item/item)
	return istype(item, /obj/item/stack/medical/suture)

/datum/wound/slash/treat(obj/item/stack/medical/suture/suture, mob/user)
	var/self = user == victim
	user.visible_message("<span class='notice'>[user] zaczyna zszywać ranę ([limb.name]) [victim].</span>", "<span class='notice'>Zaczynasz zszywać ranę ([limb.name])[self ? "" : " [victim]"].</span>")
	if(!do_mob(user, victim, self ? 5 SECONDS : 2 SECONDS))
		return FALSE
	if(QDELETED(src) || !suture.use(1))
		return FALSE
	playsound(victim, 'aquila/sound/effects/suture.ogg', 50, TRUE)
	victim.suppress_bloodloss(reopen_bleed)
	user.visible_message("<span class='green'>[user] zszywa ranę ([limb.name]) [victim].</span>", "<span class='green'>Zszywasz ranę ([limb.name]).</span>")
	replace_with(sutured_into)
	return TRUE

/datum/wound/slash/deep
	name = "Głębokie rozcięcie"
	desc = "Ostrze rozcina ci głęboko ciało"
	examine_desc = "głęboką, krwawiącą ranę"
	treat_text = "Zszyj nićmi albo przypal (operacja kauteryzacji). Gaza tylko na chwilę."
	severity = WOUND_SEVERITY_SEVERE
	threshold = 50

/datum/wound/slash/artery
	name = "Przerwana tętnica"
	desc = "Krew tryska z przeciętej tętnicy"
	examine_desc = "tryskającą krwią ranę"
	treat_text = "Zszyj nićmi dwa razy albo operacja kauteryzacji. Gaza tylko na chwilę."
	severity = WOUND_SEVERITY_CRITICAL
	threshold = 80
	initial_bleed = BLEED_CRITICAL
	reopen_interval = 20 SECONDS
	reopen_bleed = BLEED_CUT
	sutured_into = /datum/wound/slash/deep

/// The cauterization surgery closes every cut on the limb
/datum/surgery/cauterize/can_start(mob/user, mob/living/carbon/target, target_zone)
	. = ..()
	if(!.)
		var/obj/item/bodypart/limb = target.get_bodypart(check_zone(target_zone))
		return !!limb?.get_wound(WOUND_SLASH)

/datum/surgery_step/close/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	. = ..()
	if(!istype(surgery, /datum/surgery/cauterize))
		return
	var/obj/item/bodypart/limb = target.get_bodypart(check_zone(target_zone))
	for(var/datum/wound/slash/cut in limb?.wounds?.Copy())
		qdel(cut)
