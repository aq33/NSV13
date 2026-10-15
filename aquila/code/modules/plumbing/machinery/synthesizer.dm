///A single machine that produces a single chem. Can be placed in unison with others through plumbing to create chemical factories
/obj/machinery/plumbing/synthesizer
	name = "chemical synthesizer"
	desc = "Produces a single chemical at a given volume. Must be plumbed. Most effective when working in unison with other chemical synthesizers, heaters and filters."

	icon_state = "synthesizer"
	active_power_usage = 500

	///Amount we produce for every process. Ideally keep under 5 since thats currently the standard duct capacity
	var/amount = 1
	///The maximum we can produce for every process
	buffer = 5
	///I track them here because I have no idea how I'd make tgui loop like that
	var/static/list/possible_amounts = list(0,1,2,3,4,5)
	///The reagent we are producing. We are a typepath, but are also typecast because there's several occations where we need to use initial.
	var/datum/reagent/reagent_id = null
	///The amount of reagent dispensable before requiring a refill from a compressed matter cartridge.
	var/volume_left = 0
	///The maximum amount of precursor in a synthesizer.
	var/max_volume = 2000 //NSV13
	///Dirty slowdowns for not maintaining this
	var/slowdown_count = 0	//NSV13
	///straight up copied from chem dispenser. Being a subtype would be extremely tedious and making it global would restrict potential subtypes using different dispensable_reagents
	var/static/list/default_reagents = list(
		/datum/reagent/aluminium,
		/datum/reagent/bromine,
		/datum/reagent/carbon,
		/datum/reagent/chlorine,
		/datum/reagent/copper,
		/datum/reagent/consumable/ethanol,
		/datum/reagent/fluorine,
		/datum/reagent/hydrogen,
		/datum/reagent/iodine,
		/datum/reagent/iron,
		/datum/reagent/lithium,
		/datum/reagent/mercury,
		/datum/reagent/nitrogen,
		/datum/reagent/oxygen,
		/datum/reagent/phosphorus,
		/datum/reagent/potassium,
		/datum/reagent/uranium/radium,
		/datum/reagent/silicon,
		/datum/reagent/silver,
		/datum/reagent/sodium,
		/datum/reagent/stable_plasma,
		/datum/reagent/consumable/sugar,
		/datum/reagent/sulfur,
		/datum/reagent/toxin/acid,
		/datum/reagent/water,
		/datum/reagent/fuel
	)




	///reagents this synthesizer can dispense
	var/list/dispensable_reagents

/obj/machinery/plumbing/synthesizer/Initialize(mapload, layer)
	. = ..()
	AddComponent(/datum/component/plumbing/simple_supply, layer)
	dispensable_reagents = default_reagents
	update_appearance()

/obj/machinery/plumbing/synthesizer/process(delta_time)
	if(machine_stat & NOPOWER || !reagent_id || !amount)
		return
	if(reagents.total_volume >= amount*delta_time*0.5) //otherwise we get leftovers, and we need this to be precise
		return
	if(volume_left < amount) //Empty
		if(slowdown_count >= 4) //NSV13 - But what if we allow slow ticking of unmaintained devices?
			reagents.add_reagent(reagent_id, amount*delta_time*0.5)
			slowdown_count = 0
		else
			slowdown_count ++
			return
	reagents.add_reagent(reagent_id, amount*delta_time*0.5)
	volume_left = max(volume_left - amount*delta_time*0.5, 0)

/obj/machinery/plumbing/synthesizer/attackby(obj/item/O, mob/user, params)
	if(!istype(O, /obj/item/rcd_ammo))
		return ..()
	var/obj/item/rcd_ammo/R = O
	if(!R.ammoamt)
		to_chat(user, "<span class='warning'>W [R.name] nie został żaden odczynnik!</span>")
		return ..()
	var/added_volume = -volume_left //For the difference calculation
	volume_left = min(volume_left+R.ammoamt*20, src.max_volume) //400 per cartridge - x2 NSV13
	added_volume = added_volume+volume_left
	R.ammoamt -= added_volume/10
	if(R.ammoamt <= 0) //Emptied
		to_chat(user, "<span class='notice'>Uzupełniasz syntezator chemiczny zawartością [R.name], całkowicie go opróżniając!</span>")
		qdel(R)
		return
	if(added_volume == 0) //No change
		to_chat(user, "<span class='notice'>Syntezator chemiczny jest pełny!</span>")
		return
	to_chat(user, "<span class='notice'>Uzupełniasz syntezator chemiczny zawartością [R.name], zostawiając w nim [R.ammoamt*10] j.</span>")

/obj/machinery/plumbing/synthesizer/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Wyświetlacz pokazuje, że obecnie zawiera [volume_left] j. prekursora, zanim trzeba będzie go uzupełnić.</span>"

