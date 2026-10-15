// Specjalne mutacje szlamów (port z BeeStation).
// Tych kolorów nie da się wyhodować zwykłą mutacją. Szlam dostaje je tylko po spełnieniu warunku:
// - dark green: zielony szlam zaczyna jeść, stojąc na trawie,
// - cobalt: złoty szlam w grawitacji większej niż standardowa,
// - dark grey: różowy szlam nakarmiony rdzeniem regeneracyjnym,
// - crimson: czerwony szlam przyjmuje dużo obrażeń od ognia naraz.
// Wszystkie młode z następnego podziału mają nowy kolor, a potem rozmnażają się już normalnie.

#define SLIME_SPECIAL_ICON 'aquila/icons/mob/slimes_special.dmi'
/// Ile obrażeń od ognia w jednym ticku Life() zmienia czerwony szlam w crimson (w Bee 80 na sekundę)
#define SLIME_CRIMSON_BURN_THRESHOLD 160

GLOBAL_LIST_INIT(special_slime_colours, list("dark green", "cobalt", "dark grey", "crimson"))

/mob/living/simple_animal/slime
	/// Czy następny podział da młode w specjalnym kolorze
	var/special_mutation = FALSE
	/// Kolor, który dostaną młode, gdy special_mutation jest ustawione
	var/special_mutation_type
	/// Obrażenia od ognia zebrane od ostatniego ticku Life()
	var/burn_damage_stored = 0

/mob/living/simple_animal/slime/proc/set_special_mutation(new_type, message)
	if(special_mutation && special_mutation_type == new_type)
		return
	special_mutation = TRUE
	special_mutation_type = new_type
	visible_message("<span class='danger'>[message]</span>")

/mob/living/simple_animal/slime/set_colour(new_colour)
	icon = (new_colour in GLOB.special_slime_colours) ? SLIME_SPECIAL_ICON : initial(icon)
	return ..()

/mob/living/simple_animal/slime/make_baby(drop_loc, new_adult, new_nutrition, new_powerlevel, force_original_colour=FALSE, step_away=TRUE, datum/component/nanites/original_nanites=null)
	var/mob/living/simple_animal/slime/baby = ..()
	if(baby && special_mutation && !force_original_colour && mutation_chance < 100)
		baby.set_colour(special_mutation_type)
	return baby

/mob/living/simple_animal/slime/Feedon(mob/living/M)
	. = ..()
	if(colour == "green" && buckled == M && istype(get_turf(M), /turf/open/floor/grass))
		set_special_mutation("dark green", "[src] wchłania witalność z trawy wokół, a jego zielona błona ciemnieje.")

/mob/living/simple_animal/slime/update_gravity(has_gravity, override = 0)
	. = ..()
	if(colour == "gold" && stat != DEAD && has_gravity > STANDARD_GRAVITY)
		set_special_mutation("cobalt", "[src] drży pod ogromną grawitacją, a w jego błonie wirują niebieskie drobinki.")

/mob/living/simple_animal/slime/attackby(obj/item/W, mob/living/user, params)
	if(istype(W, /obj/item/organ/regenerative_core) && stat != DEAD && colour == "pink")
		to_chat(user, "<span class='warning'>Szlam wchłania rdzeń regeneracyjny, a jego róż ciemnieje do złowrogiej szarości.</span>")
		set_special_mutation("dark grey", "[src] szarzeje, wchłaniając rdzeń regeneracyjny.")
		qdel(W)
		return
	return ..()

/mob/living/simple_animal/slime/adjustFireLoss(amount, updating_health = TRUE, forced = FALSE)
	if(!forced && amount > 0)
		burn_damage_stored += amount
	return ..()

/mob/living/simple_animal/slime/bullet_act(obj/item/projectile/Proj, def_zone, piercing_hit = FALSE)
	if(Proj.damage_type == BURN)
		burn_damage_stored += abs(Proj.damage)
	return ..()

/mob/living/simple_animal/slime/Life(seconds, times_fired)
	. = ..()
	if(QDELETED(src))
		return
	if(colour == "red" && stat != DEAD && burn_damage_stored > SLIME_CRIMSON_BURN_THRESHOLD)
		set_special_mutation("crimson", "[src] drży, a jego czerwony rdzeń pogłębia się do otchłannej szkarłatnej barwy.")
	burn_damage_stored = 0

// Ekstrakty bez effectmod nie nadają się do krzyżowania. Bez tego szlam zjadłby 10 sztuk i rozpadł się bez wyniku.
/obj/item/slime_extract/attack(mob/living/simple_animal/slime/M, mob/user)
	if(isslime(M) && !effectmod)
		to_chat(user, "<span class='warning'>Rdzeń szlamu nie reaguje na [src]. Tego ekstraktu nie da się krzyżować.</span>")
		return
	return ..()

