/datum/species/golem
	// Animated beings of stone. They have increased defenses, and do not need to breathe. They're also slow as fuuuck.
	name = "\improper Golem"
	id = "iron_golem"
	species_traits = list(NOBLOOD,MUTCOLORS,NO_UNDERWEAR,NOTRANSSTING)
	inherent_traits = list(TRAIT_RESISTHEAT,TRAIT_NOBREATH,TRAIT_RESISTCOLD,TRAIT_RESISTHIGHPRESSURE,TRAIT_RESISTLOWPRESSURE,TRAIT_NOFIRE,TRAIT_NOGUNS,TRAIT_RADIMMUNE,TRAIT_PIERCEIMMUNE,TRAIT_NODISMEMBER, TRAIT_NONECRODISEASE)
	inherent_biotypes = list(MOB_INORGANIC, MOB_HUMANOID)
	mutant_organs = list(/obj/item/organ/adamantine_resonator)
	mutanttongue = /obj/item/organ/tongue/golem
	speedmod = 2
	armor = 55
	siemens_coeff = 0
	punchdamage = 11
	no_equip = list(ITEM_SLOT_MASK, ITEM_SLOT_OCLOTHING, ITEM_SLOT_GLOVES, ITEM_SLOT_FEET, ITEM_SLOT_ICLOTHING, ITEM_SLOT_SUITSTORE)
	nojumpsuit = 1
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC
	sexes = FALSE
	damage_overlay_type = ""
	meat = /obj/item/food/meat/slab/human/mutant/golem
	species_language_holder = /datum/language_holder/golem
	// To prevent golem subtypes from overwhelming the odds when random species
	// changes, only the Random Golem type can be chosen
	species_chest = /obj/item/bodypart/chest/golem
	species_head = /obj/item/bodypart/head/golem
	species_l_arm = /obj/item/bodypart/l_arm/golem
	species_r_arm = /obj/item/bodypart/r_arm/golem
	species_l_leg = /obj/item/bodypart/l_leg/golem
	species_r_leg = /obj/item/bodypart/r_leg/golem

	fixed_mut_color = "aaa"
	swimming_component = /datum/component/swimming/golem
	var/info_text = "Jako <span class='danger'>żelazny golem</span> nie masz żadnych specjalnych cech."
	var/random_eligible = TRUE //If false, the golem subtype can't be made through golem mutation toxin

	var/prefix = "Iron"
	var/list/special_names = list("Tarkus")
	var/human_surname_chance = 3
	var/special_name_chance = 5
	var/owner //dobby is a free golem

/datum/species/golem/random_name(gender,unique,lastname)
	var/golem_surname = pick(GLOB.golem_names)
	// 3% chance that our golem has a human surname, because
	// cultural contamination
	if(prob(human_surname_chance))
		golem_surname = human_last_name_random()
	else if(special_names && special_names.len && prob(special_name_chance))
		golem_surname = pick(special_names)

	var/golem_name = "[prefix] [golem_surname]"
	return golem_name

/datum/species/golem/random
	name = "Random golem"
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN
	var/static/list/random_golem_types

/datum/species/golem/random/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	..()
	if(!random_golem_types)
		random_golem_types = subtypesof(/datum/species/golem) - type
		for(var/V in random_golem_types)
			var/datum/species/golem/G = V
			if(!initial(G.random_eligible))
				random_golem_types -= G
	var/datum/species/golem/golem_type = pick(random_golem_types)
	var/mob/living/carbon/human/H = C
	H.set_species(golem_type)
	to_chat(H, "[initial(golem_type.info_text)]")

/datum/species/golem/adamantine
	name = "Adamantine Golem"
	id = "adamantine_golem"
	meat = /obj/item/food/meat/slab/human/mutant/golem/adamantine
	mutant_organs = list(/obj/item/organ/adamantine_resonator, /obj/item/organ/vocal_cords/adamantine)
	fixed_mut_color = "4ed"
	info_text = "Jako <span class='danger'>adamantytowy golem</span> masz specjalne struny głosowe, dzięki którym możesz \"rezonować\" wiadomości do wszystkich golemów. Twój unikalny skład mineralny czyni cię odpornym na większość magii."
	prefix = "Adamantine"
	special_names = null

/datum/species/golem/adamantine/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	..()
	ADD_TRAIT(C, TRAIT_ANTIMAGIC, SPECIES_TRAIT)

/datum/species/golem/adamantine/on_species_loss(mob/living/carbon/C)
	REMOVE_TRAIT(C, TRAIT_ANTIMAGIC, SPECIES_TRAIT)
	..()

//The suicide bombers of golemkind
/datum/species/golem/plasma
	name = "Plasma Golem"
	id = "plasma_golem"
	fixed_mut_color = "a3d"
	meat = /obj/item/stack/ore/plasma
	//Can burn and takes damage from heat
	inherent_traits = list(TRAIT_NOBREATH, TRAIT_RESISTCOLD,TRAIT_RESISTHIGHPRESSURE,TRAIT_RESISTLOWPRESSURE,TRAIT_NOGUNS,TRAIT_RADIMMUNE,TRAIT_PIERCEIMMUNE,TRAIT_NODISMEMBER) //no RESISTHEAT, NOFIRE
	info_text = "Jako <span class='danger'>plazmowy golem</span> łatwo się zapalasz. Uważaj - jeśli rozgrzejesz się za bardzo podczas palenia, wybuchniesz!"
	heatmod = 0 //fine until they blow up
	prefix = "Plasma"
	special_names = list("Flood","Fire","Bar","Man")
	var/boom_warning = FALSE
	var/datum/action/innate/ignite/ignite

/datum/species/golem/plasma/spec_life(mob/living/carbon/human/H)
	if(H.bodytemperature > 750)
		if(!boom_warning && H.on_fire)
			to_chat(H, "<span class='userdanger'>Czujesz, że w każdej chwili możesz wybuchnąć!</span>")
			boom_warning = TRUE
	else
		if(boom_warning)
			to_chat(H, "<span class='notice'>Czujesz się stabilniej.</span>")
			boom_warning = FALSE

	if(H.bodytemperature > 850 && H.on_fire && prob(25))
		explosion(get_turf(H),1,2,4,flame_range = 5)
		if(H)
			H.gib()
	if(H.fire_stacks < 2) //flammable
		H.adjust_fire_stacks(1)
	..()

/datum/species/golem/plasma/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	..()
	if(ishuman(C))
		ignite = new
		ignite.Grant(C)

/datum/species/golem/plasma/on_species_loss(mob/living/carbon/C)
	if(ignite)
		ignite.Remove(C)
	..()

/datum/action/innate/ignite
	name = "Ignite"
	desc = "Set yourself aflame, bringing yourself closer to exploding!"
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "sacredflame"

/datum/action/innate/ignite/Activate()
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		if(H.fire_stacks)
			to_chat(owner, "<span class='notice'>Podpalasz się!</span>")
		else
			to_chat(owner, "<span class='warning'>Próbujesz się podpalić, ale ci się nie udaje!</span>")
		H.IgniteMob() //firestacks are already there passively

//Harder to hurt
/datum/species/golem/diamond
	name = "Diamond Golem"
	id = "diamond_golem"
	fixed_mut_color = "0ff"
	armor = 70 //up from 55
	meat = /obj/item/stack/ore/diamond
	info_text = "Jako <span class='danger'>diamentowy golem</span> jesteś wytrzymalszy od przeciętnego golema."
	prefix = "Diamond"
	special_names = list("Back","Grill")

//Faster but softer and less armoured
/datum/species/golem/gold
	name = "Gold Golem"
	id = "gold_golem"
	fixed_mut_color = "cc0"
	speedmod = 1
	armor = 25 //down from 55
	meat = /obj/item/stack/ore/gold
	info_text = "Jako <span class='danger'>złoty golem</span> jesteś szybszy, ale mniej wytrzymały od przeciętnego golema."
	prefix = "Golden"
	special_names = list("Boy")

//Heavier, thus higher chance of stunning when punching
/datum/species/golem/silver
	name = "Silver Golem"
	id = "silver_golem"
	fixed_mut_color = "ddd"
	meat = /obj/item/stack/ore/silver
	info_text = "Jako <span class='danger'>srebrny golem</span> twoje ataki częściej ogłuszają. Będąc ze srebra, jesteś odporny na większość magii."
	prefix = "Silver"
	special_names = list("Surfer", "Chariot", "Lining")

