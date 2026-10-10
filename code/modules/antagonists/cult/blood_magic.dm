/datum/action/innate/cult/blood_magic //Blood magic handles the creation of blood spells (formerly talismans)
	name = "Prepare Blood Magic"
	button_icon_state = "carve"
	desc = "Prepare blood magic by carving runes into your flesh. This is easier with an <b>empowering rune</b>."
	var/list/spells = list()
	var/channeling = FALSE

/datum/action/innate/cult/blood_magic/Grant()
	..()
	button.screen_loc = DEFAULT_BLOODSPELLS
	button.moved = DEFAULT_BLOODSPELLS
	button.ordered = FALSE

/datum/action/innate/cult/blood_magic/Remove()
	for(var/X in spells)
		qdel(X)
	..()

/datum/action/innate/cult/blood_magic/IsAvailable()
	if(!iscultist(owner))
		return FALSE
	return ..()

/datum/action/innate/cult/blood_magic/proc/Positioning()
	var/list/screen_loc_split = splittext(button.screen_loc,",")
	var/list/screen_loc_X = splittext(screen_loc_split[1],":")
	var/list/screen_loc_Y = splittext(screen_loc_split[2],":")
	var/pix_X = text2num(screen_loc_X[2])
	for(var/datum/action/innate/cult/blood_spell/B in spells)
		if(B.button.locked)
			var/order = pix_X+spells.Find(B)*31
			B.button.screen_loc = "[screen_loc_X[1]]:[order],[screen_loc_Y[1]]:[screen_loc_Y[2]]"
			B.button.moved = B.button.screen_loc

/datum/action/innate/cult/blood_magic/Activate()
	var/rune = FALSE
	var/limit = RUNELESS_MAX_BLOODCHARGE
	if(locate(/obj/effect/rune/empower) in range(1, owner))
		rune = TRUE
	if(rune)
		limit = MAX_BLOODCHARGE
	if(spells.len >= limit)
		if(rune)
			to_chat(owner, "<span class='cultitalic'>Nie możesz przechowywać więcej niż [MAX_BLOODCHARGE] zaklęć. <b>Wybierz zaklęcie do usunięcia.</b></span>")
		else
			to_chat(owner, "<span class='cultitalic'><b><u>Bez wzmacniającej runy nie możesz przechowywać więcej niż [RUNELESS_MAX_BLOODCHARGE] zaklęć! Wybierz zaklęcie do usunięcia.</b></u></span>")
		var/nullify_spell = input(owner, "Wybierz zaklęcie do usunięcia.", "Obecne zaklęcia") as null|anything in spells
		if(nullify_spell)
			qdel(nullify_spell)
		return
	var/entered_spell_name
	var/datum/action/innate/cult/blood_spell/BS
	var/list/possible_spells = list()
	for(var/I in subtypesof(/datum/action/innate/cult/blood_spell))
		var/datum/action/innate/cult/blood_spell/J = I
		var/cult_name = initial(J.name)
		possible_spells[cult_name] = J
	possible_spells += "(USUŃ ZAKLĘCIE)"
	entered_spell_name = input(owner, "Wybierz zaklęcie krwi do przygotowania...", "Wybór zaklęć") as null|anything in possible_spells
	if(entered_spell_name == "(USUŃ ZAKLĘCIE)")
		var/nullify_spell = input(owner, "Wybierz zaklęcie do usunięcia.", "Obecne zaklęcia") as null|anything in spells
		if(nullify_spell)
			qdel(nullify_spell)
		return
	BS = possible_spells[entered_spell_name]
	if(QDELETED(src) || owner.incapacitated() || !BS || (rune && !(locate(/obj/effect/rune/empower) in range(1, owner))) || (spells.len >= limit))
		return
	to_chat(owner,"<span class='warning'>Zaczynasz wycinać na swoim ciele nienaturalne symbole!</span>")
	SEND_SOUND(owner, sound('sound/weapons/slice.ogg',0,1,10))
	if(!channeling)
		channeling = TRUE
	else
		to_chat(owner, "<span class='cultitalic'>Już przywołujesz magię krwi!")
		return
	if(do_after(owner, 100 - rune*60, target = owner))
		if(ishuman(owner))
			var/mob/living/carbon/human/H = owner
			H.bleed(40 - rune*32)
		var/datum/action/innate/cult/blood_spell/new_spell = new BS(owner)
		new_spell.Grant(owner, src)
		spells += new_spell
		Positioning()
		to_chat(owner, "<span class='warning'>Twoje rany jarzą się mocą - przygotowujesz inwokację: [new_spell.name]!</span>")
	channeling = FALSE

/datum/action/innate/cult/blood_spell //The next generation of talismans, handles storage/creation of blood magic
	name = "Blood Magic"
	button_icon_state = "telerune"
	desc = "Fear the Old Blood."
	var/charges = 1
	var/magic_path = null
	var/obj/item/melee/blood_magic/hand_magic
	var/datum/action/innate/cult/blood_magic/all_magic
	var/base_desc //To allow for updating tooltips
	var/invocation
	var/health_cost = 0

/datum/action/innate/cult/blood_spell/Grant(mob/living/owner, datum/action/innate/cult/blood_magic/BM)
	if(health_cost)
		desc += "<br>Zadaje twojej ręce <u>[health_cost] obrażeń</u> przy każdym użyciu."
	base_desc = desc
	desc += "<br><b><u>Pozostałe użycia: [charges]</u></b>."
	all_magic = BM
	..()
	button.locked = TRUE
	button.ordered = FALSE

