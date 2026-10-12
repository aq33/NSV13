/obj/effect/proc_holder/spell/targeted/blind
	name = "Blind"
	desc = "This spell temporarily blinds a single target."
	school = "transmutation"
	charge_max = 300
	clothes_req = FALSE
	invocation = "STI KALY"
	invocation_type = "whisper"
	cooldown_min = 50 //12 deciseconds reduction per rank
	ranged_mousepointer = 'icons/effects/blind_target.dmi'
	action_icon_state = "blind"
	range = 7
	selection_type = "range"
	var/duration = 300 //30 seconds
	var/static/list/compatible_mobs_typecache = typecacheof(list(/mob/living/carbon/human))


/obj/effect/proc_holder/spell/targeted/blind/cast(list/targets, mob/user = usr)
	if(!length(targets))
		to_chat(user, "<span class='notice'>W zasięgu nie znaleziono celu.</span>")
		revert_cast()
		return
	
	var/mob/living/carbon/target = targets[1]

	if(!compatible_mobs_typecache[target.type])
		to_chat(user, "<span class='notice'>Nie możesz przekląć [target] ślepotą!</span>")
		revert_cast()
		return
	
	if(!(target in oview(range)))
		to_chat(user, "<span class='notice'>Cel jest za daleko!</span>")
		revert_cast()
		return
	
	if(target.anti_magic_check() || HAS_TRAIT(target, TRAIT_WARDED))
		to_chat(user, "<span class='warning'>Zaklęcie nie zadziałało!</span>")
		target.visible_message("<span class='danger'>Oczy [target] ciemnieją, ale natychmiast wracają do zwykłego koloru, nie robiąc [target] krzywdy!</span>", \
						   "<span class='danger'>Oczy na chwilę cię bolą, ale ślepotę odpiera twoja ochrona antymagiczna!</span>")
		return
	
	target.visible_message("<span class='danger'>Oczy [target] ciemnieją, a zaczyna się z nich wydobywać czarny dym!</span>", \
						   "<span class='danger'>Oczy bolą cię, gdy zaczynają dymić, a ty wpadasz w panikę, uświadamiając sobie, że jesteś ślepy!</span>")
	target.emote("scream")
	target.become_blind(MAGIC_BLIND)
	addtimer(CALLBACK(src, PROC_REF(cure_blindness), target), duration)

/obj/effect/proc_holder/spell/targeted/blind/proc/cure_blindness(mob/living/L)
	L.cure_blind(MAGIC_BLIND)