/obj/machinery/plumbing/synthesizer/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/plumbing/synthesizer/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ChemSynthesizer")
		ui.open()

/obj/machinery/plumbing/synthesizer/ui_data(mob/user)
	var/list/data = list()

	var/is_hallucinating = user.hallucinating()
	var/list/chemicals = list()

	for(var/A in dispensable_reagents)
		var/datum/reagent/R = GLOB.chemical_reagents_list[A]
		if(R)
			var/chemname = R.name
			if(is_hallucinating && prob(5))
				chemname = "[pick_list_replacements("hallucination.json", "chemicals")]"
			chemicals.Add(list(list("title" = chemname, "id" = ckey(R.name))))
	data["chemicals"] = chemicals
	data["amount"] = amount
	data["possible_amounts"] = possible_amounts

	data["current_reagent"] = ckey(initial(reagent_id.name))
	return data

/obj/machinery/plumbing/synthesizer/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("amount")
			var/new_amount = text2num(params["target"])
			if(new_amount in possible_amounts)
				amount = new_amount
				. = TRUE
		if("select")
			var/new_reagent = GLOB.name2reagent[params["reagent"]]
			if(new_reagent in dispensable_reagents)
				reagent_id = new_reagent
				. = TRUE
	if(.)
		update_appearance()
		reagents.clear_reagents()

/obj/machinery/plumbing/synthesizer/update_overlays()
	. = ..()
	var/mutable_appearance/r_overlay = mutable_appearance(icon, "[initial(icon_state)]_overlay")
	r_overlay.color = reagent_id ? initial(reagent_id.color) : "#FFFFFF"
	. += r_overlay

/obj/machinery/plumbing/synthesizer/soda
	name = "soda synthesizer"
	desc = "Produces a single chemical at a given volume. Must be plumbed."
	icon_state = "synthesizer_soda"

	//Copied from soda dispenser
	var/static/list/soda_reagents = list(
		/datum/reagent/consumable/coffee,
		/datum/reagent/consumable/space_cola,
		/datum/reagent/consumable/cream,
		/datum/reagent/consumable/dr_gibb,
		/datum/reagent/consumable/grenadine,
		/datum/reagent/consumable/ice,
		/datum/reagent/consumable/icetea,
		/datum/reagent/consumable/lemonjuice,
		/datum/reagent/consumable/lemon_lime,
		/datum/reagent/consumable/limejuice,
		/datum/reagent/consumable/menthol,
		/datum/reagent/consumable/orangejuice,
		/datum/reagent/consumable/pineapplejuice,
		/datum/reagent/consumable/pwr_game,
		/datum/reagent/consumable/shamblers,
		/datum/reagent/consumable/spacemountainwind,
		/datum/reagent/consumable/sodawater,
		/datum/reagent/consumable/space_up,
		/datum/reagent/consumable/sugar,
		/datum/reagent/consumable/tea,
		/datum/reagent/consumable/tomatojuice,
		/datum/reagent/consumable/tonic,
		/datum/reagent/water,
	)

/obj/machinery/plumbing/synthesizer/soda/Initialize(mapload, layer)
	. = ..()
	dispensable_reagents = soda_reagents

/obj/machinery/plumbing/synthesizer/beer
	name = "beer synthesizer"
	desc = "Produces a single chemical at a given volume. Must be plumbed."
	icon_state = "synthesizer_booze"

	//Copied from beer dispenser
	var/static/list/beer_reagents = list(
		/datum/reagent/consumable/ethanol/absinthe,
		/datum/reagent/consumable/ethanol/ale,
		/datum/reagent/consumable/ethanol/applejack,
		/datum/reagent/consumable/ethanol/beer,
		/datum/reagent/consumable/ethanol/cognac,
		/datum/reagent/consumable/ethanol/creme_de_cacao,
		/datum/reagent/consumable/ethanol/creme_de_coconut,
		/datum/reagent/consumable/ethanol/creme_de_menthe,
		/datum/reagent/consumable/ethanol/gin,
		/datum/reagent/consumable/ethanol/hcider,
		/datum/reagent/consumable/ethanol/kahlua,
		/datum/reagent/consumable/ethanol/rum,
		/datum/reagent/consumable/ethanol/sake,
		/datum/reagent/consumable/ethanol/tequila,
		/datum/reagent/consumable/ethanol/triple_sec,
		/datum/reagent/consumable/ethanol/vermouth,
		/datum/reagent/consumable/ethanol/vodka,
		/datum/reagent/consumable/ethanol/whiskey,
		/datum/reagent/consumable/ethanol/wine,
	)

/obj/machinery/plumbing/synthesizer/beer/Initialize(mapload, layer)
	. = ..()
	dispensable_reagents = beer_reagents
