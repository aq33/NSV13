// AQUILA - demon cieni (port z ParadiseSS13), zastępuje koszmara jako duch z eventu i midroundu.

/mob/living/simple_animal/shadow_demon
	name = "shadow demon"
	real_name = "demon cieni"
	desc = "A creature that's barely tangible, you can feel its gaze piercing you."
	icon = 'aquila/icons/mob/shadow_demon.dmi'
	icon_state = "shadow_demon"
	icon_living = "shadow_demon"
	speak_emote = list("bulgocze", "zawodzi", "skrzeczy")
	response_help = "rozmyśla się i nie dotyka"
	response_disarm = "macha rękami na"
	response_harm = "uderza"
	mob_biotypes = list(MOB_ORGANIC, MOB_HUMANOID)
	speed = 1
	combat_mode = TRUE
	stop_automated_movement = TRUE
	move_resist = MOVE_FORCE_STRONG
	attack_sound = 'aquila/sound/shadowdemon/shadowattack2.ogg'
	deathsound = 'aquila/sound/shadowdemon/shadowdeath.ogg'
	deathmessage = "rozpływa się w cieniu z przeraźliwym wrzaskiem!"
	// Oddycha jak demony z Paradise: w próżni leczenie w ciemności ledwo nadąża za duszeniem
	atmos_requirements = list("min_oxy" = 16, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 18
	minbodytemp = 0
	maxbodytemp = INFINITY
	faction = list("demon")
	attacktext = "dziko rozszarpuje"
	maxHealth = 200
	health = 200
	healable = FALSE
	environment_smash = ENVIRONMENT_SMASH_STRUCTURES
	obj_damage = 50
	melee_damage = 30
	hardattacks = TRUE
	see_in_dark = 10
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE // widzi, gdzie jest ciemno
	mobchatspan = "cultmobsay"
	loot = list(/obj/item/organ/heart/shadow_demon)
	del_on_death = TRUE
	/// Czy wisi alert o świetle
	var/thrown_alert = FALSE
	/// Czy właśnie owija kogoś w kokon
	var/wrapping = FALSE
	/// TRUE, gdy leci cień-hak: w tym czasie nie da się wejść w cień
	var/block_shadow_crawl = FALSE
	/// Czas ostatniej blokady, żeby stary timer nie zdjął nowej
	var/last_block_shadow_crawl = 0
	var/obj/effect/proc_holder/spell/shadow_crawl/crawl_spell
	var/playstyle_string = "<span class='big bold'>Jesteś demonem cieni!</span><br>\
		<b>Jesteś zabójczym drapieżnikiem z zasadzki. Ciemność leczy twoje rany i przyspiesza cię, \
		ale światło jest twoim najgorszym wrogiem - zbyt długo w nim przebywając, zginiesz.</b><br>\
		<b>Cień-hak przyciąga ofiary albo ciebie do ściany i gasi światła wokół miejsca trafienia. Twoje ciosy gaszą światło w przedmiotach.</b><br>\
		<b>Martwe ofiary możesz owinąć w kokon cienia, który pochłania światło wokół siebie. Alt+klik na kokonie włącza dźwięki wabiące kolejne ofiary.</b><br>\
		<b>Cienisty pełz pozwala wtopić się w ciemność i przenikać przez ściany. Wyjść możesz tylko na ciemnym polu.</b><br>\
		<b><i>Nie pamiętasz niczego ze swoich poprzednich żyć i nie zapamiętasz niczego z tego po śmierci.</i></b>"

/mob/living/simple_animal/shadow_demon/Initialize(mapload)
	. = ..()
	AddSpell(new /obj/effect/proc_holder/spell/aimed/shadow_grapple)
	crawl_spell = new
	AddSpell(crawl_spell)
	AddSpell(new /obj/effect/proc_holder/spell/targeted/telepathy/shadow_demon)
	if(istype(loc, /obj/effect/dummy/phased_mob/shadow_crawl))
		crawl_spell.phased = TRUE
	RegisterSignal(src, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))
	add_overlay(emissive_appearance(icon, "shadow_demon_eye_glow_overlay"))
	check_darkness()

/mob/living/simple_animal/shadow_demon/Destroy()
	crawl_spell = null
	return ..()