/datum/species/golem/silver/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	..()
	ADD_TRAIT(C, TRAIT_HOLY, SPECIES_TRAIT)

/datum/species/golem/silver/on_species_loss(mob/living/carbon/C)
	REMOVE_TRAIT(C, TRAIT_HOLY, SPECIES_TRAIT)
	..()

// Softer and faster, but conductive
/datum/species/golem/copper
	name = "Copper Golem"
	id = "copper_golem"
	fixed_mut_color = "#d95802"
	speedmod = 1.5
	armor = 30
	meat = /obj/item/stack/ore/copper
	siemens_coeff = 1 //set as conductive, next line sets shock immunity
	inherent_traits = list(TRAIT_RESISTHEAT,TRAIT_NOBREATH,TRAIT_RESISTCOLD,TRAIT_RESISTHIGHPRESSURE,TRAIT_RESISTLOWPRESSURE,TRAIT_NOFIRE,TRAIT_NOGUNS,TRAIT_RADIMMUNE,TRAIT_PIERCEIMMUNE,TRAIT_NODISMEMBER, TRAIT_SHOCKIMMUNE)
	info_text = "Jako <span class='danger'>miedziany golem</span> jesteś szybszy, ale mniej wytrzymały od przeciętnego golema. Przewodzisz też prąd, sam nie odczuwając jego skutków."
	prefix = "Copper"
	special_names = list("Wire")

//Harder to stun, deals more damage, massively slowpokes, but gravproof and obstructive. Basically, The Wall.
/datum/species/golem/plasteel
	name = "Plasteel Golem"
	id = "plasteel_golem"
	fixed_mut_color = "bbb"
	stunmod = 0.4
	punchdamage = 18
	speedmod = 4 //pretty fucking slow
	meat = /obj/item/stack/ore/iron
	info_text = "Jako <span class='danger'>golem z plastali</span> jesteś wolniejszy, ale trudniej cię ogłuszyć i mocno uderzasz pięściami. Do tego magnetycznie przywierasz do powierzchni, więc nie unosisz się bez grawitacji i nie można się z tobą zamieniać miejscami."
	attack_verb = "smash"
	attack_sound = 'sound/effects/meteorimpact.ogg' //hits pretty hard
	prefix = "Plasteel"
	special_names = null

/datum/species/golem/plasteel/negates_gravity(mob/living/carbon/human/H)
	return TRUE

/datum/species/golem/plasteel/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	..()
	ADD_TRAIT(C, TRAIT_NOMOBSWAP, SPECIES_TRAIT) //THE WALL THE WALL THE WALL

/datum/species/golem/plasteel/on_species_loss(mob/living/carbon/C)
	REMOVE_TRAIT(C, TRAIT_NOMOBSWAP, SPECIES_TRAIT) //NOTHING ON ERF CAN MAKE IT FALL
	..()

//Immune to ash storms
/datum/species/golem/titanium
	name = "Titanium Golem"
	id = "titanium_golem"
	fixed_mut_color = "fff"
	meat = /obj/item/stack/ore/titanium
	info_text = "Jako <span class='danger'>tytanowy golem</span> jesteś odporny na burze popiołu i nieco odporniejszy na oparzenia."
	burnmod = 0.9
	prefix = "Titanium"
	special_names = list("Dioxide")

/datum/species/golem/titanium/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	C.weather_immunities |= "ash"

/datum/species/golem/titanium/on_species_loss(mob/living/carbon/C)
	. = ..()
	C.weather_immunities -= "ash"

//Immune to ash storms and lava
/datum/species/golem/plastitanium
	name = "Plastitanium Golem"
	id = "plastitanium_golem"
	fixed_mut_color = "888"
	meat = /obj/item/stack/ore/titanium
	info_text = "Jako <span class='danger'>plastytanowy golem</span> jesteś odporny na burze popiołu i lawę oraz nieco odporniejszy na oparzenia."
	burnmod = 0.8
	prefix = "Plastitanium"
	special_names = null

/datum/species/golem/plastitanium/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	C.weather_immunities |= "lava"
	C.weather_immunities |= "ash"

/datum/species/golem/plastitanium/on_species_loss(mob/living/carbon/C)
	. = ..()
	C.weather_immunities -= "ash"
	C.weather_immunities -= "lava"

//Fast and regenerates... but can only speak like an abductor
/datum/species/golem/alloy
	name = "Alien Alloy Golem"
	id = "alloy_golem"
	species_traits = list(NOBLOOD,NO_UNDERWEAR,NOEYESPRITES,NOTRANSSTING)
	meat = /obj/item/stack/sheet/mineral/abductor
	mutanttongue = /obj/item/organ/tongue/abductor
	speedmod = 1 //faster
	info_text = "Jako <span class='danger'>golem ze stopu</span> jesteś zbudowany z zaawansowanych obcych materiałów: jesteś szybszy i z czasem się regenerujesz. Słyszą cię jednak tylko inne golemy ze stopu."
	prefix = "Alien"
	special_names = list("Outsider", "Technology", "Watcher", "Stranger") //ominous and unknown

	species_chest = /obj/item/bodypart/chest/golem/alloy
	species_head = /obj/item/bodypart/head/golem/alloy
	species_l_arm = /obj/item/bodypart/l_arm/golem/alloy
	species_r_arm = /obj/item/bodypart/r_arm/golem/alloy
	species_l_leg = /obj/item/bodypart/l_leg/golem/alloy
	species_r_leg = /obj/item/bodypart/r_leg/golem/alloy

//Regenerates because self-repairing super-advanced alien tech
/datum/species/golem/alloy/spec_life(mob/living/carbon/human/H)
	if(H.stat == DEAD)
		return
	H.heal_overall_damage(2,2, 0, BODYTYPE_ORGANIC)
	H.adjustToxLoss(-2)
	H.adjustOxyLoss(-2)

//Since this will usually be created from a collaboration between podpeople and free golems, wood golems are a mix between the two races
/datum/species/golem/wood
	name = "Wood Golem"
	id = "wood_golem"
	fixed_mut_color = "9E704B"
	meat = /obj/item/stack/sheet/mineral/wood
	//Can burn and take damage from heat
	inherent_traits = list(TRAIT_NOBREATH, TRAIT_RESISTCOLD,TRAIT_RESISTHIGHPRESSURE,TRAIT_RESISTLOWPRESSURE,TRAIT_NOGUNS,TRAIT_RADIMMUNE,TRAIT_PIERCEIMMUNE,TRAIT_NODISMEMBER)
	armor = 30
	burnmod = 1.25
	heatmod = 1.5
	info_text = "Jako <span class='danger'>drewniany golem</span> masz cechy roślin: odnosisz obrażenia od skrajnych temperatur, możesz się zapalić i masz słabszy pancerz niż zwykły golem. W świetle się regenerujesz, a w ciemności więdniesz."
	prefix = "Wooden"
	special_names = list("Bark", "Willow", "Catalpa", "Woody", "Oak", "Sap", "Twig", "Branch", "Maple", "Birch", "Elm", "Basswood", "Cottonwood", "Larch", "Aspen", "Ash", "Beech", "Buckeye", "Cedar", "Chestnut", "Cypress", "Fir", "Hawthorn", "Hazel", "Hickory", "Ironwood", "Juniper", "Leaf", "Mangrove", "Palm", "Pawpaw", "Pine", "Poplar", "Redwood", "Redbud", "Sassafras", "Spruce", "Sumac", "Trunk", "Walnut", "Yew")
	human_surname_chance = 0
	special_name_chance = 100
	inherent_factions = list("plants", "vines")

/datum/species/golem/wood/spec_life(mob/living/carbon/human/H)
	if(H.stat == DEAD)
		return
	var/light_amount = 0 //how much light there is in the place, affects receiving nutrition and healing
	if(isturf(H.loc)) //else, there's considered to be no light
		var/turf/T = H.loc
		light_amount = min(1,T.get_lumcount()) - 0.5
		H.adjust_nutrition(light_amount * 10)
		if(H.nutrition > NUTRITION_LEVEL_ALMOST_FULL)
			H.set_nutrition(NUTRITION_LEVEL_ALMOST_FULL)
		if(light_amount > 0.2) //if there's enough light, heal
			H.heal_overall_damage(1,1,0, BODYTYPE_ORGANIC)
			H.adjustToxLoss(-1)
			H.adjustOxyLoss(-1)

	if(H.nutrition < NUTRITION_LEVEL_STARVING + 50)
		H.take_overall_damage(2,0)

