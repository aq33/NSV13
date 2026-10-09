// Fart and superfart, ported from HippieStation13 (code/modules/mob/living/carbon/human/emote.dm).
// The human *fart emote itself lives in aquila/code/modules/mob/living/carbon/human/emote.dm and calls fart() below.

/// Plain fart: random message, pocket item effects, small chance to blow the butt off
/obj/item/organ/butt/proc/fart(mob/living/carbon/user)
	set waitfor = FALSE
	var/message
	var/turf/T = get_turf(user)
	var/lose_butt = prob(12)
	if(isopenturf(T) && !isspaceturf(T))
		SSmiasma.emit(T, MIASMA_FART_MOLES)
	for(var/mob/living/M in T)
		if(M == user)
			continue
		if(lose_butt)
			message = "uderza <b>[M]</b> tyłkiem w twarz!"
			M.apply_damage(15, BRUTE, BODY_ZONE_HEAD)
		else
			message = "puszcza bąka prosto w twarz <b>[M]</b>!"
	if(!message)
		message = pick(
			"unosi się i wypuszcza bąka o niebywałej sile!",
			"puszcza bąka!",
			"pierdzi.",
			"wydobywa metan z odbytu z prędkością 3 machów!",
			"przyczynia się do globalnego ocieplenia!",
			"pierdzi i lekceważąco macha ręką.",
			"pierdzi i udaje, że nic się nie stało.",
			"to <b>pierdzący</b> skurwiel!",
			"<B><font color='red'>p</font><font color='blue'>i</font><font color='red'>e</font><font color='blue'>r</font><font color='red'>d</font><font color='blue'>z</font><font color='red'>i</font></B>")

	var/obj/item/storage/book/bible/bible = locate() in T
	if(bible)
		smite_farter(bible, user)

	if(inv?.contents.len)
		var/obj/item/O = pick(inv.contents)
		if(istype(O, /obj/item/lighter))
			var/obj/item/lighter/G = O
			if(G.lit && T)
				new /obj/effect/hotspot(T)
			playsound(user, fart_sound, 50, TRUE, 5)
		else if(istype(O, /obj/item/weldingtool))
			var/obj/item/weldingtool/J = O
			if(J.isOn() && T)
				new /obj/effect/hotspot(T)
			playsound(user, fart_sound, 50, TRUE, 5)
		else if(istype(O, /obj/item/bikehorn))
			for(var/obj/item/bikehorn/Q in inv.contents)
				playsound(user, 'sound/items/bikehorn.ogg', 50, TRUE, 5)
			message = "<span class='clown'>pierdzi.</span>"
		else if(istype(O, /obj/item/megaphone))
			message = "<span class='reallybig'>pierdzi.</span>"
			playsound(user, 'aquila/sound/misc/fartmassive.ogg', 75, TRUE, 5)
		else
			playsound(user, fart_sound, 50, TRUE, 5)
		if(prob(33))
			eject_item(O, T)
	else
		playsound(user, fart_sound, 50, TRUE, 5)

	user.audible_message("<span class='emote'><b>[user]</b> [message]</span>")
	sleep(1)
	if(lose_butt && owner == user)
		blow_off(user)
		user.adjust_nutrition(-rand(5, 20))
		user.visible_message("<span class='danger'><b>[user]</b> odstrzeliwuje sobie tyłek!</span>", "<span class='userdanger'>O kurwa, twój tyłek odlatuje łukiem!</span>")
	else
		user.adjust_nutrition(-rand(2, 10))

/datum/emote/living/alien/fart
	key = "fart"
	key_third_person = "farts"
	emote_type = EMOTE_VISIBLE

/datum/emote/living/alien/fart/run_emote(mob/user, params, type_override, intentional)
	if(!..())
		return
	. = TRUE
	var/mob/living/carbon/C = user
	var/obj/item/organ/butt/B = C.getorganslot(ORGAN_SLOT_BUTT)
	if(!B)
		to_chat(user, "<span class='warning'>Nie masz tyłka!</span>")
		return FALSE
	B.fart(C)

/datum/emote/living/carbon/human/superfart
	key = "superfart"
	key_third_person = "superfarts"
	emote_type = EMOTE_VISIBLE

/datum/emote/living/carbon/human/superfart/run_emote(mob/user, params, type_override, intentional)
	if(!..())
		return
	. = TRUE
	var/mob/living/carbon/human/H = user
	var/obj/item/organ/butt/B = H.getorganslot(ORGAN_SLOT_BUTT)
	if(!B)
		to_chat(user, "<span class='danger'>Nie masz tyłka!</span>")
		return FALSE
	if(B.loose)
		to_chat(user, "<span class='danger'>Twój tyłek jest zbyt luźny na superpierdnięcie!</span>")
		return FALSE
	B.loose = TRUE // to avoid spamsuperfart
	B.superfart(H)