/datum/action/innate/cult/blood_spell/Remove()
	if(all_magic)
		all_magic.spells -= src
	if(hand_magic)
		qdel(hand_magic)
		hand_magic = null
	..()

/datum/action/innate/cult/blood_spell/IsAvailable()
	if(!iscultist(owner) || owner.incapacitated()  || !charges)
		return FALSE
	return ..()

/datum/action/innate/cult/blood_spell/Activate()
	if(magic_path) //If this spell flows from the hand
		if(!hand_magic)
			hand_magic = new magic_path(owner, src)
			if(!owner.put_in_hands(hand_magic))
				qdel(hand_magic)
				hand_magic = null
				to_chat(owner, "<span class='warning'>Nie masz wolnej ręki, by przywołać magię krwi!</span>")
				return
			to_chat(owner, "<span class='notice'>Twoje rany jarzą się, gdy przywołujesz: [name].</span>")
			return
		if(hand_magic)
			qdel(hand_magic)
			hand_magic = null
			to_chat(owner, "<span class='warning'>Gasisz zaklęcie, zachowując je na później.</span>")


//Cult Blood Spells
/datum/action/innate/cult/blood_spell/stun
	name = "Stun"
	desc = "Empowers your hand to stun and mute a victim on contact."
	button_icon_state = "hand"
	magic_path = /obj/item/melee/blood_magic/stun
	health_cost = 10

/datum/action/innate/cult/blood_spell/teleport
	name = "Teleport"
	desc = "Empowers your hand to teleport yourself or another cultist to a teleport rune on contact."
	button_icon_state = "tele"
	magic_path = /obj/item/melee/blood_magic/teleport
	health_cost = 7

/datum/action/innate/cult/blood_spell/emp
	name = "Electromagnetic Pulse"
	desc = "Emits a large electromagnetic pulse."
	button_icon_state = "emp"
	health_cost = 10
	invocation = "Ta'gh fara'qha fel d'amar det!"
	check_flags = AB_CHECK_CONSCIOUS

/datum/action/innate/cult/blood_spell/emp/Activate()
	owner.whisper(invocation, language = /datum/language/common)
	owner.visible_message("<span class='warning'>Dłoń [owner] rozbłyska jasnym błękitem!</span>", \
						 "<span class='cultitalic'>Wypowiadasz przeklęte słowa, a z twojej dłoni wydobywa się impuls EMP.</span>")
	empulse(owner, 2, 5, holy=TRUE)
	charges--
	if(charges<=0)
		qdel(src)

/datum/action/innate/cult/blood_spell/shackles
	name = "Shadow Shackles"
	desc = "Empowers your hand to start handcuffing victim on contact, and mute them if successful."
	button_icon_state = "cuff"
	charges = 4
	magic_path = /obj/item/melee/blood_magic/shackles

/datum/action/innate/cult/blood_spell/construction
	name = "Twisted Construction"
	desc = "Empowers your hand to corrupt certain metalic objects.<br><u>Converts:</u><br>Plasteel into runed metal<br>50 iron into a construct shell<br>Living cyborgs into constructs after a delay<br>Cyborg shells into construct shells<br>Airlocks into brittle runed airlocks after a delay (harm intent)"
	button_icon_state = "transmute"
	magic_path = /obj/item/melee/blood_magic/construction
	health_cost = 12

/datum/action/innate/cult/blood_spell/equipment
	name = "Summon Combat Equipment"
	desc = "Empowers your hand to summon combat gear onto a cultist you touch, including cult armor, a cult bola, and a cult sword. Not recommended for use before the blood cult's presence has been revealed."
	button_icon_state = "equip"
	magic_path = /obj/item/melee/blood_magic/armor

/datum/action/innate/cult/blood_spell/dagger
	name = "Summon Ritual Dagger"
	desc = "Allows you to summon a ritual dagger, in case you've lost the dagger that was given to you."
	invocation = "Wur d'dai leev'mai k'sagan!" //where did I leave my keys, again?
	button_icon_state = "equip" //this is the same icon that summon equipment uses, but eh, I'm not a spriter
	/// The item given to the cultist when the spell is invoked. Typepath.
	var/obj/item/summoned_type = /obj/item/melee/cultblade/dagger

/datum/action/innate/cult/blood_spell/dagger/Activate()
	var/turf/owner_turf = get_turf(owner)
	owner.whisper(invocation, language = /datum/language/common)
	owner.visible_message("<span class='warning'>Dłoń [owner] przez chwilę jarzy się czerwienią.</span>", \
		"<span class='cultitalic'>Twoja prośba o pomoc zostaje wysłuchana, a w dłoni zaczyna migotać i nabierać kształtu światło!</span>")
	var/obj/item/summoned_blade = new summoned_type(owner_turf)
	if(owner.put_in_hands(summoned_blade))
		to_chat(owner, "<span class='warning'>W twojej dłoni pojawia się [summoned_blade]!</span>")
	else
		owner.visible_message("<span class='warning'>U stóp [owner] pojawia się [summoned_blade]!</span>", \
			 "<span class='cultitalic'>U twoich stóp materializuje się [summoned_blade].</span>")
	SEND_SOUND(owner, sound('sound/effects/magic.ogg', FALSE, 0, 25))
	charges--
	if(charges <= 0)
		qdel(src)