/datum/species/golem/wood/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(chem.type == /datum/reagent/toxin/plantbgone)
		H.adjustToxLoss(3)
		H.reagents.remove_reagent(chem.type, chem.metabolization_rate)
		return TRUE
	return ..()

//Radioactive
/datum/species/golem/uranium
	name = "Uranium Golem"
	id = "uranium_golem"
	fixed_mut_color = "7f0"
	meat = /obj/item/stack/ore/uranium
	info_text = "Jako <span class='danger'>uranowy golem</span> co jakiś czas emitujesz impulsy promieniowania. Nie szkodzą innym golemom, ale działają na organiczne formy życia."

	var/last_event = 0
	var/active = null
	prefix = "Uranium"
	special_names = list("Oxide", "Rod", "Meltdown", "235")

/datum/species/golem/uranium/spec_life(mob/living/carbon/human/H)
	if(!active)
		if(world.time > last_event+30)
			active = 1
			radiation_pulse(H, 50)
			last_event = world.time
			active = null
	..()

//Immune to physical bullets and resistant to brute, but very vulnerable to burn damage. Dusts on death.
/datum/species/golem/sand
	name = "Sand Golem"
	id = "sand_golem"
	fixed_mut_color = "ffdc8f"
	meat = /obj/item/stack/ore/glass //this is sand
	armor = 0
	burnmod = 3 //melts easily
	brutemod = 0.25
	info_text = "Jako <span class='danger'>piaskowy golem</span> jesteś odporny na pociski fizyczne i odnosisz bardzo mało obrażeń fizycznych, ale jesteś skrajnie podatny na oparzenia i broń energetyczną. Po śmierci rozsypujesz się w piasek, co uniemożliwia jakikolwiek powrót."
	attack_sound = 'sound/effects/shovel_dig.ogg'
	prefix = "Sand"
	special_names = list("Castle", "Bag", "Dune", "Worm", "Storm")

/datum/species/golem/sand/spec_death(gibbed, mob/living/carbon/human/H)
	H.visible_message("<span class='danger'>[H] rozsypuje się w kupkę piasku!</span>")
	for(var/obj/item/W in H)
		H.dropItemToGround(W)
	for(var/i=1, i <= rand(3,5), i++)
		new /obj/item/stack/ore/glass(get_turf(H))
	qdel(H)

/datum/species/golem/sand/bullet_act(obj/item/projectile/P, mob/living/carbon/human/H)
	if(!(P.original == H && P.firer == H))
		if(P.flag == "bullet" || P.flag == "bomb")
			playsound(H, 'sound/effects/shovel_dig.ogg', 70, 1)
			H.visible_message("<span class='danger'>[P.name] nieszkodliwie zapada się w piaszczyste ciało [H]!</span>", \
			"<span class='userdanger'>[P.name] nieszkodliwie zapada się w piaszczyste ciało [H]!</span>")
			return BULLET_ACT_BLOCK
	return ..()

//Reflects lasers and resistant to burn damage, but very vulnerable to brute damage. Shatters on death.
/datum/species/golem/glass
	name = "Glass Golem"
	id = "glass_golem"
	fixed_mut_color = "5a96b4aa" //transparent body
	meat = /obj/item/shard
	armor = 0
	brutemod = 3 //very fragile
	burnmod = 0.25
	info_text = "Jako <span class='danger'>szklany golem</span> odbijasz lasery i broń energetyczną i jesteś bardzo odporny na oparzenia. Jesteś jednak skrajnie podatny na obrażenia fizyczne. Po śmierci roztrzaskasz się bez szans na powrót."
	attack_sound = 'sound/effects/glassbr2.ogg'
	prefix = "Glass"
	special_names = list("Lens", "Prism", "Fiber", "Bead")

/datum/species/golem/glass/spec_death(gibbed, mob/living/carbon/human/H)
	playsound(H, "shatter", 70, 1)
	H.visible_message("<span class='danger'>[H] shatters!</span>")
	for(var/obj/item/W in H)
		H.dropItemToGround(W)
	for(var/i=1, i <= rand(3,5), i++)
		new /obj/item/shard(get_turf(H))
	qdel(H)

/datum/species/golem/glass/bullet_act(obj/item/projectile/P, mob/living/carbon/human/H)
	if(!(P.original == H && P.firer == H)) //self-shots don't reflect
		if(P.flag == "laser" || P.flag == "energy")
			H.visible_message("<span class='danger'>Szklana skóra [H] odbija [P.name]!</span>", \
			"<span class='userdanger'>Szklana skóra [H] odbija [P.name]!</span>")
			if(P.starting)
				var/new_x = P.starting.x + pick(0, 0, 0, 0, 0, -1, 1, -2, 2)
				var/new_y = P.starting.y + pick(0, 0, 0, 0, 0, -1, 1, -2, 2)
				// redirect the projectile
				P.firer = H
				P.preparePixelProjectile(locate(CLAMP(new_x, 1, world.maxx), CLAMP(new_y, 1, world.maxy), H.z), H)
			return BULLET_ACT_FORCE_PIERCE
	return ..()

//Teleports when hit or when it wants to
/datum/species/golem/bluespace
	name = "Bluespace Golem"
	id = "bluespace_golem"
	fixed_mut_color = "33f"
	meat = /obj/item/stack/ore/bluespace_crystal
	info_text = "Jako <span class='danger'>golem bluespace</span> jesteś niestabilny przestrzennie: teleportujesz się po trafieniu i możesz ręcznie teleportować się na dużą odległość."
	attack_verb = "bluespace punch"
	attack_sound = 'sound/effects/phasein.ogg'
	prefix = "Bluespace"
	special_names = list("Crystal", "Polycrystal")

	var/datum/action/innate/unstable_teleport/unstable_teleport
	var/teleport_cooldown = 100
	var/last_teleport = 0

/datum/species/golem/bluespace/proc/reactive_teleport(mob/living/carbon/human/H)
	H.visible_message("<span class='warning'>[H] teleports!</span>", "<span class='danger'>Tracisz stabilność i się teleportujesz!</span>")
	new /obj/effect/particle_effect/sparks(get_turf(H))
	playsound(get_turf(H), "sparks", 50, 1)
	do_teleport(H, get_turf(H), 6, asoundin = 'sound/weapons/emitter2.ogg', channel = TELEPORT_CHANNEL_BLUESPACE)
	last_teleport = world.time

/datum/species/golem/bluespace/spec_hitby(atom/movable/AM, mob/living/carbon/human/H)
	..()
	var/obj/item/I
	if(istype(AM, /obj/item))
		I = AM
		if(I.thrownby == WEAKREF(H)) //No throwing stuff at yourself to trigger the teleport
			return 0
		else
			reactive_teleport(H)

/datum/species/golem/bluespace/spec_attack_hand(mob/living/carbon/human/M, mob/living/carbon/human/H, datum/martial_art/attacker_style)
	..()
	if(world.time > last_teleport + teleport_cooldown && M != H &&  M.combat_mode)
		reactive_teleport(H)

/datum/species/golem/bluespace/spec_attacked_by(obj/item/I, mob/living/user, obj/item/bodypart/affecting, mob/living/carbon/human/H)
	..()
	if(world.time > last_teleport + teleport_cooldown && user != H)
		reactive_teleport(H)

/datum/species/golem/bluespace/on_hit(obj/item/projectile/P, mob/living/carbon/human/H)
	..()
	if(world.time > last_teleport + teleport_cooldown)
		reactive_teleport(H)

/datum/species/golem/bluespace/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	..()
	if(ishuman(C))
		unstable_teleport = new
		unstable_teleport.Grant(C)
		last_teleport = world.time

/datum/species/golem/bluespace/on_species_loss(mob/living/carbon/C)
	if(unstable_teleport)
		unstable_teleport.Remove(C)
	..()

/datum/action/innate/unstable_teleport
	name = "Unstable Teleport"
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "jaunt"
	icon_icon = 'icons/mob/actions/actions_spells.dmi'
	var/cooldown = 150
	var/last_teleport = 0

