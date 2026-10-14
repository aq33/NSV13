// AQUILA - kreda detektywa (wzór: Paradise crayons.dm chalk, AGPL).
// Działa jak biała kredka, a do tego kliknięcie leżącego ciała (bez combat mode) szybko rysuje obrys pod nim.

/obj/item/toy/crayon/white/chalk
	name = "kreda detektywa"
	desc = "Kawałek białej kredy do obrysowywania ciał na miejscu zbrodni. Kliknij nią leżące ciało, żeby je obrysować."
	charges = 40
	edible = FALSE

/obj/item/toy/crayon/white/chalk/attack(mob/M, mob/user)
	var/mob/living/L = M
	if(!istype(L) || L == user || user.combat_mode || (L.mobility_flags & MOBILITY_STAND))
		return ..()
	var/turf/T = get_turf(L)
	if(!isValidSurface(T))
		to_chat(user, "<span class='warning'>Tu nie da się rysować.</span>")
		return
	user.visible_message("<span class='notice'>[user] obrysowuje kredą [L].</span>", "<span class='notice'>Obrysowujesz kredą [L]...</span>")
	if(!do_after(user, 2 SECONDS, target = L))
		return
	if(T != get_turf(L) || !use_charges(user, 1))
		return
	for(var/obj/effect/decal/cleanable/crayon/old in T)
		if(old.name == "obrys ciała")
			qdel(old)
	var/obj/effect/decal/cleanable/crayon/outline = new(T, paint_color, "body", "obrys ciała", L.lying)
	outline.desc = "Kredowy obrys ciała. Ktoś tu leżał."
	outline.add_hiddenprint(user)
	to_chat(user, "<span class='notice'>Kończysz obrys.</span>")
	check_empty(user)