/datum/action/innate/cult/blood_spell/horror
	name = "Hallucinations"
	desc = "Gives hallucinations to a target at range. A silent and invisible spell."
	button_icon_state = "horror"
	var/obj/effect/proc_holder/horror/PH
	charges = 4
	check_flags = AB_CHECK_CONSCIOUS

/datum/action/innate/cult/blood_spell/horror/New()
	PH = new()
	PH.attached_action = src
	..()

/datum/action/innate/cult/blood_spell/horror/Destroy()
	var/obj/effect/proc_holder/horror/destroy = PH
	. = ..()
	if(destroy  && !QDELETED(destroy))
		QDEL_NULL(destroy)

/datum/action/innate/cult/blood_spell/horror/Activate()
	PH.toggle(owner) //the important bit
	return TRUE

/obj/effect/proc_holder/horror
	active = FALSE
	ranged_mousepointer = 'icons/effects/cult_target.dmi'
	var/datum/action/innate/cult/blood_spell/attached_action

/obj/effect/proc_holder/horror/Destroy()
	var/datum/action/innate/cult/blood_spell/AA = attached_action
	. = ..()
	if(AA && !QDELETED(AA))
		QDEL_NULL(AA)

/obj/effect/proc_holder/horror/proc/toggle(mob/user)
	if(active)
		remove_ranged_ability("<span class='cult'>Rozpraszasz magię...</span>")
	else
		add_ranged_ability(user, "<span class='cult'>Przygotowujesz się, by przerazić cel...</span>")

/obj/effect/proc_holder/horror/InterceptClickOn(mob/living/caller, params, atom/target)
	if(..())
		return
	if(ranged_ability_user.incapacitated() || !iscultist(caller))
		remove_ranged_ability()
		return
	var/turf/T = get_turf(ranged_ability_user)
	if(!isturf(T))
		return FALSE
	if(ranged_ability_user in viewers(7, get_turf(target)))
		if(!ishuman(target) || iscultist(target))
			return
		var/mob/living/carbon/human/H = target
		H.hallucination = max(H.hallucination, 120)
		SEND_SOUND(ranged_ability_user, sound('sound/effects/ghost.ogg',0,1,50))
		var/image/C = image('icons/effects/cult_effects.dmi',H,"bloodsparkles", ABOVE_MOB_LAYER)
		add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/cult, "cult_apoc", C, NONE)
		addtimer(CALLBACK(H,TYPE_PROC_REF(/atom, remove_alt_appearance),"cult_apoc",TRUE), 2400, TIMER_OVERRIDE|TIMER_UNIQUE)
		to_chat(ranged_ability_user,"<span class='cult'><b>[H] zostaje przeklęty żywymi koszmarami!</b></span>")
		attached_action.charges--
		attached_action.desc = attached_action.base_desc
		attached_action.desc += "<br><b><u>Pozostałe użycia: [attached_action.charges]</u></b>."
		attached_action.UpdateButtonIcon()
		if(attached_action.charges <= 0)
			remove_ranged_ability("<span class='cult'>Wyczerpujesz moc zaklęcia!</span>")
			qdel(src)

/datum/action/innate/cult/blood_spell/veiling
	name = "Conceal Presence"
	desc = "Alternates between hiding and revealing nearby cult structures and runes."
	invocation = "Kla'atu barada nikt'o!"
	button_icon_state = "gone"
	charges = 10
	var/revealing = FALSE //if it reveals or not
	check_flags = AB_CHECK_CONSCIOUS

/datum/action/innate/cult/blood_spell/veiling/Activate()
	if(!revealing)
		owner.visible_message("<span class='warning'>Z dłoni [owner] sypie się cienki szary pył!</span>", \
			"<span class='cultitalic'>Przywołujesz zaklęcie zasłony, ukrywając pobliskie runy.</span>")
		charges--
		SEND_SOUND(owner, sound('sound/magic/smoke.ogg',0,1,25))
		owner.whisper(invocation, language = /datum/language/common)
		for(var/obj/effect/rune/R in range(5, owner))
			R.conceal()
		for(var/obj/structure/destructible/cult/S in range(5, owner))
			S.conceal()
		for(var/obj/machinery/door/airlock/cult/AL in range(5, owner))
			AL.conceal()
		for(var/turf/open/floor/engine/cult/T in RANGE_TURFS(5,owner))
			T.realappearance.alpha = 0
		revealing = TRUE
		name = "Reveal Runes"
		button_icon_state = "back"
	else
		owner.visible_message("<span class='warning'>Z dłoni [owner] bije błysk światła!</span>", \
			 "<span class='cultitalic'>Przywołujesz przeciwzaklęcie, odsłaniając pobliskie runy.</span>")
		charges--
		owner.whisper(invocation, language = /datum/language/common)
		SEND_SOUND(owner, sound('sound/magic/enter_blood.ogg',0,1,25))
		for(var/obj/effect/rune/R in range(7,owner)) //More range in case you weren't standing in exactly the same spot
			R.reveal()
		for(var/obj/structure/destructible/cult/S in range(6,owner))
			S.reveal()
		for(var/obj/machinery/door/airlock/cult/AL in range(6, owner))
			AL.reveal()
		for(var/turf/open/floor/engine/cult/T in RANGE_TURFS(6,owner))
			T.realappearance.alpha = initial(T.realappearance.alpha)
		revealing = FALSE
		name = "Conceal Runes"
		button_icon_state = "gone"
	if(charges<= 0)
		qdel(src)
	desc = base_desc
	desc += "<br><b><u>Pozostałe użycia: [charges]</u></b>."
	UpdateButtonIcon()