/datum/action/innate/unstable_teleport/IsAvailable()
	if(..())
		if(world.time > last_teleport + cooldown)
			return 1
		return 0

/datum/action/innate/unstable_teleport/Activate()
	var/mob/living/carbon/human/H = owner
	H.visible_message("<span class='warning'>[H] zaczyna wibrować!</span>", "<span class='danger'>Zaczynasz ładować swój rdzeń bluespace...</span>")
	playsound(get_turf(H), 'sound/weapons/flash.ogg', 25, 1)
	addtimer(CALLBACK(src, PROC_REF(teleport), H), 15)

/datum/action/innate/unstable_teleport/proc/teleport(mob/living/carbon/human/H)
	H.visible_message("<span class='warning'>[H] znika w deszczu iskier!</span>", "<span class='danger'>Teleportujesz się!</span>")
	var/datum/effect_system/spark_spread/spark_system = new /datum/effect_system/spark_spread
	spark_system.set_up(10, 0, src)
	spark_system.attach(H)
	spark_system.start()
	do_teleport(H, get_turf(H), 12, asoundin = 'sound/weapons/emitter2.ogg', channel = TELEPORT_CHANNEL_BLUESPACE)
	last_teleport = world.time
	UpdateButtonIcon() //action icon looks unavailable
	//action icon looks available again
	addtimer(CALLBACK(src, PROC_REF(UpdateButtonIcon)), cooldown + 5)


//honk
/datum/species/golem/bananium
	name = "Bananium Golem"
	id = "bananium_golem"
	species_traits = list(NOBLOOD,NO_UNDERWEAR,NOEYESPRITES,NOTRANSSTING)
	punchdamage = 0
	meat = /obj/item/stack/ore/bananium
	mutanttongue = /obj/item/organ/tongue/golem/bananium
	info_text = "Jako <span class='danger'>bananowy golem</span> jesteś stworzony do psot. Twoje ciało naturalnie trąbi, a ciosami prawie nikogo nie zranisz. Gdy ktoś cię zrani, wypadają z ciebie skórki od banana."
	attack_verb = "honk"
	attack_sound = 'sound/items/airhorn2.ogg'
	prefix = "Bananium"
	special_names = null

	species_chest = /obj/item/bodypart/chest/golem/bananium
	species_head = /obj/item/bodypart/head/golem/bananium
	species_l_arm = /obj/item/bodypart/l_arm/golem/bananium
	species_r_arm = /obj/item/bodypart/r_arm/golem/bananium
	species_l_leg = /obj/item/bodypart/l_leg/golem/bananium
	species_r_leg = /obj/item/bodypart/r_leg/golem/bananium

	var/last_honk = 0
	var/honkooldown = 0
	var/last_banana = 0
	var/banana_cooldown = 100
	var/active = null