/obj/item/slime_extract/darkgreen
	name = "dark green slime extract"
	icon = SLIME_SPECIAL_ICON
	icon_state = "dark green slime extract"
	color_slime = "dark green"
	activate_reagents = list(/datum/reagent/water, /datum/reagent/medicine/earthsblood)
	plort_value = 100

/obj/item/slime_extract/cobalt
	name = "cobalt slime extract"
	icon = SLIME_SPECIAL_ICON
	icon_state = "cobalt slime extract"
	color_slime = "cobalt"
	activate_reagents = list(/datum/reagent/blood, /datum/reagent/toxin/plasma)
	plort_value = 100

/obj/item/slime_extract/darkgrey
	name = "dark grey slime extract"
	icon = SLIME_SPECIAL_ICON
	icon_state = "dark grey slime extract"
	color_slime = "dark grey"
	activate_reagents = list(/datum/reagent/blood, /datum/reagent/toxin/plasma)
	plort_value = 100

/obj/item/slime_extract/crimson
	name = "crimson slime extract"
	icon = SLIME_SPECIAL_ICON
	icon_state = "crimson slime extract"
	color_slime = "crimson"
	activate_reagents = list(/datum/reagent/blackpowder, /datum/reagent/toxin/plasma)
	plort_value = 100

/datum/export/slime/special
	cost = 220
	unit_name = "special slime core"
	export_types = list(/obj/item/slime_extract/darkgreen, /obj/item/slime_extract/cobalt, /obj/item/slime_extract/darkgrey, /obj/item/slime_extract/crimson)

// Reakcje

//Dark Green
/datum/chemical_reaction/slime/slimeseed
	name = "Seed Creation"
	id = "m_seed"
	required_reagents = list(/datum/reagent/medicine/earthsblood = 1)
	required_other = TRUE
	required_container = /obj/item/slime_extract/darkgreen

/datum/chemical_reaction/slime/slimeseed/on_reaction(datum/reagents/holder)
	var/turf/T = get_turf(holder.my_atom)
	playsound(T, 'sound/effects/phasein.ogg', 100, TRUE)
	for(var/mob/living/carbon/C in viewers(T))
		C.flash_act()
	var/static/list/blocked_seeds = list(
		/obj/item/seeds/banana/bombanana,
		/obj/item/seeds/lavaland,
		/obj/item/seeds/sample,
		/obj/item/seeds/sample/alienweed,
		/obj/item/seeds/cherry/bomb,
	)
	var/chosen = pick(subtypesof(/obj/item/seeds) - blocked_seeds)
	new chosen(T)
	..()

/datum/chemical_reaction/slime/slimefertilise
	name = "Slime Fertiliser"
	id = "m_fertilise"
	results = list(/datum/reagent/plantnutriment/slimenutriment = 1)
	required_reagents = list(/datum/reagent/water = 1)
	required_other = TRUE
	required_container = /obj/item/slime_extract/darkgreen

//Cobalt
/datum/chemical_reaction/slime/slimepush
	name = "Slime Repulsion"
	id = "m_push"
	results = list(/datum/reagent/sorium = 5)
	required_reagents = list(/datum/reagent/toxin/plasma = 1)
	required_other = TRUE
	required_container = /obj/item/slime_extract/cobalt

/datum/chemical_reaction/slime/slimepush/on_reaction(datum/reagents/holder)
	holder.chem_temp += 500
	..()

/datum/chemical_reaction/slime/slimepull
	name = "Slime Attraction"
	id = "m_pull"
	results = list(/datum/reagent/liquid_dark_matter = 5)
	required_reagents = list(/datum/reagent/blood = 1)
	required_other = TRUE
	required_container = /obj/item/slime_extract/cobalt

/datum/chemical_reaction/slime/slimepull/on_reaction(datum/reagents/holder)
	holder.chem_temp += 500
	..()

//Dark Grey
/datum/chemical_reaction/slime/slimesummonlegion
	name = "Slime Legion"
	id = "m_legion"
	required_reagents = list(/datum/reagent/blood = 1)
	required_other = TRUE
	required_container = /obj/item/slime_extract/darkgrey

/datum/chemical_reaction/slime/slimesummonlegion/on_reaction(datum/reagents/holder)
	var/turf/T = get_turf(holder.my_atom)
	T.visible_message("<span class='danger'>Ekstrakt ze szlamu zaczyna gwałtownie wibrować!</span>")
	addtimer(CALLBACK(src, PROC_REF(slime_legion), holder), 5 SECONDS)
	var/obj/item/slime_extract/M = holder.my_atom
	deltimer(M.qdel_timer)
	..()
	M.qdel_timer = addtimer(CALLBACK(src, PROC_REF(delete_extract), holder), 55, TIMER_STOPPABLE)

/datum/chemical_reaction/slime/slimesummonlegion/proc/slime_legion(datum/reagents/holder)
	if(!holder?.my_atom)
		return
	var/turf/T = get_turf(holder.my_atom)
	playsound(T, 'sound/effects/phasein.ogg', 100, TRUE)
	T.visible_message("<span class='danger'>Z ekstraktu w błysku światła wyrywają się czaszki i popielate kości!</span>")
	for(var/mob/living/carbon/C in viewers(T))
		C.flash_act()
	new /mob/living/simple_animal/hostile/asteroid/hivelord/legion/tendril(T)