/datum/action/innate/cult/blood_spell/manipulation
	name = "Blood Rites"
	desc = "Empowers your hand to absorb blood to be used for advanced rites, or heal a cultist on contact. Use the spell in-hand to cast advanced rites."
	invocation = "Fel'th Dol Ab'orod!"
	button_icon_state = "manip"
	charges = 5
	magic_path = /obj/item/melee/blood_magic/manipulator


// The "magic hand" items
/obj/item/melee/blood_magic
	name = "\improper magical aura"
	desc = "A sinister looking aura that distorts the flow of reality around it."
	icon = 'icons/obj/items_and_weapons.dmi'
	lefthand_file = 'icons/mob/inhands/misc/touchspell_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/touchspell_righthand.dmi'
	icon_state = "disintegrate"
	item_state = "disintegrate"
	item_flags = NEEDS_PERMIT | ABSTRACT | DROPDEL

	w_class = WEIGHT_CLASS_HUGE
	throwforce = 0
	throw_range = 0
	throw_speed = 0
	var/invocation
	var/uses = 1
	var/health_cost = 0 //The amount of health taken from the user when invoking the spell
	var/datum/action/innate/cult/blood_spell/source
/obj/item/melee/blood_magic/Initialize(mapload, var/spell)
	. = ..()
	if(!istype(spell, /datum/action/innate/cult/blood_spell))
		return INITIALIZE_HINT_QDEL
	source = spell
	uses = source.charges
	health_cost = source.health_cost

/obj/item/melee/blood_magic/Destroy()
	if(!QDELETED(source))
		if(uses <= 0)
			source?.hand_magic = null
			qdel(source)
			source = null
		else
			source.hand_magic = null
			source.charges = uses
			source.desc = source.base_desc
			source.desc += "<br><b><u>Pozostałe użycia: [uses]</u></b>."
			source.UpdateButtonIcon()
	..()

/obj/item/melee/blood_magic/attack_self(mob/living/user)
	afterattack(user, user, TRUE)

/obj/item/melee/blood_magic/attack(mob/living/M, mob/living/carbon/user)
	if(!iscarbon(user) || !iscultist(user))
		uses = 0
		qdel(src)
		return
	log_combat(user, M, "used a cult spell on", source.name, "")
	M.lastattacker = user.real_name
	M.lastattackerckey = user.ckey

/obj/item/melee/blood_magic/afterattack(atom/target, mob/living/carbon/user, proximity)
	. = ..()
	if(invocation)
		user.whisper(invocation, language = /datum/language/common)
	if(health_cost)
		if(user.active_hand_index == 1)
			user.apply_damage(health_cost, BRUTE, BODY_ZONE_L_ARM)
		else
			user.apply_damage(health_cost, BRUTE, BODY_ZONE_R_ARM)
	if(uses <= 0)
		qdel(src)
	else if(source)
		source.desc = source.base_desc
		source.desc += "<br><b><u>Pozostałe użycia: [uses]</u></b>."
		source.UpdateButtonIcon()

//Stun
/obj/item/melee/blood_magic/stun //NSV13 - reverted to pre-nerf state
	name = "Stunning Aura"
	desc = "Will stun and mute a victim on contact."
	color = RUNE_COLOR_RED
	invocation = "Fuu ma'jin!"

/obj/item/melee/blood_magic/stun/afterattack(atom/target, mob/living/carbon/user, proximity) //NSV13 - Reverted proc to pre-nerf state
	if(!isliving(target) || !proximity)
		return
	var/mob/living/L = target
	if(iscultist(L))
		return
	if(iscultist(user))
		user.visible_message("<span class='warning'>[user] unosi dłoń, która eksploduje błyskiem czerwonego światła!</span>", \
							"<span class='cultitalic'>Próbujesz ogłuszyć [L] zaklęciem!</span>")

		user.mob_light(_range = 3, _color = LIGHT_COLOR_BLOOD_MAGIC, _duration = 0.2 SECONDS)

		var/anti_magic_source = L.anti_magic_check(holy = TRUE)
		if(anti_magic_source)

			L.mob_light(_range = 2, _color = LIGHT_COLOR_HOLY_MAGIC, _duration = 10 SECONDS)
			var/mutable_appearance/forbearance = mutable_appearance('icons/effects/genetics.dmi', "servitude", -MUTATIONS_LAYER)
			L.add_overlay(forbearance)
			addtimer(CALLBACK(L, TYPE_PROC_REF(/atom, cut_overlay)), 100)

			if(istype(anti_magic_source, /obj/item))
				target.visible_message("<span class='warning'>[L] zupełnie nie przejmuje się twoimi słowami!</span>", \
									   "<span class='userdanger'>[GLOB.deity] chroni cię przed herezją [user]!</span>")
		else if(!HAS_TRAIT(target, TRAIT_MINDSHIELD) && !istype(L.get_item_by_slot(ITEM_SLOT_HEAD), /obj/item/clothing/head/foilhat))
			to_chat(user, "<span class='cultitalic'>[L] pada na ziemię, bełkocząc jak szalony!</span>")
			L.Paralyze(160)
			L.flash_act(1,1)
			if(issilicon(target))
				var/mob/living/silicon/S = L
				S.emp_act(EMP_HEAVY)
			else if(iscarbon(target))
				var/mob/living/carbon/C = L
				C.silent += 6
				C.stuttering += 15
				C.cultslurring += 15
				C.Jitter(1.5 SECONDS)
		uses--
	..()