/datum/species/golem/bananium/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	..()
	last_banana = world.time
	last_honk = world.time
	RegisterSignal(C, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/datum/species/golem/bananium/on_species_loss(mob/living/carbon/C)
	. = ..()
	UnregisterSignal(C, COMSIG_MOB_SAY)

/datum/species/golem/bananium/random_name(gender,unique,lastname)
	var/clown_name = pick(GLOB.clown_names)
	var/golem_name = "[uppertext(clown_name)]"
	return golem_name

/datum/species/golem/bananium/spec_attack_hand(mob/living/carbon/human/M, mob/living/carbon/human/H, datum/martial_art/attacker_style)
	..()
	if(world.time > last_banana + banana_cooldown && M != H &&  M.combat_mode)
		new/obj/item/grown/bananapeel/specialpeel(get_turf(H))
		last_banana = world.time

/datum/species/golem/bananium/spec_attacked_by(obj/item/I, mob/living/user, obj/item/bodypart/affecting, mob/living/carbon/human/H)
	..()
	if(world.time > last_banana + banana_cooldown && user != H)
		new/obj/item/grown/bananapeel/specialpeel(get_turf(H))
		last_banana = world.time

/datum/species/golem/bananium/on_hit(obj/item/projectile/P, mob/living/carbon/human/H)
	..()
	if(world.time > last_banana + banana_cooldown)
		new/obj/item/grown/bananapeel/specialpeel(get_turf(H))
		last_banana = world.time

/datum/species/golem/bananium/spec_hitby(atom/movable/AM, mob/living/carbon/human/H)
	..()
	var/obj/item/I
	if(istype(AM, /obj/item))
		I = AM
		if(I.thrownby == WEAKREF(H)) //No throwing stuff at yourself to make bananas
			return 0
		else
			new/obj/item/grown/bananapeel/specialpeel(get_turf(H))
			last_banana = world.time

/datum/species/golem/bananium/spec_life(mob/living/carbon/human/H)
	if(!active)
		if(world.time > last_honk + honkooldown)
			active = 1
			playsound(get_turf(H), 'sound/items/bikehorn.ogg', 50, 1)
			last_honk = world.time
			honkooldown = rand(20, 80)
			active = null
	..()

/datum/species/golem/bananium/spec_death(gibbed, mob/living/carbon/human/H)
	playsound(get_turf(H), 'sound/misc/sadtrombone.ogg', 70, 0)

/datum/species/golem/bananium/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER

	speech_args[SPEECH_SPANS] |= SPAN_CLOWN

/datum/species/golem/runic
	name = "Runic Golem"
	id = "cult_golem"
	sexes = FALSE
	info_text = "Jako <span class='danger'>runiczny golem</span> masz pradawne moce nadane przez Starszą Boginię Nar'Sie."
	species_traits = list(NOBLOOD,NO_UNDERWEAR,NOEYESPRITES,NOFLASH,NOTRANSSTING) //no mutcolors
	prefix = "Runic"
	special_names = null
	random_eligible = FALSE //Zesko claims runic golems break the game
	inherent_factions = list("cult")
	species_language_holder = /datum/language_holder/golem/runic
	var/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/shift/golem/phase_shift
	var/obj/effect/proc_holder/spell/targeted/abyssal_gaze/abyssal_gaze
	var/obj/effect/proc_holder/spell/targeted/dominate/dominate

	species_chest = /obj/item/bodypart/chest/golem/cult
	species_head = /obj/item/bodypart/head/golem/cult
	species_l_arm = /obj/item/bodypart/l_arm/golem/cult
	species_r_arm = /obj/item/bodypart/r_arm/golem/cult
	species_l_leg = /obj/item/bodypart/l_leg/golem/cult
	species_r_leg = /obj/item/bodypart/r_leg/golem/cult

/datum/species/golem/runic/random_name(gender,unique,lastname)
	var/edgy_first_name = pick("Razor","Blood","Dark","Evil","Cold","Pale","Black","Silent","Chaos","Deadly","Coldsteel")
	var/edgy_last_name = pick("Edge","Night","Death","Razor","Blade","Steel","Calamity","Twilight","Shadow","Nightmare") //dammit Razor Razor
	var/golem_name = "[edgy_first_name] [edgy_last_name]"
	return golem_name

/datum/species/golem/runic/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	phase_shift = new
	phase_shift.charge_counter = 0
	phase_shift.start_recharge()
	C.AddSpell(phase_shift)
	abyssal_gaze = new
	abyssal_gaze.charge_counter = 0
	abyssal_gaze.start_recharge()
	C.AddSpell(abyssal_gaze)
	dominate = new
	dominate.charge_counter = 0
	dominate.start_recharge()
	C.AddSpell(dominate)

/datum/species/golem/runic/on_species_loss(mob/living/carbon/C)
	. = ..()
	if(phase_shift)
		C.RemoveSpell(phase_shift)
	if(abyssal_gaze)
		C.RemoveSpell(abyssal_gaze)
	if(dominate)
		C.RemoveSpell(dominate)

/datum/species/golem/runic/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(istype(chem, /datum/reagent/water/holywater))
		H.adjustFireLoss(4)
		H.reagents.remove_reagent(chem.type, chem.metabolization_rate)
		return TRUE

	if(chem.type == /datum/reagent/fuel/unholywater)
		H.adjustBruteLoss(-4)
		H.adjustFireLoss(-4)
		H.reagents.remove_reagent(chem.type, chem.metabolization_rate)
		return TRUE
	return ..()
/datum/species/golem/clockwork
	name = "Clockwork Golem"
	id = "clockwork_golem"
	info_text = "<span class='bold alloy'>Jako </span><span class='bold brass'>mechaniczny golem</span><span class='bold alloy'> jesteś szybszy od innych golemów. Po śmierci rozpadniesz się na złom.</span>"
	species_traits = list(NOBLOOD,NO_UNDERWEAR,NOEYESPRITES,NOFLASH,NOTRANSSTING)
	inherent_biotypes = list(MOB_ROBOTIC, MOB_HUMANOID)
	armor = 20 //Reinforced, but much less so to allow for fast movement
	attack_verb = "smash"
	attack_sound = 'sound/magic/clockwork/anima_fragment_attack.ogg'
	sexes = FALSE
	speedmod = 0
	changesource_flags = MIRROR_BADMIN | WABBAJACK
	damage_overlay_type = "synth"
	prefix = "Clockwork"
	special_names = list("Remnant", "Relic", "Scrap", "Vestige") //RIP Ratvar
	inherent_factions = list("ratvar")
	mutanttongue = /obj/item/organ/tongue/golem/clockwork
	var/has_corpse

	species_chest = /obj/item/bodypart/chest/golem/clock
	species_head = /obj/item/bodypart/head/golem/clock
	species_l_arm = /obj/item/bodypart/l_arm/golem/clock
	species_r_arm = /obj/item/bodypart/r_arm/golem/clock
	species_l_leg = /obj/item/bodypart/l_leg/golem/clock
	species_r_leg = /obj/item/bodypart/r_leg/golem/clock

/datum/species/golem/clockwork/on_species_gain(mob/living/carbon/human/H)
	. = ..()
	RegisterSignal(H, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/datum/species/golem/clockwork/on_species_loss(mob/living/carbon/human/H)
	UnregisterSignal(H, COMSIG_MOB_SAY)
	. = ..()

/datum/species/golem/clockwork/proc/handle_speech(datum/source, list/speech_args)
	speech_args[SPEECH_SPANS] |= SPAN_ROBOT //beep

/datum/species/golem/clockwork/spec_death(gibbed, mob/living/carbon/human/H)
	gibbed = !has_corpse ? FALSE : gibbed
	. = ..()
	if(!has_corpse)
		var/turf/T = get_turf(H)
		H.visible_message("<span class='warning'>Egzoszkielet [H] pęka i rozpada się w stertę złomu!</span>")
		playsound(H, 'sound/magic/clockwork/anima_fragment_death.ogg', 62, TRUE)
		for(var/i in 1 to rand(3, 5))
			new/obj/item/clockwork/alloy_shards/small(T)
		new/obj/item/clockwork/alloy_shards/clockgolem_remains(T)
		qdel(H)

/datum/species/golem/clockwork/no_scrap //These golems are created through the herald's beacon and leave normal corpses on death.
	id = "clockwork golem servant"
	armor = 15 //Balance reasons make this armor weak
	no_equip = list()
	nojumpsuit = FALSE
	has_corpse = TRUE
	random_eligible = FALSE
	info_text = "<span class='bold alloy'>Jako </span><span class='bold brass'>mechaniczny golem-sługa</span><span class='bold alloy'> jesteś szybszy od innych golemów.</span>" //warcult golems leave a corpse

/datum/species/golem/cloth
	name = "Cloth Golem"
	id = "cloth_golem"
	sexes = FALSE
	info_text = "Jako <span class='danger'>materiałowy golem</span> możesz odrodzić się po śmierci, o ile twoje szczątki nie zostaną spalone ani zniszczone. Jesteś oczywiście bardzo łatwopalny. Będąc z materiału, jesteś odporny na magię i szybszy od innych golemów, ale słabszy i mniej wytrzymały."
	species_traits = list(NOBLOOD,NO_UNDERWEAR,NOTRANSSTING) //no mutcolors, and can burn
	inherent_traits = list(TRAIT_RESISTCOLD,TRAIT_NOBREATH,TRAIT_RESISTHIGHPRESSURE,TRAIT_RESISTLOWPRESSURE,TRAIT_RADIMMUNE,TRAIT_PIERCEIMMUNE,TRAIT_NODISMEMBER,TRAIT_NOGUNS)
	inherent_biotypes = list(MOB_UNDEAD, MOB_HUMANOID)
	armor = 15 //feels no pain, but not too resistant
	burnmod = 2 // don't get burned
	speedmod = 1 // not as heavy as stone
	punchdamage = 6
	prefix = "Cloth"
	special_names = null

	species_chest = /obj/item/bodypart/chest/golem/cloth
	species_head = /obj/item/bodypart/head/golem/cloth
	species_l_arm = /obj/item/bodypart/l_arm/golem/cloth
	species_r_arm = /obj/item/bodypart/r_arm/golem/cloth
	species_l_leg = /obj/item/bodypart/l_leg/golem/cloth
	species_r_leg = /obj/item/bodypart/r_leg/golem/cloth

/datum/species/golem/cloth/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	..()
	ADD_TRAIT(C, TRAIT_HOLY, SPECIES_TRAIT)

/datum/species/golem/cloth/on_species_loss(mob/living/carbon/C)
	REMOVE_TRAIT(C, TRAIT_HOLY, SPECIES_TRAIT)
	..()

/datum/species/golem/cloth/check_roundstart_eligible()
	if(SSevents.holidays && SSevents.holidays[HALLOWEEN])
		return TRUE
	return ..()

/datum/species/golem/cloth/random_name(gender,unique,lastname)
	var/pharaoh_name = pick("Neferkare", "Hudjefa", "Khufu", "Mentuhotep", "Ahmose", "Amenhotep", "Thutmose", "Hatshepsut", "Tutankhamun", "Ramses", "Seti", \
	"Merenptah", "Djer", "Semerkhet", "Nynetjer", "Khafre", "Pepi", "Intef", "Ay") //yes, Ay was an actual pharaoh
	var/golem_name = "[pharaoh_name] \Roman[rand(1,99)]"
	return golem_name

/datum/species/golem/cloth/spec_life(mob/living/carbon/human/H)
	if(H.fire_stacks < 1)
		H.adjust_fire_stacks(1) //always prone to burning
	..()

/datum/species/golem/cloth/spec_death(gibbed, mob/living/carbon/human/H)
	if(gibbed)
		return
	if(H.on_fire)
		H.visible_message("<span class='danger'>[H] spala się na popiół!</span>")
		H.dust(just_ash = TRUE)
		return

	H.visible_message("<span class='danger'>[H] rozpada się w stertę bandaży!</span>")
	new /obj/structure/cloth_pile(get_turf(H), H)
	..()

/obj/structure/cloth_pile
	name = "pile of bandages"
	desc = "It emits a strange aura, as if there was still life within it..."
	max_integrity = 50
	armor = list("melee" = 90, "bullet" = 90, "laser" = 25, "energy" = 80, "bomb" = 50, "bio" = 100, "fire" = -50, "acid" = -50, "stamina" = 0, "bleed" = 0)
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "pile_bandages"
	resistance_flags = FLAMMABLE

	var/revive_time = 900
	var/mob/living/carbon/human/cloth_golem

/obj/structure/cloth_pile/Initialize(mapload, mob/living/carbon/human/H)
	. = ..()
	if(!QDELETED(H) && is_species(H, /datum/species/golem/cloth))
		H.unequip_everything()
		H.forceMove(src)
		cloth_golem = H
		to_chat(cloth_golem, "<span class='notice'>Zaczynasz zbierać energię życiową, przygotowując się do powstania...</span>")
		addtimer(CALLBACK(src, PROC_REF(revive)), revive_time)
	else
		return INITIALIZE_HINT_QDEL

/obj/structure/cloth_pile/Destroy()
	if(cloth_golem)
		QDEL_NULL(cloth_golem)
	return ..()

/obj/structure/cloth_pile/burn()
	visible_message("<span class='danger'>[src] spala się na popiół!</span>")
	new /obj/effect/decal/cleanable/ash(get_turf(src))
	..()

/obj/structure/cloth_pile/proc/revive()
	if(QDELETED(src) || QDELETED(cloth_golem)) //QDELETED also checks for null, so if no cloth golem is set this won't runtime
		return
	if(cloth_golem.suiciding || cloth_golem.ishellbound())
		QDEL_NULL(cloth_golem)
		return

	invisibility = INVISIBILITY_MAXIMUM //disappear before the animation
	new /obj/effect/temp_visual/mummy_animation(get_turf(src))
	if(cloth_golem.revive(full_heal = TRUE, admin_revive = TRUE))
		cloth_golem.grab_ghost() //won't pull if it's a suicide
	sleep(20)
	cloth_golem.forceMove(get_turf(src))
	cloth_golem.visible_message("<span class='danger'>[src] powstaje i odtwarza się jako [cloth_golem]!</span>","<span class='userdanger'>Odtwarzasz się!</span>")
	cloth_golem = null
	qdel(src)

/obj/structure/cloth_pile/attackby(obj/item/P, mob/living/carbon/human/user, params)
	. = ..()

	if(resistance_flags & ON_FIRE)
		return

	if(P.is_hot())
		visible_message("<span class='danger'>[src] staje w płomieniach!</span>")
		fire_act()

/datum/species/golem/plastic
	name = "Plastic Golem"
	id = "plastic_golem"
	prefix = "Plastic"
	special_names = list("Sheet", "Bag", "Bottle")
	fixed_mut_color = "fffa"
	info_text = "Jako <span class='danger'>plastikowy golem</span> możesz chodzić wywietrznikami i przechodzić przez plastikowe kurtyny, o ile jesteś nagi."

/datum/species/golem/plastic/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	C.ventcrawler = VENTCRAWLER_NUDE

/datum/species/golem/plastic/on_species_loss(mob/living/carbon/C)
	. = ..()
	C.ventcrawler = initial(C.ventcrawler)

/datum/species/golem/bronze
	name = "Bronze Golem"
	id = "bronze_golem"
	prefix = "Bronze"
	special_names = list("Bell")
	fixed_mut_color = "cd7f32"
	info_text = "Jako <span class='danger'>brązowy golem</span> jesteś bardzo odporny na głośne dźwięki i głośno dzwonisz, gdy uderzy w ciebie coś twardego, ale ta zdolność szkodzi twojemu słuchowi."
	special_step_sounds = list('sound/machines/clockcult/integration_cog_install.ogg', 'sound/magic/clockwork/fellowship_armory.ogg' )
	mutantears = /obj/item/organ/ears/bronze
	var/last_gong_time = 0
	var/gong_cooldown = 150

/datum/species/golem/bronze/bullet_act(obj/item/projectile/P, mob/living/carbon/human/H)
	if(!(world.time > last_gong_time + gong_cooldown))
		return ..()
	if(P.flag == "bullet" || P.flag == "bomb")
		gong(H)
		return ..()

/datum/species/golem/bronze/spec_hitby(atom/movable/AM, mob/living/carbon/human/H)
	..()
	if(world.time > last_gong_time + gong_cooldown)
		gong(H)

/datum/species/golem/bronze/spec_attack_hand(mob/living/carbon/human/M, mob/living/carbon/human/H, datum/martial_art/attacker_style)
	..()
	if(world.time > last_gong_time + gong_cooldown &&  M.combat_mode)
		gong(H)

/datum/species/golem/bronze/spec_attacked_by(obj/item/I, mob/living/user, obj/item/bodypart/affecting, mob/living/carbon/human/H)
	..()
	if(world.time > last_gong_time + gong_cooldown)
		gong(H)

/datum/species/golem/bronze/on_hit(obj/item/projectile/P, mob/living/carbon/human/H)
	..()
	if(world.time > last_gong_time + gong_cooldown)
		gong(H)

/datum/species/golem/bronze/proc/gong(mob/living/carbon/human/H)
	last_gong_time = world.time
	for(var/mob/living/M in hearers(7,H))
		if(M.stat == DEAD)	//F
			return
		if(M == H)
			H.show_message("<span class='narsiesmall'>Krzywisz się z bólu, gdy twoje ciało dzwoni wokół ciebie!</span>", MSG_AUDIBLE)
			H.playsound_local(H, 'sound/effects/gong.ogg', 100, TRUE)
			H.soundbang_act(2, 0, 100, 1)
			H.jitteriness += 7
		var/distance = max(0,get_dist(get_turf(H),get_turf(M)))
		switch(distance)
			if(0 to 1)
				M.show_message("<span class='narsiesmall'>GONG!</span>", MSG_AUDIBLE)
				M.playsound_local(H, 'sound/effects/gong.ogg', 100, TRUE)
				M.soundbang_act(1, 0, 30, 3)
				M.confused += 10
				M.jitteriness += 4
				SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "gonged", /datum/mood_event/loud_gong)
			if(2 to 3)
				M.show_message("<span class='cult'>GONG!</span>", MSG_AUDIBLE)
				M.playsound_local(H, 'sound/effects/gong.ogg', 75, TRUE)
				M.soundbang_act(1, 0, 15, 2)
				M.jitteriness += 3
				SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "gonged", /datum/mood_event/loud_gong)
			else
				M.show_message("<span class='warning'>GONG!</span>", MSG_AUDIBLE)
				M.playsound_local(H, 'sound/effects/gong.ogg', 50, TRUE)


