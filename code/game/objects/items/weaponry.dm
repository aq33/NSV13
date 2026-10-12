/obj/item/banhammer
	desc = "A banhammer."
	name = "banhammer"
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "toyhammer"
	slot_flags = ITEM_SLOT_BELT
	throwforce = 0
	force = 1
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7
	attack_verb = list("banuje")
	max_integrity = 200
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 70, "stamina" = 0)
	resistance_flags = FIRE_PROOF

/obj/item/banhammer/suicide_act(mob/user)
		user.visible_message("<span class='suicide'>[user] okłada się [src]! Wygląda na to, że próbuje zbanować się z życia.</span>")
		return (BRUTELOSS|FIRELOSS|TOXLOSS|OXYLOSS)
/*
oranges says: This is a meme relating to the english translation of the ss13 russian wiki page on lurkmore.
mrdoombringer sez: and remember kids, if you try and PR a fix for this item's grammar, you are admitting that you are, indeed, a newfriend.
for further reading, please see: https://github.com/tgstation/tgstation/pull/30173 and https://translate.google.com/translate?sl=auto&tl=en&js=y&prev=_t&hl=en&ie=UTF-8&u=%2F%2Flurkmore.to%2FSS13&edit-text=&act=url
*/
/obj/item/banhammer/attack(mob/M, mob/user)
	if(user.zone_selected == BODY_ZONE_HEAD)
		M.visible_message("<span class='danger'>[user] głaszcze [M] po głowie banhammerem</span>", "<span class='userdanger'>[user] głaszcze głowę banhammerem</span>", "słyszysz, jak banhammer głaszcze czyjąś głowę");
	else
		M.visible_message("<span class='danger'>[user] banuje [M] BEZ POWODU</span>", "<span class='userdanger'>[user] banuje cię BEZ POWODU</span>", "słyszysz, jak banhammer kogoś banuje")
	playsound(loc, 'sound/effects/adminhelp.ogg', 15) //keep it at 15% volume so people don't jump out of their skin too much
	if(user.combat_mode)
		return ..(M, user)

/obj/item/sord
	name = "\improper SORD"
	desc = "This thing is so unspeakably shitty you are having a hard time even holding it."
	icon_state = "sord"
	item_state = "sord"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	slot_flags = ITEM_SLOT_BELT
	force = 2
	throwforce = 1
	block_upgrade_walk = 1
	w_class = WEIGHT_CLASS_NORMAL
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("atakuje", "ciacha", "dźga", "kroi", "rozdziera", "rozrywa", "sieka", "tnie")

/obj/item/sord/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] próbuje nadziać się na [src]! Byłaby to próba samobójcza, gdyby nie było to takie kiepskie.</span>", \
	"<span class='suicide'>Próbujesz nadziać się na [src], ale to BEZUŻYTECZNE...</span>")
	return SHAME

/obj/item/sord/on_block(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", damage = 0, attack_type = MELEE_ATTACK)
	if(isitem(hitby))
		var/obj/item/I = hitby
		owner.attackby(src)
		owner.attackby(src, owner)
		owner.visible_message("<span class='danger'>[owner] nie może złapać pewnego chwytu i, próbując sparować [I], dźga się zarówno [I], jak i [src]!</span>")
	return ..()

/obj/item/claymore
	name = "claymore"
	desc = "What are you standing around staring at this for? Get to killing!"
	icon_state = "claymore"
	item_state = "claymore"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	hitsound = 'sound/weapons/bladeslice.ogg'
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT | ITEM_SLOT_BACK
	force = 40
	throwforce = 10
	w_class = WEIGHT_CLASS_NORMAL
	attack_weight = 1
	attack_verb = list("atakuje", "ciacha", "dźga", "kroi", "rozdziera", "rozrywa", "sieka", "tnie")
	block_power = 40
	block_upgrade_walk = 1
	block_level = 1
	block_flags = BLOCKING_ACTIVE | BLOCKING_NASTY
	sharpness = IS_SHARP
	max_integrity = 200
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 50, "stamina" = 0)
	resistance_flags = FIRE_PROOF

/obj/item/claymore/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/butchering, 40, 105)

/obj/item/claymore/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] rzuca się na [src]! Wygląda na to, że próbuje popełnić samobójstwo!</span>")
	return(BRUTELOSS)

/obj/item/claymore/highlander //ALL COMMENTS MADE REGARDING THIS SWORD MUST BE MADE IN ALL CAPS
	desc = "<b><i>THERE CAN BE ONLY ONE, AND IT WILL BE YOU!!!</i></b>\nActivate it in your hand to point to the nearest victim."
	flags_1 = CONDUCT_1
	item_flags = DROPDEL
	slot_flags = null
	light_range = 3
	attack_verb = list("brutalnie traktuje", "wypatrosza", "wypatrosza", "siecze", "rzeźbi w", "rozłupuje") //ONLY THE MOST VISCERAL ATTACK VERBS
	var/notches = 0 //HOW MANY PEOPLE HAVE BEEN SLAIN WITH THIS BLADE
	var/obj/item/disk/nuclear/nuke_disk //OUR STORED NUKE DISK

/obj/item/claymore/highlander/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, HIGHLANDER)
	START_PROCESSING(SSobj, src)

