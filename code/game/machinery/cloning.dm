//Cloning revival method.
//The pod handles the actual cloning while the computer manages the clone profiles

//Potential replacement for genetics revives or something I dunno (?)

#define CLONE_INITIAL_DAMAGE     150    //Clones in clonepods start with 150 cloneloss damage and 150 brainloss damage, thats just logical
#define MINIMUM_HEAL_LEVEL 40

#define SPEAK(message) radio.talk_into(src, message, radio_channel)

/obj/machinery/clonepod
	name = "cloning pod"
	desc = "An electronically-lockable pod for growing organic tissue."
	density = TRUE
	icon = 'icons/obj/machines/cloning.dmi'
	icon_state = "pod_0"
	req_access = list(ACCESS_CLONING) //FOR PREMATURE UNLOCKING.
	verb_say = "stwierdza"
	circuit = /obj/item/circuitboard/machine/clonepod

	var/heal_level //The clone is released once its health reaches this level.
	var/obj/machinery/computer/cloning/connected //So we remember the connected clone machine.
	var/mess = FALSE //Need to clean out it if it's full of exploded clone.
	var/attempting = FALSE //One clone attempt at a time thanks
	var/speed_coeff
	var/efficiency

	var/fleshamnt = 1 //Amount of synthflesh needed per cloning cycle, is divided by efficiency

	var/datum/mind/clonemind
	var/grab_ghost_when = CLONER_MATURE_CLONE

	var/internal_radio = TRUE
	var/obj/item/radio/radio
	var/radio_key = /obj/item/encryptionkey/headset_med
	var/radio_channel = RADIO_CHANNEL_MEDICAL

	var/obj/effect/countdown/clonepod/countdown

	var/list/unattached_flesh
	var/flesh_number = 0
	var/datum/bank_account/current_insurance
	fair_market_price = 5 // He nodded, because he knew I was right. Then he swiped his credit card to pay me for arresting him.
	payment_department = ACCOUNT_MED
	var/experimental_pod = FALSE //experimental cloner will have true. TRUE allows you to clone a weird brain after scanning it.

/obj/machinery/clonepod/Initialize(mapload)
	create_reagents(100, OPENCONTAINER)

	. = ..()

	countdown = new(src)

	if(internal_radio)
		radio = new(src)
		radio.keyslot = new radio_key
		radio.subspace_transmission = TRUE
		radio.canhear_range = 0
		radio.recalculateChannels()

/obj/machinery/clonepod/Destroy()
	var/mob/living/mob_occupant = occupant
	go_out()
	if(mob_occupant)
		// Random comment: this is a bad situation since breaking the pod ejects the occupant
		log_cloning("[key_name(mob_occupant)] ejected from [src] at [AREACOORD(src)] due to Destroy().")
	QDEL_NULL(radio)
	QDEL_NULL(countdown)
	if(connected)
		connected.DetachCloner(src)
	QDEL_LIST(unattached_flesh)
	. = ..()

/obj/machinery/clonepod/RefreshParts()
	speed_coeff = 0
	efficiency = 0
	reagents.maximum_volume = 0
	fleshamnt = 1
	for(var/obj/item/reagent_containers/glass/beaker/G in component_parts)
		reagents.maximum_volume += G.volume
		G.reagents.trans_to(src, G.reagents.total_volume)
	for(var/obj/item/stock_parts/scanning_module/S in component_parts)
		efficiency += S.rating
		fleshamnt = 1/max(efficiency-1, 1)
	for(var/obj/item/stock_parts/manipulator/P in component_parts)
		speed_coeff += P.rating
	heal_level = (efficiency * 15) + 10
	if(heal_level < MINIMUM_HEAL_LEVEL)
		heal_level = MINIMUM_HEAL_LEVEL
	if(heal_level > 100)
		heal_level = 100

/obj/machinery/clonepod/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	user.examinate(src)

/obj/machinery/clonepod/AltClick(mob/user)
	if (alert(user, "Na pewno chcesz opróżnić kapsułę klonującą?", "Opróżnij magazyn odczynników:", "Yes", "No") != "Yes")
		return
	to_chat(user, "<span class='notice'>Opróżniasz [src] przez zawór spustowy na podłogę.</span>")
	reagents.reaction(user.loc)
	src.reagents.clear_reagents()

