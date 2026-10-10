/datum/religion_rites
	/// name of the religious rite
	var/name = "religious rite"
	/// Description of the religious rite
	var/desc = "immm gonna rooon"
	/// length it takes to complete the ritual
	var/ritual_length = (10 SECONDS) //total length it'll take
	/// list of invocations said (strings) throughout the rite
	var/list/ritual_invocations //strings that are by default said evenly throughout the rite
	/// message when you invoke
	var/invoke_msg
	var/favor_cost = 0
	/// does the altar auto-delete the rite
	var/auto_delete = TRUE

/datum/religion_rites/New()
	. = ..()
	if(!GLOB?.religious_sect)
		return
	LAZYADD(GLOB.religious_sect.active_rites, src)

/datum/religion_rites/Destroy()
	if(!GLOB?.religious_sect)
		return
	LAZYREMOVE(GLOB.religious_sect.active_rites, src)
	return ..()

/datum/religion_rites/proc/can_afford(mob/living/user)
	if(GLOB.religious_sect?.favor < favor_cost)
		to_chat(user, "<span class='warning'>Ten obrzęd wymaga więcej łaski!</span>")
		return FALSE
	return TRUE

///Called to perform the invocation of the rite, with args being the performer and the altar where it's being performed. Maybe you want it to check for something else?
/datum/religion_rites/proc/perform_rite(mob/living/user, atom/religious_tool)
	if(!can_afford(user))
		return FALSE
	to_chat(user, "<span class='notice'>Zaczynasz odprawiać obrzęd: [name]...</span>")
	if(!ritual_invocations)
		if(do_after(user, target = user, delay = ritual_length))
			return TRUE
		return FALSE
	var/first_invoke = TRUE
	for(var/i in ritual_invocations)
		if(first_invoke) //instant invoke
			user.say(i)
			first_invoke = FALSE
			continue
		if(!length(ritual_invocations)) //we divide so we gotta protect
			return FALSE
		if(!do_after(user, target = user, delay = ritual_length/length(ritual_invocations)))
			return FALSE
		user.say(i)
	if(!do_after(user, target = user, delay = ritual_length/length(ritual_invocations))) //because we start at 0 and not the first fraction in invocations, we still have another fraction of ritual_length to complete
		return FALSE
	if(invoke_msg)
		user.say(invoke_msg)
	return TRUE


///Does the thing if the rite was successfully performed. return value denotes that the effect successfully (IE a harm rite does harm)
/datum/religion_rites/proc/invoke_effect(mob/living/user, atom/religious_tool)
	SHOULD_CALL_PARENT(TRUE)
	GLOB.religious_sect.on_riteuse(user,religious_tool)
	return TRUE


/**** Technophile Sect ****/

/datum/religion_rites/synthconversion
	name = "Synthetic Conversion"
	desc = "Convert a human-esque individual into a (superior) Android. Buckle a human to convert them, otherwise it will convert you."
	ritual_length = 30 SECONDS
	ritual_invocations = list("Na wewnętrzne mechanizmy naszego boga...",
						"...wzywamy cię w obliczu przeciwności...",
						"...dopełnij nas, usuwając to, co niepożądane...")
	invoke_msg = "...Powstań, nasz czempionie! Stań się tym, czego pragnie twoja dusza, żyj w świecie w swej prawdziwej postaci!!"
	favor_cost = 1800

/datum/religion_rites/synthconversion/perform_rite(mob/living/user, atom/religious_tool)
	if(!ismovable(religious_tool))
		to_chat(user,"<span class='warning'>Ten obrzęd wymaga przedmiotu religijnego, do którego można przypiąć osobę.</span>")
		return FALSE
	var/atom/movable/movable_reltool = religious_tool
	if(!movable_reltool)
		return FALSE
	if(LAZYLEN(movable_reltool.buckled_mobs))
		to_chat(user,"<span class='warning'>Nawrócisz osobę przypiętą do [movable_reltool].</span>")
	else
		if(!movable_reltool.can_buckle) //yes, if you have somehow managed to have someone buckled to something that now cannot buckle, we will still let you perform the rite!
			to_chat(user,"<span class='warning'>Ten obrzęd wymaga przedmiotu religijnego, do którego można przypiąć osobę.</span>")
			return FALSE
		if(isandroid(user))
			to_chat(user,"<span class='warning'>Już nawróciłeś siebie. Aby nawracać innych, muszą być przypięci do [movable_reltool].</span>")
			return FALSE
		to_chat(user,"<span class='warning'>Tym rytuałem nawrócisz siebie.</span>")
	return ..()