/obj/item/claymore/highlander/Destroy()
	if(nuke_disk)
		nuke_disk.forceMove(get_turf(src))
		nuke_disk.visible_message("<span class='warning'>Dysk nuklearny jest zagrożony!</span>")
		nuke_disk = null
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/claymore/highlander/process()
	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		loc.layer = LARGE_MOB_LAYER //NO HIDING BEHIND PLANTS FOR YOU, DICKWEED (HA GET IT, BECAUSE WEEDS ARE PLANTS)
		H.bleedsuppress = TRUE //AND WE WON'T BLEED OUT LIKE COWARDS
	else
		if(!(flags_1 & ADMIN_SPAWNED_1))
			qdel(src)


/obj/item/claymore/highlander/pickup(mob/living/user)
	..()
	to_chat(user, "<span class='notice'>Chroni cię moc Szkocji! Jesteś odporny na wszelkie ogłuszenia i powalenia.</span>")
	user.add_stun_absorption("highlander", INFINITY, 1, " chroni moc Szkocji!", "Moc Szkocji pochłania ogłuszenie!", " chroni moc Szkocji!")
	user.ignore_slowdown(HIGHLANDER)

/obj/item/claymore/highlander/dropped(mob/living/user)
	..()
	user.unignore_slowdown(HIGHLANDER)
	if(!QDELETED(src))
		qdel(src) //If this ever happens, it's because you lost an arm

/obj/item/claymore/highlander/examine(mob/user)
	. = ..()
	. += "Na ostrzu [!notches ? "nie ma żadnych nacięć" : "wyryto nacięć: [notches]"]."
	if(nuke_disk)
		. += "<span class='boldwarning'>Trzyma dysk nuklearny!</span>"

/obj/item/claymore/highlander/attack(mob/living/target, mob/living/user)
	. = ..()
	if(!QDELETED(target) && iscarbon(target) && target.stat == DEAD && target.mind && target.mind.special_role == "highlander")
		user.fully_heal() //STEAL THE LIFE OF OUR FALLEN FOES
		add_notch(user)
		target.visible_message("<span class='warning'>[target] rozsypuje się w proch pod ciosami [user]!</span>", "<span class='userdanger'>Gdy upadasz, twoje ciało rozsypuje się w proch!</span>")
		target.dust()

/obj/item/claymore/highlander/attack_self(mob/living/user)
	var/closest_victim
	var/closest_distance = 255
	for(var/mob/living/carbon/human/H in GLOB.player_list - user)
		if(H.client && H.mind.special_role == "highlander" && (!closest_victim || get_dist(user, closest_victim) < closest_distance))
			closest_victim = H
	if(!closest_victim)
		to_chat(user, "<span class='warning'>[src] przez chwilę buczy, po czym gaśnie. Może w pobliżu nikogo nie ma.</span>")
		return
	to_chat(user, "<span class='danger'>[src] buczy i wskazuje kierunek: [dir2text(get_dir(user, closest_victim))].</span>")

/obj/item/claymore/highlander/IsReflect()
	return 1 //YOU THINK YOUR PUNY LASERS CAN STOP ME?

/obj/item/claymore/highlander/proc/add_notch(mob/living/user) //DYNAMIC CLAYMORE PROGRESSION SYSTEM - THIS IS THE FUTURE
	notches++
	force++
	var/new_name = name
	switch(notches)
		if(1)
			to_chat(user, "<span class='notice'>Twoje pierwsze zabójstwo - oby jedno z wielu. Wycinasz nacięcie na ostrzu [src].</span>")
			to_chat(user, "<span class='warning'>Czujesz, jak dusza pokonanego wroga wnika w twoje ostrze, lecząc twoje rany!</span>")
			new_name = "notched claymore"
		if(2)
			to_chat(user, "<span class='notice'>Kolejny pada przed tobą. Kolejna dusza łączy się z twoją. Kolejne nacięcie na ostrzu.</span>")
			new_name = "double-notched claymore"
			add_atom_colour(rgb(255, 235, 235), ADMIN_COLOUR_PRIORITY)
		if(3)
			to_chat(user, "<span class='notice'>Zaczynasz</span> <span class='danger'><b>rozkoszować się</b> <b>dreszczem</b> <b>bitwy.</b></span>")
			new_name = "triple-notched claymore"
			add_atom_colour(rgb(255, 215, 215), ADMIN_COLOUR_PRIORITY)
		if(4)
			to_chat(user, "<span class='notice'>Straciłeś rachubę</span> <span class='boldannounce'>tego, ilu zabiłeś.</span>")
			new_name = "many-notched claymore"
			add_atom_colour(rgb(255, 195, 195), ADMIN_COLOUR_PRIORITY)
		if(5)
			to_chat(user, "<span class='boldannounce'>W twoim umyśle rozbrzmiewa już pięć głosów, wiwatujących na cześć rzezi.</span>")
			new_name = "battle-tested claymore"
			add_atom_colour(rgb(255, 175, 175), ADMIN_COLOUR_PRIORITY)
		if(6)
			to_chat(user, "<span class='boldannounce'>Czy tak czuli się wikingowie? Gdy zabijasz szóstego wroga, twoją głowę wypełniają wizje chwały.</span>")
			new_name = "battle-scarred claymore"
			add_atom_colour(rgb(255, 155, 155), ADMIN_COLOUR_PRIORITY)
		if(7)
			to_chat(user, "<span class='boldannounce'>Zabijaj. Rzeź. <i>Podbijaj.</i></span>")
			new_name = "vicious claymore"
			add_atom_colour(rgb(255, 135, 135), ADMIN_COLOUR_PRIORITY)
		if(8)
			to_chat(user, "<span class='userdanger'>TO SIĘ NIGDY NIE NUDZI. <i>WRZASKI</i>. <i>KREW</i>, KTÓRA <i>TRYSKA</i> CI NA <i>TWARZ.</i></span>")
			new_name = "bloodthirsty claymore"
			add_atom_colour(rgb(255, 115, 115), ADMIN_COLOUR_PRIORITY)
		if(9)
			to_chat(user, "<span class='userdanger'>KOLEJNY PADA OD TWOICH CIOSÓW. KOLEJNY SŁABEUSZ NIEGODNY ŻYCIA.</span>")
			new_name = "gore-stained claymore"
			add_atom_colour(rgb(255, 95, 95), ADMIN_COLOUR_PRIORITY)
		if(10)
			user.visible_message("<span class='warning'>Oczy [user] rozpalają się mściwym ogniem!</span>", \
			"<span class='userdanger'>CZUJESZ, JAK PRZEPŁYWA PRZEZ CIEBIE MOC WALHALLI! <i>MOŻE BYĆ TYLKO JEDEN!!!</i></span>")
			user.update_icons()
			new_name = "GORE-DRENCHED CLAYMORE OF [pick("THE WHIMSICAL SLAUGHTER", "A THOUSAND SLAUGHTERED CATTLE", "GLORY AND VALHALLA", "ANNIHILATION", "OBLITERATION")]"
			icon_state = "claymore_valhalla"
			item_state = "cultblade"
			remove_atom_colour(ADMIN_COLOUR_PRIORITY)

	name = new_name
	playsound(user, 'sound/items/screwdriver2.ogg', 50, 1)

