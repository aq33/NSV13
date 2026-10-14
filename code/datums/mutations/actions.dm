/datum/mutation/telepathy
	name = "Telepathy"
	desc = "A rare mutation that allows the user to telepathically communicate to others."
	quality = POSITIVE
	text_gain_indication = "<span class='notice'>Słyszysz w umyśle echo własnego głosu!</span>"
	text_lose_indication = "<span class='notice'>Nie słyszysz już echa swojego umysłu.</span>"
	difficulty = 12
	power = /obj/effect/proc_holder/spell/targeted/telepathy
	instability = 10
	energy_coeff = 1


/datum/mutation/olfaction
	name = "Transcendent Olfaction"
	desc = "Your sense of smell is comparable to that of a canine."
	quality = POSITIVE
	difficulty = 12
	text_gain_indication = "<span class='notice'>Zapachy zaczynają mieć więcej sensu...</span>"
	text_lose_indication = "<span class='notice'>Twój węch wraca do normy.</span>"
	power = /obj/effect/proc_holder/spell/targeted/olfaction
	instability = 30
	synchronizer_coeff = 1
	var/reek = 200

// NSV13 - kept hygiene
/datum/mutation/olfaction/on_life()
	var/hygiene_now = owner.hygiene

	if(hygiene_now < 100 && prob(3))
		owner.adjust_disgust(GET_MUTATION_SYNCHRONIZER(src) * (rand(3,5)))
	if(hygiene_now < HYGIENE_LEVEL_DIRTY && prob(15))
		to_chat(owner,"<span class='danger'>Czujesz swój własny smród i robi ci się niedobrze!</span>")
		owner.adjust_disgust(GET_MUTATION_SYNCHRONIZER(src) * rand(5,10))

	if(hygiene_now < HYGIENE_LEVEL_NORMAL && reek >= HYGIENE_LEVEL_NORMAL)
		to_chat(owner,"<span class='warning'>Twój nieludzko silny nos wyczuwa słaby zapach. Może niedługo powinieneś się umyć.</span>")
	if(hygiene_now < 150 && reek >= 150)
		to_chat(owner,"<span class='warning'>Twój zapach robi się nieprzyjemny, zwłaszcza że masz supernos.</span>")
	if(hygiene_now < 100 && reek >= 100)
		to_chat(owner,"<span class='danger'>Twój zapach zaczyna przyprawiać cię o odruch wymiotny. Po cichu przeklinasz swój boski nos. Naprawdę powinieneś się umyć!</span>")
	if(hygiene_now < HYGIENE_LEVEL_DIRTY && reek >= HYGIENE_LEVEL_DIRTY)
		to_chat(owner,"<span class='userdanger'>Twój supernos ma w 100% dość twojego smrodu. Koniecznie musisz się umyć.</span>")
	reek = hygiene_now

/obj/effect/proc_holder/spell/targeted/olfaction
	name = "Remember the Scent"
	desc = "Get a scent off of the item you're currently holding to track it. With an empty hand, you'll track the scent you've remembered."
	charge_max = 100
	clothes_req = FALSE
	range = -1
	include_user = TRUE
	action_icon_state = "nose"
	var/mob/living/carbon/tracking_target
	var/list/mob/living/carbon/possible = list()

/obj/effect/proc_holder/spell/targeted/olfaction/cast(list/targets, mob/living/user = usr)
	var/atom/sniffed = user.get_active_held_item()
	if(sniffed)
		var/old_target = tracking_target
		possible = list()
		var/list/prints = sniffed.return_fingerprints()
		for(var/mob/living/carbon/C in GLOB.carbon_list)
			if(prints[rustg_hash_string(RUSTG_HASH_MD5, C.dna.uni_identity)])
				possible |= C
		if(!length(possible))
			to_chat(user,"<span class='warning'>Mimo twoich starań na [sniffed] nie ma żadnych zapachów...</span>")
			return
		tracking_target = input(user, "Wybierz zapach do zapamiętania.", "Śledzenie zapachu") as null|anything in sortNames(possible)
		if(!tracking_target)
			if(!old_target)
				to_chat(user,"<span class='warning'>Postanawiasz nie zapamiętywać żadnych zapachów. Zamiast tego zauważasz kątem oka własny nos. Przypomina ci to, jak kiedyś zacząłeś oddychać ręcznie i nie mogłeś przestać. Co to był za okropny dzień.</span>")
				return
			tracking_target = old_target
			on_the_trail(user)
			return
		to_chat(user,"<span class='notice'>Wyczuwasz zapach [tracking_target]. Polowanie się zaczyna.</span>")
		on_the_trail(user)
		return

	if(!tracking_target)
		to_chat(user,"<span class='warning'>Nie trzymasz niczego do powąchania i nie wyczułeś niczego, co dałoby się wyśledzić. Zamiast tego wąchasz swoją dłoń; jest trochę słona.</span>")
		return

	on_the_trail(user)