//Teleportation
/obj/item/melee/blood_magic/teleport
	name = "Teleporting Aura"
	color = RUNE_COLOR_TELEPORT
	desc = "Will teleport a cultist to a teleport rune on contact."
	invocation = "Sas'so c'arta forbici!"

/obj/item/melee/blood_magic/teleport/afterattack(atom/target, mob/living/carbon/user, proximity)
	if(!iscultist(target) || !proximity)
		to_chat(user, "<span class='warning'>Tym zaklęciem możesz teleportować tylko kultystów obok ciebie!</span>")
		return
	if(iscultist(user))
		var/list/potential_runes = list()
		var/list/teleportnames = list()
		for(var/obj/effect/rune/teleport/teleport_rune as anything in GLOB.teleport_runes)
			potential_runes[avoid_assoc_duplicate_keys(teleport_rune.listkey, teleportnames)] = teleport_rune

		if(!potential_runes.len)
			to_chat(user, "<span class='warning'>Nie ma run, do których można się teleportować!</span>")
			return

		var/turf/T = get_turf(src)
		if(is_away_level(T.z))
			to_chat(user, "<span class='cultitalic'>Nie jesteś we właściwym wymiarze!</span>")
			return

		var/input_rune_key = input(user, "Wybierz runę, do której chcesz się teleportować.", "Runa docelowa") as null|anything in potential_runes //we know what key they picked
		var/obj/effect/rune/teleport/actual_selected_rune = potential_runes[input_rune_key] //what rune does that key correspond to?
		if(QDELETED(src) || !user || !user.is_holding(src) || user.incapacitated() || !actual_selected_rune || !proximity)
			return
		var/turf/dest = get_turf(actual_selected_rune)
		if(is_blocked_turf(dest, TRUE))
			to_chat(user, "<span class='warning'>Runa docelowa jest zablokowana. Nie możesz się tam teleportować.</span>")
			return
		uses--
		var/turf/origin = get_turf(user)
		var/mob/living/L = target
		if(do_teleport(L, dest, channel = TELEPORT_CHANNEL_CULT))
			origin.visible_message("<span class='warning'>Z dłoni [user] sypie się pył, a [user] znika z ostrym trzaskiem!</span>", \
				"<span class='cultitalic'>Wypowiadasz słowa talizmanu i nagle jesteś gdzie indziej!</span>", "<i>Słyszysz ostry trzask.</i>")
			dest.visible_message("<span class='warning'>Rozlega się huk wypychanego powietrza i nad runą coś się pojawia!</span>", null, "<i>Słyszysz huk.</i>")
		..()

//Shackles
/obj/item/melee/blood_magic/shackles
	name = "Shackling Aura"
	desc = "Will start handcuffing a victim on contact, and mute them if successful."
	invocation = "In'totum Lig'abis!"
	color = "#000000" // black

/obj/item/melee/blood_magic/shackles/afterattack(atom/target, mob/living/carbon/user, proximity)
	if(iscultist(user) && iscarbon(target) && proximity)
		var/mob/living/carbon/C = target
		if(C.get_num_arms(FALSE) >= 2 || C.get_arm_ignore())
			CuffAttack(C, user)
		else
			user.visible_message("<span class='cultitalic'>Ta ofiara nie ma dość rąk, by ją skrępować!</span>")
			return
		..()

/obj/item/melee/blood_magic/shackles/proc/CuffAttack(mob/living/carbon/C, mob/living/user)
	if(!C.handcuffed)
		playsound(loc, 'sound/weapons/cablecuff.ogg', 30, 1, -2)
		C.visible_message("<span class='danger'>[user] zaczyna krępować [C] mroczną magią!</span>", \
								"<span class='userdanger'>[user] zaczyna formować wokół twoich nadgarstków kajdany z mrocznej magii!</span>")
		if(do_mob(user, C, 30))
			if(!C.handcuffed)
				C.handcuffed = new /obj/item/restraints/handcuffs/energy/cult/used(C)
				C.update_handcuffed()
				C.silent += 5
				to_chat(user, "<span class='notice'>Skuwasz [C].</span>")
				log_combat(user, C, "shackled")
				uses--
			else
				to_chat(user, "<span class='warning'>[C] jest już skrępowany.</span>")
		else
			to_chat(user, "<span class='warning'>Nie udaje ci się skuć [C].</span>")
	else
		to_chat(user, "<span class='warning'>[C] jest już skrępowany.</span>")


/obj/item/restraints/handcuffs/energy/cult //For the shackling spell
	name = "shadow shackles"
	desc = "Shackles that bind the wrists with sinister magic."
	trashtype = /obj/item/restraints/handcuffs/energy/used
	item_flags = DROPDEL

/obj/item/restraints/handcuffs/energy/cult/used/dropped(mob/user)
	user.visible_message("<span class='danger'>Kajdany [user] pękają w wyładowaniu mrocznej magii!</span>", \
							"<span class='userdanger'>[src] pęka w wyładowaniu mrocznej magii!</span>")
	..()


//Construction: Converts 50 iron to a construct shell, plasteel to runed metal, airlock to brittle runed airlock, a borg to a construct, or borg shell to a construct shell
/obj/item/melee/blood_magic/construction
	name = "Twisting Aura"
	desc = "Corrupts certain metalic objects on contact."
	invocation = "Ethra p'ni dedol!"
	color = "#000000" // black
	var/channeling = FALSE

