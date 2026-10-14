// AQUILA - rozszerzenie komponentu kryminalistycznego o utajoną krew (luminol) i ślady prochu (GSR)

/datum/component/forensics
	/// Krew zmyta zwykłym sprzątaniem. assoc dna = grupa krwi. Widać ją tylko po luminolu.
	var/list/latent_blood_DNA
	/// Ślady prochu. assoc kaliber = world.time ostatniego strzału
	var/list/gunshot_residue
	/// Do kiedy ślady świecą po luminolu
	var/luminol_until = 0
	/// Nakładka świecenia na przedmiocie
	var/mutable_appearance/luminol_overlay

/datum/component/forensics/InheritComponent(datum/component/forensics/F, original)
	if(length(F.latent_blood_DNA))
		add_latent_blood_DNA(F.latent_blood_DNA)
	if(length(F.gunshot_residue))
		LAZYINITLIST(gunshot_residue)
		for(var/caliber in F.gunshot_residue)
			gunshot_residue[caliber] = max(gunshot_residue[caliber], F.gunshot_residue[caliber])
	return ..()

/datum/component/forensics/clean_act(datum/source, strength)
	// Zwykłe sprzątanie zmywa krew, ale zostawia jej ślad dla luminolu
	if(strength >= CLEAN_STRENGTH_BLOOD && strength < CLEAN_STRENGTH_LATENT_BLOOD && length(blood_DNA))
		add_latent_blood_DNA(blood_DNA)
	if(strength >= CLEAN_STRENGTH_LATENT_BLOOD)
		wipe_latent_blood_DNA()
	if(strength >= CLEAN_STRENGTH_RESIDUE)
		gunshot_residue = null
	return ..()

/datum/component/forensics/Destroy(force)
	if(luminol_overlay && isatom(parent))
		var/atom/A = parent
		A.cut_overlay(luminol_overlay)
	luminol_overlay = null
	return ..()

/datum/component/forensics/proc/add_latent_blood_DNA(list/dna)
	if(!length(dna))
		return FALSE
	LAZYINITLIST(latent_blood_DNA)
	for(var/i in dna)
		latent_blood_DNA[i] = dna[i]
	return TRUE

/datum/component/forensics/proc/wipe_latent_blood_DNA()
	latent_blood_DNA = null
	luminol_fade()
	return TRUE

/datum/component/forensics/proc/add_gunshot_residue(caliber)
	if(!caliber)
		return FALSE
	LAZYINITLIST(gunshot_residue)
	gunshot_residue[caliber] = world.time
	return TRUE

/// Zwraca listę kaliber = wiek śladu, bez śladów, które już się rozpadły
/datum/component/forensics/proc/get_gunshot_residue()
	if(!length(gunshot_residue))
		return null
	var/list/result = list()
	for(var/caliber in gunshot_residue)
		var/age = world.time - gunshot_residue[caliber]
		if(age >= GSR_FADE_TIME)
			gunshot_residue -= caliber
			continue
		result[caliber] = age
	if(!length(gunshot_residue))
		gunshot_residue = null
	return length(result) ? result : null

/// Luminol: jeśli jest zmyta krew, zaczyna świecić. Zwraca TRUE, jeśli coś się ujawniło.
/datum/component/forensics/proc/luminol_react()
	if(!length(latent_blood_DNA))
		return FALSE
	var/was_glowing = luminol_until > world.time
	luminol_until = world.time + LUMINOL_DURATION
	if(isitem(parent) && !luminol_overlay)
		var/obj/item/I = parent
		luminol_overlay = mutable_appearance('icons/effects/blood.dmi', "itemblood", appearance_flags = RESET_COLOR)
		luminol_overlay.color = LUMINOL_COLOR
		luminol_overlay.blend_mode = BLEND_INSET_OVERLAY
		ADD_KEEP_TOGETHER(I, "luminol")
		I.add_overlay(luminol_overlay)
	addtimer(CALLBACK(src, PROC_REF(luminol_fade)), LUMINOL_DURATION, TIMER_UNIQUE|TIMER_OVERRIDE)
	return !was_glowing

/datum/component/forensics/proc/luminol_fade()
	luminol_until = 0
	if(!luminol_overlay)
		return
	if(isitem(parent))
		var/obj/item/I = parent
		I.cut_overlay(luminol_overlay)
		REMOVE_KEEP_TOGETHER(I, "luminol")
	luminol_overlay = null

/datum/component/forensics/proc/is_luminol_active()
	return luminol_until > world.time

// Pomocnicze procy na atomach

/atom/proc/return_latent_blood_DNA()
	var/datum/component/forensics/D = GetComponent(/datum/component/forensics)
	if(D)
		. = D.latent_blood_DNA

/// Utajona krew, ale tylko gdy w tej chwili świeci po luminolu
/atom/proc/return_revealed_latent_blood()
	var/datum/component/forensics/D = GetComponent(/datum/component/forensics)
	if(D && D.is_luminol_active())
		. = D.latent_blood_DNA

/atom/proc/add_latent_blood_DNA(list/dna)
	if(!length(dna))
		return FALSE
	var/datum/component/forensics/D = AddComponent(/datum/component/forensics)
	return D?.add_latent_blood_DNA(dna)

/atom/proc/wipe_latent_blood_DNA()
	var/datum/component/forensics/D = GetComponent(/datum/component/forensics)
	D?.wipe_latent_blood_DNA()