/datum/religion_rites/synthconversion/invoke_effect(mob/living/user, atom/religious_tool)
	..()
	if(!ismovable(religious_tool))
		CRASH("[name]'s perform_rite had a movable atom that has somehow turned into a non-movable!")
	var/atom/movable/movable_reltool = religious_tool
	var/mob/living/carbon/human/rite_target
	if(!movable_reltool?.buckled_mobs?.len)
		rite_target = user
	else
		for(var/buckled in movable_reltool.buckled_mobs)
			if(ishuman(buckled))
				rite_target = buckled
				break
	if(!rite_target)
		return FALSE
	rite_target.set_species(/datum/species/android)
	rite_target.visible_message("<span class='notice'>[rite_target] zostaje nawrócony obrzędem: [name]!</span>")
	return TRUE


/datum/religion_rites/machine_blessing
	name = "Receive Blessing"
	desc = "Receive a random blessing from the machine god to further your ascension."
	ritual_length = 5 SECONDS
	ritual_invocations =list( "Niech twoja wola zasila nasze kuźnie.",
							"...Pomóż nam w naszym wielkim podboju!")
	invoke_msg = "Koniec ciała jest bliski!"
	favor_cost = 800

/datum/religion_rites/machine_blessing/invoke_effect(mob/living/user, atom/movable/religious_tool)
	..()
	var/altar_turf = get_turf(religious_tool)
	var/blessing = pick(
					/obj/item/organ/cyberimp/arm/surgery,
					/obj/item/organ/cyberimp/eyes/hud/diagnostic,
					/obj/item/organ/cyberimp/eyes/hud/medical,
					/obj/item/organ/cyberimp/mouth/breathing_tube,
					/obj/item/organ/cyberimp/chest/thrusters,
					/obj/item/organ/cyberimp/chest/nutriment,
					/obj/item/organ/cyberimp/arm/toolset,
					/obj/item/organ/wings/cybernetic,
					/obj/item/organ/eyes/robotic/glow)
	new blessing(altar_turf)
	return TRUE


/datum/religion_rites/machine_implantation
	name = "Machine Implantation"
	desc = "Apply a provided upgrade to your body. Place a cybernetic item on the altar, then buckle someone to implant them, otherwise it will implant you."
	ritual_length = 30 SECONDS
	ritual_invocations = list("Użycz nam swej mocy...",
						"...wzywamy cię, daj nam to ulepszenie...",
						"...Dopełnij nas, łącząc człowieka i maszynę...")
	invoke_msg = "...Niech części mechaniczne się Połączą!!"
	favor_cost = 1000
	var/obj/item/organ/chosen_implant

/datum/religion_rites/machine_implantation/perform_rite(mob/living/user, atom/religious_tool)
	chosen_implant = locate() in get_turf(religious_tool)
	if(!chosen_implant)
		to_chat(user, "<span class='warning'>Ten obrzęd wymaga cybernetyki do wszczepienia.</span>")
		return FALSE
	if(!ismovable(religious_tool))
		to_chat(user,"<span class='warning'>Ten obrzęd wymaga przedmiotu religijnego, do którego można przypiąć osobę.</span>")
		return FALSE
	var/atom/movable/movable_reltool = religious_tool
	if(length(movable_reltool.buckled_mobs))
		to_chat(user,"<span class='warning'>Połączysz implant z osobą przypiętą do [movable_reltool].</span>")
	else if(!movable_reltool.can_buckle) //yes, if you have somehow managed to have someone buckled to something that now cannot buckle, we will still let you perform the rite!
		to_chat(user,"<span class='warning'>Ten obrzęd wymaga przedmiotu religijnego, do którego można przypiąć osobę.</span>")
		return FALSE
	to_chat(user,"<span class='warning'>Tym rytuałem połączysz implant ze sobą.</span>")
	return ..()

