// AQUILA - luminol: zmyta krew nie znika
// Każda usunięta plama krwi zostawia na kafelku niewidzialny ślad z DNA. Przedmioty i ubrania pamiętają zmytą krew
// w komponencie kryminalistycznym. Luminol ujawnia jedno i drugie na LUMINOL_DURATION. Ślady usuwa dopiero sterilizine.

// Ślad na podłodze

/obj/effect/blood_trace
	name = "utajony ślad krwi"
	desc = "Słabo świecący ślad krwi, której ktoś próbował się pozbyć. Gołym okiem byłby niewidoczny."
	icon = 'icons/effects/blood.dmi'
	icon_state = "floor1"
	color = LUMINOL_COLOR
	alpha = 170
	anchored = TRUE
	layer = ABOVE_NORMAL_TURF_LAYER
	invisibility = INVISIBILITY_MAXIMUM
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	/// Czy ślad świeci w tej chwili po luminolu
	var/revealed = FALSE
	/// Nakładka emisyjna, dzięki której ślad widać w ciemności
	var/mutable_appearance/glow

/obj/effect/blood_trace/Initialize(mapload, obj/effect/decal/cleanable/blood/source)
	. = ..()
	if(!istype(source))
		return
	icon = source.icon
	icon_state = source.icon_state
	dir = source.dir
	pixel_x = source.pixel_x
	pixel_y = source.pixel_y
	// ślady stóp i ciągnięcia są rysowane nakładkami
	for(var/overlay in source.overlays)
		overlays += overlay

/obj/effect/blood_trace/Destroy()
	glow = null
	return ..()

/// Ujawnia ślad. Zwraca TRUE, jeśli wcześniej był niewidoczny.
/obj/effect/blood_trace/proc/reveal()
	. = !revealed
	revealed = TRUE
	invisibility = 0
	mouse_opacity = MOUSE_OPACITY_ICON
	if(!glow && icon_state)
		glow = emissive_appearance(icon, icon_state, alpha = 150)
		overlays += glow
	addtimer(CALLBACK(src, PROC_REF(conceal)), LUMINOL_DURATION, TIMER_UNIQUE|TIMER_OVERRIDE)

/obj/effect/blood_trace/proc/conceal()
	revealed = FALSE
	invisibility = INVISIBILITY_MAXIMUM
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	if(glow)
		overlays -= glow
		glow = null

// Plamy krwi zostawiają ślad przy usunięciu (mop, środek czyszczący, mydło, cleanbot, wybuch...)

/obj/effect/decal/cleanable/blood
	/// Czy usunięcie tej plamy zostawi utajony ślad dla luminolu
	var/leaves_trace = TRUE

/obj/effect/decal/cleanable/blood/hitsplatter
	leaves_trace = FALSE // kasuje się w locie, krew i tak ląduje na podłodze w Destroy()

/obj/effect/decal/cleanable/blood/Initialize(mapload, list/datum/disease/diseases)
	. = ..()
	if(mapload)
		leaves_trace = FALSE // stara krew z mapy to tylko szum

/obj/effect/decal/cleanable/blood/replace_decal(obj/effect/decal/cleanable/blood/C)
	. = ..()
	if(.)
		leaves_trace = FALSE // scalona z istniejącą plamą, ślad zostawi tamta

/obj/effect/decal/cleanable/blood/Destroy()
	if(leaves_trace && isturf(loc) && !isspaceturf(loc))
		var/list/dna = return_blood_DNA()
		if(length(dna))
			var/obj/effect/blood_trace/trace = locate() in loc
			if(!trace)
				trace = new(loc, src)
			trace.add_latent_blood_DNA(dna)
	return ..()

// Odczynnik

/datum/reagent/luminol
	name = "Luminol"
	description = "Związek chemiluminescencyjny. W kontakcie z resztkami krwi, nawet starannie zmytej, przez chwilę świeci na niebiesko."
	color = "#C8F0FF"
	chem_flags = CHEMICAL_RNG_GENERAL
	taste_description = "metaliczna gorycz"
	reagent_weight = 0.6

// Chmurka sprayu pomija niewidzialne obiekty, więc ślady na podłodze szukamy tutaj, a nie w reaction_obj
/datum/reagent/luminol/reaction_turf(turf/T, reac_volume)
	. = ..()
	if(reac_volume <= 0)
		return
	for(var/obj/effect/blood_trace/trace in T)
		trace.reveal()
	for(var/obj/item/I in T)
		I.luminol_act()