/obj/machinery/clonepod/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/clonepod/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Urządzenie <i>łączące</i> można <i>zeskanować</i> multitoolem. Można je opróżnić, alt-klikając.</span>"
	if(in_range(user, src) || isobserver(user))
		. += "<span class='notice'>Wyświetlacz stanu pokazuje: szybkość klonowania: <b>[speed_coeff*50]%</b>.<br>Przewidywane uszkodzenia komórkowe: <b>[100-heal_level]%</b><br> Pojemność: do <b>[reagents.maximum_volume]cm<sup>3</sup></b> syntetycznego ciała.<br>"
		. += "Zużycie syntetycznego ciała: <b>[round(fleshamnt*90, 1)]cm<sup>3</sup></b> na klona.</span><br>"
		. += "<span class='notice'>Wyświetlacz odczynników pokazuje: [round(reagents.total_volume, 1)] / [reagents.maximum_volume] cm<sup>3</sup></span>"
		if(efficiency > 5)
			. += "<span class='notice'>Kapsuła została ulepszona o automatyczne przetwarzanie i nakładanie korzystnych mutacji.</span>"

//The return of data disks?? Just for transferring between genetics machine/cloning machine.
//TO-DO: Make the genetics machine accept them.
/obj/item/disk/data
	name = "cloning data disk"
	icon_state = "datadisk0" //Gosh I hope syndies don't mistake them for the nuke disk.
	var/list/genetic_makeup_buffer = list()
	var/list/fields = list()
	var/list/mutations = list()
	var/max_mutations = 6
	var/read_only = FALSE //Well,it's still a floppy disk

//Disk stuff.
/obj/item/disk/data/Initialize(mapload)
	. = ..()
	icon_state = "datadisk[rand(0,6)]"
	add_overlay("datadisk_gene")

/obj/item/disk/data/attack_self(mob/user)
	read_only = !read_only
	to_chat(user, "<span class='notice'>Przestawiasz blokadę zapisu na: [read_only ? "chroniony" : "niechroniony"].</span>")

/obj/item/disk/data/examine(mob/user)
	. = ..()
	. += "Blokada zapisu jest ustawiona na: [read_only ? "chroniony" : "niechroniony"]."

/obj/item/disk/data/debug
	name = "Debug genetic data disk"
	desc = "A disk that contains all existing genetic mutations."
	max_mutations = 100

/obj/item/disk/data/debug/Initialize(mapload)
	. = ..()
	for(var/datum/mutation/HM as() in GLOB.all_mutations)
		mutations += new HM

//Clonepod

/obj/machinery/clonepod/examine(mob/user)
	. = ..()
	var/mob/living/mob_occupant = occupant
	if(mess)
		. += "Jest pełna krwi i wnętrzności. Przysiągłbyś, że to się rusza..."
	if(is_operational && istype(mob_occupant))
		if(mob_occupant.stat != DEAD)
			. += "Obecny cykl klonowania ukończono w [round(get_completion())]%."

/obj/machinery/clonepod/return_air()
	// We want to simulate the clone not being in contact with
	// the atmosphere, so we'll put them in a constant pressure
	// nitrogen. They don't need to breathe while cloning anyway.
	var/static/datum/gas_mixture/immutable/cloner/GM //global so that there's only one instance made for all cloning pods
	if(!GM)
		GM = new
	return GM

/obj/machinery/clonepod/proc/get_completion()
	. = FALSE
	var/mob/living/mob_occupant = occupant
	if(mob_occupant)
		. = (100 * ((mob_occupant.health + 100) / (heal_level + 100)))

/obj/machinery/clonepod/attack_ai(mob/user)
	return examine(user)