/datum/religion_rites/machine_implantation/invoke_effect(mob/living/user, atom/religious_tool)
	..()
	if(!ismovable(religious_tool))
		CRASH("[name]'s perform_rite had a movable atom that has somehow turned into a non-movable!")
	var/atom/movable/movable_reltool = religious_tool
	var/mob/living/carbon/human/rite_target
	if(!length(movable_reltool.buckled_mobs))
		rite_target = user
	else
		for(var/buckled in movable_reltool.buckled_mobs)
			if(ishuman(buckled))
				rite_target = buckled
				break
	if(!rite_target)
		chosen_implant = null
		return FALSE
	chosen_implant.Insert(rite_target)
	rite_target.visible_message("<span class='notice'>Obrzęd [name] łączy [chosen_implant] z [rite_target]!</span>")
	chosen_implant = null
	return TRUE


/**** Ever-Burning Candle sect ****/

///apply a bunch of fire immunity effect to clothing
/datum/religion_rites/fireproof/proc/apply_fireproof(obj/item/clothing/fireproofed)
	fireproofed.name = "unmelting [fireproofed.name]"
	fireproofed.max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	fireproofed.heat_protection = chosen_clothing.body_parts_covered
	fireproofed.resistance_flags |= FIRE_PROOF

/datum/religion_rites/fireproof
	name = "Unmelting Protection"
	desc = "Grants fire immunity to any piece of clothing."
	ritual_length = 15 SECONDS
	ritual_invocations = list("I tak, by wspierać dzierżącego Wiecznie Płonącą świecę...",
	"...pozwól tej niegodnej szacie ci służyć...",
	"...uczyń ją dość silną, by płonęła tysiąc razy i więcej...")
	invoke_msg = "...Wyjdź w swojej nowej postaci i dołącz do nietopniejącego wosku jedynego prawdziwego płomienia!"
	favor_cost = 1000
///the piece of clothing that will be fireproofed, only one per rite
	var/obj/item/clothing/chosen_clothing

/datum/religion_rites/fireproof/perform_rite(mob/living/user, atom/religious_tool)
	for(var/obj/item/clothing/apparel in get_turf(religious_tool))
		if(apparel.max_heat_protection_temperature >= FIRE_IMMUNITY_MAX_TEMP_PROTECT)
			continue //we ignore anything that is already fireproof
		chosen_clothing = apparel //the apparel has been chosen by our lord and savior
		return ..()
	return FALSE

/datum/religion_rites/fireproof/invoke_effect(mob/living/user, atom/religious_tool)
	..()
	if(!QDELETED(chosen_clothing) && get_turf(religious_tool) == chosen_clothing.loc) //check if the same clothing is still there
		if(istype(chosen_clothing,/obj/item/clothing/suit/hooded))
			for(var/obj/item/clothing/head/integrated_helmet in chosen_clothing.contents) //check if the clothing has a hood/helmet integrated and fireproof it if there is one.
				apply_fireproof(integrated_helmet)
		apply_fireproof(chosen_clothing)
		playsound(get_turf(religious_tool), 'sound/magic/fireball.ogg', 50, TRUE)
		chosen_clothing = null //our lord and savior no longer cares about this apparel
		return TRUE
	chosen_clothing = null
	to_chat(user,"<span class='warning'>Ubranie wybrane do obrzędu nie leży już na ołtarzu!</span>")
	return FALSE

/datum/religion_rites/burning_sacrifice
	name = "Burning Offering"
	desc = "Sacrifice a buckled burning corpse for favor, the more burn damage the corpse has the more favor you will receive."
	ritual_length = 20 SECONDS
	ritual_invocations = list("Płonące ciało...",
	"...oczyszczone przez płomień...",
	"...wszyscy zostaliśmy stworzeni z ognia...",
	"...i do niego...")
	invoke_msg = "...POWRACAMY! "
///the burning corpse chosen for the sacrifice of the rite
	var/mob/living/carbon/chosen_sacrifice

/datum/religion_rites/burning_sacrifice/perform_rite(mob/living/user, atom/religious_tool)
	if(!ismovable(religious_tool))
		to_chat(user,"<span class='warning'>Ten obrzęd wymaga przedmiotu religijnego, do którego można przypiąć osobę.</span>")
		return FALSE
	var/atom/movable/movable_reltool = religious_tool
	if(!movable_reltool)
		return FALSE
	if(!LAZYLEN(movable_reltool.buckled_mobs))
		to_chat(user,"<span class='warning'>Nic nie jest przypięte do ołtarza!</span>")
		return FALSE
	for(var/corpse in movable_reltool.buckled_mobs)
		if(!iscarbon(corpse))// only works with carbon corpse since most normal mobs can't be set on fire.
			to_chat(user,"<span class='warning'>Tylko węglowe formy życia mogą zostać właściwie spalone w ofierze!</span>")
			return FALSE
		chosen_sacrifice = corpse
		if(chosen_sacrifice.stat != DEAD)
			to_chat(user,"<span class='warning'>Możesz ofiarowywać tylko martwe ciała, to wciąż żyje!</span>")
			return FALSE
		if(!chosen_sacrifice.on_fire)
			to_chat(user,"<span class='warning'>Te zwłoki muszą płonąć, by mogły zostać złożone w ofierze!</span>")
			return FALSE
		return ..()