/mob/living/simple_animal/shadow_demon/Life(seconds, times_fired)
	. = ..()
	if(QDELETED(src) || stat == DEAD)
		return
	var/lum_count = check_darkness()
	var/damage_mod = istype(loc, /obj/effect/dummy/phased_mob/shadow_crawl) ? 0.5 : 1
	if(lum_count > SHADOW_DEMON_LIGHT_THRESHOLD)
		adjustBruteLoss(40 * damage_mod) // ok. 10 sekund w świetle
		SEND_SOUND(src, sound('sound/weapons/sear.ogg'))
		to_chat(src, "<span class='userdanger'>Światło cię parzy!</span>")
	else
		adjustBruteLoss(-20)

/mob/living/simple_animal/shadow_demon/death(gibbed)
	// Serce ma wypaść na podłogę, a nie do cienia
	if(istype(loc, /obj/effect/dummy/phased_mob/shadow_crawl))
		var/obj/effect/dummy/phased_mob/shadow_crawl/holder = loc
		forceMove(get_turf(holder))
		qdel(holder)
	return ..()

/mob/living/simple_animal/shadow_demon/proc/on_moved()
	SIGNAL_HANDLER
	check_darkness()

/// Aktualizuje alert, przezroczystość i prędkość. Zwraca jasność pola.
/mob/living/simple_animal/shadow_demon/proc/check_darkness()
	var/turf/T = get_turf(src)
	if(!T)
		return 0
	var/lum_count = T.get_lumcount()
	if(lum_count > SHADOW_DEMON_LIGHT_THRESHOLD)
		if(!thrown_alert)
			thrown_alert = TRUE
			throw_alert("light", /atom/movable/screen/alert/lightexposure)
		alpha = 255
		if(speed != initial(speed))
			set_varspeed(initial(speed))
	else
		if(thrown_alert)
			thrown_alert = FALSE
			clear_alert("light")
		alpha = 125
		if(speed != 0.5)
			set_varspeed(0.5)
	return lum_count

/mob/living/simple_animal/shadow_demon/UnarmedAttack(atom/A, proximity_flag, list/modifiers)
	attack_sound = pick('aquila/sound/shadowdemon/shadowattack2.ogg', 'aquila/sound/shadowdemon/shadowattack3.ogg', 'aquila/sound/shadowdemon/shadowattack4.ogg')
	if(!ishuman(A) || !proximity_flag)
		if(isitem(A))
			A.extinguish_light()
		return ..()
	var/mob/living/carbon/human/target = A
	if(target.stat != DEAD)
		return ..()
	if(wrapping)
		to_chat(src, "<span class='notice'>Już kogoś owijasz.</span>")
		return
	visible_message("<span class='danger'>[src] zaczyna owijać [target] cienistymi nićmi.</span>")
	wrapping = TRUE
	if(!do_after(src, 4 SECONDS, target = target))
		wrapping = FALSE
		return
	wrapping = FALSE
	if(QDELETED(target) || !isturf(target.loc))
		return
	target.visible_message("<span class='warning'><b>[src] zamyka [target] w eterycznym kokonie, z którego zaczyna pełznąć ciemność.</b></span>")
	var/obj/structure/shadowcocoon/C = new(get_turf(target))
	target.extinguish_light()
	target.forceMove(C)
	var/datum/antagonist/shadow_demon/antag = mind?.has_antag_datum(/datum/antagonist/shadow_demon)
	if(antag && target.mind) // do celu liczą się tylko gracze, nie puste ciała
		antag.cocooned_victims |= REF(target)

/mob/living/simple_animal/shadow_demon/hitby(atom/movable/AM, skipcatch, hitpush = TRUE, blocked = FALSE, datum/thrownthing/throwingdatum)
	if(isliving(AM)) // przyciągnięta cień-hakiem ofiara nie odpycha demona
		return
	return ..()

/mob/living/simple_animal/shadow_demon/get_stat_tab_status()
	var/list/tab_data = ..()
	var/datum/antagonist/shadow_demon/antag = mind?.has_antag_datum(/datum/antagonist/shadow_demon)
	if(antag)
		tab_data["Ofiary w kokonach"] = GENERATE_STAT_TEXT("[length(antag.cocooned_victims)]")
	return tab_data