/obj/item/claymore/bone
	name = "Bone Sword"
	desc = "Jagged pieces of bone are tied to what looks like a goliaths femur."
	icon_state = "bone_sword"
	item_state = "bone_sword"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	slot_flags = ITEM_SLOT_BELT | ITEM_SLOT_BACK
	force = 15
	throwforce = 10
	armour_penetration = 15
	w_class = WEIGHT_CLASS_NORMAL
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("atakuje", "ciacha", "dźga", "kroi", "rozdziera", "rozrywa", "sieka", "tnie")
	block_level = 0
	block_power = 30
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 50, "stamina" = 0)

/obj/item/katana
	name = "katana"
	desc = "Woefully underpowered in D20."
	icon_state = "katana"
	item_state = "katana"
	worn_icon_state = "katana"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT | ITEM_SLOT_BACK
	force = 40
	throwforce = 10
	w_class = WEIGHT_CLASS_HUGE
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("atakuje", "ciacha", "dźga", "kroi", "rozdziera", "rozrywa", "sieka", "tnie")
	block_power = 20
	block_level = 1
	block_upgrade_walk = 1
	block_flags = BLOCKING_ACTIVE | BLOCKING_NASTY | BLOCKING_PROJECTILE
	sharpness = IS_SHARP
	max_integrity = 200
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 50, "stamina" = 0)
	resistance_flags = FIRE_PROOF

/obj/item/katana/cursed
	slot_flags = null

/obj/item/katana/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] rozcina sobie brzuch [src]! Wygląda na to, że próbuje popełnić seppuku!</span>")
	return(BRUTELOSS)

/obj/item/wirerod
	name = "wired rod"
	desc = "A rod with some wire wrapped around the top. It'd be easy to attach something to the top bit."
	icon_state = "wiredrod"
	item_state = "rods"
	flags_1 = CONDUCT_1
	force = 9
	throwforce = 10
	w_class = WEIGHT_CLASS_NORMAL
	materials = list(/datum/material/iron=1150, /datum/material/glass=75)
	attack_verb = list("uderza", "tłucze", "wali", "bonkuje")

/obj/item/wirerod/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/shard))
		var/obj/item/spear/S = new /obj/item/spear

		remove_item_from_storage(user)
		if (!user.transferItemToLoc(I, S))
			return
		S.CheckParts(list(I))
		qdel(src)

		user.put_in_hands(S)
		to_chat(user, "<span class='notice'>Mocujesz odłamek szkła kablem na czubku pręta.</span>")

	else if(istype(I, /obj/item/assembly/igniter) && !(HAS_TRAIT(I, TRAIT_NODROP)))
		var/obj/item/melee/baton/cattleprod/P = new /obj/item/melee/baton/cattleprod

		remove_item_from_storage(user)

		to_chat(user, "<span class='notice'>Mocujesz [I] kablem na czubku pręta.</span>")

		qdel(I)
		qdel(src)

		user.put_in_hands(P)
	else
		return ..()


/obj/item/throwing_star
	name = "throwing star"
	desc = "An ancient weapon still used to this day, due to its ease of lodging itself into its victim's body parts."
	icon_state = "throwingstar"
	item_state = "eshield0"
	lefthand_file = 'icons/mob/inhands/equipment/shields_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/shields_righthand.dmi'
	force = 2
	throwforce = 24
	throw_speed = 4
	embedding = list("pain_mult" = 4, "embed_chance" = 300, "fall_chance" = 0, "armour_block" = 70)
	armour_penetration = 40
	w_class = WEIGHT_CLASS_SMALL
	hitsound = 'sound/weapons/bladeslice.ogg'
	sharpness = IS_SHARP
	materials = list(/datum/material/iron=500, /datum/material/glass=500)
	resistance_flags = FIRE_PROOF

