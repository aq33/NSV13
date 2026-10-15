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
	// Sprite "body" już leży (głowa w prawo, jak ciało z lying = 90), więc nie obracamy go o kąt leżenia,
	// tylko odbijamy w poziomie dla lying = 270. Figura w sprite'cie jest 4 px pod środkiem, ciało ma własne przesunięcie.
	var/obj/effect/decal/cleanable/crayon/outline = new(T, paint_color, "body", "obrys ciała")
	var/matrix/flip = matrix()
	if(L.lying == 270)
		flip.Scale(-1, 1)
	outline.transform = flip
	outline.pixel_x = L.pixel_x
	outline.pixel_y = L.pixel_y + 4
	outline.desc = "Kredowy obrys ciała. Ktoś tu leżał."
	outline.add_hiddenprint(user)
	to_chat(user, "<span class='notice'>Kończysz obrys.</span>")
	check_empty(user)