/mob/living/simple_animal/shadow_demon/proc/set_block_shadow_crawl()
	last_block_shadow_crawl = world.time
	block_shadow_crawl = TRUE
	addtimer(CALLBACK(src, PROC_REF(check_block_shadow_crawl), last_block_shadow_crawl), 10 SECONDS)

/mob/living/simple_animal/shadow_demon/proc/unblock_shadow_crawl()
	last_block_shadow_crawl = 0
	block_shadow_crawl = FALSE

/mob/living/simple_animal/shadow_demon/proc/check_block_shadow_crawl(block_time)
	// 10 sekund od strzału, a hak nie zdjął blokady sam
	if(block_time == last_block_shadow_crawl)
		to_chat(src, "<span class='warning'>Znów możesz użyć cienistego pełzu.</span>")
		unblock_shadow_crawl()

/atom/movable/screen/alert/lightexposure
	name = "Wystawienie na światło"
	desc = "Stoisz w świetle. Uciekaj w ciemność, zanim cię spali!"
	icon = 'aquila/icons/mob/shadow_demon.dmi'
	icon_state = "lightexposure"

// Kokon cienia

/obj/structure/shadowcocoon
	name = "shadowy cocoon"
	desc = "Something wrapped in what seems to be manifested darkness. Its surface distorts unnaturally, and it emanates deep shadows."
	icon = 'aquila/icons/mob/shadow_demon.dmi'
	icon_state = "shadowcocoon"
	light_power = -4
	light_range = 6
	light_color = "#ddd6cf"
	max_integrity = 100
	anchored = TRUE
	density = FALSE
	/// Ile ticków SSobj (ok. 2 sekundy) minęło od ostatniego wabiącego dźwięku
	var/time_since_last_hallucination = 0
	/// Czy kokon milczy, czy wabi ofiary dźwiękami
	var/silent = TRUE

/obj/structure/shadowcocoon/Initialize(mapload)
	. = ..()
	playsound(loc, 'aquila/sound/shadowdemon/shadownode.ogg', 5, TRUE, -1)
	START_PROCESSING(SSobj, src)

/obj/structure/shadowcocoon/Destroy()
	STOP_PROCESSING(SSobj, src)
	for(var/atom/movable/A as anything in contents)
		A.forceMove(loc)
	return ..()

/obj/structure/shadowcocoon/examine(mob/user)
	. = ..()
	if(istype(user, /mob/living/simple_animal/shadow_demon))
		. += silent ? "<span class='notice'>Macki są spokojne i nie wydają dźwięków.</span>" : "<span class='notice'>Macki są pobudzone <b>i co jakiś czas wydają dźwięki, by zwabić kolejne ofiary.</b></span>"
		. += "<span class='notice'>Alt+klik przełącza wabienie ofiar dźwiękami.</span>"

/obj/structure/shadowcocoon/process()
	time_since_last_hallucination++
	for(var/atom/to_darken in range(4, src))
		if(prob(60))
			continue
		if(isliving(to_darken))
			to_darken.extinguish_light()
			continue
		if(!to_darken.is_emitting_light())
			continue
		if(istype(to_darken, /obj/item/weldingtool))
			var/obj/item/weldingtool/welder_to_darken = to_darken
			welder_to_darken.reagents?.remove_reagent(/datum/reagent/fuel, welder_to_darken.reagents.get_reagent_amount(/datum/reagent/fuel))
			welder_to_darken.extinguish_light()
			continue
		if(istype(to_darken, /obj/item/flashlight/flare))
			to_darken.extinguish_light(TRUE)
			continue
		to_darken.extinguish_light()
	if(!silent && time_since_last_hallucination >= rand(8, 12))
		playsound(src, pick('aquila/sound/shadowdemon/shadowhalluc1.ogg', 'aquila/sound/shadowdemon/shadowhalluc2.ogg', 'aquila/sound/shadowdemon/shadowhalluc3.ogg', 'sound/machines/airlockopen.ogg', 'sound/machines/airlockclose.ogg', 'sound/machines/boltsup.ogg', "bodyfall", 'sound/weapons/egloves.ogg'), 50)
		time_since_last_hallucination = 0

/obj/structure/shadowcocoon/AltClick(mob/user)
	if(!istype(user, /mob/living/simple_animal/shadow_demon) || !user.Adjacent(src))
		return ..()
	if(silent)
		to_chat(user, "<span class='notice'>Wykręcasz ofiarę uwięzioną w [src], by zwabiała kolejne.</span>")
		silent = FALSE
		return
	to_chat(user, "<span class='notice'>Macki [src] wracają do pierwotnego kształtu.</span>")
	silent = TRUE

