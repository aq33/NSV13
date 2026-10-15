/*
Stabilized extracts:
	Provides a passive buff to the holder.
*/

//To add: Create an effect in crossbreeding/_status_effects.dm with the name "/datum/status_effect/stabilized/[color]"
//Status effect will automatically be applied while held, and lost on drop.

/obj/item/slimecross/stabilized
	name = "stabilized extract"
	desc = "It seems inert, but anything it touches glows softly..."
	effect = "stabilized"
	icon_state = "stabilized"
	var/datum/status_effect/linked_effect
	var/mob/living/owner

/obj/item/slimecross/stabilized/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj,src)

/obj/item/slimecross/stabilized/Destroy()
	STOP_PROCESSING(SSobj,src)
	qdel(linked_effect)
	return ..()

/obj/item/slimecross/stabilized/process()
	var/humanfound = null
	if(ishuman(loc))
		humanfound = loc
	if(ishuman(loc.loc)) //Check if in backpack.
		humanfound = (loc.loc)
	if(!humanfound)
		return
	var/mob/living/carbon/human/H = humanfound
	var/effectpath = /datum/status_effect/stabilized
	var/static/list/effects = subtypesof(/datum/status_effect/stabilized)
	for(var/X in effects)
		var/datum/status_effect/stabilized/S = X
		if(initial(S.colour) == colour)
			effectpath = S
			break
	if(!H.has_status_effect(effectpath))
		var/datum/status_effect/stabilized/S = H.apply_status_effect(effectpath)
		owner = H
		S.linked_extract = src
		STOP_PROCESSING(SSobj,src)



//Colors and subtypes:
/obj/item/slimecross/stabilized/grey
	colour = "grey"
	effect_desc = "Sprawia, że szlamy są przyjazne dla właściciela"

/obj/item/slimecross/stabilized/orange
	colour = "orange"
	effect_desc = "Biernie próbuje podnieść lub obniżyć temperaturę ciała właściciela do normalnej"

/obj/item/slimecross/stabilized/purple
	colour = "purple"
	effect_desc = "Zapewnia efekt regeneracji"

/obj/item/slimecross/stabilized/blue
	colour = "blue"
	effect_desc = "Czyni właściciela odpornym na poślizgnięcie na wodzie, mydle lub pianie. Kosmiczny smar i lód nadal są zbyt śliskie."

/obj/item/slimecross/stabilized/metal
	colour = "metal"
	effect_desc = "Co 30 sekund dodaje arkusz materiału do losowego stosu w plecaku właściciela."

/obj/item/slimecross/stabilized/yellow
	colour = "yellow"
	effect_desc = "Co dziesięć sekund ładuje jedno z urządzeń właściciela o 10%."

/obj/item/slimecross/stabilized/darkpurple
	colour = "dark purple"
	effect_desc = "Daje płonące opuszki palców, które automatycznie gotują każde trzymane jedzenie nadające się do mikrofalówki."

/obj/item/slimecross/stabilized/darkblue
	colour = "dark blue"
	effect_desc = "Powoli gasi właściciela, jeśli płonie; moczy też przedmioty, takie jak kostki małpie, tworząc małpę."

/obj/item/slimecross/stabilized/silver
	colour = "silver"
	effect_desc = "Spowalnia tempo, w jakim właściciel traci składniki odżywcze"

/obj/item/slimecross/stabilized/bluespace
	colour = "bluespace"
	effect_desc = "Z dwuminutowym odnowieniem: gdy właściciel otrzyma dość obrażeń, zostaje teleportowany w bezpieczne miejsce."

/obj/item/slimecross/stabilized/sepia
	colour = "sepia"
	effect_desc = "Losowo zmienia szybkość właściciela."

/obj/item/slimecross/stabilized/cerulean
	colour = "cerulean"
	effect_desc = "Tworzy duplikat właściciela. Jeśli właściciel zginie, przejmie kontrolę nad duplikatem, chyba że śmierć nastąpiła przez ścięcie lub rozerwanie na kawałki."

/obj/item/slimecross/stabilized/pyrite
	colour = "pyrite"
	effect_desc = "Co kilka sekund losowo barwi właściciela."

/obj/item/slimecross/stabilized/red
	colour = "red"
	effect_desc = "Niweluje wszystkie spowolnienia wynikające z wyposażenia."

/obj/item/slimecross/stabilized/green
	colour = "green"
	effect_desc = "Zmienia imię i wygląd właściciela, gdy trzyma ten ekstrakt."

