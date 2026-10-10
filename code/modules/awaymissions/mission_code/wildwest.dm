/* Code for the Wild West map by Brotemis
 * Contains:
 *		Wish Granter
 *		Meat Grinder
 */

//Areas

/area/awaymission/wildwest/mines
	name = "Wild West Mines"
	icon_state = "away1"
	requires_power = FALSE

/area/awaymission/wildwest/gov
	name = "Wild West Mansion"
	icon_state = "away2"
	requires_power = FALSE

/area/awaymission/wildwest/refine
	name = "Wild West Refinery"
	icon_state = "away3"
	requires_power = FALSE

/area/awaymission/wildwest/vault
	name = "Wild West Vault"
	icon_state = "away3"

/area/awaymission/wildwest/vaultdoors
	name = "Wild West Vault Doors"  // this is to keep the vault area being entirely lit because of requires_power
	icon_state = "away2"
	requires_power = FALSE


 ////////// wildwest papers

/obj/item/paper/fluff/awaymissions/wildwest/grinder
	default_raw_text = "meat grinder requires sacri"


/obj/item/paper/fluff/awaymissions/wildwest/journal/page1
	name = "Planer Saul's Journal: Page 1"
	default_raw_text = "We've discovered something floating in space. We can't really tell how old it is, but it is scraped and bent to hell. There object is the size of about a room with double doors that we have yet to break into.   It is a lot sturdier than we could have imagined.  We have decided to call it 'The Vault' "

/obj/item/paper/fluff/awaymissions/wildwest/journal/page4
	name = "Planer Saul's Journal: Page 4"
	default_raw_text = " The miners in the town have become sick and almost all production has stopped. They, in a fit of delusion, tossed all of their mining equipment into the furnaces.  They all claimed the same thing. A voice beckoning them to lay down their arms. Stupid miners."

/obj/item/paper/fluff/awaymissions/wildwest/journal/page7
	name = "Planer Sauls' Journal: Page 7"
	default_raw_text = "The Vault...it just keeps growing and growing.  I went on my daily walk through the garden and now it's just right outside the mansion... a few days ago it was only barely visible. But whatever is inside...it's calling to me."

/obj/item/paper/fluff/awaymissions/wildwest/journal/page8
	name = "Planer Saul's Journal: Page 8"
	default_raw_text = "The syndicate have invaded.  Their ships appeared out of nowhere and now they likely intend to kill us all and take everything.  On the off-chance that the Vault may grant us sanctuary, many of us have decided to force our way inside and bolt the door, taking as many provisions with us as we can carry.  In case you find this, send for help immediately and open the Vault. Find us inside."


/*
 * Wish Granter
 */
/obj/machinery/wish_granter_dark
	name = "Wish Granter"
	desc = "You're not so sure about this, anymore..."
	icon = 'icons/obj/device.dmi'
	icon_state = "syndbeacon"

	density = TRUE
	use_power = NO_POWER_USE

	var/chargesa = 1
	var/insistinga = 0

/obj/machinery/wish_granter_dark/interact(mob/living/carbon/human/user)
	if(chargesa <= 0)
		to_chat(user, "Spełniacz Życzeń milczy.")
		return

	else if(!ishuman(user))
		to_chat(user, "Czujesz w Spełniaczu Życzeń mroczne poruszenie, coś, czego nie chcesz. Twoje instynkty są lepsze niż u jakiegokolwiek człowieka.")
		return

	else if(is_special_character(user))
		to_chat(user, "Nawet przy sercu tak mrocznym jak twoje wiesz, że nic dobrego z tego nie wyniknie. Coś instynktownego każe ci się odsunąć.")

	else if (!insistinga)
		to_chat(user, "Twój pierwszy dotyk budzi Spełniacza Życzeń, który zaczyna cię słuchać. Czy na pewno chcesz to zrobić?")
		insistinga++

	else
		chargesa--
		insistinga = 0
		var/wish = input("Pragniesz...","Wish") as null|anything in sortList(list("Power","Wealth","Immortality","Peace"))
		switch(wish)
			if("Power")
				to_chat(user, "<B>Twoje życzenie zostaje spełnione, ale za straszliwą cenę...</B>")
				to_chat(user, "Spełniacz Życzeń karze cię za twoje samolubstwo, zabierając twoją duszę i wykrzywiając ciało, by pasowało do ciemności w twoim sercu.")
				user.dna.add_mutation(LASEREYES)
				user.dna.add_mutation(SPACEMUT)
				user.dna.add_mutation(XRAY)
				user.set_species(/datum/species/shadow)
			if("Wealth")
				to_chat(user, "<B>Twoje życzenie zostaje spełnione, ale za straszliwą cenę...</B>")
				to_chat(user, "Spełniacz Życzeń karze cię za twoje samolubstwo, zabierając twoją duszę i wykrzywiając ciało, by pasowało do ciemności w twoim sercu.")
				new /obj/structure/closet/syndicate/resources/everything(loc)
				user.set_species(/datum/species/shadow)
			if("Immortality")
				to_chat(user, "<B>Twoje życzenie zostaje spełnione, ale za straszliwą cenę...</B>")
				to_chat(user, "Spełniacz Życzeń karze cię za twoje samolubstwo, zabierając twoją duszę i wykrzywiając ciało, by pasowało do ciemności w twoim sercu.")
				user.add_verb(/mob/living/carbon/proc/immortality)
				user.set_species(/datum/species/shadow)
			if("Peace")
				to_chat(user, "<B>Jakakolwiek obca świadomość zamieszkuje Spełniacza Życzeń, jest usatysfakcjonowana twoim życzeniem. Słychać odległe zawodzenie, gdy ostatni z Niewiernych zaczynają umierać, a potem cisza.</B>")
				to_chat(user, "Czujesz, że właśnie ledwo uniknąłeś straszliwego losu...")
				for(var/mob/living/simple_animal/hostile/faithless/F in GLOB.mob_living_list)
					F.death()


///////////////Meatgrinder//////////////


/obj/effect/meatgrinder
	name = "Meat Grinder"
	desc = "What is that thing?"
	density = TRUE
	anchored = TRUE
	icon = 'icons/mob/blob.dmi'
	icon_state = "blobpod"
	var/triggered = 0

/obj/effect/meatgrinder/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/effect/meatgrinder/proc/on_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER

	Bumped(AM)

/obj/effect/meatgrinder/Bumped(atom/movable/AM)

	if(triggered)
		return
	if(!ishuman(AM))
		return

	var/mob/living/carbon/human/M = AM

	if(M.stat != DEAD && M.ckey)
		visible_message("<span class='warning'>[M] triggered [src]!</span>")
		triggered = 1

		var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
		s.set_up(3, 1, src)
		s.start()
		explosion(M, 1, 0, 0, 0)
		qdel(src)

/////For the Wishgranter///////////

/mob/living/carbon/proc/immortality() //Mob proc so people cant just clone themselves to get rid of the shadowperson race. No hiding your wickedness.
	set category = "Immortality"
	set name = "Resurrection"

	var/mob/living/carbon/C = usr
	if(!C.stat)
		to_chat(C, "<span class='notice'>Jeszcze nie jesteś martwy!</span>")
		return
	if(C.has_status_effect(STATUS_EFFECT_WISH_GRANTERS_GIFT))
		to_chat(C, "<span class='warning'>Już się wskrzeszasz!</span>")
		return
	C.apply_status_effect(STATUS_EFFECT_WISH_GRANTERS_GIFT)
	return 1