//Start growing a human clone in the pod!
/obj/machinery/clonepod/proc/growclone(clonename, ui, mutation_index, mindref, last_death, datum/species/mrace, list/features, factions, list/quirks, datum/bank_account/insurance, list/traumas, body_only, experimental)
	var/result = CLONING_SUCCESS
	if(!reagents.has_reagent(/datum/reagent/medicine/synthflesh, fleshamnt))
		connected_message("Nie można rozpocząć klonowania: za mało syntetycznego ciała.")
		return ERROR_NO_SYNTHFLESH
	if(panel_open)
		return ERROR_PANEL_OPENED
	if(mess || attempting)
		return ERROR_MESS_OR_ATTEMPTING
	if(experimental && !experimental_pod)
		return ERROR_MISSING_EXPERIMENTAL_POD

	if(!body_only && !(experimental && experimental_pod))
		clonemind = locate(mindref) in SSticker.minds
		if(!istype(clonemind))	//not a mind
			return ERROR_NOT_MIND
		//if(last_death<0) //presaved clone is not clonable
		//	return ERROR_PRESAVED_CLONE
		if((last_death > 0) && (abs(clonemind.last_death - last_death) > 5)) //You can't clone old ones. 5 seconds grace because a sync-failure can happen. //NSV13 - allow precloning
			return ERROR_OUTDATED_CLONE
		if(!QDELETED(clonemind.current))
			if(clonemind.current.stat != DEAD)	//mind is associated with a non-dead body
				return ERROR_ALREADY_ALIVE
			if(clonemind.current.suiciding) // Mind is associated with a body that is suiciding.
				return ERROR_COMMITED_SUICIDE
		if(!clonemind.active)
			// get_ghost() will fail if they're unable to reenter their body
			var/mob/dead/observer/G = clonemind.get_ghost()
			if(!G)
				return ERROR_SOUL_DEPARTED
			if(G.suiciding) // The ghost came from a body that is suiciding.
				return ERROR_SUICIDED_BODY
		if(clonemind.damnation_type) //Can't clone the damned.
			INVOKE_ASYNC(src, PROC_REF(horrifyingsound))
			mess = TRUE
			icon_state = "pod_g"
			update_icon()
			return ERROR_SOUL_DAMNED
		if(clonemind.no_cloning_at_all) // nope.
			return ERROR_UNCLONABLE
		current_insurance = insurance
	attempting = TRUE //One at a time!!
	countdown.start()

	var/mob/living/carbon/human/H = new /mob/living/carbon/human(src)

	H.hardset_dna(ui, mutation_index, H.real_name, null, mrace, features)

	if(!HAS_TRAIT(H, TRAIT_RADIMMUNE))//dont apply mutations if the species is Mutation proof.
		if(efficiency > 2)
			var/list/unclean_mutations = (GLOB.not_good_mutations|GLOB.bad_mutations)
			H.dna.remove_mutation_group(unclean_mutations)
		if(efficiency > 5 && prob(20))
			H.easy_randmut(POSITIVE)
		if(efficiency < 3 && prob(50))
			var/mob/M = H.easy_randmut(NEGATIVE+MINOR_NEGATIVE)
			if(ismob(M))
				H = M

	H.silent = 20 //Prevents an extreme edge case where clones could speak if they said something at exactly the right moment.
	occupant = H

	if(!clonename)	//to prevent null names
		clonename = "clone ([rand(1,999)])"
	H.real_name = clonename

	icon_state = "pod_1"
	//Get the clone body ready
	maim_clone(H)
	ADD_TRAIT(H, TRAIT_STABLEHEART, CLONING_POD_TRAIT)
	ADD_TRAIT(H, TRAIT_STABLELIVER, CLONING_POD_TRAIT)
	ADD_TRAIT(H, TRAIT_EMOTEMUTE, CLONING_POD_TRAIT)
	ADD_TRAIT(H, TRAIT_MUTE, CLONING_POD_TRAIT)
	ADD_TRAIT(H, TRAIT_NOBREATH, CLONING_POD_TRAIT)
	ADD_TRAIT(H, TRAIT_NOCRITDAMAGE, CLONING_POD_TRAIT)
	H.Unconscious(80)

	if(!experimental && !experimental_pod && !body_only) //everything should be perfect to none
		clonemind.transfer_to(H)
	else if(!(!experimental && body_only))
		current_insurance = insurance
		offer_to_ghost(H)
		result = CLONING_SUCCESS_EXPERIMENTAL

	if(H.mind)
		if(grab_ghost_when == CLONER_FRESH_CLONE)
			H.grab_ghost()
			to_chat(H, "<span class='notice'><b>Gdy twoje ciało się regeneruje, powoli wraca ci świadomość.</b><br><i>A więc tak się czuje klonowanie?</i></span>")

		if(grab_ghost_when == CLONER_MATURE_CLONE)
			H.ghostize(TRUE)	//Only does anything if they were still in their old body and not already a ghost
			to_chat(H.get_ghost(TRUE), "<span class='notice'>Twoje ciało zaczyna się regenerować w kapsule klonującej. Odzyskasz świadomość, gdy proces się zakończy.</span>")

	if(H)
		H.faction |= factions
		remove_hivemember(H)

		for(var/V in quirks)
			var/datum/quirk/Q = new V(H)
			Q.on_clone(quirks[V])

		for(var/t in traumas)
			var/datum/brain_trauma/BT = t
			var/datum/brain_trauma/cloned_trauma = BT.on_clone()
			if(cloned_trauma)
				H.gain_trauma(cloned_trauma, BT.resilience)

		H.set_cloned_appearance()

		H.set_suicide(FALSE)
	to_chat(H, "<span class='warning'><b>Zostajesz sklonowany. Nie pamiętasz, jak zginąłeś.</b></span>") //NSV13
	attempting = FALSE
	return result

