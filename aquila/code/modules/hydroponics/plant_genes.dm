/// How long a squashed plant with Separated Chemicals bubbles before its contents react
#define SEPARATED_CHEMICALS_MIX_TIME (2 SECONDS)

/// AQUILA - Separated Chemicals (aq33/NSV13#263, from BeeStation#5306): the produce's reagents can't react with each other until it is squashed
/datum/plant_gene/trait/noreact
	name = "Separated Chemicals"

/datum/plant_gene/trait/noreact/on_new(obj/item/reagent_containers/food/snacks/grown/G, newloc)
	..()
	// on_new runs before the seed adds its reagents, so they go in already separated
	if(G.reagents)
		ENABLE_BITFIELD(G.reagents.flags, NO_REACT)

/datum/plant_gene/trait/noreact/on_squashreact(obj/item/reagent_containers/food/snacks/grown/G, atom/target)
	if(!G.reagents)
		return
	DISABLE_BITFIELD(G.reagents.flags, NO_REACT)
	G.reagents.handle_reactions()

/obj/item/reagent_containers/food/snacks/grown
	/// AQUILA - Separated Chemicals: TRUE once squashed, while the contents mix; stops a second squash
	var/separated_mixing = FALSE

/// AQUILA - Separated Chemicals: squash() calls this instead of splashing; the contents react after a short delay, then splash (see squashreact())
/obj/item/reagent_containers/food/snacks/grown/proc/start_separated_mixing()
	separated_mixing = TRUE
	visible_message("<span class='warning'>[src] crumples, and bubbles ominously as its contents mix.</span>")
	addtimer(CALLBACK(src, PROC_REF(squashreact)), SEPARATED_CHEMICALS_MIX_TIME)

#undef SEPARATED_CHEMICALS_MIX_TIME