/obj/item/melee/blood_magic/construction/examine(mob/user)
	. = ..()
	. += "<u>Złowieszcze zaklęcie, które zmienia:</u>\n"+\
	"plastal w runiczny metal\n"+\
	"[IRON_TO_CONSTRUCT_SHELL_CONVERSION] metalu w powłokę konstruktu\n"+\
	"żywe cyborgi w konstrukty (po chwili)\n"+\
	"powłoki cyborgów w powłoki konstruktów\n"+\
	"śluzy w kruche runiczne śluzy (po chwili, intencja krzywdy)"

/obj/item/melee/blood_magic/construction/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(proximity_flag && iscultist(user))
		if(channeling)
			to_chat(user, "<span class='cultitalic'>Już przywołujesz wypaczoną budowę!</span>")
			return
		var/turf/T = get_turf(target)
		if(istype(target, /obj/item/stack/sheet/iron))
			var/obj/item/stack/sheet/candidate = target
			if(candidate.use(IRON_TO_CONSTRUCT_SHELL_CONVERSION))
				uses--
				to_chat(user, "<span class='warning'>Z twojej dłoni wydobywa się mroczna chmura, która owija żelazo i wykręca je w powłokę konstruktu!</span>")
				new /obj/structure/constructshell(T)
				SEND_SOUND(user, sound('sound/effects/magic.ogg',0,1,25))
			else
				to_chat(user, "<span class='warning'>Potrzebujesz [IRON_TO_CONSTRUCT_SHELL_CONVERSION] żelaza, by stworzyć powłokę konstruktu!</span>")
				return
		else if(istype(target, /obj/item/stack/sheet/plasteel))
			var/obj/item/stack/sheet/plasteel/candidate = target
			var/quantity = candidate.amount
			if(candidate.use(quantity))
				uses --
				new /obj/item/stack/sheet/runed_metal(T,quantity)
				to_chat(user, "<span class='warning'>Z twojej dłoni wydobywa się mroczna chmura, która owija plastal i zmienia ją w runiczny metal!</span>")
				SEND_SOUND(user, sound('sound/effects/magic.ogg',0,1,25))
		else if(istype(target,/mob/living/silicon/robot))
			var/mob/living/silicon/robot/candidate = target
			if(candidate.mmi)
				channeling = TRUE
				user.visible_message("<span class='danger'>Z dłoni [user] wydobywa się mroczna chmura i owija [candidate]!</span>")
				playsound(T, 'sound/machines/airlock_alien_prying.ogg', 80, 1)
				var/prev_color = candidate.color
				candidate.color = "black"
				if(do_after(user, 90, target = candidate))
					candidate.emp_act(EMP_HEAVY)
					var/construct_class = alert(user, "Wybierz rodzaj konstruktu, który chcesz stworzyć.",,"Juggernaut","Wraith","Artificer")
					if(QDELETED(candidate))
						channeling = FALSE
						return
					user.visible_message("<span class='danger'>Mroczna chmura cofa się z tego, co było wcześniej [candidate], odsłaniając\n konstrukt: [construct_class]!</span>")
					switch(construct_class)
						if("Juggernaut")
							makeNewConstruct(/mob/living/simple_animal/hostile/construct/armored, candidate, user, 0, T)
						if("Wraith")
							makeNewConstruct(/mob/living/simple_animal/hostile/construct/wraith, candidate, user, 0, T)
						if("Artificer")
							makeNewConstruct(/mob/living/simple_animal/hostile/construct/builder, candidate, user, 0, T)
					SEND_SOUND(user, sound('sound/effects/magic.ogg',0,1,25))
					uses--
					candidate.mmi = null
					qdel(candidate)
					channeling = FALSE
				else
					channeling = FALSE
					candidate.color = prev_color
					return
			else
				uses--
				to_chat(user, "<span class='warning'>Z twojej dłoni wydobywa się mroczna chmura, która owija [candidate] i wykręca w powłokę konstruktu!</span>")
				new /obj/structure/constructshell(T)
				SEND_SOUND(user, sound('sound/effects/magic.ogg',0,1,25))
				qdel(candidate)
		else if(istype(target,/obj/machinery/door/airlock))
			channeling = TRUE
			playsound(T, 'sound/machines/airlockforced.ogg', 50, 1)
			do_sparks(5, TRUE, target)
			if(do_after(user, 50, target = user))
				if(QDELETED(target))
					channeling = FALSE
					return
				target.narsie_act()
				uses--
				user.visible_message("<span class='warning'>Z dłoni [user] nagle wysuwają się czarne wstęgi, które oplatają śluzę, wykręcając ją i spaczając!</span>")
				SEND_SOUND(user, sound('sound/effects/magic.ogg',0,1,25))
				channeling = FALSE
			else
				channeling = FALSE
				return
		else
			to_chat(user, "<span class='warning'>Zaklęcie nie zadziała na [target]!</span>")
			return
		..()

//Armor: Gives the target (cultist) a basic cultist combat loadout
/obj/item/melee/blood_magic/armor
	name = "Arming Aura"
	desc = "On contact, equips a cultist with combat gear."
	color = "#33cc33" // green