/obj/item/throwing_star/stamina
	name = "shock throwing star"
	desc = "An aerodynamic disc designed to cause excruciating pain when stuck inside fleeing targets, hopefully without causing fatal harm."
	throwforce = 5
	embedding = list("pain_chance" = 5, "embed_chance" = 300, "fall_chance" = 0, "jostle_chance" = 10, "pain_stam_pct" = 0.8, "jostle_pain_mult" = 3, "armour_block" = 70)

/obj/item/throwing_star/toy
	name = "toy throwing star"
	desc = "An aerodynamic disc strapped with adhesive for sticking to people, good for playing pranks and getting yourself killed by security."
	sharpness = IS_BLUNT
	force = 0
	throwforce = 0
	embedding = list("pain_mult" = 0, "jostle_pain_mult" = 0, "embed_chance" = 300, "fall_chance" = 0, "armour_block" = 70)

/obj/item/throwing_star/magspear
	name = "magnetic spear"
	desc = "A reusable spear that is typically loaded into kinetic spearguns."
	icon = 'icons/obj/ammo.dmi'
	icon_state = "magspear"
	throwforce = 40
	force = 15 //can be used in melee- a speargun user may be beat to death with their own spear
	w_class = WEIGHT_CLASS_BULKY
	hitsound = 'sound/weapons/bladeslice.ogg'
	throw_range = 0 //throwing these invalidates the speargun
	attack_verb = list("dźga", "rozrywa", "bodzie", "nadziewa")
	embedding = list("pain_mult" = 8, "embed_chance" = 1000, "fall_chance" = 0, "armour_block" = 100)

/obj/item/switchblade
	name = "long switchblade"
	icon_state = "switchblade"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	desc = "A sharp, concealable, spring-loaded knife with a long blade."
	flags_1 = CONDUCT_1
	force = 3
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 5
	throw_speed = 3
	throw_range = 6
	materials = list(/datum/material/iron=12000)
	hitsound = 'sound/weapons/genhit.ogg'
	attack_verb = list("przytyka", "szturcha")
	resistance_flags = FIRE_PROOF
	var/extended = 0
	var/extended_force = 20
	var/extended_throwforce = 23
	var/extended_icon_state = "switchblade_ext"

/obj/item/switchblade/attack_self(mob/user)
	extended = !extended
	playsound(src.loc, 'sound/weapons/batonextend.ogg', 50, 1)
	if(extended)
		force = extended_force
		w_class = WEIGHT_CLASS_NORMAL
		throwforce = extended_throwforce
		icon_state = extended_icon_state
		attack_verb = list("ciacha", "dźga", "kroi", "rozdziera", "rozrywa", "sieka", "tnie")
		hitsound = 'sound/weapons/bladeslice.ogg'
		sharpness = IS_SHARP
	else
		force = initial(force)
		w_class = WEIGHT_CLASS_SMALL
		throwforce = initial(throwforce)
		icon_state = initial(icon_state)
		attack_verb = list("przytyka", "szturcha")
		hitsound = 'sound/weapons/genhit.ogg'
		sharpness = IS_BLUNT

/obj/item/switchblade/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] podrzyna sobie gardło [src]! Wygląda na to, że próbuje popełnić samobójstwo!</span>")
	return (BRUTELOSS)

/obj/item/switchblade/kitchen
	name = "iron switchblade"
	icon_state = "switchblade_ms"
	desc = "A concealable spring-loaded knife with an iron blade."
	force = 2
	throwforce = 3
	extended_force = 12
	extended_throwforce = 15
	extended_icon_state = "switchblade_ext_ms"

/obj/item/switchblade/plastitanium
	name = "plastitanium switchblade"
	icon_state = "switchblade_msf"
	desc = "A concealable spring-loaded knife with a plastitanium blade."
	force = 3
	throwforce = 4
	extended_force = 15
	extended_throwforce = 17
	extended_icon_state = "switchblade_ext_msf"

/obj/item/phone
	name = "red phone"
	desc = "Should anything ever go wrong..."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "red_phone"
	force = 3
	throwforce = 2
	throw_speed = 3
	throw_range = 4
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("woła", "dzwoni na")
	hitsound = 'sound/weapons/ring.ogg'

/obj/item/phone/suicide_act(mob/user)
	if(locate(/obj/structure/chair/stool) in user.loc)
		user.visible_message("<span class='suicide'>[user] zaczyna wiązać pętlę z przewodu [src]! Wygląda na to, że próbuje popełnić samobójstwo!</span>")
	else
		user.visible_message("<span class='suicide'>[user] dusi się przewodem [src]! Wygląda na to, że próbuje popełnić samobójstwo!</span>")
	return(OXYLOSS)

/obj/item/cane
	name = "cane"
	desc = "A cane used by a true gentleman. Or a clown."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "cane"
	item_state = "stick"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	block_upgrade_walk = 1
	force = 5
	throwforce = 5
	w_class = WEIGHT_CLASS_SMALL
	materials = list(/datum/material/iron=50)
	attack_verb = list("tłucze", "wali", "dyscyplinuje", "młóci")

