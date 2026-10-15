//Items for nuke theft, supermatter theft traitor objective


// STEALING THE NUKE

//the nuke core - objective item
/obj/item/nuke_core
	name = "plutonium core"
	desc = "Extremely radioactive. Wear goggles."
	icon = 'icons/obj/nuke_tools.dmi'
	icon_state = "plutonium_core"
	item_state = "plutoniumcore"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	layer = ABOVE_MOB_LAYER
	var/pulse = 0
	var/cooldown = 0
	var/pulseicon = "plutonium_core_pulse"

/obj/item/nuke_core/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/nuke_core/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/nuke_core/attackby(obj/item/nuke_core_container/container, mob/user)
	if(istype(container))
		container.load(src, user)
	else
		return ..()

/obj/item/nuke_core/process()
	if(cooldown < world.time - 60)
		cooldown = world.time
		flick(pulseicon, src)
		radiation_pulse(src, 400, 2)

/obj/item/nuke_core/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] pociera się [src]! Wygląda na to, że próbuje popełnić samobójstwo!</span>")
	return (TOXLOSS)

//nuke core box, for carrying the core
/obj/item/nuke_core_container
	name = "nuke core container"
	desc = "Solid container for radioactive objects."
	icon = 'icons/obj/nuke_tools.dmi'
	icon_state = "core_container_empty"
	item_state = "tile"
	lefthand_file = 'icons/mob/inhands/misc/sheets_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/sheets_righthand.dmi'
	var/obj/item/nuke_core/core

/obj/item/nuke_core_container/Destroy()
	QDEL_NULL(core)
	return ..()

/obj/item/nuke_core_container/proc/load(obj/item/nuke_core/ncore, mob/user)
	if(core || !istype(ncore))
		return FALSE
	ncore.forceMove(src)
	core = ncore
	icon_state = "core_container_loaded"
	to_chat(user, "<span class='warning'>Pojemnik się zamyka...</span>")
	addtimer(CALLBACK(src, PROC_REF(seal)), 50)
	return TRUE

/obj/item/nuke_core_container/proc/seal()
	if(istype(core))
		STOP_PROCESSING(SSobj, core)
		icon_state = "core_container_sealed"
		playsound(src, 'sound/items/deconstruct.ogg', 60, 1)
		if(ismob(loc))
			to_chat(loc, "<span class='warning'>[src] jest trwale zamknięty, promieniowanie [core] jest odizolowane.</span>")

/obj/item/nuke_core_container/attackby(obj/item/nuke_core/core, mob/user)
	if(istype(core))
		if(!user.temporarilyRemoveItemFromInventory(core))
			to_chat(user, "<span class='warning'>[core] przykleił się do twojej ręki!</span>")
			return
		else
			load(core, user)
	else
		return ..()

//snowflake screwdriver, works as a key to start nuke theft, traitor only
/obj/item/screwdriver/nuke
	name = "screwdriver"
	desc = "A screwdriver with an ultra thin tip that's carefully designed to boost screwing speed."
	icon = 'icons/obj/nuke_tools.dmi'
	icon_state = "screwdriver_nuke"
	item_state = "screwdriver_nuke"
	toolspeed = 0.5
	random_color = FALSE
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null

/obj/item/paper/guides/antag/nuke_instructions
	default_raw_text = "Jak włamać się do terminala samozniszczenia Nanotrasen i wyjąć jego rdzeń plutonowy:<br><ul><li>Odkręć przedni panel terminala śrubokrętem z bardzo cienką końcówką (w zestawie)</li><li>Podważ i zdejmij przedni panel łomem</li><li>Przetnij wewnętrzną metalową płytę spawarką</li><li>Podważ wewnętrzną płytę łomem, by odsłonić radioaktywny rdzeń</li><li>Wyjmij rdzeń plutonowy za pomocą pojemnika na rdzeń; zamknięcie pojemnika zajmie trochę czasu</li><li>???</li>\
	</ul>"