/datum/reagent/luminol/reaction_obj(obj/O, reac_volume)
	. = ..()
	if(reac_volume <= 0)
		return
	if(O.luminol_act() && isturf(O.loc))
		O.visible_message("<span class='notice'>Na [O] pojawiają się świecące, niebieskie plamy.</span>")

/datum/reagent/luminol/reaction_mob(mob/living/M, method = TOUCH, reac_volume, show_message = 1, touch_protection = 0, obj/item/bodypart/affecting)
	if(method == TOUCH || method == VAPOR)
		var/list/glowing = list()
		var/list/exposed = M.aq_exposed_surfaces()
		for(var/atom/A as anything in exposed)
			if(A.luminol_act())
				glowing += (A == M) ? "dłonie" : "[A.name]"
		if(length(glowing))
			M.visible_message("<span class='notice'>Na [M] zaczynają świecić niebieskie plamy ([jointext(glowing, ", ")]).</span>")
	return ..()

/datum/chemical_reaction/luminol
	name = "Luminol"
	id = /datum/reagent/luminol
	results = list(/datum/reagent/luminol = 3)
	required_reagents = list(/datum/reagent/space_cleaner = 1, /datum/reagent/ammonia = 1, /datum/reagent/carbon = 1)
	mix_message = "Roztwór na chwilę rozbłyskuje bladym, niebieskim światłem."

// Sterilizine jako jedyny środek, który zaciera także utajoną krew

/datum/reagent/space_cleaner/sterilizine/reaction_turf(turf/T, reac_volume)
	. = ..()
	if(reac_volume >= 1)
		for(var/obj/effect/blood_trace/trace in T)
			qdel(trace)

/datum/reagent/space_cleaner/sterilizine/reaction_obj(obj/O, reac_volume)
	. = ..()
	if(!QDELETED(O))
		O.wipe_latent_blood_DNA()

/datum/reagent/space_cleaner/sterilizine/reaction_mob(mob/living/carbon/C, method = TOUCH, reac_volume)
	. = ..()
	if(!(method in list(TOUCH, VAPOR)) || !istype(C))
		return
	for(var/atom/A as anything in C.aq_exposed_surfaces())
		A.wipe_latent_blood_DNA()
	for(var/obj/item/I in C.held_items)
		I.wipe_latent_blood_DNA()

/// Powierzchnie, do których dociera spray: wierzchnie ubrania i sam mob (dłonie), jeśli dłonie są odsłonięte.
/mob/living/proc/aq_exposed_surfaces()
	return list(src)

/mob/living/carbon/human/aq_exposed_surfaces()
	. = list()
	var/obscured = check_obscured_slots()
	var/hands_covered = gloves || (wear_suit && (wear_suit.body_parts_covered & HANDS))
	if(!hands_covered)
		. += src
	if(wear_suit)
		. += wear_suit
	if(head)
		. += head
	if(w_uniform && !(obscured & ITEM_SLOT_ICLOTHING))
		. += w_uniform
	if(gloves && !(obscured & ITEM_SLOT_GLOVES))
		. += gloves
	if(shoes && !(obscured & ITEM_SLOT_FEET))
		. += shoes

// Spray

/obj/item/reagent_containers/spray/luminol
	name = "luminol w sprayu"
	desc = "Butelka z luminolem dla kryminalistyków. Miejsca i przedmioty, na których kiedyś była krew, po spryskaniu świecą przez minutę na niebiesko, nawet jeśli ktoś je umył. Świecące ślady można zbadać skanerem."
	volume = 100
	list_reagents = list(/datum/reagent/luminol = 100)
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = list(5, 10)
	stream_amount = 5

/obj/structure/closet/secure_closet/detective/PopulateContents()
	..()
	new /obj/item/reagent_containers/spray/luminol(src)

/datum/supply_pack/security/forensics
	desc = "Stay hot on the criminal's heels with Nanotrasen's Detective Essentials(tm). Contains a forensics scanner, a luminol spray, six evidence bags, camera, tape recorder, white crayon, and of course, a fedora. Requires Security access to open."

/datum/supply_pack/security/forensics/New()
	. = ..()
	contains += /obj/item/reagent_containers/spray/luminol