/obj/item/staff
	name = "wizard staff"
	desc = "Apparently a staff used by the wizard."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "staff"
	lefthand_file = 'icons/mob/inhands/weapons/staves_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/staves_righthand.dmi'
	block_upgrade_walk = 1
	force = 3
	throwforce = 5
	throw_speed = 2
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	armour_penetration = 100
	attack_verb = list("tłucze", "wali", "dyscyplinuje")
	resistance_flags = FLAMMABLE

/obj/item/staff/broom
	name = "broom"
	desc = "Used for sweeping, and flying into the night while cackling. Black cat not included."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "broom"
	resistance_flags = FLAMMABLE

/obj/item/staff/stick
	name = "stick"
	desc = "A great tool to drag someone else's drinks across the bar."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "cane"
	item_state = "stick"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	force = 3
	throwforce = 5
	throw_speed = 2
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL

/obj/item/ectoplasm
	name = "ectoplasm"
	desc = "Spooky."
	gender = PLURAL
	icon = 'icons/obj/wizard.dmi'
	icon_state = "ectoplasm"

/obj/item/ectoplasm/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] wdycha [src]! Wygląda na to, że próbuje odwiedzić plan astralny!</span>")
	return (OXYLOSS)

/obj/item/ectoplasm/angelic
	icon = 'icons/obj/wizard.dmi'
	icon_state = "angelplasm"

/obj/item/mounted_chainsaw
	name = "mounted chainsaw template"
	desc = "A chainsaw that has replaced your arm."
	icon_state = "chainsaw_on"
	item_state = "mounted_chainsaw"
	lefthand_file = 'icons/mob/inhands/weapons/chainsaw_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/chainsaw_righthand.dmi'
	item_flags = ABSTRACT | DROPDEL
	w_class = WEIGHT_CLASS_HUGE
	block_upgrade_walk = 2
	block_power = 20
	block_flags = BLOCKING_ACTIVE | BLOCKING_NASTY
	force = 24
	attack_weight = 2
	throwforce = 0
	throw_range = 0
	throw_speed = 0
	sharpness = IS_SHARP
	attack_verb = list("piłuje", "rozdziera", "tnie", "rąbie", "sieka")
	hitsound = 'sound/weapons/chainsawhit.ogg'
	tool_behaviour = TOOL_SAW
	toolspeed = 1

/obj/item/mounted_chainsaw/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT)

/obj/item/mounted_chainsaw/normal
	name = "mounted chainsaw"

/obj/item/mounted_chainsaw/normal/Destroy()
	var/obj/item/bodypart/part
	new /obj/item/chainsaw(get_turf(src))
	if(iscarbon(loc))
		var/mob/living/carbon/holder = loc
		var/index = holder.get_held_index_of_item(src)
		if(index)
			part = holder.hand_bodyparts[index]
	. = ..()
	if(part)
		part.drop_limb()

/obj/item/mounted_chainsaw/energy
	name = "mounted energy chainsaw"
	desc = "An energy chainsaw that has replaced your arm."
	force = 40
	armour_penetration = 50
	hitsound = 'sound/weapons/echainsawhit1.ogg'

/obj/item/mounted_chainsaw/energy/Destroy()
	var/obj/item/bodypart/part
	new /obj/item/chainsaw/energy(get_turf(src))
	if(iscarbon(loc))
		var/mob/living/carbon/holder = loc
		var/index = holder.get_held_index_of_item(src)
		if(index)
			part = holder.hand_bodyparts[index]
	. = ..()
	if(part)
		part.drop_limb()

/obj/item/mounted_chainsaw/super
	name = "mounted super energy chainsaw"
	desc = "A super energy chainsaw that has replaced your arm."
	force = 60
	armour_penetration = 75
	hitsound = 'sound/weapons/echainsawhit1.ogg'

/obj/item/mounted_chainsaw/super/Destroy()
	var/obj/item/bodypart/part
	new /obj/item/chainsaw/energy/doom(get_turf(src))
	if(iscarbon(loc))
		var/mob/living/carbon/holder = loc
		var/index = holder.get_held_index_of_item(src)
		if(index)
			part = holder.hand_bodyparts[index]
	. = ..()
	if(part)
		part.drop_limb()

/obj/item/mounted_chainsaw/super/attack(mob/living/target)
	..()
	target.Knockdown(4)

/obj/item/statuebust
	name = "bust"
	desc = "A priceless ancient marble bust, the kind that belongs in a museum." //or you can hit people with it
	icon = 'icons/obj/statue.dmi'
	icon_state = "bust"
	force = 15
	attack_weight = 2
	throwforce = 10
	throw_speed = 5
	throw_range = 2
	attack_verb = list("rozwala")

/obj/item/statuebust/hippocratic
	name = "hippocrates bust"
	desc = "A bust of the famous Greek physician Hippocrates of Kos, often referred to as the father of western medicine."
	icon_state = "hippocratic"

/obj/item/melee/chainofcommand/tailwhip
	name = "liz o' nine tails"
	desc = "A whip fashioned from the severed tails of lizards."
	icon_state = "tailwhip"
	item_flags = NONE