/obj/item/slimecross/stabilized/pink
	colour = "pink"
	effect_desc = "Dopóki w obecności właściciela żadne stworzenie nie zostanie skrzywdzone, nie zaatakują cię. Jeśli pokój zostanie złamany, przywrócenie go trwa dwie minuty."

/obj/item/slimecross/stabilized/gold
	colour = "gold"
	effect_desc = "Gdy jest trzymany, tworzy zwierzaka."
	var/mob_type
	var/datum/mind/saved_mind
	var/mob_name = "Familiar"

/obj/item/slimecross/stabilized/gold/proc/generate_mobtype()
	var/static/list/mob_spawn_pets = list()
	if(mob_spawn_pets.len <= 0)
		for(var/T in typesof(/mob/living/simple_animal))
			var/mob/living/simple_animal/SA = T
			switch(initial(SA.gold_core_spawnable))
				if(FRIENDLY_SPAWN)
					mob_spawn_pets += T
	mob_type = pick(mob_spawn_pets)

/obj/item/slimecross/stabilized/gold/Initialize(mapload)
	. = ..()
	generate_mobtype()

/obj/item/slimecross/stabilized/gold/attack_self(mob/user)
	var/choice = input(user, "Co chcesz zresetować?", "Dostosowanie chowańca") as null|anything in sortList(list("Familiar Location", "Familiar Species", "Familiar Sentience", "Familiar Name"))
	if(!user.canUseTopic(src, BE_CLOSE))
		return
	if(isliving(user))
		var/mob/living/L = user
		if(L.has_status_effect(/datum/status_effect/stabilized/gold))
			L.remove_status_effect(/datum/status_effect/stabilized/gold)
	if(choice == "Familiar Location")
		to_chat(user, "<span class='notice'>Szturchasz [src], a on lekko drży.</span>")
		START_PROCESSING(SSobj, src)
	if(choice == "Familiar Species")
		to_chat(user, "<span class='notice'>Ściskasz [src], a w środku zdaje się przesuwać jakiś kształt.</span>")
		generate_mobtype()
		START_PROCESSING(SSobj, src)
	if(choice == "Familiar Sentience")
		to_chat(user, "<span class='notice'>Dźgasz [src], a on wysyła świecący impuls.</span>")
		saved_mind = null
		START_PROCESSING(SSobj, src)
	if(choice == "Familiar Name")
		var/newname = sanitize_name(stripped_input(user, "Czy chcesz zmienić imię [mob_name]", "Zmiana imienia", mob_name, MAX_NAME_LEN))
		if(newname)
			mob_name = newname
		to_chat(user, "<span class='notice'>Mówisz cicho do [src], a on lekko drży w odpowiedzi.</span>")
		START_PROCESSING(SSobj, src)

/obj/item/slimecross/stabilized/oil
	colour = "oil"
	effect_desc = "Właściciel gwałtownie eksploduje, jeśli umrze, trzymając ten ekstrakt."

/obj/item/slimecross/stabilized/black
	colour = "black"
	effect_desc = "Podczas duszenia kogoś dłonie właściciela roztapiają się wokół szyi ofiary, wysysając z niej życie w zamian za jedzenie i leczenie."

/obj/item/slimecross/stabilized/lightpink
	colour = "light pink"
	effect_desc = "Właściciel porusza się bardzo szybko, trzymając ten ekstrakt; stabilizuje też epinefryną każdego w stanie krytycznym wokół ciebie."

/obj/item/slimecross/stabilized/adamantine
	colour = "adamantine"
	effect_desc = "Właściciel zyskuje niewielką premię do odporności na wszystkie rodzaje obrażeń."

/obj/item/slimecross/stabilized/rainbow
	colour = "rainbow"
	effect_desc = "Przyjmuje ekstrakt regeneracyjny i automatycznie go używa, gdy właściciel znajdzie się w stanie krytycznym."
	var/obj/item/slimecross/regenerative/regencore

/obj/item/slimecross/stabilized/rainbow/attackby(obj/item/O, mob/user)
	var/obj/item/slimecross/regenerative/regen = O
	if(istype(regen) && !regencore)
		to_chat(user, "<span class='notice'>Umieszczasz [O] w [src], przygotowując ekstrakt do automatycznego użycia!</span>")
		regencore = regen
		regen.forceMove(src)
		return
	return ..()