// STEALING SUPERMATTER

/obj/item/paper/guides/antag/supermatter_sliver
	default_raw_text = "Jak bezpiecznie pozyskać odłamek supermaterii:<br><ul><li>Podejdź do aktywnego kryształu supermaterii w sprzęcie ochronnym osłaniającym przed promieniowaniem. NIE DOTYKAJ GO.</li><li>Odetnij odłamek kryształu skalpelem z supermaterii (w zestawie).</li><li>Bezpiecznie podnieś odcięty odłamek szczypcami do supermaterii (również w zestawie).</li><li>Fizyczny kontakt dowolnego obiektu z odłamkiem obróci go w pył, podobnie jak ciebie.</li><li>Umieść odłamek szczypcami w dołączonym pojemniku; zamknięcie pojemnika zajmie trochę czasu.</li><li>Uciekaj, zanim kryształ ulegnie delaminacji.</li><li>???</li>\
	</ul>"

/obj/item/nuke_core/supermatter_sliver
	name = "supermatter sliver"
	desc = "A tiny, highly volatile sliver of a supermatter crystal. Do not handle without protection!"
	icon_state = "supermatter_sliver"
	item_state = "supermattersliver"
	pulseicon = "supermatter_sliver_pulse"

/obj/item/nuke_core/supermatter_sliver/attack_tk() // no TK dusting memes
	return FALSE

/obj/item/nuke_core/supermatter_sliver/can_be_pulled(user) // no drag memes
	return FALSE

/obj/item/nuke_core/supermatter_sliver/attackby(obj/item/W, mob/living/user, params)
	if(istype(W, /obj/item/hemostat/supermatter))
		var/obj/item/hemostat/supermatter/tongs = W
		if (tongs.sliver)
			to_chat(user, "<span class='notice'>[tongs] już trzymają odłamek supermaterii!</span>")
			return FALSE
		forceMove(tongs)
		tongs.sliver = src
		tongs.update_icon()
		to_chat(user, "<span class='notice'>Ostrożnie podnosisz [src] za pomocą [tongs].</span>")
	else if(istype(W, /obj/item/scalpel/supermatter) || istype(W, /obj/item/nuke_core_container/supermatter/)) // we don't want it to dust
		return
	else
		to_chat(user, "<span class='notice'>Gdy dotyka [src], zarówno [src], jak i [W] obracają się w pył!</span>")
		radiation_pulse(user, 100)
		playsound(src, 'sound/effects/supermatter.ogg', 50, 1)
		qdel(W)
		qdel(src)

/obj/item/nuke_core/supermatter_sliver/pickup(mob/living/user)
	..()
	if(!iscarbon(user))
		return FALSE
	var/mob/ded = user
	user.visible_message("<span class='danger'>[ded] sięga, by podnieść [src]. Jego ciało zaczyna świecić i staje w płomieniach, po czym obraca się w pył!</span>",\
			"<span class='userdanger'>Sięgasz po [src] gołymi rękami. To było głupie.</span>",\
			"<span class='italics'>Nagle zapada zupełna cisza.</span>")
	radiation_pulse(user, 500, 2)
	playsound(get_turf(user), 'sound/effects/supermatter.ogg', 50, 1)
	ded.dust()

/obj/item/nuke_core_container/supermatter
	name = "supermatter bin"
	desc = "A tiny receptacle that releases an inert hyper-noblium mix upon sealing, allowing a sliver of a supermatter crystal to be safely stored."
	var/obj/item/nuke_core/supermatter_sliver/sliver

/obj/item/nuke_core_container/supermatter/Destroy()
	QDEL_NULL(sliver)
	return ..()