/obj/machinery/clonepod/proc/offer_to_ghost(mob/living/carbon/H)
	set waitfor = FALSE
	var/list/mob/dead/observer/candidates = pollCandidatesForMob("Chcesz zagrać jako eksperymentalny klon [H.real_name]?", ROLE_EXPERIMENTAL_CLONE, null, 30 SECONDS, H)
	if(length(candidates))
		var/mob/dead/observer/C = pick(candidates)
		H.key = C.key
		log_game("[key_name(C)] became [H.real_name]'s experimental clone.")
		message_admins("[key_name_admin(C)] became [H.real_name]'s experimental clone.")
		to_chat(H, "<span class='warning'>Jeśli zamienisz się w ducha, natychmiast zginiesz. Zaczekaj, aż klonowanie się zakończy.</span>")

//Grow clones to maturity then kick them out.  FREELOADERS
/obj/machinery/clonepod/process()
	var/mob/living/mob_occupant = occupant

	if(!is_operational) //Autoeject if power is lost (or the pod is dysfunctional due to whatever reason)
		if(mob_occupant)
			go_out()
			log_cloning("[key_name(mob_occupant)] ejected from [src] at [AREACOORD(src)] due to power loss.")

			connected_message("Wyrzucono klona: utrata zasilania.")

	else if(mob_occupant && (mob_occupant.loc == src))
		if(!reagents.has_reagent(/datum/reagent/medicine/synthflesh, fleshamnt))
			go_out()
			log_cloning("[key_name(mob_occupant)] ejected from [src] at [AREACOORD(src)] due to insufficient material.")
			connected_message("Wyrzucono klona: za mało materiału.")
			if(internal_radio)
				SPEAK("Klonowanie [mob_occupant.real_name] zostało przedwcześnie przerwane z powodu braku materiału.")
		else if(SSeconomy.full_ancap)
			if(!current_insurance)
				go_out()
				log_cloning("[key_name(mob_occupant)] ejected from [src] at [AREACOORD(src)] due to invalid bank account.")
				connected_message("Wyrzucono klona: brak konta bankowego.")
				if(internal_radio)
					SPEAK("Klonowanie [mob_occupant.real_name] zostało przerwane, bo nie ma konta bankowego, z którego można by pobrać opłatę.")
			else if(!current_insurance.adjust_money(-fair_market_price))
				go_out()
				log_cloning("[key_name(mob_occupant)] ejected from [src] at [AREACOORD(src)] due to insufficient funds.")
				connected_message("Wyrzucono klona: brak pieniędzy.")
				if(internal_radio)
					SPEAK("Klonowanie [mob_occupant.real_name] zostało przedwcześnie przerwane z powodu braku możliwości zapłaty.")
			else
				var/datum/bank_account/department/D = SSeconomy.get_dep_account(payment_department)
				if(D && !D.is_nonstation_account())
					D.adjust_money(fair_market_price)
		if(mob_occupant && (mob_occupant.stat == DEAD) || (mob_occupant.suiciding) || mob_occupant.ishellbound())  //Autoeject corpses and suiciding dudes.
			connected_message("Odrzucono klona: zmarły.")
			if(internal_radio)
				SPEAK("Klonowanie [mob_occupant.real_name] zostało przerwane z powodu nieodwracalnej niewydolności tkanek.")
			go_out()
			log_cloning("[key_name(mob_occupant)] ejected from [src] at [AREACOORD(src)] after suiciding.")

		else if(mob_occupant && mob_occupant.cloneloss > (100 - heal_level))
			mob_occupant.Unconscious(80)
			var/dmg_mult = CONFIG_GET(number/damage_multiplier)
			 //Slowly get that clone healed and finished.
			mob_occupant.adjustCloneLoss(-((speed_coeff / 2) * dmg_mult), TRUE, TRUE)
			if(reagents.has_reagent(/datum/reagent/medicine/synthflesh, fleshamnt))
				reagents.remove_reagent(/datum/reagent/medicine/synthflesh, fleshamnt)
			else if(reagents.has_reagent(/datum/reagent/blood, fleshamnt*3))
				reagents.remove_reagent(/datum/reagent/blood, fleshamnt*3)
			var/progress = CLONE_INITIAL_DAMAGE - mob_occupant.getCloneLoss()
			// To avoid the default cloner making incomplete clones
			progress += (100 - MINIMUM_HEAL_LEVEL)
			var/milestone = CLONE_INITIAL_DAMAGE / flesh_number
			var/installed = flesh_number - unattached_flesh.len

			if((progress / milestone) >= installed)
				// attach some flesh
				var/obj/item/I = pick_n_take(unattached_flesh)
				if(isorgan(I))
					var/obj/item/organ/O = I
					O.organ_flags &= ~ORGAN_FROZEN
					O.Insert(mob_occupant)
				else if(isbodypart(I))
					var/obj/item/bodypart/BP = I
					BP.attach_limb(mob_occupant)

			use_power(5000 * speed_coeff) //This might need tweaking.

		else if(mob_occupant && (mob_occupant.cloneloss <= (100 - heal_level)))
			connected_message("Proces klonowania zakończony.")
			if(internal_radio)
				SPEAK("Cykl klonowania [mob_occupant.real_name] został zakończony.")

			// If the cloner is upgraded to debugging high levels, sometimes
			// organs and limbs can be missing.
			for(var/i in unattached_flesh)
				if(isorgan(i))
					var/obj/item/organ/O = i
					O.organ_flags &= ~ORGAN_FROZEN
					O.Insert(mob_occupant)
				else if(isbodypart(i))
					var/obj/item/bodypart/BP = i
					BP.attach_limb(mob_occupant)

			go_out()
			log_cloning("[key_name(mob_occupant)] completed cloning cycle in [src] at [AREACOORD(src)].")

	else if (!mob_occupant || mob_occupant.loc != src)
		occupant = null
		if (!mess && !panel_open)
			icon_state = "pod_0"
		use_power(200)

