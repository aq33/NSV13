// AQUILA - two priority directives of the BeeStation traitor rework, turned into plain objectives.
// Poisoning items: BeeStation/BeeStation-Hornet directives/steal/poison.dm + poison_paper + transfer_reagents.
// Beacon: BeeStation/BeeStation-Hornet directives/deploy_beacon, given to blood brother teams.

// Poison several valuable items with a contact toxin

/datum/objective/poison_items
	name = "zatrucie przedmiotów"
	martyr_compatible = TRUE
	/// Items that can be poisoned, the same ones Bee flags with STEAL_DIRECTIVE_TOXIN
	var/static/list/poisonable_items = list(
		/datum/objective_item/steal/caplaser,
		/datum/objective_item/steal/hoslaser,
		/datum/objective_item/steal/handtele,
		/datum/objective_item/steal/hypo,
		/datum/objective_item/steal/nukedisc,
		/datum/objective_item/steal/reactive,
	)
	/// Item paths that have to be poisoned
	var/list/target_paths = list()
	/// Item paths already poisoned
	var/list/poisoned_paths = list()

/datum/objective/poison_items/traitor_roll_setup(datum/antagonist/traitor/rolling)
	if(!length(GLOB.possible_items))
		for(var/item_type in subtypesof(/datum/objective_item/steal))
			new item_type
	var/list/candidates = list()
	for(var/datum/objective_item/item as anything in GLOB.possible_items)
		if(!(item.type in poisonable_items) || !item.owner_present())
			continue
		if(owner && (owner.assigned_role in item.excludefromjob))
			continue
		candidates[item.targetitem] = item.name
	if(length(candidates) < 2)
		return FALSE
	target_paths = list()
	for(var/i in 1 to min(rand(2, 3), length(candidates)))
		var/path = pick(candidates)
		target_paths[path] = candidates[path]
		candidates -= path
	update_explanation_text()
	give_papers()
	return TRUE

/datum/objective/poison_items/proc/give_papers()
	var/datum/mind/receiver = owner || pick(get_owners())
	if(!ishuman(receiver?.current))
		return
	var/mob/living/carbon/human/H = receiver.current
	for(var/i in 1 to length(target_paths))
		var/obj/item/poison_paper/objective/paper = new(get_turf(H))
		paper.objective = src
		H.equip_in_one_of_slots(paper, list("backpack" = ITEM_SLOT_BACKPACK, "left pocket" = ITEM_SLOT_LPOCKET, "right pocket" = ITEM_SLOT_RPOCKET, "hands" = ITEM_SLOT_HANDS))

/datum/objective/poison_items/admin_edit(mob/admin)
	traitor_roll_setup()

/datum/objective/poison_items/update_explanation_text()
	var/list/names = list()
	for(var/path in target_paths)
		names += target_paths[path]
	explanation_text = "Nanotrasen ma kilka cennych przedmiotów, którymi chcemy się zająć. Nałóż dostarczoną truciznę kontaktową na każdy z nich: [english_list(names, and_text = " oraz ")] Kto dotknie zatrutego przedmiotu gołymi rękami, padnie. Nakładaj ją w rękawiczkach."

/datum/objective/poison_items/check_completion()
	if(completed)
		return TRUE
	for(var/path in target_paths)
		if(!(path in poisoned_paths))
			return FALSE
	return TRUE

/// Called by the poison paper when it got applied to an item
/datum/objective/poison_items/proc/on_poison_applied(obj/item/target)
	for(var/path in target_paths)
		if(istype(target, path) && !(path in poisoned_paths))
			poisoned_paths += path
			return TRUE
	return FALSE

/obj/item/poison_paper
	name = "papier z trucizną"
	desc = "Arkusz papieru do przenoszenia toksyny na powierzchnię innego przedmiotu. Następna osoba, która dotknie przedmiotu bez ochrony, przyjmie dawkę. Nakładaj w rękawiczkach, żeby się nie otruć."
	icon = 'aquila/icons/obj/traitor_devices.dmi'
	icon_state = "toxin_slip"
	w_class = WEIGHT_CLASS_SMALL
	resistance_flags = FLAMMABLE
	/// Toxins put on the paper
	var/list/toxins = list(/datum/reagent/toxin/initropidril = 6, /datum/reagent/toxin/sodium_thiopental = 4)

/obj/item/poison_paper/Initialize(mapload)
	. = ..()
	create_reagents(10)
	reagents.add_reagent_list(toxins)
	update_icon()