/obj/item/nuke_core_container/supermatter/load(obj/item/hemostat/supermatter/T, mob/user)
	if(!istype(T) || !T.sliver)
		return FALSE
	T.sliver.forceMove(src)
	sliver = T.sliver
	T.sliver = null
	T.icon_state = "supermatter_tongs"
	icon_state = "core_container_loaded"
	to_chat(user, "<span class='warning'>Pojemnik się zamyka...</span>")
	addtimer(CALLBACK(src, PROC_REF(seal)), 50)
	return TRUE

/obj/item/nuke_core_container/supermatter/seal()
	if(istype(sliver))
		STOP_PROCESSING(SSobj, sliver)
		icon_state = "core_container_sealed"
		playsound(src, 'sound/items/Deconstruct.ogg', 60, 1)
		if(ismob(loc))
			to_chat(loc, "<span class='warning'>[src] jest trwale zamknięty, [sliver] jest bezpiecznie odizolowany.</span>")

/obj/item/nuke_core_container/supermatter/attackby(obj/item/hemostat/supermatter/tongs, mob/user)
	if(istype(tongs))
		//try to load shard into core
		load(tongs, user)
	else
		return ..()

/obj/item/scalpel/supermatter
	name = "supermatter scalpel"
	desc = "A scalpel with a fragile tip of condensed hyper-noblium gas, searingly cold to the touch, that can safely shave a sliver off a supermatter crystal."
	icon = 'icons/obj/nuke_tools.dmi'
	icon_state = "supermatter_scalpel"
	toolspeed = 0.5
	damtype = "fire"
	usesound = 'sound/weapons/bladeslice.ogg'
	var/usesLeft

/obj/item/scalpel/supermatter/Initialize(mapload)
	. = ..()
	usesLeft = rand(2, 4)

/obj/item/hemostat/supermatter
	name = "supermatter extraction tongs"
	desc = "A pair of tongs made from condensed hyper-noblium gas, searingly cold to the touch, that can safely grip a supermatter sliver."
	icon = 'icons/obj/nuke_tools.dmi'
	icon_state = "supermatter_tongs"
	toolspeed = 0.75
	damtype = "fire"
	var/obj/item/nuke_core/supermatter_sliver/sliver

/obj/item/hemostat/supermatter/Destroy()
	QDEL_NULL(sliver)
	return ..()

/obj/item/hemostat/supermatter/update_icon()
	if(sliver)
		icon_state = "supermatter_tongs_loaded"
	else
		icon_state = "supermatter_tongs"

/obj/item/hemostat/supermatter/afterattack(atom/O, mob/user, proximity)
	. = ..()
	if(!sliver)
		return
	if(proximity && ismovableatom(O) && O != sliver)
		Consume(O, user)

/obj/item/hemostat/supermatter/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum) // no instakill supermatter javelins
	if(sliver)
		sliver.forceMove(loc)
		visible_message("<span class='notice'>[sliver] wypada z [src], gdy ten uderza o ziemię.</span>")
		sliver = null
		update_icon()
	..()

/obj/item/hemostat/supermatter/proc/Consume(atom/movable/AM, mob/user)
	if(ismob(AM))
		var/mob/victim = AM
		victim.dust()
		message_admins("[src] has consumed [key_name_admin(victim)] [ADMIN_JMP(src)].")
		investigate_log("has consumed [key_name(victim)].", "supermatter")
	else
		investigate_log("has consumed [AM].", "supermatter")
		qdel(AM)
	if (user)
		user.visible_message("<span class='danger'>Gdy [user] dotyka [AM] za pomocą [src], oba obracają się w pył, a pomieszczenie wypełnia cisza...</span>",\
			"<span class='userdanger'>Dotykasz [AM] za pomocą [src] i nagle zapada cisza.\n[AM] i [sliver] obracają się w pył, a zanim zdążysz to pojąć, ty również.</span>",\
			"<span class='italics'>Nagle zapada zupełna cisza.</span>")
		user.dust()
	radiation_pulse(src, 500, 2)
	playsound(src, 'sound/effects/supermatter.ogg', 50, 1)
	QDEL_NULL(sliver)
	update_icon()