//Let's unlock this early I guess.  Might be too early, needs tweaking.
/obj/machinery/clonepod/attackby(obj/item/W, mob/user, params)
	if(!(occupant || mess))
		if(default_deconstruction_screwdriver(user, "[icon_state]_maintenance", "[initial(icon_state)]",W))
			return

	if(default_deconstruction_crowbar(W))
		return

	if(W.tool_behaviour == TOOL_MULTITOOL)
		if(!multitool_check_buffer(user, W))
			return
		var/obj/item/multitool/P = W

		if(istype(P.buffer, /obj/machinery/computer/cloning))
			if(get_area(P.buffer) != get_area(src))
				to_chat(user, "<font color = #666633>-% Nie można łączyć maszyn między strefami zasilania. Bufor wyczyszczony %-</font color>")
				P.buffer = null
				return
			to_chat(user, "<font color = #666633>-% Pomyślnie połączono [P.buffer] z [src] %-</font color>")
			var/obj/machinery/computer/cloning/comp = P.buffer
			if(connected)
				connected.DetachCloner(src)
			comp.AttachCloner(src)
		else
			P.buffer = src
			to_chat(user, "<font color = #666633>-% Pomyślnie zapisano [REF(P.buffer)] [P.buffer.name] w buforze %-</font color>")
		return

	var/mob/living/mob_occupant = occupant
	if(W.GetID())
		if(!check_access(W))
			to_chat(user, "<span class='danger'>Odmowa dostępu.</span>")
			return
		if(!(mob_occupant || mess))
			to_chat(user, "<span class='danger'>Błąd: kapsuła nie ma pacjenta.</span>")
			return
		else
			add_fingerprint(user)
			connected_message("Awaryjne wyrzucenie")
			SPEAK("Nastąpiło awaryjne wyrzucenie [clonemind.name]. Przeżycie nie jest gwarantowane.")
			to_chat(user, "<span class='notice'>Wymuszasz awaryjne wyrzucenie. </span>")
			go_out()
			log_cloning("[key_name(user)] manually ejected [key_name(mob_occupant)] from [src] at [AREACOORD(src)].")
			log_combat(user, mob_occupant, "ejected", W, "from [src]")
	else
		return ..()