/obj/item/poison_paper/update_icon_state()
	icon_state = reagents?.total_volume ? initial(icon_state) : "[initial(icon_state)]_used"
	return ..()

/obj/item/poison_paper/pre_attack(atom/A, mob/living/user, params)
	if(!isitem(A) || A == src)
		return ..()
	if(!reagents.total_volume)
		to_chat(user, "<span class='warning'>Na [src] nie ma już trucizny!</span>")
		return FALSE
	to_chat(user, "<span class='notice'>Zaczynasz nakładać truciznę z [src] na [A].</span>")
	if(!do_after(user, 3 SECONDS, target = A))
		return FALSE
	to_chat(user, "<span class='notice'>Przenosisz truciznę kontaktową z [src] na [A].</span>")
	A.AddComponent(/datum/component/contact_poison, reagents)
	log_game("[key_name(user)] applied contact poison to [A] at [AREACOORD(A)].")
	on_applied(A, user)
	update_icon()
	return FALSE

/obj/item/poison_paper/proc/on_applied(obj/item/target, mob/living/user)
	return

/obj/item/poison_paper/objective
	var/datum/objective/poison_items/objective

/obj/item/poison_paper/objective/Destroy()
	objective = null
	return ..()

/obj/item/poison_paper/objective/on_applied(obj/item/target, mob/living/user)
	if(objective && !QDELETED(objective) && objective.on_poison_applied(target))
		to_chat(user, "<span class='notice'>Ten przedmiot był na liście. Jeden z głowy.</span>")

/// Item covered in a contact toxin. The first carbon to pick it up without gloves gets the dose.
/datum/component/contact_poison
	dupe_mode = COMPONENT_DUPE_ALLOWED
	var/datum/reagents/reagents

/datum/component/contact_poison/Initialize(datum/reagents/reagent_source)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	reagents = new /datum/reagents(reagent_source.maximum_volume)
	reagent_source.trans_to(reagents, reagent_source.total_volume)

/datum/component/contact_poison/Destroy(force, silent)
	QDEL_NULL(reagents)
	return ..()

/datum/component/contact_poison/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equipped))
	RegisterSignal(parent, COMSIG_COMPONENT_CLEAN_ACT, PROC_REF(on_clean))

/datum/component/contact_poison/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ITEM_EQUIPPED, COMSIG_COMPONENT_CLEAN_ACT))

/datum/component/contact_poison/proc/on_equipped(obj/item/source, mob/living/carbon/equipper, slot)
	SIGNAL_HANDLER
	if(slot != ITEM_SLOT_HANDS || !iscarbon(equipper))
		return
	var/obj/item/clothing/gloves = equipper.gloves
	if(gloves && (gloves.body_parts_covered & HANDS))
		return
	reagents.trans_to(equipper, reagents.total_volume)
	to_chat(equipper, "<span class='warning'>Czujesz lekkie mrowienie w dłoniach.</span>")
	qdel(src)

/datum/component/contact_poison/proc/on_clean(datum/source)
	SIGNAL_HANDLER
	qdel(src)

// Blood brother beacon - deploy it at the site on your team's channel and hold it for 4 minutes

/// Where every brother team has to deploy its beacon this round
GLOBAL_DATUM(brother_beacon_site, /turf)
/// The beacon currently standing at the site
GLOBAL_DATUM(brother_beacon_active, /obj/structure/brother_beacon)
/// Every beacon objective of the round, to tell the teams what is going on
GLOBAL_LIST_EMPTY(brother_beacon_objectives)

/datum/objective/brother_beacon
	name = "beacon braci"
	martyr_compatible = TRUE
	/// Channel of this team, 0-8
	var/channel

/datum/objective/brother_beacon/Destroy()
	GLOB.brother_beacon_objectives -= src
	return ..()