/datum/chemical_reaction/slime/lavasteroid
	name = "Slime Lava Steroid"
	id = "m_lavasteroid"
	required_reagents = list(/datum/reagent/toxin/plasma = 1)
	required_other = TRUE
	required_container = /obj/item/slime_extract/darkgrey

/datum/chemical_reaction/slime/lavasteroid/on_reaction(datum/reagents/holder)
	new /obj/item/slimepotion/lavasteroid(get_turf(holder.my_atom))
	..()

//Crimson
/datum/chemical_reaction/slime/techshell
	name = "Slime Techshell"
	id = "m_techshell"
	required_reagents = list(/datum/reagent/blackpowder = 5)
	required_other = TRUE
	required_container = /obj/item/slime_extract/crimson

/datum/chemical_reaction/slime/techshell/on_reaction(datum/reagents/holder)
	var/static/list/techshells = list(
		/obj/item/ammo_casing/shotgun/dragonsbreath,
		/obj/item/ammo_casing/shotgun/pulseslug,
		/obj/item/ammo_casing/shotgun/ion,
		/obj/item/ammo_casing/shotgun/laserslug,
	)
	var/chosen = pick(techshells)
	new chosen(get_turf(holder.my_atom))
	..()

/datum/chemical_reaction/slime/pyroxadone
	name = "Pyroxadone Generation"
	id = "m_pyroxadone"
	results = list(/datum/reagent/medicine/pyroxadone = 3)
	required_reagents = list(/datum/reagent/toxin/plasma = 1)
	required_other = TRUE
	required_container = /obj/item/slime_extract/crimson

// Mikstura z dark grey: ewolucja fauny z lavalandu

/obj/item/slimepotion/lavasteroid
	name = "lavaland steroid"
	desc = "A chemical concoction that changes the makeup of certain fauna native to lavaland, bringing rare mutations to the surface."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "potred"

/obj/item/slimepotion/lavasteroid/pre_attack(atom/A, mob/living/user, params)
	if(!isliving(A))
		return ..()
	var/mob/living/evolving_mob = A
	var/mob/living/new_monster
	if(istype(evolving_mob, /mob/living/simple_animal/hostile/asteroid/goliath/beast) && !istype(evolving_mob, /mob/living/simple_animal/hostile/asteroid/goliath/beast/ancient))
		new_monster = new /mob/living/simple_animal/hostile/asteroid/goliath/beast/ancient(evolving_mob.loc)
	else if(evolving_mob.type == /mob/living/simple_animal/hostile/asteroid/basilisk/watcher)
		if(prob(50))
			new_monster = new /mob/living/simple_animal/hostile/asteroid/basilisk/watcher/icewing(evolving_mob.loc)
		else
			new_monster = new /mob/living/simple_animal/hostile/asteroid/basilisk/watcher/magmawing(evolving_mob.loc)
	else if(evolving_mob.type == /mob/living/simple_animal/hostile/asteroid/hivelord/legion)
		new_monster = new /mob/living/simple_animal/hostile/asteroid/hivelord/legion/dwarf(evolving_mob.loc)

	if(!new_monster)
		to_chat(user, "<span class='warning'>To stworzenie nie reaguje na miksturę!</span>")
		return FALSE

	evolving_mob.mind?.transfer_to(new_monster)
	user.visible_message("<span class='danger'>[evolving_mob] zrzuca dawną postać i wyłania się ze sterty flaków z nowymi, świeżymi kończynami!</span>")
	evolving_mob.gib()
	qdel(src)
	return FALSE

// Nawóz z dark green: szybszy cykl kosztem plonu

/datum/reagent/plantnutriment/slimenutriment
	name = "Living Fertiliser"
	description = "Lepki płyn, który przylega do żywej tkanki i przyspiesza wzrost kosztem plonu."
	color = "#6ed8db"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	tox_prob = 17

/obj/machinery/hydroponics/applyChemicals(datum/reagents/S, mob/user)
	. = ..()
	if(S.has_reagent(/datum/reagent/plantnutriment/slimenutriment, 1))
		yieldmod = 0.8
		mutmod = 1
		cycledelay = 150
		adjustNutri(round(S.get_reagent_amount(/datum/reagent/plantnutriment/slimenutriment)))
	else if(S.has_reagent(/datum/reagent/plantnutriment/eznutriment, 1) || S.has_reagent(/datum/reagent/plantnutriment/left4zednutriment, 1) || S.has_reagent(/datum/reagent/plantnutriment/robustharvestnutriment, 1))
		cycledelay = initial(cycledelay)

#undef SLIME_SPECIAL_ICON
#undef SLIME_CRIMSON_BURN_THRESHOLD