/obj/machinery/clonepod/emag_act(mob/user)
	if(!occupant)
		return
	to_chat(user, "<span class='warning'>Psujesz kompilator genetyczny.</span>")
	malfunction()
	add_fingerprint(user)
	log_cloning("[key_name(user)] emagged [src] at [AREACOORD(src)], causing it to malfunction.")
	log_combat(user, src, "emagged", null, occupant ? "[occupant] inside, killing them via malfunction." : null)

//Put messages in the connected computer's temp var for display.
/obj/machinery/clonepod/proc/connected_message(message)
	if ((isnull(connected)) || (!istype(connected, /obj/machinery/computer/cloning)))
		return FALSE
	if (!message)
		return FALSE

	connected.temp = message
	connected.updateUsrDialog()
	return TRUE

/obj/machinery/clonepod/proc/go_out(move = TRUE)
	countdown.stop()
	var/mob/living/mob_occupant = occupant
	var/turf/T = get_turf(src)

	if(mess) //Clean that mess and dump those gibs!
		for(var/obj/fl in unattached_flesh)
			fl.forceMove(T)
			if(istype(fl, /obj/item/organ))
				var/obj/item/organ/O = fl
				O.organ_flags &= ~ORGAN_FROZEN
		unattached_flesh.Cut()
		mess = FALSE
		new /obj/effect/gibspawner/generic(get_turf(src), mob_occupant)
		audible_message("<span class='italics'>Słyszysz plaśnięcie.</span>")
		icon_state = "pod_0"
		return

	if(!mob_occupant)
		return

	if(HAS_TRAIT(mob_occupant, TRAIT_NOCLONELOSS))
		var/cl_loss = mob_occupant.getCloneLoss()
		mob_occupant.adjustBruteLoss(cl_loss, FALSE)
		mob_occupant.setCloneLoss(0, FALSE, TRUE)

	current_insurance = null
	REMOVE_TRAIT(mob_occupant, TRAIT_STABLEHEART, CLONING_POD_TRAIT)
	REMOVE_TRAIT(mob_occupant, TRAIT_STABLELIVER, CLONING_POD_TRAIT)
	REMOVE_TRAIT(mob_occupant, TRAIT_EMOTEMUTE, CLONING_POD_TRAIT)
	REMOVE_TRAIT(mob_occupant, TRAIT_MUTE, CLONING_POD_TRAIT)
	REMOVE_TRAIT(mob_occupant, TRAIT_NOCRITDAMAGE, CLONING_POD_TRAIT)
	REMOVE_TRAIT(mob_occupant, TRAIT_NOBREATH, CLONING_POD_TRAIT)

	if(grab_ghost_when == CLONER_MATURE_CLONE)
		mob_occupant.grab_ghost()
		to_chat(occupant, "<span class='notice'><b>Następuje jasny błysk!</b><br><i>Czujesz się jak nowa istota.</i></span>")
		mob_occupant.flash_act()

	if(move)
		occupant.forceMove(T)
	icon_state = "pod_0"
	mob_occupant.domutcheck(1) //Waiting until they're out before possible monkeyizing. The 1 argument forces powers to manifest.
	for(var/fl in unattached_flesh)
		qdel(fl)
	unattached_flesh.Cut()

	occupant = null
	clonemind = null

// Guess they moved out on their own, remove any clone status effects
// If the occupant var is null, welp what can we do
/obj/machinery/clonepod/Exited(atom/movable/AM, atom/newloc)
	if(AM == occupant)
		go_out(FALSE)
	. = ..()