/// Picks the site and a free channel and gives every brother a beacon. FALSE if there is no maintenance to use.
/datum/objective/brother_beacon/proc/setup_beacon()
	if(!GLOB.brother_beacon_site)
		var/list/maintenance = get_station_areas_of_types(list(/area/maintenance))
		while(length(maintenance) && !GLOB.brother_beacon_site)
			var/area/picked = pick_n_take(maintenance)
			var/list/turfs = list()
			for(var/turf/open/floor/T in picked)
				if(!is_blocked_turf(T, TRUE))
					turfs += T
			if(length(turfs))
				GLOB.brother_beacon_site = pick(turfs)
	if(!GLOB.brother_beacon_site)
		return FALSE
	var/list/free_channels = list(0, 1, 2, 3, 4, 5, 6, 7, 8)
	for(var/datum/objective/brother_beacon/other as anything in GLOB.brother_beacon_objectives)
		free_channels -= other.channel
	if(!length(free_channels))
		return FALSE
	channel = pick(free_channels)
	GLOB.brother_beacon_objectives += src
	update_explanation_text()
	for(var/datum/mind/member as anything in get_owners())
		if(ishuman(member.current))
			var/mob/living/carbon/human/H = member.current
			var/obj/item/brother_beacon/beacon = new(get_turf(H))
			H.equip_in_one_of_slots(beacon, list("backpack" = ITEM_SLOT_BACKPACK, "left pocket" = ITEM_SLOT_LPOCKET, "right pocket" = ITEM_SLOT_RPOCKET, "hands" = ITEM_SLOT_HANDS))
	return TRUE

/datum/objective/brother_beacon/update_explanation_text()
	var/area/site_area = get_area(GLOB.brother_beacon_site)
	explanation_text = "Rozstawcie beacon w technicznych ([site_area?.name || "nieznane miejsce"]) na kanale waszej drużyny ([brother_beacon_channel_name(channel)]) i utrzymajcie go przez 4 minuty. Inni agenci mogą przestawić go na swój kanał - nie dajcie im."

/datum/objective/brother_beacon/admin_edit(mob/admin)
	setup_beacon()

/datum/objective/brother_beacon/proc/notify(message)
	for(var/datum/mind/member as anything in get_owners())
		to_chat(member.current, "<span class='alertsyndie'>[message]</span>")

/// The beacon objective of whoever is using the beacon, if any
/proc/get_brother_beacon_objective(mob/user)
	for(var/datum/antagonist/antag as anything in user?.mind?.antag_datums)
		var/datum/objective/brother_beacon/objective = locate() in antag.objectives
		if(objective)
			return objective
	return null

/proc/brother_beacon_channel_name(channel)
	var/static/list/names = list("zielony", "fioletowy", "żółty", "pomarańczowy", "czerwony", "czarny", "biały", "niebieski", "brązowy")
	return names[channel + 1]

/proc/brother_beacon_channel_color(channel)
	var/static/list/colors = list("#4bad4b", "#c179d9", "#e0da84", "#e38e3f", "#f65f5f", "#4c4c4c", "#d5d5d4", "#5960e9", "#744d23")
	return colors[channel + 1]

/obj/item/brother_beacon
	name = "beacon łączności"
	desc = "Przenośny beacon do nawiązania łączności dalekiego zasięgu."
	icon = 'aquila/icons/obj/traitor_devices.dmi'
	icon_state = "beacon_base"
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/brother_beacon/examine(mob/user)
	. = ..()
	var/datum/objective/brother_beacon/objective = get_brother_beacon_objective(user)
	if(objective && GLOB.brother_beacon_site)
		. += "<span class='notice'>Trzeba go rozstawić w [get_area_name(GLOB.brother_beacon_site)]. Użyj go w ręce na miejscu.</span>"

/obj/item/brother_beacon/attack_self(mob/user)
	var/datum/objective/brother_beacon/objective = get_brother_beacon_objective(user)
	if(!objective)
		to_chat(user, "<span class='warning'>Nie wiesz, co z tym zrobić.</span>")
		return
	if(GLOB.brother_beacon_active)
		to_chat(user, "<span class='warning'>Jeden beacon już działa. Znajdź go i przestaw na swój kanał.</span>")
		return
	if(!GLOB.brother_beacon_site || get_dist(user, GLOB.brother_beacon_site) > 5 || user.z != GLOB.brother_beacon_site.z)
		to_chat(user, "<span class='warning'>Jesteś za daleko od miejsca rozstawienia ([get_area_name(GLOB.brother_beacon_site)]).</span>")
		return
	balloon_alert(user, "rozstawianie...")
	if(!do_after(user, 3 SECONDS, target = user) || GLOB.brother_beacon_active)
		return
	var/obj/structure/brother_beacon/deployed = new(get_turf(user))
	deployed.set_channel(objective.channel, user)
	log_game("[key_name(user)] deployed a brother beacon at [AREACOORD(deployed)].")
	qdel(src)