/datum/species/golem/cardboard //Faster but weaker, can also make new shells on its own
	name = "Cardboard Golem"
	id = "cardboard_golem"
	prefix = "Cardboard"
	special_names = list("Box")
	info_text = "Jako <span class='danger'>tekturowy golem</span> nie jesteś zbyt silny, ale jesteś trochę szybszy i łatwo tworzysz kolejnych braci, używając na sobie tektury."
	species_traits = list(NOBLOOD,NO_UNDERWEAR,NOEYESPRITES,NOFLASH,NOTRANSSTING)
	inherent_traits = list(TRAIT_NOBREATH, TRAIT_RESISTCOLD,TRAIT_RESISTHIGHPRESSURE,TRAIT_RESISTLOWPRESSURE,TRAIT_NOGUNS,TRAIT_RADIMMUNE,TRAIT_PIERCEIMMUNE,TRAIT_NODISMEMBER)
	attack_verb = "whips"
	attack_sound = 'sound/weapons/whip.ogg'
	miss_sound = 'sound/weapons/etherealmiss.ogg'
	fixed_mut_color = null
	armor = 25
	burnmod = 1.25
	heatmod = 2
	speedmod = 1.5
	punchdamage = 6
	var/last_creation = 0
	var/brother_creation_cooldown = 300

	species_chest = /obj/item/bodypart/chest/golem/cardboard
	species_head = /obj/item/bodypart/head/golem/cardboard
	species_l_arm = /obj/item/bodypart/l_arm/golem/cardboard
	species_r_arm = /obj/item/bodypart/r_arm/golem/cardboard
	species_l_leg = /obj/item/bodypart/l_leg/golem/cardboard
	species_r_leg = /obj/item/bodypart/r_leg/golem/cardboard

/datum/species/golem/cardboard/spec_attacked_by(obj/item/I, mob/living/user, obj/item/bodypart/affecting, mob/living/carbon/human/H)
	. = ..()
	if(user != H)
		return FALSE //forced reproduction is rape.
	if(istype(I, /obj/item/stack/sheet/cardboard))
		var/obj/item/stack/sheet/cardboard/C = I
		if(last_creation + brother_creation_cooldown > world.time) //no cheesing dork
			return
		if(C.amount < 10)
			to_chat(H, "<span class='warning'>Masz za mało tektury!</span>")
			return FALSE
		to_chat(H, "<span class='notice'>Próbujesz stworzyć nowego tekturowego brata.</span>")
		if(do_after(user, 30, target = user))
			if(last_creation + brother_creation_cooldown > world.time) //no cheesing dork
				return
			if(!C.use(10))
				to_chat(H, "<span class='warning'>Masz za mało tektury!</span>")
				return FALSE
			to_chat(H, "<span class='notice'>Tworzysz nową powłokę tekturowego golema.</span>")
			create_brother(H.loc)

/datum/species/golem/cardboard/proc/create_brother(var/location)
	new /obj/effect/mob_spawn/human/golem/servant(location, /datum/species/golem/cardboard, owner)
	last_creation = world.time