/obj/machinery/clonepod/proc/malfunction()
	var/mob/living/mob_occupant = occupant
	if(mob_occupant)
		connected_message("Błąd krytyczny!")
		SPEAK("Błąd krytyczny! Skontaktuj się z technikiem Thinktronic Systems, ponieważ może to wpłynąć na gwarancję.")
		mess = TRUE
		maim_clone(mob_occupant)	//Remove every bit that's grown back so far to drop later, also destroys bits that haven't grown yet
		icon_state = "pod_g"
		if(clonemind && mob_occupant.mind != clonemind)
			clonemind.transfer_to(mob_occupant)
		mob_occupant.grab_ghost() // We really just want to make you suffer.
		flash_color(mob_occupant, flash_color="#960000", flash_time=100)
		to_chat(mob_occupant, "<span class='warning'><b>Rozdzierający ból przeszywa twoją świadomość, gdy twoje ciało zostaje rozerwane.</b><br><i>Czy tak wygląda umieranie? Tak.</i></span>")
		playsound(src, 'sound/machines/warning-buzzer.ogg', 50)
		SEND_SOUND(mob_occupant, sound('sound/hallucinations/veryfar_noise.ogg',0,1,50))
		log_cloning("[key_name(mob_occupant)] destroyed within [src] at [AREACOORD(src)] due to malfunction.")
		QDEL_IN(mob_occupant, 40)

/obj/machinery/clonepod/relaymove(mob/user)
	container_resist(user)

/obj/machinery/clonepod/container_resist(mob/living/user)
	if(user.stat == CONSCIOUS)
		go_out()

/obj/machinery/clonepod/emp_act(severity)
	. = ..()
	if (!(. & EMP_PROTECT_SELF))
		var/mob/living/mob_occupant = occupant
		if(mob_occupant && prob(100/(severity*efficiency)))
			connected_message(Gibberish("Przypadkowe wyrzucenie z powodu EMP"))
			SPEAK(Gibberish("Wystawienie na pola elektromagnetyczne spowodowało przedwczesne wyrzucenie [mob_occupant.real_name]."))
			go_out()
			log_cloning("[key_name(mob_occupant)] ejected from [src] at [AREACOORD(src)] due to EMP pulse.")

/obj/machinery/clonepod/ex_act(severity, target)
	..()
	if(!QDELETED(src) && occupant)
		var/mob/living/mob_occupant = occupant
		go_out()
		log_cloning("[key_name(mob_occupant)] ejected from [src] at [AREACOORD(src)] due to explosion.")

/obj/machinery/clonepod/handle_atom_del(atom/A)
	if(A == occupant)
		occupant = null
		countdown.stop()

/obj/machinery/clonepod/proc/horrifyingsound()
	for(var/i in 1 to 5)
		playsound(src,pick('sound/hallucinations/growl1.ogg','sound/hallucinations/growl2.ogg','sound/hallucinations/growl3.ogg'), 100, rand(0.95,1.05))
		sleep(1)
	sleep(10)
	playsound(src,'sound/hallucinations/wail.ogg', 100, TRUE)

/obj/machinery/clonepod/deconstruct(disassembled = TRUE)
	for(var/obj/item/reagent_containers/glass/beaker/G in component_parts)
		reagents.trans_to(G, G.reagents.maximum_volume)
	if(occupant)
		var/mob/living/mob_occupant = occupant
		go_out()
		log_cloning("[key_name(mob_occupant)] ejected from [src] at [AREACOORD(src)] due to deconstruction.")
	..()

/obj/machinery/clonepod/proc/maim_clone(mob/living/carbon/human/H)
	if(!unattached_flesh)
		unattached_flesh = list()
	else
		for(var/fl in unattached_flesh)
			qdel(fl)
		unattached_flesh.Cut()

	H.setCloneLoss(CLONE_INITIAL_DAMAGE, TRUE, TRUE)     //Yeah, clones start with very low health, not with random, because why would they start with random health
	// In addition to being cellularly damaged, they also have no limbs or internal organs.
	// Applying brainloss is done when the clone leaves the pod, so application of traumas can happen
	// based on the level of damage sustained.

	if(!HAS_TRAIT(H, TRAIT_NODISMEMBER))
		var/static/list/zones = list(BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_R_LEG, BODY_ZONE_L_LEG)
		for(var/zone in zones)
			var/obj/item/bodypart/BP = H.get_bodypart(zone)
			if(BP)
				BP.drop_limb()
				BP.forceMove(src)
				unattached_flesh += BP

	for(var/o in H.internal_organs)
		var/obj/item/organ/organ = o
		if(!istype(organ) || (organ.organ_flags & ORGAN_VITAL))
			continue
		organ.organ_flags |= ORGAN_FROZEN
		organ.Remove(H, special=TRUE)
		organ.forceMove(src)
		unattached_flesh += organ

	flesh_number = unattached_flesh.len