/obj/structure/shadowcocoon/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	if(damage_type != BURN)
		return ..()
	playsound(loc, 'sound/items/welder.ogg', 100, TRUE)

/obj/structure/shadowcocoon/obj_destruction(damage_flag)
	visible_message("<span class='danger'>[src] pęka, a cienie tańczące wokół niego znikają.</span>")
	return ..()

// Serce ciemności - łup z demona, zjedzone daje cień-hak

/obj/item/organ/heart/shadow_demon
	name = "heart of darkness"
	desc = "It still beats furiously, emitting an aura of fear."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "demon_heart-on"
	color = "#1C1C1C"
	decay_factor = 0

/obj/item/organ/heart/shadow_demon/update_icon()
	return // zawsze bije

/obj/item/organ/heart/shadow_demon/Stop()
	return FALSE

/obj/item/organ/heart/shadow_demon/attack(mob/M, mob/living/carbon/user, obj/target)
	if(M != user)
		return ..()
	user.visible_message("<span class='warning'>[user] podnosi [src] do ust i wgryza się w to zębami!</span>", \
						"<span class='danger'>Ogarnia cię nienaturalny głód. Podnosisz [src] do ust i pożerasz!</span>")
	playsound(user, 'sound/magic/demon_consume.ogg', 50, TRUE)
	user.temporarilyRemoveItemFromInventory(src, TRUE)
	Insert(user)

/obj/item/organ/heart/shadow_demon/Insert(mob/living/carbon/M, special = 0, drop_if_replaced = TRUE)
	. = ..()
	if(M.mind && !(locate(/obj/effect/proc_holder/spell/aimed/shadow_grapple) in M.mind.spell_list))
		M.mind.AddSpell(new /obj/effect/proc_holder/spell/aimed/shadow_grapple(null))
		to_chat(M, "<span class='userdanger'>Czujesz, jak w twoje ręce wsiąka ciemność... możesz wystrzeliwać cień-hak!</span>")

/obj/item/organ/heart/shadow_demon/Remove(mob/living/carbon/M, special = 0)
	if(M.mind)
		M.mind.RemoveSpell(/obj/effect/proc_holder/spell/aimed/shadow_grapple)
	return ..()

// Antagonista

/datum/antagonist/shadow_demon
	name = "Demon cieni"
	roundend_category = "demony cieni"
	antagpanel_category = "Demon cieni"
	banning_key = ROLE_SHADOW_DEMON
	show_in_antagpanel = FALSE
	show_name_in_check_antagonists = TRUE
	show_to_ghosts = TRUE
	/// Ofiary owinięte w kokon (REF), żeby nie liczyć dwa razy tej samej
	var/list/cocooned_victims = list()

/datum/antagonist/shadow_demon/on_gain()
	forge_objectives()
	return ..()

/datum/antagonist/shadow_demon/greet()
	var/mob/living/simple_animal/shadow_demon/demon = owner.current
	if(istype(demon))
		to_chat(owner.current, demon.playstyle_string)
	owner.announce_objectives()

/datum/antagonist/shadow_demon/proc/forge_objectives()
	var/datum/objective/shadow_demon_cocoon/cocoon_objective = new
	cocoon_objective.owner = owner
	objectives += cocoon_objective
	log_objective(owner, cocoon_objective.explanation_text)
	var/datum/objective/survive/survive_objective = new
	survive_objective.owner = owner
	objectives += survive_objective
	log_objective(owner, survive_objective.explanation_text)

/datum/objective/shadow_demon_cocoon
	name = "Owiń ofiary w kokony"
	target_amount = 3

/datum/objective/shadow_demon_cocoon/New()
	target_amount = rand(3, 6)
	explanation_text = "Owiń w kokony cienia [target_amount] martwych członków załogi."
	return ..()

/datum/objective/shadow_demon_cocoon/check_completion()
	var/total = 0
	for(var/datum/mind/M as anything in get_owners())
		var/datum/antagonist/shadow_demon/antag = M.has_antag_datum(/datum/antagonist/shadow_demon)
		if(antag)
			total += length(antag.cocooned_victims)
	return total >= target_amount || ..()