/datum/species/golem/leather
	name = "Leather Golem"
	id = "leather_golem"
	special_names = list("Face", "Man", "Belt") //Ah dude 4 strength 4 stam leather belt AHHH
	inherent_traits = list(TRAIT_NOBREATH, TRAIT_RESISTCOLD,TRAIT_RESISTHIGHPRESSURE,TRAIT_RESISTLOWPRESSURE,TRAIT_NOGUNS,TRAIT_RADIMMUNE,TRAIT_PIERCEIMMUNE,TRAIT_NODISMEMBER, TRAIT_STRONG_GRABBER)
	prefix = "Leather"
	fixed_mut_color = "624a2e"
	info_text = "Jako <span class='danger'>skórzany golem</span> jesteś łatwopalny, ale z niezwykłą łatwością chwytasz rzeczy - wszystkie twoje chwyty zaczynają się od silnego poziomu."
	grab_sound = 'sound/weapons/whipgrab.ogg'
	attack_sound = 'sound/weapons/whip.ogg'

/datum/species/golem/durathread
	name = "Durathread Golem"
	id = "durathread_golem"
	prefix = "Durathread"
	special_names = list("Boll","Weave")
	species_traits = list(NOBLOOD,NO_UNDERWEAR,NOEYESPRITES,NOFLASH,NOTRANSSTING)
	fixed_mut_color = null
	inherent_traits = list(TRAIT_NOBREATH, TRAIT_RESISTCOLD,TRAIT_RESISTHIGHPRESSURE,TRAIT_RESISTLOWPRESSURE,TRAIT_NOGUNS,TRAIT_RADIMMUNE,TRAIT_PIERCEIMMUNE,TRAIT_NODISMEMBER)
	info_text = "Jako <span class='danger'>golem z duranici</span> sprawiasz, że twoje cele zaczynają się dusić, ale twoje tkane ciało gorzej znosi ogień."

	species_chest = /obj/item/bodypart/chest/golem/durathread
	species_head = /obj/item/bodypart/head/golem/durathread
	species_l_arm = /obj/item/bodypart/l_arm/golem/durathread
	species_r_arm = /obj/item/bodypart/r_arm/golem/durathread
	species_l_leg = /obj/item/bodypart/l_leg/golem/durathread
	species_r_leg = /obj/item/bodypart/r_leg/golem/durathread

/datum/species/golem/durathread/spec_unarmedattacked(mob/living/carbon/human/user, mob/living/carbon/human/target)
	. = ..()
	target.apply_status_effect(STATUS_EFFECT_CHOKINGSTRAND)

/datum/species/golem/bone
	name = "Bone Golem"
	id = "bone_golem"
	prefix = "Bone"
	special_names = list("Head", "Broth", "Fracture", "Rattler", "Appetit")
	species_traits = list(NOBLOOD,NO_UNDERWEAR,NOEYESPRITES,NOFLASH)
	inherent_biotypes = list(MOB_UNDEAD, MOB_HUMANOID)
	mutanttongue = /obj/item/organ/tongue/bone
	sexes = FALSE
	fixed_mut_color = null
	inherent_traits = list(TRAIT_RESISTHEAT,TRAIT_NOBREATH,TRAIT_RESISTCOLD,TRAIT_RESISTHIGHPRESSURE,TRAIT_RESISTLOWPRESSURE,TRAIT_NOFIRE,TRAIT_NOGUNS,TRAIT_RADIMMUNE,TRAIT_PIERCEIMMUNE,TRAIT_NODISMEMBER,TRAIT_FAKEDEATH)
	species_language_holder = /datum/language_holder/golem/bone
	info_text = "Jako <span class='danger'>kościany golem</span> masz potężne zaklęcie, które mrozi wrogów strachem, a mleko cię leczy! Tylko uważaj na sok od bólu kości."
	var/datum/action/innate/bonechill/bonechill

	species_chest = /obj/item/bodypart/chest/golem/bone
	species_head = /obj/item/bodypart/head/golem/bone
	species_l_arm = /obj/item/bodypart/l_arm/golem/bone
	species_r_arm = /obj/item/bodypart/r_arm/golem/bone
	species_l_leg = /obj/item/bodypart/l_leg/golem/bone
	species_r_leg = /obj/item/bodypart/r_leg/golem/bone

/datum/species/golem/bone/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	..()
	if(ishuman(C))
		bonechill = new
		bonechill.Grant(C)

/datum/species/golem/bone/on_species_loss(mob/living/carbon/C)
	if(bonechill)
		bonechill.Remove(C)
	..()

/datum/species/golem/bone/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(chem.type == /datum/reagent/consumable/milk)
		if(chem.volume >= 6)
			H.reagents.remove_reagent(chem.type, chem.volume - 5)
			to_chat(H, "<span class='warning'>Nadmiar mleka spływa po twoich kościach!</span>")
		H.heal_bodypart_damage(1.5,0, 0)
		H.reagents.remove_reagent(chem.type, REAGENTS_METABOLISM)
		return TRUE

	if(chem.type == /datum/reagent/toxin/bonehurtingjuice)
		H.adjustBruteLoss(0.5, 0)
		H.reagents.remove_reagent(chem.type, REAGENTS_METABOLISM)
		return TRUE
	return ..()
/datum/action/innate/bonechill
	name = "Bone Chill"
	desc = "Rattle your bones and strike fear into your enemies!"
	check_flags = AB_CHECK_CONSCIOUS
	icon_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "bonechill"
	var/cooldown = 600
	var/last_use
	var/snas_chance = 3

/datum/action/innate/bonechill/Activate()
	if(world.time < last_use + cooldown)
		to_chat("<span class='notice'>Nie możesz jeszcze znów zagrzechotać kośćmi.</span>")
		return
	owner.visible_message("<span class='warning'>[owner] złowieszczo grzechocze kośćmi.</span>", "<span class='notice'>Grzechoczesz kośćmi.</span>")
	last_use = world.time
	if(prob(snas_chance))
		playsound(get_turf(owner),'sound/magic/RATTLEMEBONES2.ogg', 100)
		if(ishuman(owner))
			var/mob/living/carbon/human/H = owner
			var/mutable_appearance/badtime = mutable_appearance('icons/mob/human_parts.dmi', "b_golem_eyes", -FIRE_LAYER-0.5)
			badtime.appearance_flags = RESET_COLOR
			H.overlays_standing[FIRE_LAYER+0.5] = badtime
			H.apply_overlay(FIRE_LAYER+0.5)
			addtimer(CALLBACK(H, TYPE_PROC_REF(/mob/living/carbon, remove_overlay), FIRE_LAYER+0.5), 25)
	else
		playsound(get_turf(owner),'sound/magic/RATTLEMEBONES.ogg', 100)
	for(var/mob/living/L in orange(7, get_turf(owner)))
		if((MOB_UNDEAD in L.mob_biotypes) || isgolem(L) || HAS_TRAIT(L, TRAIT_RESISTCOLD))
			return //Do not affect our brothers

		to_chat(L, "<span class='cultlarge'>Mrożący krew w żyłach dźwięk przenika cię do szpiku kości!</span>")
		L.apply_status_effect(/datum/status_effect/bonechill)
		SEND_SIGNAL(L, COMSIG_ADD_MOOD_EVENT, "spooked", /datum/mood_event/spooked)

/datum/species/golem/snow
	name = "Snow Golem"
	id = "snow_golem"
	fixed_mut_color = "null" //custom sprites
	armor = 45 //down from 55
	burnmod = 3 //melts easily
	info_text = "Jako <span class='danger'>śnieżny golem</span> jesteś skrajnie podatny na oparzenia, ale możesz tworzyć śnieżki i strzelać promieniami kriokinetycznymi. Po śmierci zmieniasz się w śnieg, co uniemożliwia jakikolwiek powrót."
	prefix = "Snow"
	special_names = list("Flake", "Blizzard", "Storm")
	species_traits = list(NOBLOOD,NO_UNDERWEAR,NOEYESPRITES,NOTRANSSTING) //no mutcolors, no eye sprites
	inherent_traits = list(TRAIT_NOBREATH,TRAIT_RESISTCOLD,TRAIT_RESISTHIGHPRESSURE,TRAIT_RESISTLOWPRESSURE,TRAIT_NOGUNS,TRAIT_RADIMMUNE,TRAIT_PIERCEIMMUNE,TRAIT_NODISMEMBER)

	var/obj/effect/proc_holder/spell/targeted/conjure_item/snowball/ball
	var/obj/effect/proc_holder/spell/aimed/cryo/cryo

	species_chest = /obj/item/bodypart/chest/golem/snow
	species_head = /obj/item/bodypart/head/golem/snow
	species_l_arm = /obj/item/bodypart/l_arm/golem/snow
	species_r_arm = /obj/item/bodypart/r_arm/golem/snow
	species_l_leg = /obj/item/bodypart/l_leg/golem/snow
	species_r_leg = /obj/item/bodypart/r_leg/golem/snow