/obj/item/melee/blood_magic/armor/afterattack(atom/target, mob/living/carbon/user, proximity)
	if(iscarbon(target) && iscultist(target) && proximity)
		uses--
		var/mob/living/carbon/C = target
		C.visible_message("<span class='warning'>Na [C] nagle pojawia się nieziemska zbroja!</span>")
		C.equip_to_slot_or_del(new /obj/item/clothing/under/color/black,ITEM_SLOT_ICLOTHING)
		C.equip_to_slot_or_del(new /obj/item/clothing/suit/cultrobes/alt(user), ITEM_SLOT_OCLOTHING)
		C.equip_to_slot_or_del(new /obj/item/clothing/head/culthood/alt(user), ITEM_SLOT_HEAD)
		C.equip_to_slot_or_del(new /obj/item/clothing/shoes/cult/alt(user), ITEM_SLOT_FEET)
		C.equip_to_slot_or_del(new /obj/item/storage/backpack/cultpack(user), ITEM_SLOT_BACK)
		if(C == user)
			qdel(src) //Clears the hands
		C.put_in_hands(new /obj/item/melee/cultblade(user))
		C.put_in_hands(new /obj/item/restraints/legcuffs/bola/cult(user))
		..()

/obj/item/melee/blood_magic/manipulator
	name = "Blood Rite Aura"
	desc = "Absorbs blood from anything you touch. Touching cultists and constructs can heal them. Use in-hand to cast an advanced rite."
	color = "#7D1717"

/obj/item/melee/blood_magic/manipulator/examine(mob/user)
	. = ..()
	. += "Krwawa włócznia, salwa krwawych pocisków i krwawy promień kosztują odpowiednio [BLOOD_SPEAR_COST], [BLOOD_BARRAGE_COST] i [BLOOD_BEAM_COST] ładunków."

/obj/item/melee/blood_magic/manipulator/afterattack(atom/target, mob/living/carbon/human/user, proximity)
	if(proximity)
		if(ishuman(target))
			var/mob/living/carbon/human/H = target
			if(NOBLOOD in H.dna.species.species_traits)
				to_chat(user,"<span class='warning'>Rytuały krwi nie działają na gatunki bez krwi!</span>")
				return
			if(iscultist(H))
				if(H.stat == DEAD)
					to_chat(user,"<span class='warning'>Tylko runa wskrzeszenia może przywrócić zmarłych!</span>")
					return
				if(H.blood_volume < BLOOD_VOLUME_SAFE)
					var/restore_blood = BLOOD_VOLUME_SAFE - H.blood_volume
					if(uses*2 < restore_blood)
						H.blood_volume += uses*2
						to_chat(user,"<span class='danger'>Zużywasz resztkę rytuałów krwi, by przywrócić tyle krwi, ile się dało!</span>")
						uses = 0
						return ..()
					else
						H.blood_volume = BLOOD_VOLUME_SAFE
						uses -= round(restore_blood/2)
						to_chat(user,"<span class='warning'>Twoje rytuały krwi przywróciły [H == user ? "twoją" : "jego"] krew do bezpiecznego poziomu!</span>")
				var/overall_damage = H.getBruteLoss() + H.getFireLoss() + H.getToxLoss() + H.getOxyLoss()
				if(overall_damage == 0)
					to_chat(user,"<span class='cult'>Ten kultysta nie potrzebuje leczenia!</span>")
				else
					var/ratio = uses/overall_damage
					if(H == user)
						to_chat(user,"<span class='cult'><b>Leczenie krwią jest dużo mniej skuteczne, gdy używasz go na sobie!</b></span>")
						ratio *= 0.35 // Healing is half as effective if you can't perform a full heal
						uses -= round(overall_damage) // Healing is 65% more "expensive" even if you can still perform the full heal
					if(ratio>1)
						ratio = 1
						uses -= round(overall_damage)
						H.visible_message("<span class='warning'>[H] zostaje w pełni uleczony magią krwi!</span>")
					else
						H.visible_message("<span class='warning'>[H] zostaje częściowo uleczony magią krwi.</span>")
						uses = 0
					ratio *= -1
					H.adjustOxyLoss((overall_damage*ratio) * (H.getOxyLoss() / overall_damage), 0)
					H.adjustToxLoss((overall_damage*ratio) * (H.getToxLoss() / overall_damage), 0)
					H.adjustFireLoss((overall_damage*ratio) * (H.getFireLoss() / overall_damage), 0)
					H.adjustBruteLoss((overall_damage*ratio) * (H.getBruteLoss() / overall_damage), 0)
					H.updatehealth()
					playsound(get_turf(H), 'sound/magic/staff_healing.ogg', 25)
					new /obj/effect/temp_visual/cult/sparks(get_turf(H))
					user.Beam(H,icon_state="sendbeam",time=15)
			else
				if(H.stat == DEAD)
					to_chat(user,"<span class='warning'>Krew przestała płynąć, musisz znaleźć inny sposób, by ją pozyskać.</span>")
					return
				if(H.cultslurring)
					to_chat(user,"<span class='danger'>Krew została skażona jeszcze silniejszą magią krwi, w tej postaci jest dla nas bezużyteczna!</span>")
					return
				if(H.blood_volume > BLOOD_VOLUME_SAFE)
					H.blood_volume -= 100
					uses += 50
					user.Beam(H,icon_state="drainbeam",time=10)
					playsound(get_turf(H), 'sound/magic/enter_blood.ogg', 50)
					H.visible_message("<span class='danger'>[user] wysysa trochę krwi z [H]!</span>")
					to_chat(user,"<span class='cultitalic'>Twój rytuał krwi zyskuje 50 ładunków z krwi [H].</span>")
					new /obj/effect/temp_visual/cult/sparks(get_turf(H))
				else
					to_chat(user,"<span class='danger'>Brakuje mu już za dużo krwi - nie możesz wysysać dalej!</span>")
					return
		if(isconstruct(target))
			var/mob/living/simple_animal/M = target
			var/missing = M.maxHealth - M.health
			if(missing)
				if(uses > missing)
					M.adjustHealth(-missing)
					M.visible_message("<span class='warning'>[M] zostaje w pełni uleczony magią krwi [user]!</span>")
					uses -= missing
				else
					M.adjustHealth(-uses)
					M.visible_message("<span class='warning'>[M] zostaje częściowo uleczony magią krwi [user]!</span>")
					uses = 0
				playsound(get_turf(M), 'sound/magic/staff_healing.ogg', 25)
				user.Beam(M,icon_state="sendbeam",time=10)
		if(istype(target, /obj/effect/decal/cleanable/blood))
			blood_draw(target, user)
		..()