/datum/religion_rites/burning_sacrifice/invoke_effect(mob/living/user, atom/movable/religious_tool)
	..()
	if(!(chosen_sacrifice in religious_tool.buckled_mobs)) //checks one last time if the right corpse is still buckled
		to_chat(user,"<span class='warning'>Właściwej ofiary nie ma już na ołtarzu!</span>")
		chosen_sacrifice = null
		return FALSE
	if(!chosen_sacrifice.on_fire)
		to_chat(user,"<span class='warning'>Ofiara już nie płonie, musi płonąć do końca obrzędu!</span>")
		chosen_sacrifice = null
		return FALSE
	if(chosen_sacrifice.stat != DEAD)
		to_chat(user,"<span class='warning'>Ofiara musi pozostać martwa, by obrzęd zadziałał!</span>")
		chosen_sacrifice = null
		return FALSE
	var/favor_gained = 100 + round(chosen_sacrifice.getFireLoss())
	GLOB.religious_sect.adjust_favor(favor_gained, user)
	to_chat(user, "<span class='notice'>[GLOB.deity] pochłania płonące zwłoki i wraz z nimi wszelki ślad ognia. [GLOB.deity] nagradza cię łaską: [favor_gained] pkt.")
	chosen_sacrifice.dust(force = TRUE)
	playsound(get_turf(religious_tool), 'sound/effects/supermatter.ogg', 50, TRUE)
	chosen_sacrifice = null
	return TRUE

/datum/religion_rites/infinite_candle
	name = "Immortal Candles"
	desc = "Creates 5 candles that never run out of wax."
	ritual_length = 10 SECONDS
	invoke_msg = "Płońcie jasno, małe świece, bo zgaśniecie dopiero razem ze wszechświatem."
	favor_cost = 200

/datum/religion_rites/infinite_candle/invoke_effect(mob/living/user, atom/movable/religious_tool)
	..()
	var/altar_turf = get_turf(religious_tool)
	for(var/i in 1 to 5)
		new /obj/item/candle/infinite(altar_turf)
	playsound(altar_turf, 'sound/magic/fireball.ogg', 50, TRUE)
	return TRUE

/// Necro Rites

/datum/religion_rites/create_lesser_lich
	name = "Create Lesser Lich"
	desc = "Gives the bound creature a spell granting them the ability to create a lesser phylactery, causing them to become a skeleton and revive on death twice if the phylactery still exists on-station. Be warned, becoming a lesser lich will prevent revivial by any other means."
	ritual_length = 70 SECONDS
	ritual_invocations = list("Z głębin sadzawki dusz...",
	"...wstąp w tę istotę...",
	"...daj temu słudze moc...",
	"...daj mu tymczasową nieśmiertelność...")
	invoke_msg = "...Daj mu moc zjednoczenia się z nekromancją!!"
	favor_cost = 2250
/// the creature chosen for the rite
	var/mob/living/lich_to_be
/// the the typepath of the spell to gran
	var/lichspell = /obj/effect/proc_holder/spell/targeted/lesserlichdom