/obj/effect/proc_holder/spell/targeted/olfaction/proc/on_the_trail(mob/living/user)
	if(!tracking_target)
		to_chat(user,"<span class='warning'>Nie śledzisz zapachu, ale gra myślała, że tak. Coś poszło nie tak! Zgłoś to jako błąd.</span>")
		return
	if(tracking_target == user)
		to_chat(user,"<span class='warning'>Wyczuwasz trop prowadzący do ciebie samego. Tak, to ty.</span>")
		return
	if(usr.get_virtual_z_level() < tracking_target.get_virtual_z_level())
		to_chat(user,"<span class='warning'>Trop prowadzi... daleko w górę? Hm. Ta osoba musi być naprawdę bardzo daleko.</span>")
		return
	else if(usr.get_virtual_z_level() > tracking_target.get_virtual_z_level())
		to_chat(user,"<span class='warning'>Trop prowadzi... daleko w dół? Hm. Ta osoba musi być naprawdę bardzo daleko.</span>")
		return
	var/direction_text = "[dir2text(get_dir(usr, tracking_target))]"
	if(direction_text)
		to_chat(user,"<span class='notice'>Analizujesz zapach [tracking_target]. Trop prowadzi <b>[direction_text].</b></span>")

/datum/mutation/firebreath
	name = "Fire Breath"
	desc = "An ancient mutation that gives lizards breath of fire."
	quality = POSITIVE
	difficulty = 12
	locked = TRUE
	text_gain_indication = "<span class='notice'>Pali cię w gardle!</span>"
	text_lose_indication = "<span class='notice'>Twoje gardło się schładza.</span>"
	power = /obj/effect/proc_holder/spell/aimed/firebreath
	instability = 30
	energy_coeff = 1
	power_coeff = 1
	species_allowed = list(SPECIES_LIZARD)

/datum/mutation/firebreath/modify()
	..()
	if(power)
		var/obj/effect/proc_holder/spell/aimed/firebreath/S = power
		S.strength = GET_MUTATION_POWER(src)

/obj/effect/proc_holder/spell/aimed/firebreath
	name = "Fire Breath"
	desc = "You can breathe fire at a target."
	school = "evocation"
	charge_max = 600
	clothes_req = FALSE
	range = 20
	projectile_type = /obj/item/projectile/magic/fireball/firebreath
	base_icon_state = "fireball"
	action_icon_state = "fireball0"
	sound = 'sound/magic/demon_dies.ogg' //horrifying lizard noises
	active_msg = "Zbierasz w ustach żar."
	deactive_msg = "Połykasz płomień."
	var/strength = 1

/obj/effect/proc_holder/spell/aimed/firebreath/before_cast(list/targets)
	. = ..()
	if(iscarbon(usr))
		var/mob/living/carbon/C = usr
		if(C.is_mouth_covered())
			C.adjust_fire_stacks(2)
			C.IgniteMob()
			to_chat(C,"<span class='warning'>Coś przed twoimi ustami zajmuje się ogniem!</span>")
			return FALSE

/obj/effect/proc_holder/spell/aimed/firebreath/ready_projectile(obj/item/projectile/P, atom/target, mob/user, iteration)
	if(!istype(P, /obj/item/projectile/magic/fireball))
		return
	var/obj/item/projectile/magic/fireball/F = P
	F.exp_light = strength-1
	F.exp_fire += strength

/obj/item/projectile/magic/fireball/firebreath
	name = "fire breath"
	exp_heavy = 0
	exp_light = 0
	exp_flash = 0
	exp_fire= 4
	magic = FALSE

/datum/mutation/void
	name = "Void Magnet"
	desc = "A rare genome that attracts odd forces not usually observed."
	quality = MINOR_NEGATIVE //upsides and downsides
	text_gain_indication = "<span class='notice'>Czujesz ciężką, tępą siłę tuż za ścianami, która cię obserwuje.</span>"
	instability = 30
	power = /obj/effect/proc_holder/spell/self/void
	energy_coeff = 1
	synchronizer_coeff = 1

/datum/mutation/void/on_life()
	if(!isturf(owner.loc))
		return
	if(prob((0.5+((100-dna.stability)/20))) * GET_MUTATION_SYNCHRONIZER(src)) //very rare, but enough to annoy you hopefully. +0.5 probability for every 10 points lost in stability
		new /obj/effect/immortality_talisman/void(get_turf(owner), owner)

/obj/effect/proc_holder/spell/self/void
	name = "Convoke Void" //magic the gathering joke here
	desc = "A rare genome that attracts odd forces not usually observed. May sometimes pull you in randomly."
	school = "evocation"
	clothes_req = FALSE
	charge_max = 600
	invocation = "DOOOOOOOOOOOOOOOOOOOOM!!!"
	invocation_type = "shout"
	action_icon_state = "void_magnet"

/obj/effect/proc_holder/spell/self/void/can_cast(mob/user = usr)
	. = ..()
	if(!isturf(user.loc))
		return FALSE

/obj/effect/proc_holder/spell/self/void/cast(mob/user = usr)
	. = ..()
	new /obj/effect/immortality_talisman/void(get_turf(user), user)