/obj/item/melee/chainofcommand/tailwhip/kitty
	name = "cat o' nine tails"
	desc = "A whip fashioned from the severed tails of cats."
	icon_state = "catwhip"

/obj/item/melee/skateboard
	name = "improvised skateboard"
	desc = "A skateboard. It can be placed on its wheels and ridden, or used as a strong weapon."
	icon_state = "skateboard"
	item_state = "skateboard"
	block_upgrade_walk = 1
	force = 12
	throwforce = 4
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb = list("trzepie", "wali", "grzmoci", "rozbija")
	///The vehicle counterpart for the board
	var/board_item_type = /obj/vehicle/ridden/scooter/skateboard

/obj/item/melee/skateboard/attack_self(mob/user)
	var/obj/vehicle/ridden/scooter/skateboard/S = new board_item_type(get_turf(user))//this probably has fucky interactions with telekinesis but for the record it wasn't my fault
	S.buckle_mob(user)
	qdel(src)

/obj/item/melee/skateboard/pro
	name = "skateboard"
	desc = "A RaDSTORMz brand professional skateboard. It looks sturdy and well made."
	icon_state = "skateboard2"
	item_state = "skateboard2"
	board_item_type = /obj/vehicle/ridden/scooter/skateboard/pro
	custom_premium_price = 300

/obj/item/melee/skateboard/hoverboard
	name = "hoverboard"
	desc = "A blast from the past, so retro!"
	icon_state = "hoverboard_red"
	item_state = "hoverboard_red"
	board_item_type = /obj/vehicle/ridden/scooter/skateboard/hoverboard
	custom_premium_price = 2015

/obj/item/melee/skateboard/hoverboard/admin
	name = "\improper Board Of Directors"
	desc = "The engineering complexity of a spaceship concentrated inside of a board. Just as expensive, too."
	icon_state = "hoverboard_nt"
	item_state = "hoverboard_nt"
	board_item_type = /obj/vehicle/ridden/scooter/skateboard/hoverboard/admin

/obj/item/melee/baseball_bat
	name = "baseball bat"
	desc = "There ain't a skull in the league that can withstand a swatter."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "baseball_bat"
	item_state = "baseball_bat"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	block_upgrade_walk = 1
	attack_weight = 2
	force = 13
	throwforce = 6
	attack_verb = list("bije", "trzepie")
	w_class = WEIGHT_CLASS_HUGE
	var/homerun_ready = 0
	var/homerun_able = 0
	var/click_delay = 2

/obj/item/melee/baseball_bat/homerun
	name = "home run bat"
	desc = "This thing looks dangerous... Dangerously good at baseball, that is."
	homerun_able = 1

/obj/item/melee/baseball_bat/attack_self(mob/user)
	if(!homerun_able)
		..()
		return
	if(homerun_ready)
		to_chat(user, "<span class='notice'>Już jesteś gotowy na home run!</span>")
		..()
		return
	to_chat(user, "<span class='warning'>Zaczynasz zbierać siły...</span>")
	playsound(get_turf(src), 'sound/magic/lightning_chargeup.ogg', 65, 1)
	if(do_after(user, 90, target = src))
		to_chat(user, "<span class='userdanger'>Zbierasz moc! Czas na home run!</span>")
		homerun_ready = 1
	..()

/obj/item/melee/baseball_bat/attack(mob/living/target, mob/living/user)
	. = ..()
	var/atom/throw_target = get_edge_target_turf(target, user.dir)
	if(homerun_ready)
		user.visible_message("<span class='userdanger'>Home run!</span>")
		target.throw_at(throw_target, rand(8,10), 14, user)
		SSexplosions.medturf += throw_target
		playsound(get_turf(src), 'sound/weapons/homerun.ogg', 100, 1)
		homerun_ready = 0
		return
	else if(!target.anchored)
		target.throw_at(throw_target, rand(1,2), 7, user, force = MOVE_FORCE_WEAK)
	user.changeNext_move(CLICK_CD_MELEE * click_delay)
	return


/obj/item/melee/baseball_bat/ablative
	name = "metal baseball bat"
	desc = "This bat is made of highly reflective, highly armored material."
	icon_state = "baseball_bat_metal"
	item_state = "baseball_bat_metal"
	block_flags = BLOCKING_ACTIVE | BLOCKING_NASTY | BLOCKING_PROJECTILE
	block_level = 1
	force = 12
	throwforce = 15

/obj/item/melee/baseball_bat/ablative/IsReflect()//some day this will reflect thrown items instead of lasers
	var/picksound = rand(1,2)
	var/turf = get_turf(src)
	if(picksound == 1)
		playsound(turf, 'sound/weapons/effects/batreflect1.ogg', 50, 1)
	if(picksound == 2)
		playsound(turf, 'sound/weapons/effects/batreflect2.ogg', 50, 1)
	return 1

/obj/item/melee/flyswatter
	name = "flyswatter"
	desc = "Useful for killing insects of all sizes."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "flyswatter"
	item_state = "flyswatter"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	force = 1
	throwforce = 1
	attack_verb = list("pacnięciem trąca", "trzepie")
	hitsound = 'sound/effects/snap.ogg'
	w_class = WEIGHT_CLASS_SMALL
	//Things in this list will be instantly splatted.  Flyman weakness is handled in the flyman species weakness proc.
	var/list/strong_against