/datum/religion_rites/create_lesser_lich/perform_rite(mob/living/user, atom/religious_tool)
	if(!ismovable(religious_tool))
		to_chat(user,"<span class='warning'>Ten obrzęd wymaga przedmiotu religijnego, do którego można przypiąć osobę.</span>")
		return FALSE
	var/atom/movable/movable_reltool = religious_tool
	if(length(movable_reltool.buckled_mobs))
		for(var/creature in movable_reltool.buckled_mobs)
			lich_to_be = creature
		if(!lich_to_be.mind.hasSoul)
			to_chat(user,"<span class='warning'>[lich_to_be] nie ma duszy, więc ten obrzęd mu nie pomoże. Aby wzmocnić kogoś innego, musi być przypięty do [movable_reltool].</span>")
			lich_to_be = null
			return FALSE
		for(var/obj/effect/proc_holder/spell/knownspell in lich_to_be.mob_spell_list)
			if(knownspell.type == lichspell)
				to_chat(user,"<span class='warning'>Już wzmocniłeś [lich_to_be], niech użyje otrzymanego zaklęcia! Aby wzmocnić kogoś innego, musi być przypięty do [movable_reltool].</span>")
				lich_to_be = null
				return FALSE
		to_chat(user,"<span class='warning'>Wzmocnisz [lich_to_be], przypiętego do [movable_reltool].</span>")
		return ..()
	else
		if(!movable_reltool.can_buckle) //yes, if you have somehow managed to have someone buckled to something that now cannot buckle, we will still let you perform the rite!
			to_chat(user,"<span class='warning'>Ten obrzęd wymaga przedmiotu religijnego, do którego można przypiąć osobę.</span>")
			return FALSE
		lich_to_be = user
		if(!lich_to_be.mind.hasSoul)
			to_chat(user,"<span class='warning'>Nie masz duszy, więc ten obrzęd ci nie pomoże. Aby wzmocnić kogoś innego, musi być przypięty do [movable_reltool].</span>")
			lich_to_be = null
			return FALSE
		for(var/obj/effect/proc_holder/spell/knownspell in lich_to_be.mob_spell_list)
			if(knownspell.type == lichspell)
				to_chat(user,"<span class='warning'>Już wzmocniłeś siebie, użyj otrzymanego zaklęcia! Aby wzmocnić kogoś innego, musi być przypięty do [movable_reltool].</span>")
				lich_to_be = null
				return FALSE
		to_chat(user,"<span class='warning'>Wzmacniasz siebie!</span>")
		return ..()


/datum/religion_rites/create_lesser_lich/invoke_effect(mob/living/user, atom/movable/religious_tool)
	..()
	if(!ismovable(religious_tool))
		CRASH("[name]'s perform_rite had a movable atom that has somehow turned into a non-movable!")
	var/atom/movable/movable_reltool = religious_tool
	if(!length(movable_reltool.buckled_mobs))
		lich_to_be = user
	else
		for(var/mob/living/carbon/human/buckled in movable_reltool.buckled_mobs)
			lich_to_be = buckled
			break
	if(!lich_to_be)
		return FALSE
	lich_to_be.AddSpell(new lichspell(null))
	lich_to_be.visible_message("<span class='notice'>Sadzawka dusz wzmacnia [lich_to_be]!</span>")
	lich_to_be = null
	return ..()

/datum/religion_rites/raise_undead
	name = "Raise Undead"
	desc = "Creates an undead creature if a soul is willing to take it."
	ritual_length = 50 SECONDS
	ritual_invocations = list("Wyjdź z sadzawki dusz...",
	"...wejdź do naszego świata...",
	"...stań się jednym z naszym światem...",
	"... rise ...",
	"... RISE! ...")
	invoke_msg = "... RISE!!!"
	favor_cost = 1250