/datum/mutation/self_amputation
	name = "Autotomy"
	desc = "Allows a creature to voluntary discard a random appendage."
	quality = POSITIVE
	text_gain_indication = "<span class='notice'>Twoje stawy wydają się luźne.</span>"
	instability = 30
	power = /obj/effect/proc_holder/spell/self/self_amputation

	energy_coeff = 1
	synchronizer_coeff = 1

/obj/effect/proc_holder/spell/self/self_amputation
	name = "Drop a limb"
	desc = "Concentrate to make a random limb pop right off your body."
	clothes_req = FALSE
	human_req = FALSE
	charge_max = 100
	action_icon_state = "autotomy"

/obj/effect/proc_holder/spell/self/self_amputation/cast(mob/user = usr)
	if(!iscarbon(user))
		return

	var/mob/living/carbon/C = user
	if(HAS_TRAIT(C, TRAIT_NODISMEMBER))
		return

	var/list/parts = list()
	for(var/obj/item/bodypart/BP as() in C.bodyparts)
		if(BP.body_part != HEAD && BP.body_part != CHEST)
			if(BP.dismemberable)
				parts += BP
	if(!parts.len)
		to_chat(usr, "<span class='notice'>Nie możesz zrzucić więcej kończyn!</span>")
		return

	var/obj/item/bodypart/BP = pick(parts)
	BP.dismember()

/datum/mutation/overload
	name = "Overload"
	desc = "Allows an Ethereal to overload their skin to cause a bright flash."
	quality = POSITIVE
	locked = TRUE
	text_gain_indication = "<span class='notice'>Twoja skóra wydaje się bardziej trzeszcząca.</span>"
	instability = 30
	power = /obj/effect/proc_holder/spell/self/overload
	species_allowed = list(SPECIES_ETHEREAL)

/obj/effect/proc_holder/spell/self/overload
	name = "Overload"
	desc = "Concentrate to make your skin energize."
	clothes_req = FALSE
	human_req = FALSE
	charge_max = 400
	action_icon_state = "blind"
	var/max_distance = 4

/obj/effect/proc_holder/spell/self/overload/cast(mob/user = usr)
	if(!isethereal(user))
		return

	var/list/mob/targets = oviewers(max_distance, get_turf(user))
	visible_message("<span class='disarm'>[user] wydziela oślepiające światło!</span>")
	for(var/mob/living/carbon/C in targets)
		if(C.flash_act(1))
			C.Paralyze(10 + (5*max_distance))

/datum/mutation/overload/modify()
	if(power)
		var/obj/effect/proc_holder/spell/self/overload/S = power
		S.max_distance = 4 * GET_MUTATION_POWER(src)

/datum/mutation/acidooze
	name = "Acidic Hands"
	desc = "Allows an Oozeling to metabolize some of their blood into acid, concentrated on their hands."
	quality = POSITIVE
	locked = TRUE
	text_gain_indication = "<span class='notice'>Bolą cię dłonie.</span>"
	instability = 30
	power = /obj/effect/proc_holder/spell/targeted/touch/acidooze
	species_allowed = list(SPECIES_OOZELING)

/obj/effect/proc_holder/spell/targeted/touch/acidooze
	name = "Acidic Hands"
	desc = "Concentrate to make some of your blood become acidic."
	clothes_req = FALSE
	human_req = FALSE
	charge_max = 100
	action_icon_state = "summons"
	var/volume = 10
	hand_path = /obj/item/melee/touch_attack/acidooze
	drawmessage = "Wydzielasz kwas do dłoni."
	dropmessage = "Pozwalasz, by kwas w twojej dłoni się rozwiał."

/obj/item/melee/touch_attack/acidooze
	name = "\improper acidic hand"
	desc = "Keep away from children, paperwork, and children doing paperwork."
	catchphrase = null
	icon = 'icons/effects/blood.dmi'
	color = COLOR_BLOOD
	var/icon_left = "bloodhand_left"
	var/icon_right = "bloodhand_right"
	icon_state = "bloodhand_left"
	item_state = "fleshtostone"

/obj/item/melee/touch_attack/acidooze/equipped(mob/user, slot)
	. = ..()
	//these are intentionally inverted
	var/i = user.get_held_index_of_item(src)
	if(!(i % 2))
		icon_state = icon_left
	else
		icon_state = icon_right

/obj/item/melee/touch_attack/acidooze/afterattack(atom/target, mob/living/carbon/user, proximity)
	if(!proximity || !isoozeling(user))
		return
	var/mob/living/carbon/C = user
	if(!target || user.incapacitated())
		return FALSE
	if(C.blood_volume < 40)
		to_chat(user, "<span class='warning'>Masz za mało krwi, by to zrobić!</span>")
		return FALSE
	if(target.acid_act(50, 15))
		user.visible_message("<span class='warning'>[user] rozsmarowuje grudy obrzydliwej mazi po [target].</span>")
		C.blood_volume = max(C.blood_volume - 20, 0)
		return ..()
	else
		to_chat(user, "<span class='notice'>Nie możesz rozpuścić tego przedmiotu.</span>")
		return FALSE
