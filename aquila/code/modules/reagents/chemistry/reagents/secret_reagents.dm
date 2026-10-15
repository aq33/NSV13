// AQUILA - sekretne chemikalia z tg (metalgen, sekretny sos, wittel) + tgstation/tgstation#95952

/// Rzeczy, których metalgen nie przemienia (niezniszczalne ściany i podłogi mają takie zostać)
GLOBAL_LIST_INIT(blacklisted_metalgen_types, typecacheof(list(
	/turf/closed/indestructible,
	/turf/open/indestructible,
	/turf/open/space,
	/obj/effect,
)))

/datum/reagent/wittel
	name = "Wittel"
	description = "Niezwykle rzadka, metalicznie biała substancja, spotykana tylko na planetach klasy demonicznej."
	color = "#FFFFFF"
	taste_mult = 0
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY

/datum/reagent/consumable/secretsauce
	name = "Secret Sauce"
	description = "Co to w ogóle jest?"
	color = "#792300"
	nutriment_factor = 2 * REAGENTS_METABOLISM
	taste_description = "najlepsza rzecz, jaką kiedykolwiek jadłeś"
	taste_mult = 100
	chem_flags = CHEMICAL_NOT_SYNTH

/datum/reagent/metalgen
	name = "Metalgen"
	data = list("material" = null)
	description = "Fioletowa, metaliczna ciecz, która podobno narzuca swoje metaliczne właściwości wszystkiemu, czego dotknie."
	color = "#b000aa"
	taste_mult = 0
	chem_flags = CHEMICAL_NOT_SYNTH

/datum/reagent/metalgen/reaction_obj(obj/O, volume)
	. = ..()
	// Hologramów i abstrakcyjnych obiektów nie przemieniamy
	if(!(O.flags_1 & HOLOGRAM_1) && O.invisibility < INVISIBILITY_ABSTRACT)
		metal_morph(O)

/datum/reagent/metalgen/reaction_turf(turf/T, volume)
	. = ..()
	if(isclosedturf(T) || isopenturf(T))
		metal_morph(T)

/// Przemienia cel w materiał zapisany w danych
/datum/reagent/metalgen/proc/metal_morph(atom/target)
	var/metal_ref = data?["material"]
	if(!metal_ref)
		return
	metal_transmute(target, metal_ref)

/// Zmienia materiał obiektu lub tura, razem z kolorem i efektami materiału.
/// Nasze recyklery czytają `materials`, nie `custom_materials`, więc to nie dubluje surowców.
/proc/metal_transmute(atom/target, metal_type, default_material_amount = 100)
	if(is_type_in_typecache(target, GLOB.blacklisted_metalgen_types))
		return
	var/datum/material/metal = getmaterialref(metal_type)
	if(!metal)
		return

	var/metal_amount = 0
	for(var/metal_key in target.custom_materials)
		metal_amount += target.custom_materials[metal_key]
	if(!metal_amount)
		metal_amount = default_material_amount

	// Najpierw zdejmujemy stare materiały, żeby efekty się nie kumulowały
	if(length(target.custom_materials))
		var/old_flags = target.material_flags
		target.set_custom_materials()
		target.custom_materials = null
		target.material_flags = old_flags
	target.material_flags &= ~MATERIAL_NO_COLOR
	target.set_custom_materials(list((metal) = metal_amount))

	if(isobj(target))
		var/obj/transmuted = target
		var/initial_name = initial(transmuted.name)
		if(transmuted.name == initial_name || findtext(transmuted.name, " [initial_name]"))
			transmuted.name = "[metal.name] [initial_name]"

/// Zamienia w KAMIEŃ
/datum/reagent/metalgen/gorgium
	name = "Gorgium"
	description = "Zamienia dotkniętego... w KAMIEŃ!!!"
	color = "#929292"
	metabolization_rate = 10 * REAGENTS_METABOLISM
	taste_description = "kamienie"
	chem_flags = CHEMICAL_NOT_SYNTH | CHEMICAL_RNG_FUN
	data = list("material" = /datum/material/rock)
	/// Poniżej tej ilości nie skamienia
	var/min_volume_to_petrify = 3
	/// Ile sekund posągu za każdą jednostkę
	var/seconds_per_unit = 5

/datum/reagent/metalgen/gorgium/reaction_mob(mob/living/M, method = TOUCH, reac_volume, show_message = 1, touch_protection = 0, obj/item/bodypart/affecting)
	. = ..()
	if(reac_volume < min_volume_to_petrify)
		return
	M.Stun(4 SECONDS)
	M.petrify(round(reac_volume * seconds_per_unit))

/// Zmienia w losowe stworzenie, jak polimorfia czarodzieja
/datum/reagent/polyjuice
	name = "Polyjuice"
	description = "Jaskrawa ciecz wywołująca nagłe i nieodwracalne zmiany w budowie ciała żywych istot."
	color = "#ff00ea"
	taste_description = "magia"
	chem_flags = CHEMICAL_NOT_SYNTH | CHEMICAL_RNG_FUN
	/// Cykl, po którym następuje przemiana
	var/polymorph_cycle = 10

/datum/reagent/polyjuice/on_mob_life(mob/living/carbon/M)
	if(current_cycle > polymorph_cycle)
		M.reagents.del_reagent(type)
		wabbajack(M)
		return
	return ..()

/// Gibuje (po łatwo uleczalnej chorobie, bo jesteśmy TCHÓRZAMI)
/datum/reagent/toxin/gibbium
	name = "Gibbium"
	description = "Zgadnij, co robi."
	silent_toxin = TRUE
	color = "#ff0000"
	metabolization_rate = 4 * REAGENTS_METABOLISM
	toxpwr = 0
	taste_description = "żal"
	chem_flags = CHEMICAL_NOT_SYNTH | CHEMICAL_RNG_FUN
	/// Cykl, od którego łapie się GBS
	var/gib_cycle = 5

/datum/reagent/toxin/gibbium/on_mob_life(mob/living/carbon/M)
	if(current_cycle >= gib_cycle)
		M.ForceContractDisease(new /datum/disease/gbs/no_transmission(), FALSE, TRUE)
	return ..()

/datum/reagent/toxin/spider_serum
	name = "Spider Serum"
	description = "Okropny mutagen przemieniający ciało w pająki."
	color = "#000000"
	taste_description = "niekończące się koszmary"
	toxpwr = 0
	chem_flags = CHEMICAL_NOT_SYNTH | CHEMICAL_RNG_FUN
	/// Cykl, w którym następuje przemiana
	var/transformation_cycle = 30

/datum/reagent/toxin/spider_serum/on_mob_life(mob/living/carbon/M)
	if(current_cycle >= transformation_cycle)
		M.reagents.del_reagent(type)
		var/datum/mind/serum_mind = M.mind
		M.change_mob_type(/mob/living/simple_animal/hostile/spider/giant, delete_old_mob = TRUE)
		if(serum_mind && !serum_mind.has_antag_datum(/datum/antagonist/spider))
			serum_mind.add_antag_datum(/datum/antagonist/spider)
		return
	if(prob(10))
		new /mob/living/simple_animal/hostile/spider/growing/spiderling(get_turf(M))
		M.vomit(20, TRUE)
		to_chat(M, "<span class='warning'>Czujesz malutkie nóżki wspinające się po twoim gardle.</span>")
	return ..()