/obj/item/melee/flyswatter/Initialize(mapload)
	. = ..()
	strong_against = typecacheof(list(
					/mob/living/simple_animal/hostile/poison/bees/,
					/mob/living/simple_animal/butterfly,
					/mob/living/simple_animal/cockroach,
					/obj/item/queen_bee
	))


/obj/item/melee/flyswatter/afterattack(atom/target, mob/user, proximity_flag)
	. = ..()
	if(proximity_flag)
		if(is_type_in_typecache(target, strong_against))
			new /obj/effect/decal/cleanable/insectguts(target.drop_location())
			to_chat(user, "<span class='warning'>Bez trudu rozpłaszczasz [target].</span>")
			if(istype(target, /mob/living/))
				var/mob/living/bug = target
				bug.death(1)
			else
				qdel(target)

/obj/item/circlegame
	name = "circled hand"
	desc = "If somebody looks at this while it's below your waist, you get to bop them."
	icon_state = "madeyoulook"
	force = 0
	throwforce = 0
	item_flags = DROPDEL | ABSTRACT
	attack_verb = list("pstryka")

/obj/item/slapper
	name = "slapper"
	desc = "This is how real men fight."
	icon_state = "latexballon"
	item_state = "nothing"
	force = 0
	throwforce = 0
	item_flags = DROPDEL | ABSTRACT
	attack_verb = list("policzkuje")
	hitsound = 'sound/effects/snap.ogg'
	/// How many smaller table smacks we can do before we're out
	var/table_smacks_left = 3

/obj/item/slapper/attack(mob/living/M, mob/living/carbon/human/user)
	if(ishuman(M))
		var/mob/living/carbon/human/L = M
		if(L && L.dna && L.dna.species)
			L.dna.species.stop_wagging_tail(M)
	user.do_attack_animation(M)

	var/slap_volume = 50
	if(user.zone_selected == BODY_ZONE_HEAD || user.zone_selected == BODY_ZONE_PRECISE_MOUTH)
		user.visible_message("<span class='danger'>[user] daje [M] w twarz!</span>",
			"<span class='notice'>Dajesz [M] w twarz!</span>",
			"<span class='hear'>Słyszysz plaśnięcie.</span>")
	else
		user.visible_message("<span class='danger'>[user] slaps [M]!</span>",
			"<span class='notice'>Dajesz [M] klapsa!</span>",
			"<span class='hear'>Słyszysz plaśnięcie.</span>")
	playsound(M, 'sound/weapons/slap.ogg', slap_volume, TRUE, -1)
	return

/obj/item/slapper/afterattack(atom/target, mob/living/user, proximity_flag, click_parameters)
	if(!istype(target, /obj/structure/table))
		return ..()

	var/obj/structure/table/the_table = target

	if(!proximity_flag)
		return

	if(user.combat_mode && table_smacks_left == initial(table_smacks_left)) // so you can't do 2 weak slaps followed by a big slam
		transform = transform.Scale(5) // BIG slap
		if(HAS_TRAIT(user, TRAIT_HULK))
			transform = transform.Scale(2)
			color = COLOR_GREEN
			user.do_attack_animation(the_table)
			//Uncomment if we ever port table slam signals
			//SEND_SIGNAL(user, COMSIG_LIVING_SLAM_TABLE, the_table)
			//SEND_SIGNAL(the_table, COMSIG_TABLE_SLAMMED, user)
			playsound(get_turf(the_table), 'sound/effects/tableslam.ogg', 110, TRUE)
			user.visible_message("<b><span class='danger'>[user] wali pięścią w [the_table]!</span></b>", "<b><span class='danger'>Walisz pięścią w [the_table]!</span></b>")
			qdel(src)
		//NSV13 CHANGE BEGIN - BONE SHATTERING FIST
		else
			user.do_attack_animation(the_table)
			//Uncomment if we ever port table slam signals
			//SEND_SIGNAL(user, COMSIG_LIVING_SLAM_TABLE, the_table)
			//SEND_SIGNAL(the_table, COMSIG_TABLE_SLAMMED, user)
			var/mob/living/carbon/victim = user
			var/obj/item/bodypart/affecting = victim.get_bodypart("[(user.active_hand_index % 2 == 0) ? "r" : "l" ]_arm")
			if(affecting)
				if(prob(50))
					victim.update_damage_overlays()
					playsound(get_turf(the_table), 'sound/effects/snap.ogg', 110, TRUE)
					user.visible_message("<b><span class='danger'>[user] wali pięścią w [the_table] i krzyczy z bólu!</span></b>", "<b><span class='danger'>Walisz pięścią w [the_table] i czujesz, jak ręka krzyczy z bólu!!</span></b>")
					affecting.receive_damage(0, 0, 50)
					qdel(src)
				else
					victim.update_damage_overlays()
					playsound(get_turf(the_table), 'sound/effects/snap.ogg', 110, TRUE)
					user.visible_message("<b><span class='danger'>[user] wali pięścią w [the_table] i się krzywi!</span></b>", "<b><span class='danger'>Walisz pięścią w [the_table] i czujesz piekący ból w ręce!</span></b>")
					affecting.receive_damage(0, 0, 25)
					qdel(src)
		//NSV13 END
	else
		user.do_attack_animation(the_table)
		playsound(get_turf(the_table), 'sound/effects/tableslam.ogg', 40, TRUE)
		user.visible_message("<span class='notice'>[user] kładzie dłoń z plaśnięciem na [the_table].</span>", "<span class='notice'>Kładziesz dłoń z plaśnięciem na [the_table].</span>", vision_distance=COMBAT_MESSAGE_RANGE)
		table_smacks_left--
		if(table_smacks_left <= 0)
			qdel(src)