/// Zwraca TRUE, jeśli luminol coś ujawnił
/atom/proc/luminol_act()
	var/datum/component/forensics/D = GetComponent(/datum/component/forensics)
	return D?.luminol_react()

/atom/proc/add_gunshot_residue(caliber)
	var/datum/component/forensics/D = AddComponent(/datum/component/forensics)
	return D?.add_gunshot_residue(caliber)

/atom/proc/return_gunshot_residue()
	var/datum/component/forensics/D = GetComponent(/datum/component/forensics)
	if(D)
		. = D.get_gunshot_residue()

// Skaner detektywa: dodatkowe sekcje raportu

/// Wołane ze skanera po sekcji włókien. Zwraca TRUE, jeśli coś znaleziono.
/obj/item/detective_scanner/proc/scan_aquila_forensics(atom/A)
	. = FALSE

	// Utajona krew: tylko to, co w tej chwili świeci po luminolu
	var/list/latent = list()
	if(istype(A, /obj/effect/blood_trace))
		var/obj/effect/blood_trace/trace = A
		if(trace.revealed)
			merge_dna_list(latent, trace.return_latent_blood_DNA())
	else
		merge_dna_list(latent, A.return_revealed_latent_blood())
	if(isturf(A))
		for(var/obj/effect/blood_trace/trace in A)
			if(trace.revealed)
				merge_dna_list(latent, trace.return_latent_blood_DNA())
	var/list/latent_worn = list()
	if(ishuman(A))
		var/mob/living/carbon/human/H = A
		for(var/obj/item/I in list(H.wear_suit, H.w_uniform, H.gloves, H.shoes, H.head))
			var/list/item_latent = I.return_revealed_latent_blood()
			if(length(item_latent))
				latent_worn[I] = item_latent
	if(length(latent) || length(latent_worn))
		sleep(30)
		add_log("<span class='info'><B>Utajona krew (luminol):</B></span>")
		for(var/dna in latent)
			add_log("Typ: <font color='[LUMINOL_COLOR]'>[latent[dna]]</font> DNA: <font color='[LUMINOL_COLOR]'>[dna]</font>")
		for(var/obj/item/I as anything in latent_worn)
			var/list/item_latent = latent_worn[I]
			for(var/dna in item_latent)
				add_log("[I.name]: Typ: <font color='[LUMINOL_COLOR]'>[item_latent[dna]]</font> DNA: <font color='[LUMINOL_COLOR]'>[dna]</font>")
		. = TRUE

	// Ślady prochu
	var/list/residue_lines = list()
	add_residue_lines(residue_lines, A.return_gunshot_residue())
	if(ishuman(A))
		var/mob/living/carbon/human/H = A
		if(H.gloves)
			add_residue_lines(residue_lines, H.gloves.return_gunshot_residue(), H.gloves.name)
		if(H.wear_suit && (H.wear_suit.body_parts_covered & HANDS))
			add_residue_lines(residue_lines, H.wear_suit.return_gunshot_residue(), H.wear_suit.name)
	if(length(residue_lines))
		sleep(30)
		add_log("<span class='info'><B>Ślady prochu:</B></span>")
		for(var/line in residue_lines)
			add_log(line)
		. = TRUE

	// Balistyka
	var/list/ballistic_lines = list()
	if(istype(A, /obj/item/gun/ballistic))
		var/obj/item/gun/ballistic/G = A
		if(G.ballistic_id)
			ballistic_lines += "Sygnatura gwintu lufy: <font color='red'>[G.ballistic_id]</font>"
		if(G.serial_number)
			ballistic_lines += G.serial_filed ? "Numer seryjny: <I>spiłowany</I>" : "Numer seryjny: <font color='red'>[G.serial_number]</font>"
	else if(istype(A, /obj/item/ammo_casing))
		var/obj/item/ammo_casing/casing = A
		if(casing.ballistic_id)
			ballistic_lines += "Ślady iglicy i wyciągu: <font color='red'>[casing.ballistic_id]</font> (kaliber [casing.caliber])"
	else if(istype(A, /obj/item/bullet_fragment))
		var/obj/item/bullet_fragment/fragment = A
		if(fragment.ballistic_id)
			ballistic_lines += "Rysy po gwincie lufy: <font color='red'>[fragment.ballistic_id]</font>[fragment.caliber ? " (kaliber [fragment.caliber])" : ""]"
	else if(iscarbon(A))
		var/mob/living/carbon/C = A
		var/fragments = 0
		for(var/obj/item/bodypart/BP as anything in C.bodyparts)
			for(var/obj/item/bullet_fragment/fragment in BP)
				fragments++
		if(fragments)
			ballistic_lines += "Fragmenty pocisków w ciele: <font color='red'>[fragments]</font>"
	if(length(ballistic_lines))
		sleep(30)
		add_log("<span class='info'><B>Balistyka:</B></span>")
		for(var/line in ballistic_lines)
			add_log(line)
		. = TRUE

/obj/item/detective_scanner/proc/add_residue_lines(list/lines, list/residue, source_name)
	if(!length(residue))
		return
	for(var/caliber in residue)
		var/strength = residue[caliber] >= GSR_FAINT_TIME ? "słabe ślady" : "wyraźne ślady"
		lines += "[source_name ? "[source_name]: " : ""]kaliber <font color='red'>[caliber]</font> ([strength])"

/obj/item/detective_scanner/proc/merge_dna_list(list/target, list/source)
	for(var/dna in source)
		target[dna] = source[dna]