/datum/religion_rites/raise_undead/invoke_effect(mob/living/user, atom/movable/religious_tool)
	var/turf/altar_turf = get_turf(religious_tool)
	new /obj/effect/temp_visual/cult/blood/long(altar_turf)
	new /obj/effect/temp_visual/dir_setting/curse/long(altar_turf)
	var/list/candidates = pollGhostCandidates("Czy chcesz zostać wskrzeszony jako Święty Przywołany Nieumarły?", ROLE_HOLY_SUMMONED, null, FALSE)
	if(!length(candidates))
		to_chat(user, "<span class='warning'>Sadzawka dusz jest pusta...")
		new /obj/effect/gibspawner/human/bodypartless(altar_turf)
		user.visible_message("<span class='warning'>Sadzawka dusz nie była dość silna, by przywołać nieumarłego.")
		GLOB.religious_sect?.adjust_favor(favor_cost, user) //refund if nobody takes the role
		return NOT_ENOUGH_PLAYERS
	var/mob/dead/observer/selected = pick_n_take(candidates)
	var/datum/mind/Mind = new /datum/mind(selected.key)
	var/undead_species = pick(/mob/living/carbon/human/species/zombie, /mob/living/carbon/human/species/skeleton)
	var/mob/living/carbon/human/species/undead = new undead_species(altar_turf)
	undead.real_name = "Święty Nieumarły ([rand(1,999)])"
	Mind.active = 1
	Mind.transfer_to(undead)
	undead.equip_to_slot_or_del(new /obj/item/storage/backpack/cultpack(undead), ITEM_SLOT_BACK)
	undead.equip_to_slot_or_del(new /obj/item/clothing/under/costume/skeleton(undead), ITEM_SLOT_ICLOTHING)
	undead.equip_to_slot_or_del(new /obj/item/clothing/suit/hooded/chaplain_hoodie(undead), ITEM_SLOT_OCLOTHING)
	undead.equip_to_slot_or_del(new /obj/item/clothing/shoes/sneakers/black(undead), ITEM_SLOT_FEET)
	undead.AddSpell(new /obj/effect/proc_holder/spell/targeted/smoke(null))
	if(GLOB.religion)
		var/obj/item/storage/book/bible/booze/B = new
		undead.mind?.holy_role = HOLY_ROLE_PRIEST
		B.deity_name = GLOB.deity
		B.name = GLOB.bible_name
		B.icon_state = GLOB.bible_icon_state
		B.item_state = GLOB.bible_item_state
		to_chat(undead, "Na stacji istnieje już ustanowiona religia. Jesteś akolitą [GLOB.deity]. Podporządkuj się kapelanowi.")
		undead.equip_to_slot_or_del(B, ITEM_SLOT_BACKPACK)
		GLOB.religious_sect?.on_conversion(undead)
	if(is_special_character(user))
		to_chat(undead, "<span class='userdanger'>Jesteś wdzięczny, że [user] przywołał cię do tego świata. Służ [user.real_name] i pomagaj mu osiągnąć jego cele za wszelką cenę.</span>")
	playsound(altar_turf, pick('sound/hallucinations/growl1.ogg','sound/hallucinations/growl2.ogg','sound/hallucinations/growl3.ogg',), 50, TRUE)
	return ..()

/datum/religion_rites/raise_dead
	name = "Raise Dead"
	desc = "Revives a buckled dead creature or person."
	ritual_length = 70 SECONDS
	ritual_invocations = list("Wróć do naszego świata...",
	"...wyjdź z zaświatów...",
	"...czeka na ciebie nowe życie...",
	"...wróć do nas...",
	"...mocą danej przez bogów...",
	"...powstaniesz znowu...")
	invoke_msg = "Witaj z powrotem na planie śmiertelników."
	favor_cost = 1500

///the target
	var/mob/living/carbon/human/raise_target

/datum/religion_rites/raise_dead/perform_rite(mob/living/user, atom/religious_tool)
	if(!religious_tool || !ismovable(religious_tool))
		to_chat(user, "<span class='warning'>Ten obrzęd wymaga przedmiotu religijnego, do którego można przypiąć osobę.</span>")
		return FALSE
	var/atom/movable/movable_reltool = religious_tool
	if(!length(movable_reltool.buckled_mobs))
		to_chat(user, "<span class='warning'>Nic nie jest przypięte do ołtarza!</span>")
		return FALSE
	for(var/mob/living/carbon/r_target in movable_reltool.buckled_mobs)
		if(!iscarbon(r_target))
			to_chat(user, "<span class='warning'>Tylko węglowe formy życia mogą zostać właściwie wskrzeszone!</span>")
			return FALSE
		if(r_target.stat != DEAD)
			to_chat(user, "<span class='warning'>Możesz wskrzeszać tylko martwe ciała, to wciąż żyje!</span>")
			return FALSE
		if(!r_target.mind)
			to_chat(user, "<span class='warning'>To stworzenie nie ma połączonej duszy...")
			return FALSE
		raise_target = r_target
		raise_target.notify_ghost_cloning("Mistyczna moc przywołuje twoją duszę z powrotem do ciała!", source = src)
		return ..()

/datum/religion_rites/raise_dead/invoke_effect(mob/living/user, atom/movable/religious_tool)
	var/turf/altar_turf = get_turf(religious_tool)
	if(!(raise_target in religious_tool.buckled_mobs))
		to_chat(user, "<span class='warning'>Ciała nie ma już na ołtarzu!</span>")
		raise_target = null
		return FALSE
	if(!raise_target.mind)
		to_chat(user, "<span class='warning'>Dusza tego stworzenia opuściła sadzawkę...")
		raise_target = null
		return FALSE
	if(raise_target.stat != DEAD)
		to_chat(user, "<span class='warning'>Cel musi pozostać martwy, by obrzęd zadziałał! Jeśli wróci bez twojego duchowego przewodnictwa... Kto wie, co może się stać!?</span>")
		raise_target = null
		return FALSE
	raise_target.grab_ghost() // Shove them back in their body.
	raise_target.revive(full_heal = 1, admin_revive = 1)
	playsound(altar_turf, 'sound/magic/staff_healing.ogg', 50, TRUE)
	raise_target = null
	return ..()