/obj/item/proc/can_trigger_gun(mob/living/user)
	if(!user.can_use_guns(src))
		return FALSE
	return TRUE

/obj/item/extendohand
	name = "extendo-hand"
	desc = "Futuristic tech has allowed these classic spring-boxing toys to essentially act as a fully functional hand-operated hand prosthetic."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "extendohand"
	item_state = "extendohand"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	force = 0
	throwforce = 5
	reach = 2

/obj/item/extendohand/acme
	name = "\improper ACME Extendo-Hand"
	desc = "A novelty extendo-hand produced by the ACME corporation. Originally designed to knock out roadrunners."

/obj/item/extendohand/attack(atom/M, mob/living/carbon/human/user, params)
	var/dist = get_dist(M, user)
	if(dist < reach)
		to_chat(user, "<span class='warning'>[M] jest za blisko, by użyć na nim [src].</span>")
		return
	var/list/modifiers = params2list(params)
	M.attack_hand(user, modifiers)


/obj/item/highfive
	name = "raised hand"
	desc = "Slap my hand."
	icon_state = "latexballon"
	item_state = "nothing"
	hitsound = 'sound/weapons/punchmiss.ogg'
	force = 0
	throwforce = 0
	item_flags = DROPDEL | ABSTRACT
	attack_verb = list("zostawia bez przybicia piątki")

/obj/item/highfive/attack(mob/target, mob/user)
	if(target == user)
		to_chat(user, "<span class='notice'>Nie przybijesz piątki sam sobie! Znajdź przyjaciela!</span>")
	else if(ishuman(target) && (target.stat == CONSCIOUS) && (istype(target.get_active_held_item(), /obj/item/highfive)) )
		var/obj/item/highfive/downlow = target.get_active_held_item()
		user.visible_message("[user] i [target] przybijają piątkę!", "<span class='notice'>Przybijasz piątkę z [target]!</span>", "<span class='italics'>Słyszysz plaśnięcie!</span>")
		user.do_attack_animation(target)
		target.do_attack_animation(user)
		playsound(src, 'sound/weapons/punch2.ogg', 50, 0)
		qdel(src)
		qdel(downlow)
	else
		user.visible_message("[target] zostawia [user] bez przybicia piątki.", "<span class='notice'>[target] zostawia cię bez przybicia piątki.</span>")
		playsound(src, 'sound/weapons/punchmiss.ogg', 50, 0)

/obj/item/club
	name = "Billy club"
	desc = "Used to bash heads and break down defenses."
	icon_state = "billyclub"
	item_state = "classic_baton"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	force = 10
	throwforce = 5
	attack_verb = list("pałuje", "tłucze")
	var/breakforce = 30
	var/stamforce = 15

/obj/item/club/attack(mob/living/M, mob/living/user)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.check_shields(src, breakforce))
			return
		else
			var/def_check = H.getarmor(type = "melee")
			H.apply_damage(stamforce, STAMINA, blocked = def_check)
	return ..()

/obj/item/club/tailclub
	name = "tail club"
	desc = "For the beating to death of lizards with their own tails."
	icon_state = "tailclub"
	force = 14
	breakforce = 40

/obj/item/club/ghettoclub
	name = "improvised maul"
	desc = "A bundle of heavy stuff on a stick."
	icon_state = "ghettoclub"
	force = 14
	breakforce = 25
	stamforce = 5

/obj/item/melee/hydraulic_blade
	name = "hydraulic blade"
	desc = "Extremely sharp and dangerous weapon."
	icon_state = "hydraulic_blade"
	item_state = "hydraulic_blade"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	force = 18
	block_upgrade_walk = 1
	block_flags = BLOCKING_ACTIVE | BLOCKING_NASTY
	sharpness = IS_SHARP
	attack_verb = list("atakuje", "ciacha", "dźga", "kroi", "rozdziera", "rozrywa", "sieka", "tnie")
	hitsound = 'sound/weapons/bladeslice.ogg'

//HF blade
/obj/item/vibro_weapon
	icon_state = "hfrequency0"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	name = "vibro sword"
	desc = "A potent weapon capable of cutting through nearly anything. Wielding it in two hands will allow you to deflect gunfire."
	armour_penetration = 100
	block_level = 1
	block_upgrade_walk = 2
	block_flags = BLOCKING_ACTIVE | BLOCKING_NASTY | BLOCKING_PROJECTILE
	block_sound = 'sound/weapons/genhit.ogg'
	force = 20
	throwforce = 20
	throw_speed = 4
	sharpness = IS_SHARP
	attack_verb = list("tnie", "kroi", "sieka")
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	hitsound = 'sound/weapons/bladeslice.ogg'

/obj/item/vibro_weapon/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/butchering, 20, 105)
	AddComponent(/datum/component/two_handed, force_multiplier=2, block_power_wielded=40, icon_wielded="hfrequency1")

/obj/item/vibro_weapon/update_icon()
	icon_state = "hfrequency0"
	..()