/obj/machinery/clonepod/prefilled

/obj/machinery/clonepod/prefilled/Initialize(mapload)
	. = ..()
	reagents.add_reagent(/datum/reagent/medicine/synthflesh, 100)

//Experimental cloner; clones a body regardless of the owner's status.
/obj/machinery/clonepod/experimental
	name = "experimental cloning pod"
	desc = "An ancient cloning pod. It seems to be an early prototype of the experimental cloners used in Nanotrasen Stations."
	icon = 'icons/obj/machines/cloning.dmi'
	icon_state = "pod_0"
	req_access = null
	circuit = /obj/item/circuitboard/machine/clonepod/experimental
	internal_radio = FALSE
	experimental_pod = TRUE

/*
 *	Manual -- A big ol' manual.
 */

/obj/item/paper/guides/jobs/medical/cloning
	name = "paper - 'H-87 Cloning Apparatus Manual"
	default_raw_text = {"<h4>Pierwsze kroki</h4>
	Gratulacje, twoja stacja zakupiła przemysłowe urządzenie klonujące H-87!<br>
	Korzystanie z H-87 jest prawie tak proste jak operacja mózgu! Wystarczy umieścić docelowego humanoida w komorze skanującej i wybrać opcję skanowania, by utworzyć nowy profil!<br>
	<b>To wszystko!</b><br>
	<i>Uwaga: system klonujący nie skanuje życia nieorganicznego ani małych naczelnych. Skan może się nie udać, jeśli obiekt ma poważne uszkodzenia mózgu.</i><br>
	<p>Profile klonów można przeglądać w menu profili. Skanowanie wszczepia obiektowi uzupełniający IMPLANT MONITORUJĄCY ZDROWIE, którego dane widać w każdym profilu.
	Usuwanie profili ograniczono do poziomu dostępu \[szef działu\].</p>
	<h4>Klonowanie z profilu</h4>
	Klonowanie jest tak proste jak naciśnięcie opcji KLONUJ na dole wybranego profilu.<br>
	Zgodnie z umową o PRAWIE PRACOWNIKÓW DO PRYWATNOŚCI w twojej firmie H-87 nie może klonować członków załogi, którzy wciąż żyją.<br>
	<br>
	<p>Dołączony SYSTEM KAPSUŁ KLONUJĄCYCH wytworzy żądanego klona. Standardowy czas dojrzewania klona (z technologią SPEEDCLONE) to około 90 sekund.
	Kapsułę klonującą można odblokować wcześniej dowolnym ID z dostępem \[badacz medyczny\] po zakończeniu wstępnego dojrzewania.</p><br>
	<i>Uwaga: w wyniku dryfu genetycznego powstałe klony mogą mieć niewielką WADĘ ROZWOJOWĄ.</i><br>
	<h4>Zarządzanie profilami</h4>
	<p>H-87 (podobnie jak standardowa maszyna genetyczna twojej stacji) przyjmuje STANDARDOWE DYSKIETKI Z DANYMI.
	Dyskietki służą do przenoszenia informacji genetycznych między maszynami i profilami.
	Po włożeniu dysku w każdym profilu pojawi się okno wczytywania/zapisu.</p><br>
	<i>Dobra dyskietka to świetny sposób na przeciwdziałanie wspomnianemu dryfowi genetycznemu!</i><br>
	<br>
	<font size=1>Technologia wyprodukowana na licencji Thinktronic Systems, LTD.</font>"}

#undef CLONE_INITIAL_DAMAGE
#undef SPEAK
#undef MINIMUM_HEAL_LEVEL