/datum/religion_rites/living_sacrifice
	name = "Living Sacrifice"
	desc = "Sacrifice a non-sentient living buckled creature for favor."
	ritual_length = 40 SECONDS
	ritual_invocations = list("By ofiarować tę istotę bogom...",
	"...by nakarmić ich jej duszą...",
	"...by mogli pochłonąć wszystko na swej drodze...",
	"...uwolnij ich więzy z tym śmiertelnym planem...",
	"...ofiarowuję ci tę żywą istotę...")
	invoke_msg = "...niech dołączy do hordy nieumarłych i stanie się jednym z duszami potępionych. "

//the living creature chosen for the sacrifice of the rite
	var/mob/living/chosen_sacrifice
/datum/religion_rites/living_sacrifice/perform_rite(mob/living/user, atom/religious_tool)
	if(!religious_tool || !ismovable(religious_tool))
		to_chat(user, "<span class='warning'>Ten obrzęd wymaga przedmiotu religijnego, do którego można przypiąć osobę.</span>")
		return FALSE
	var/atom/movable/movable_reltool = religious_tool
	if(!length(movable_reltool.buckled_mobs))
		to_chat(user, "<span class='warning'>Nic nie jest przypięte do ołtarza!</span>")
		return FALSE
	for(var/creature in movable_reltool.buckled_mobs)
		chosen_sacrifice = creature
		if(chosen_sacrifice.stat == DEAD)
			to_chat(user, "<span class='warning'>Możesz ofiarowywać tylko żywe stworzenia, to jest martwe!</span>")
			chosen_sacrifice = null
			return FALSE
		if(chosen_sacrifice.mind)
			to_chat(user, "<span class='warning'>Ta ofiara jest świadoma! [GLOB.deity] nie przyjmie takiego daru.</span>")
			chosen_sacrifice = null
			return FALSE
		return ..()

/datum/religion_rites/living_sacrifice/invoke_effect(mob/living/user, atom/movable/religious_tool)
	var/turf/altar_turf = get_turf(religious_tool)
	if(!(chosen_sacrifice in religious_tool.buckled_mobs)) //checks one last time if the right creature is still buckled
		to_chat(user, "<span class='warning'>Właściwej ofiary nie ma już na ołtarzu!</span>")
		chosen_sacrifice = null
		return FALSE
	if(chosen_sacrifice.stat == DEAD)
		to_chat(user, "<span class='warning'>Ofiara już nie żyje, musi żyć do końca obrzędu!</span>")
		chosen_sacrifice = null
		return FALSE
	var/favor_gained = 200 + round(chosen_sacrifice.health * 2)
	GLOB.religious_sect?.adjust_favor(favor_gained, user)
	new /obj/effect/temp_visual/cult/blood/out(altar_turf)
	to_chat(user, "<span class='notice'>[GLOB.deity] pochłania [chosen_sacrifice], zostawiając po nim krew i szczątki. [GLOB.deity] nagradza cię łaską: [favor_gained] pkt.</span>")
	chosen_sacrifice.gib(TRUE, FALSE, TRUE)
	playsound(get_turf(religious_tool), 'sound/effects/bamf.ogg', 50, TRUE)
	chosen_sacrifice = null
	return ..()

/**** Carp rites ****/

/datum/religion_rites/summon_carp
	name = "Summon Carp"
	desc = "Creates a Sentient Space Carp, if a soul is willing to take it. If not, the favor is refunded."
	ritual_length = 90 SECONDS
	ritual_invocations = list("Daj nam nowego wyznawcę...",
	"...niech wejdzie do naszego świata...",
	"...stań się jednym z naszym światem...",
	"...by pływać w naszej przestrzeni...",
	"...i wspierać naszą sprawę...")
	invoke_msg = "...Przyzywamy cię, Święty Karpiu!"
	favor_cost = 500