/obj/structure/brother_beacon
	name = "beacon łączności"
	desc = "Mały beacon próbujący nawiązać łączność z nieznanym źródłem."
	icon = 'aquila/icons/obj/traitor_devices.dmi'
	icon_state = "beacon_base"
	anchored = TRUE
	density = TRUE
	max_integrity = 100
	light_range = 2
	light_power = 0.7
	var/channel = 0
	var/time_left = 4 MINUTES
	var/finished = FALSE
	COOLDOWN_DECLARE(channel_cooldown)

/obj/structure/brother_beacon/Initialize(mapload)
	. = ..()
	GLOB.brother_beacon_active = src
	START_PROCESSING(SSobj, src)

/obj/structure/brother_beacon/Destroy()
	STOP_PROCESSING(SSobj, src)
	if(GLOB.brother_beacon_active == src)
		GLOB.brother_beacon_active = null
	if(!finished)
		for(var/datum/objective/brother_beacon/objective as anything in GLOB.brother_beacon_objectives)
			objective.notify("Beacon został zniszczony! Rozstawcie kolejny, jeśli macie.")
	return ..()

/obj/structure/brother_beacon/update_overlays()
	. = ..()
	var/mutable_appearance/glow = mutable_appearance(icon, "beacon_overlay")
	glow.color = brother_beacon_channel_color(channel)
	. += glow

/obj/structure/brother_beacon/proc/set_channel(new_channel, mob/user)
	var/old_channel = channel
	channel = new_channel
	set_light_color(brother_beacon_channel_color(channel))
	update_icon()
	if(time_left < 30 SECONDS)
		time_left = 30 SECONDS
	for(var/datum/objective/brother_beacon/objective as anything in GLOB.brother_beacon_objectives)
		if(objective.channel == channel)
			objective.notify("Beacon nadaje teraz na waszym kanale. Utrzymajcie go przez [DisplayTimeText(time_left)].")
		else if(objective.channel == old_channel || !user)
			objective.notify("Beacon nadaje teraz na kanale innej drużyny ([brother_beacon_channel_name(channel)])! Przestawcie go na [brother_beacon_channel_name(objective.channel)] w ciągu [DisplayTimeText(time_left)].")

/obj/structure/brother_beacon/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	INVOKE_ASYNC(src, PROC_REF(pick_channel), user)
	return TRUE

/obj/structure/brother_beacon/proc/pick_channel(mob/user)
	var/datum/objective/brother_beacon/objective = get_brother_beacon_objective(user)
	if(!objective || finished)
		return
	if(!COOLDOWN_FINISHED(src, channel_cooldown))
		to_chat(user, "<span class='warning'>[src] potrzebuje jeszcze chwili, zanim zmieni kanał.</span>")
		return
	var/list/choices = list()
	for(var/i in 0 to 8)
		choices[brother_beacon_channel_name(i)] = i
	var/picked = tgui_input_list(user, "Kanał beacona", "Beacon", choices, brother_beacon_channel_name(channel))
	if(isnull(picked) || finished || !user.canUseTopic(src, BE_CLOSE))
		return
	COOLDOWN_START(src, channel_cooldown, 10 SECONDS)
	set_channel(choices[picked], user)

/obj/structure/brother_beacon/process(delta_time)
	if(finished)
		return PROCESS_KILL
	time_left -= delta_time * 1 SECONDS
	if(time_left > 0)
		return
	finished = TRUE
	for(var/datum/objective/brother_beacon/objective as anything in GLOB.brother_beacon_objectives)
		if(objective.channel == channel)
			objective.completed = TRUE
			objective.notify("Łączność nawiązana na waszym kanale. Cel wykonany!")
		else
			objective.notify("Łączność nawiązano na kanale innej drużyny. Przegraliście ten wyścig.")
	INVOKE_ASYNC(src, PROC_REF(self_destruct))
	return PROCESS_KILL

/obj/structure/brother_beacon/proc/self_destruct()
	balloon_alert_to_viewers("nawiązuje łączność i uruchamia autodestrukcję!")
	for(var/delay in list(5 SECONDS, 3 SECONDS, 2 SECONDS, 1 SECONDS, 0.5 SECONDS, 0.3 SECONDS, 0.2 SECONDS))
		playsound(src, 'sound/items/timer.ogg', 60)
		sleep(delay)
	if(QDELETED(src))
		return
	explosion(src, 0, 0, 4, 6)
	qdel(src)
