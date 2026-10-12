/* Station-Collision(sc) away mission map specific stuff
 *
 * Notes:
 *		Feel free to use parts of this map, or even all of it for your own project. Just include me in the credits :)
 *
 *		Some of this code unnecessary, but the intent is to add a little bit of everything to serve as examples
 *		for anyone who wants to make their own stuff.
 *
 * Contains:
 *		Landmarks
 *		Guns
 *		Safe code hints
 *		Captain's safe
 *		Modified Nar'Sie
 */



/*
 * Landmarks - Instead of spawning a new object type, I'll spawn the bible using a landmark!
 */
/obj/effect/landmark/sc_bible_spawner
	name = "Safecode hint spawner"

/obj/effect/landmark/sc_bible_spawner/Initialize(mapload)
	..()
	var/obj/item/storage/book/bible/B = new /obj/item/storage/book/bible/booze(loc)
	B.name = "The Holy book of the Geometer"
	B.deity_name = "Narsie"
	B.icon_state = "melted"
	B.item_state = "melted"
	B.lefthand_file = 'icons/mob/inhands/misc/books_lefthand.dmi'
	B.righthand_file = 'icons/mob/inhands/misc/books_righthand.dmi'
	new /obj/item/paper/fluff/awaymissions/stationcollision/safehint_paper_bible(B)
	new /obj/item/pen(B)
	return INITIALIZE_HINT_QDEL

/*
 * Guns - I'm making these specifically so that I dont spawn a pile of fully loaded weapons on the map.
 */
//Captain's retro laser - Fires practice laser shots instead.
/obj/item/gun/energy/laser/retro/sc_retro
	name ="retro laser"
	icon_state = "retro"
	desc = "An older model of the basic lasergun, no longer used by Nanotrasen's security or military forces."
//	projectile_type = "/obj/item/projectile/practice"
	clumsy_check = 0 //No sense in having a harmless gun blow up in the clowns face

//Syndicate sub-machine guns.
/obj/item/gun/ballistic/automatic/c20r/sc_c20r

/obj/item/gun/ballistic/automatic/c20r/sc_c20r/Initialize(mapload)
	. = ..()
	for(var/ammo in magazine.stored_ammo)
		if(prob(95)) //95% chance
			magazine.stored_ammo -= ammo

//Barman's shotgun
/obj/item/gun/ballistic/shotgun/sc_pump

/obj/item/gun/ballistic/shotgun/sc_pump/Initialize(mapload)
	. = ..()
	for(var/ammo in magazine.stored_ammo)
		if(prob(95)) //95% chance
			magazine.stored_ammo -= ammo

//Lasers
/obj/item/gun/energy/laser/practice/sc_laser
	name = "Old laser"
	desc = "A once potent weapon, years of dust have collected in the chamber and lens of this weapon, weakening the beam significantly."
	clumsy_check = 0

/*
 * Safe code hints
 */

//These vars hold the code itself, they'll be generated at round-start
GLOBAL_VAR_INIT(sc_safecode1, "[rand(0,9)]")
GLOBAL_VAR_INIT(sc_safecode2, "[rand(0,9)]")
GLOBAL_VAR_INIT(sc_safecode3, "[rand(0,9)]")
GLOBAL_VAR_INIT(sc_safecode4, "[rand(0,9)]")
GLOBAL_VAR_INIT(sc_safecode5, "[rand(0,9)]")

//Pieces of paper actually containing the hints
/obj/item/paper/fluff/awaymissions/stationcollision/safehint_paper_prison
	name = "smudged paper"

/obj/item/paper/fluff/awaymissions/stationcollision/safehint_paper_prison/Initialize(mapload)
	default_raw_text = "<i>Atrament jest rozmazany, da się odczytać tylko kilka cyfr:</i> '[GLOB.sc_safecode1]**[GLOB.sc_safecode4]*'"
	return ..()

/obj/item/paper/fluff/awaymissions/stationcollision/safehint_paper_hydro
	name = "shredded paper"
/obj/item/paper/fluff/awaymissions/stationcollision/safehint_paper_hydro/Initialize(mapload)
	default_raw_text = "<i>Choć kartka jest podarta, wyraźnie widać liczbę:</i> '[GLOB.sc_safecode2]'"
	return ..()

/obj/item/paper/fluff/awaymissions/stationcollision/safehint_paper_caf
	name = "blood-soaked paper"
	//This does not have to be in New() because it is a constant. There are no variables in it i.e. [sc_safcode]
	default_raw_text = "<font color=red><i>Ta kartka jest przesiąknięta krwią, nie da się odczytać żadnego tekstu.</i></font>"

/obj/item/paper/fluff/awaymissions/stationcollision/safehint_paper_bible
	name = "hidden paper"
/obj/item/paper/fluff/awaymissions/stationcollision/safehint_paper_bible/Initialize(mapload)
	default_raw_text = {"<i>Wygląda na to, że długopis schowany razem z kartką wylał na nią atrament. Da się jednak odczytać trzy ostatnie cyfry:</i>'[GLOB.sc_safecode3][GLOB.sc_safecode4][GLOB.sc_safecode5]'
			"}
	return ..()

/obj/item/paper/fluff/awaymissions/stationcollision/safehint_paper_shuttle
	default_raw_text = {"<b>Cel:</b> stacja badawcza Epsilon<br>
			<b>Zadanie:</b> prototypowa broń. Kapitan zapewne trzyma ją zamkniętą w swoim sejfie.<br>
			<br>
			Nasz szpieg na pokładzie poznał szyfr i ukrył kilka jego kopii na stacji. Niestety został schwytany przez ochronę.
			Waszym zadaniem jest rozdzielić się, odnaleźć którąkolwiek z kartek z szyfrem do sejfu kapitan, otworzyć sejf i
			zabezpieczyć wszystko, co znajdziecie w środku. Jeśli to możliwe, odbijcie uwięzionego agenta Syndykatu i zdobądźcie od niego szyfr.<br>
			<br>
			<u>Jak zawsze eliminujcie każdego, kto stanie wam na drodze.</u><br>
			<br>
			Przydzielony wam statek zaprojektowano specjalnie do przebijania kadłuba innej stacji lub statku przy minimalnych obrażeniach agentów.
			Jest w pełni sterowany automatycznie, więc musicie tylko cieszyć się lotem, a gdy zapali się czerwona lampka... złapcie się czegoś!"}
/*
 * Captain's safe
 */
/obj/item/storage/secure/safe/sc_ssafe
	name = "Captain's secure safe"

/obj/item/storage/secure/safe/sc_ssafe/Initialize(mapload)
	. = ..()
	l_code = "[GLOB.sc_safecode1][GLOB.sc_safecode2][GLOB.sc_safecode3][GLOB.sc_safecode4][GLOB.sc_safecode5]"
	l_set = 1
	new /obj/item/gun/energy/mindflayer(src)
	new /obj/item/soulstone(src)
	new /obj/item/clothing/suit/space/hardsuit/cult(src)
	//new /obj/item/teleportation_scroll(src)
	new /obj/item/stack/ore/diamond(src)