/datum/species/golem/snow/spec_death(gibbed, mob/living/carbon/human/H)
	H.visible_message("<span class='danger'>[H] zmienia się w kupkę śniegu!</span>")
	for(var/obj/item/W in H)
		H.dropItemToGround(W)
	for(var/i=1, i <= rand(3,5), i++)
		new /obj/item/stack/sheet/mineral/snow(get_turf(H))
	new /obj/item/food/grown/carrot(get_turf(H))
	qdel(H)

/datum/species/golem/snow/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	C.weather_immunities |= "snow"
	ball = new
	ball.charge_counter = 0
	ball.start_recharge()
	C.AddSpell(ball)
	cryo = new
	cryo.charge_counter = 0
	cryo.start_recharge()
	C.AddSpell(cryo)

/datum/species/golem/snow/on_species_loss(mob/living/carbon/C)
	. = ..()
	C.weather_immunities -= "snow"
	if(ball)
		C.RemoveSpell(ball)
	if(cryo)
		C.RemoveSpell(cryo)

/obj/effect/proc_holder/spell/targeted/conjure_item/snowball
	name = "Snowball"
	desc = "Concentrates cryokinetic forces to create snowballs, useful for throwing at people."
	item_type = /obj/item/toy/snowball
	charge_max = 15
	action_icon = 'icons/obj/toy.dmi'
	action_icon_state = "snowball"

/datum/species/golem/capitalist
	name = "Capitalist Golem"
	id = "capitalist_golem"
	prefix = "Capitalist"
	attack_verb = "monopoliz"
	special_names = list("John D. Rockefeller","Rich Uncle Pennybags","Commodore Vanderbilt","Entrepreneur","Mr. Moneybags", "Adam Smith")
	species_traits = list(NOBLOOD,NO_UNDERWEAR,NOEYESPRITES,NOFLASH,NOTRANSSTING)
	fixed_mut_color = null
	inherent_traits = list(TRAIT_RESISTHEAT,TRAIT_NOBREATH,TRAIT_RESISTCOLD,TRAIT_RESISTHIGHPRESSURE,TRAIT_RESISTLOWPRESSURE,TRAIT_NOFIRE,TRAIT_RADIMMUNE,TRAIT_PIERCEIMMUNE,TRAIT_NODISMEMBER)
	info_text = "Jako <span class='danger'>kapitalistyczny golem</span> twoja pięść szerzy potężne, uprzemysławiające światło kapitalizmu."
	changesource_flags = MIRROR_BADMIN
	random_eligible = FALSE

	var/last_cash = 0
	var/cash_cooldown = 100

/datum/species/golem/capitalist/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	C.equip_to_slot_or_del(new /obj/item/clothing/glasses/monocle (), ITEM_SLOT_EYES)
	C.revive(full_heal = TRUE)

	SEND_SOUND(C, sound('sound/misc/capitialism.ogg'))
	C.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/knock ())
	RegisterSignal(C, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/datum/species/golem/capitalist/on_species_loss(mob/living/carbon/C)
	. = ..()
	UnregisterSignal(C, COMSIG_MOB_SAY)
	for(var/obj/effect/proc_holder/spell/aoe_turf/knock/spell in C.mob_spell_list)
		C.RemoveSpell(spell)

/datum/species/golem/capitalist/spec_unarmedattacked(mob/living/carbon/human/user, mob/living/carbon/human/target)
	..()
	if(isgolem(target))
		return
	if(target.nutrition >= NUTRITION_LEVEL_FAT)
		target.set_species(/datum/species/golem/capitalist)
		return
	target.adjust_nutrition(40)

/datum/species/golem/capitalist/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER

	playsound(source, 'sound/misc/mymoney.ogg', 25, 0)
	speech_args[SPEECH_MESSAGE] = "Cześć, lubię pieniądze!"

/datum/species/golem/soviet
	name = "Soviet Golem"
	id = "soviet_golem"
	prefix = "Comrade"
	attack_verb = "nationaliz"
	special_names = list("Stalin","Lenin","Trotsky","Marx","Comrade") //comrade comrade
	species_traits = list(NOBLOOD,NO_UNDERWEAR,NOEYESPRITES,NOFLASH,NOTRANSSTING)
	fixed_mut_color = null
	inherent_traits = list(TRAIT_RESISTHEAT,TRAIT_NOBREATH,TRAIT_RESISTCOLD,TRAIT_RESISTHIGHPRESSURE,TRAIT_RESISTLOWPRESSURE,TRAIT_NOFIRE,TRAIT_RADIMMUNE,TRAIT_PIERCEIMMUNE,TRAIT_NODISMEMBER)
	info_text = "Jako <span class='danger'>radziecki golem</span> twoja pięść szerzy jasne radzieckie światło komunizmu."
	changesource_flags = MIRROR_BADMIN
	random_eligible = FALSE

/datum/species/golem/soviet/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	C.equip_to_slot_or_del(new /obj/item/clothing/head/ushanka (), ITEM_SLOT_HEAD)
	C.revive(full_heal = TRUE)

	SEND_SOUND(C, sound('sound/misc/Russian_Anthem_chorus.ogg'))
	C.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/knock ())
	RegisterSignal(C, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/datum/species/golem/soviet/on_species_loss(mob/living/carbon/C)
	. = ..()
	for(var/obj/effect/proc_holder/spell/aoe_turf/knock/spell in C.mob_spell_list)
		C.RemoveSpell(spell)
	UnregisterSignal(C, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/datum/species/golem/soviet/spec_unarmedattacked(mob/living/carbon/human/user, mob/living/carbon/human/target)
	..()
	if(isgolem(target))
		return
	if(target.nutrition <= NUTRITION_LEVEL_STARVING)
		target.set_species(/datum/species/golem/soviet)
		return
	target.adjust_nutrition(-40)

/datum/species/golem/soviet/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER

	playsound(source, 'sound/misc/Cyka Blyat.ogg', 25, 0)
	speech_args[SPEECH_MESSAGE] = "Cyka Blyat"

/datum/species/golem/cheese
	name = "Cheese Golem"
	id = "cheese golem"
	fixed_mut_color = "F1D127"
	meat = /obj/item/stack/sheet/cheese
	inherent_traits = list(TRAIT_RESISTCOLD,TRAIT_RESISTHIGHPRESSURE,TRAIT_RESISTLOWPRESSURE,TRAIT_NOGUNS,TRAIT_RADIMMUNE,TRAIT_PIERCEIMMUNE,TRAIT_NODISMEMBER)
	armor = 10
	burnmod = 1.25
	heatmod = 1.5
	brutemod = 0.8
	info_text = "Jesteś <span class='danger'>serowym golemem</span> - odnosisz dodatkowe obrażenia od gorąca i ognia, jesteś odporny na obrażenia fizyczne, ale ludzie mogą cię zjeść!"
	prefix = "Cheese"
	special_names = list("Gouda","Brie","Cheddar","Raclette","Stilton","Maasdamer")
	var/integrity = 40
	punchdamage = 10

/datum/species/golem/cheese/spec_attack_hand(mob/living/carbon/human/M, mob/living/carbon/human/H)
	..()
	if(M.reagents && M != H && M.combat_mode)
		if((M.nutrition + 10) > (600 * (1 + M.overeatduration / 2000)))
			return
		else
			M.visible_message("<span class='danger'>[M] odgryza kęs [H]!</span>")
			playsound(get_turf(H), 'sound/items/eatfood.ogg', 25, 0)
			M.reagents.add_reagent(/datum/reagent/consumable/nutriment, 0.4)
			M.reagents.add_reagent(/datum/reagent/consumable/nutriment/vitamin, 0.4)
			if(integrity <= 0)
				qdel(H)
				M.visible_message("<span class='danger'>[H] traci integralność strukturalną i rozpada się na kawałki!</span>")
			else
				integrity = integrity - 0.4
