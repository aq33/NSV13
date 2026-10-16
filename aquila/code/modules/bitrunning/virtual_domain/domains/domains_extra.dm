// Domeny spoza obecnego tg: Legion (usunięty z tg w tgstation/tgstation#79522) i LV-624 (psychonaut-station/PsychonautStation).

/datum/lazy_template/virtual_domain/legion
	name = "Komnata Ech"
	cost = BITRUNNER_COST_MEDIUM
	desc = "Przerażające królestwo z nekropolią Legiona. Kto mu ulegnie, jest potępiony na wieki."
	difficulty = BITRUNNER_DIFFICULTY_MEDIUM
	forced_outfit = /datum/outfit/job/miner
	help_text = "Legion przy śmierci dzieli się na mniejsze kopie. Skrzynia pojawi się dopiero, gdy padnie ostatnia z nich."
	key = "legion"
	map_name = "legion"
	reward_points = BITRUNNER_REWARD_MEDIUM

/// Legion z domeny: bez łupu z nekropolii, a skrzynia wypada dopiero po ostatnim kawałku
/mob/living/simple_animal/hostile/megafauna/legion/virtual_domain
	health = 1500
	maxHealth = 1500
	true_spawn = FALSE
	gps_name = null

/mob/living/simple_animal/hostile/megafauna/legion/virtual_domain/death()
	if(health > 0)
		return
	if(size > 1)
		// jak w bazowym Legionie, ale kopia też jest wirtualna
		adjustHealth(-maxHealth)
		var/mob/living/simple_animal/hostile/megafauna/legion/virtual_domain/copy = new(loc)
		copy.maxHealth = round(maxHealth * 0.6, DAMAGE_PRECISION)
		maxHealth = copy.maxHealth
		copy.health = copy.maxHealth
		health = maxHealth
		size--
		copy.size = size
		copy.resize = copy.size * 0.2
		transform = initial(transform)
		resize = size * 0.2
		copy.update_transform()
		update_transform()
		copy.faction = faction.Copy()
		copy.GiveTarget(target)
		visible_message(span_boldannounce("[src] rozdziela się na dwoje!"))
		return
	var/last_legion = TRUE
	for(var/mob/living/simple_animal/hostile/megafauna/legion/other in GLOB.mob_living_list)
		if(other != src && other.z == z && other.stat != DEAD)
			last_legion = FALSE
			break
	var/turf/drop_turf = get_turf(src)
	crusher_loot = list()
	. = ..() // bazowy Legion bez true_spawn zeruje łup, więc skrzynię kładziemy sami
	if(last_legion && drop_turf)
		new /obj/structure/closet/crate/secure/bitrunning/encrypted(drop_turf)

/// Brama nekropolii z domeny: nie zastępuje prawdziwej bramy Lavalandu i znika przy czyszczeniu domeny
/obj/structure/necropolis_gate/legion_gate/virtual_domain

/obj/structure/necropolis_gate/legion_gate/virtual_domain/Initialize(mapload)
	var/obj/structure/necropolis_gate/legion_gate/real_gate = GLOB.necropolis_gate
	. = ..()
	GLOB.necropolis_gate = real_gate

/obj/structure/necropolis_gate/legion_gate/virtual_domain/Destroy(force)
	return ..(TRUE)


/datum/lazy_template/virtual_domain/cleanlv624
	name = "LV-624"
	desc = "LV-624, miejsce misji: rejon opanowany przez obce stworzenia."
	help_text = "Kolonia Lazarus Landing została zaatakowana przez obce stworzenia. Ty i reszta marines macie zbadać kolonię, \
	znaleźć skrzynię z dokumentami misji i wybić stwory. Kolonia to kilka kopuł połączonych ziemnymi drogami w gęstej, zamglonej dżungli. \
	Gdy mgła się rozejdzie, rośnie ryzyko spotkania z obcymi. Uważajcie!"
	key = "cleanlv624"
	map_name = "cleanlv624"
	completion_loot = list(/obj/item/toy/plush/rouny = 1)
	cost = BITRUNNER_COST_LOW
	difficulty = BITRUNNER_DIFFICULTY_MEDIUM
	reward_points = BITRUNNER_REWARD_MEDIUM
	is_modular = TRUE
	mob_modules = list(/datum/modular_mob_segment/xenos)