/obj/item/organ/butt/proc/superfart(mob/living/carbon/human/user)
	set waitfor = FALSE
	var/fart_type = 1 // 1: ASSBLAST  2: SUPERNOVA  3: FARTFLY
	if(prob(76)) // 76%
		fart_type = 1
	else if(prob(12)) // 3%
		fart_type = 2
	else if(prob(12)) // 0.4%
		fart_type = is_station_level(user.z) ? 3 : 2

	var/obj/item/storage/book/bible/bible = locate() in get_turf(user)
	if(bible)
		smite_farter(bible, user)

	sleep(4)
	for(var/i in 1 to 10)
		playsound(user, fart_sound, 50, TRUE, 5)
		sleep(1)
	if(QDELETED(user) || owner != user)
		loose = FALSE
		return
	playsound(user, 'aquila/sound/misc/fartmassive.ogg', 75, TRUE, 5)

	var/turf/T = get_turf(user)
	var/shoot_dir = turn(user.dir, 180)
	if(inv)
		for(var/obj/item/O in inv.contents)
			eject_item(O, T)
			var/turf/target = T
			for(var/i in 1 to 6)
				var/turf/next = get_step(target, shoot_dir)
				if(!next || next.density)
					break
				target = next
			O.ass_throw(target)

	Remove(user)
	forceMove(T)
	loose = FALSE
	new blood_type(T)
	user.adjust_nutrition(-500)

	switch(fart_type)
		if(1)
			for(var/mob/living/M in T)
				if(M != user)
					user.visible_message("<span class='danger'>Tyłek <b>[user]</b> wystrzeliwuje prosto w twarz <b>[M]</b>!</span>", "<span class='danger'>Strzelasz tyłkiem w <b>[M]</b>!</span>")
					M.apply_damage(50, BRUTE, BODY_ZONE_HEAD)
			user.visible_message("<span class='danger'><b>[user]</b> odstrzeliwuje sobie tyłek!</span>", "<span class='userdanger'>O kurwa, twój tyłek odlatuje łukiem!</span>")
		if(2)
			user.visible_message("<span class='danger'><b>[user]</b> rozrywa sobie tyłek w potężnej eksplozji!</span>", "<span class='userdanger'>O kurwa, twój tyłek wybucha jak supernowa!</span>")
			explosion(T, 0, 1, 3, adminlog = FALSE, flame_range = 3)
			user.gib()
		if(3)
			var/endx = T.x
			var/endy = T.y
			switch(user.dir)
				if(NORTH)
					endy = 8
				if(SOUTH)
					endy = world.maxy - 8
				if(EAST)
					endx = 8
				else
					endx = world.maxx - 8
			//ASS BLAST USA
			user.visible_message("<span class='danger'><b>[user]</b> odstrzeliwuje sobie tyłek z taką siłą, że wybucha!</span>", "<span class='userdanger'>O kurwa, twój tyłek odlatuje w głąb galaktyki!</span>")
			user.gib()
			new /obj/effect/immovablerod/butt(T, locate(endx, endy, T.z))
			priority_announce("Co to, kurwa, było?!", "Alarm ogólny")
			qdel(src)

/// Thrown out of a superfarting butt: guaranteed to embed in whoever it hits
/obj/item/proc/ass_throw(turf/target)
	var/list/old_embedding = embedding
	embedding = list("embed_chance" = 100, "ignore_throwspeed_threshold" = TRUE)
	updateEmbedding()
	throw_at(target, 7, throw_speed, callback = CALLBACK(src, PROC_REF(ass_throw_end), old_embedding))

/obj/item/proc/ass_throw_end(list/old_embedding)
	disableEmbedding()
	embedding = old_embedding
	updateEmbedding()

/obj/effect/immovablerod/butt
	name = "enormous ass"
	desc = "godDAMN that ass is well rounded"
	icon = 'aquila/icons/obj/butt.dmi'
	icon_state = "butt"

/obj/effect/immovablerod/butt/New(atom/start, atom/end, aimed_at)
	..()
	SpinAnimation(24, 200)

/// Farting on a bible: lightning strikes and the heretic gets gibbed
/proc/smite_farter(obj/item/storage/book/bible/bible, mob/living/user)
	var/image/img = image(icon = 'aquila/icons/effects/butt_lightning.dmi', icon_state = "lightning")
	img.pixel_x = -world.icon_size * 3
	img.pixel_y = -world.icon_size
	flick_overlay_static(img, bible, 10)
	playsound(bible, 'aquila/sound/effects/thunder.ogg', 90, TRUE)
	addtimer(CALLBACK(user, TYPE_PROC_REF(/mob/living, gib)), 1 SECONDS)