/datum/religion_rites/summon_carp/invoke_effect(mob/living/user, atom/movable/religious_tool)
	var/turf/altar_turf = get_turf(religious_tool)
	new /obj/effect/temp_visual/bluespace_fissure/long(altar_turf)
	user.visible_message("<span class'notice'>Nad ołtarzem pojawia się rozdarcie w rzeczywistości!</span>")
	var/list/candidates = pollGhostCandidates("Czy chcesz zostać przyzwany jako Święty Karp?", ROLE_HOLY_SUMMONED, null, FALSE)
	if(!length(candidates))
		new /obj/effect/gibspawner/generic(altar_turf)
		user.visible_message("<span class='warning'>Sadzawka karpi nie była dość silna, by przywołać kosmicznego karpia.")
		GLOB.religious_sect?.adjust_favor(400, user)
		return NOT_ENOUGH_PLAYERS
	var/mob/dead/observer/selected = pick_n_take(candidates)
	var/datum/mind/M = new /datum/mind(selected.key)
	var/carp_species = pick(/mob/living/simple_animal/hostile/carp/megacarp, /mob/living/simple_animal/hostile/carp)
	var/mob/living/simple_animal/hostile/carp = new carp_species(altar_turf)
	carp.name = "Holy Space-Carp ([rand(1,999)])"
	carp.key = selected.key
	carp.sentience_act()
	carp.maxHealth += 100
	carp.health += 100
	M.transfer_to(carp)
	if(GLOB.religion)
		carp.mind?.holy_role = HOLY_ROLE_PRIEST
		to_chat(carp, "Na stacji istnieje już ustanowiona religia. Jesteś akolitą [GLOB.deity]. Podporządkuj się kapelanowi.")
		GLOB.religious_sect?.on_conversion(carp)
	playsound(altar_turf, 'sound/effects/slosh.ogg', 50, TRUE)
	return ..()

/datum/religion_rites/summon_carpsuit
	name = "Summon Carp-Suit"
	desc = "Summons a Space-Carp Suit"
	ritual_length = 60 SECONDS
	ritual_invocations = list("Staniemy się jednym...",
	"...wtopimy się w tłum...",
	"...przyjmiemy drogę karpia...",
	"...daj nam nowe szaty...")
	invoke_msg = "Byśmy mogli pływać."
	favor_cost = 300
	var/obj/item/clothing/suit/chosen_clothing

/datum/religion_rites/summon_carpsuit/perform_rite(mob/living/user, atom/religious_tool)
	var/turf/T = get_turf(religious_tool)
	var/list/L = T.contents
	if(!locate(/obj/item/clothing/suit) in L)
		to_chat(user, "<span class='warning'>Na ołtarzu nie ma żadnego ubrania!</span>")
		return FALSE
	for(var/obj/item/clothing/suit/apparel in L)
		chosen_clothing = apparel //the apparel has been chosen by our lord and savior
		return ..()
	return FALSE

/datum/religion_rites/summon_carpsuit/invoke_effect(mob/living/user, atom/religious_tool)
	if(!QDELETED(chosen_clothing) && get_turf(religious_tool) == chosen_clothing.loc) //check if the same clothing is still there
		user.visible_message("<span class'notice'>[chosen_clothing] się przemienia!</span>")
		chosen_clothing.obj_destruction()
		chosen_clothing = null
		new /obj/item/clothing/suit/space/hardsuit/carp/old(get_turf(religious_tool))
		playsound(get_turf(religious_tool), 'sound/effects/slosh.ogg', 50, TRUE)
		return ..()
	chosen_clothing = null
	to_chat(user, "<span class='warning'>Ubranie wybrane do obrzędu nie leży już na ołtarzu!</span>")
	return FALSE

/datum/religion_rites/flood_area
	name = "Flood Area"
	desc = "Flood the area with water vapor, great for learning to swim!"
	ritual_length = 40 SECONDS
	ritual_invocations = list("Musimy pływać...",
	"...ale do tego potrzebujemy wody...",
	"...ześlij nam wielki potop...",
	"...zanurz nas w swej chwale...",
	"...będziemy pływać na wieki...")
	invoke_msg = "...w naszym własnym oceanie."
	favor_cost = 200

/datum/religion_rites/flood_area/invoke_effect(mob/living/user, atom/movable/religious_tool)
	var/turf/open/T = get_turf(religious_tool)
	if(istype(T))
		T.atmos_spawn_air("water_vapor=5000;TEMP=255")
	return ..()