/obj/item/melee/blood_magic/manipulator/proc/blood_draw(atom/target, mob/living/carbon/human/user)
	var/temp = 0
	var/turf/T = get_turf(target)
	if(T)
		for(var/obj/effect/decal/cleanable/blood/B in view(2, T))
			if(B.blood_state == BLOOD_STATE_HUMAN)
				if(B.bloodiness == 100) //Bonus for "pristine" bloodpools, also to prevent cheese with footprint spam
					temp += 30
				else
					temp += max((B.bloodiness**2)/800,1)
				new /obj/effect/temp_visual/cult/turf/floor(get_turf(B))
				qdel(B)
		for(var/obj/effect/decal/cleanable/blood/trail_holder/TH in view(2, T))
			qdel(TH)
		var/obj/item/clothing/shoes/shoecheck = user.shoes
		if(shoecheck && shoecheck.bloody_shoes[/datum/reagent/blood])
			temp += shoecheck.bloody_shoes[/datum/reagent/blood]/20
			shoecheck.bloody_shoes[/datum/reagent/blood] = 0
		if(temp)
			user.Beam(T,icon_state="drainbeam",time=15)
			new /obj/effect/temp_visual/cult/sparks(get_turf(user))
			playsound(T, 'sound/magic/enter_blood.ogg', 50)
			to_chat(user, "<span class='cultitalic'>Twój rytuał krwi zyskuje [round(temp)] ładunków z okolicznych źródeł krwi!</span>")
			uses += max(1, round(temp))

/obj/item/melee/blood_magic/manipulator/attack_self(mob/living/user)
	if(iscultist(user))
		var/list/options = list("Blood Spear (150)", "Blood Bolt Barrage (300)", "Blood Beam (500)")
		var/choice = input(user, "Wybierz większy rytuał krwi.", "Większe rytuały krwi") as null|anything in options
		if(!choice)
			to_chat(user, "<span class='cultitalic'>Rezygnujesz z odprawienia większego rytuału krwi.</span>")
			return
		switch(choice)
			if("Blood Spear (150)")
				if(uses < BLOOD_SPEAR_COST)
					to_chat(user, "<span class='cultitalic'>Potrzebujesz [BLOOD_SPEAR_COST] ładunków, by odprawić ten rytuał.</span>")
				else
					uses -= BLOOD_SPEAR_COST
					var/turf/T = get_turf(user)
					qdel(src)
					var/datum/action/innate/cult/spear/S = new(user)
					var/obj/item/cult_spear/rite = new(T)
					S.Grant(user, rite)
					rite.spear_act = S
					if(user.put_in_hands(rite))
						to_chat(user, "<span class='cultitalic'>W twojej dłoni pojawia się [rite.name]!</span>")
					else
						user.visible_message("<span class='warning'>U stóp [user] pojawia się [rite.name]!</span>", \
							 "<span class='cultitalic'>U twoich stóp materializuje się [rite.name].</span>")
			if("Blood Bolt Barrage (300)")
				if(uses < BLOOD_BARRAGE_COST)
					to_chat(user, "<span class='cultitalic'>Potrzebujesz [BLOOD_BARRAGE_COST] ładunków, by odprawić ten rytuał.</span>")
				else
					var/obj/rite = new /obj/item/gun/ballistic/rifle/boltaction/enchanted/arcane_barrage/blood()
					uses -= BLOOD_BARRAGE_COST
					qdel(src)
					if(user.put_in_hands(rite))
						to_chat(user, "<span class='cult'><b>Twoje dłonie jarzą się mocą!</b></span>")
					else
						to_chat(user, "<span class='cultitalic'>Do tego rytuału potrzebujesz wolnej ręki!</span>")
						qdel(rite)
			if("Blood Beam (500)")
				if(uses < BLOOD_BEAM_COST)
					to_chat(user, "<span class='cultitalic'>Potrzebujesz [BLOOD_BEAM_COST] ładunków, by odprawić ten rytuał.</span>")
				else
					var/obj/rite = new /obj/item/blood_beam()
					uses -= BLOOD_BEAM_COST
					qdel(src)
					if(user.put_in_hands(rite))
						to_chat(user, "<span class='cultlarge'><b>Twoje dłonie jarzą się PRZYTŁACZAJĄCĄ MOCĄ!!!</b></span>")
					else
						to_chat(user, "<span class='cultitalic'>Do tego rytuału potrzebujesz wolnej ręki!</span>")
						qdel(rite)
