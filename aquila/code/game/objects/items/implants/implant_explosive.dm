/obj/item/implant/explosive/engineering
	actions_types = list() // override to not let person explode it themselves

/obj/item/implant/explosive/engineering/Initialize(mapload)
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_STROMDRIVE_EXPLOSION, PROC_REF(stormdrive_went_boom))

/obj/item/implant/explosive/engineering/on_mob_death()
	return // this one doesn't explode on death

/obj/item/implant/explosive/engineering/get_data()
	var/dat = {"<b>Specyfikacja implantu:</b><BR><b>Nazwa:</b> Implant karny dla inżynierów Robust Corp RX-79<BR><b>Żywotność:</b> aktywuje się po wybuchu napędu burzowego.<BR><b>Ważne uwagi:</b> wybucha<BR><HR><b>Szczegóły implantu:</b><BR><b>Działanie:</b> zawiera kompaktowy, detonowany elektrycznie ładunek wybuchowy, który wybucha po wykryciu eksplozji napędu burzowego.<BR><b>Cechy specjalne:</b> wybucha<BR>
				"}
	return dat

/obj/item/implant/explosive/engineering/proc/stormdrive_went_boom(datum/source, obj/machinery/reactor)
	SIGNAL_HANDLER
	if(!imp_in)
		return
	if(reactor && !shares_overmap(reactor, imp_in)) // tylko silnik własnego statku
		return
	to_chat(imp_in, "<span class='userdanger'>Pozwoliłeś żeby silnik stormdrive wybuchł, przygotuj się na działania dyscyplinarne</span>")
	addtimer(CALLBACK(src, PROC_REF(activate), "stormdrive"), 5 SECONDS)

/datum/job/after_spawn(mob/living/H, mob/M)
	. = ..()
	if(M.real_name == "Zachary Andromalis")
		var/obj/item/implant/explosive/engineering/zachary_fucked_up = new
		zachary_fucked_up.implant(H, null, silent = TRUE)


/datum/job/chief_engineer/after_spawn(mob/living/H, mob/M)
	. = ..()
	var/obj/item/implant/explosive/engineering/ce_fucked_up = new
	ce_fucked_up.implant(H, null, silent = TRUE)

/obj/item/implantcase/engineering
	name = "implant case - 'engineers fucked up'"
	desc = "A glass case containing a modified explosive implant."
	imp_type = /obj/item/implant/explosive/engineering

/obj/item/storage/box/engimp/PopulateContents()
	var/static/items_inside = list(
		/obj/item/implantcase/engineering = 5,
		/obj/item/implanter = 1)
	generate_items_inside(items_inside,src)
