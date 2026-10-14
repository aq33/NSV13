/datum/test_chamber_kit/pr_437
	name = "Rewenant z tg"
	pr = "aq33/AquilaStation#437"
	description = "Przejmij rewenanta (prawy klik → Assume direct control). Ma 500 SE na odblokowanie wszystkiego. \
		Haunt Object przy narzędziach: mają się unieść, świecić i rzucać w ludzi, nullrod rozprasza. Vortex przy pudełku (opróżnia, przyciąga), Scatter odpycha. \
		Tablica spirytystyczna w ciemności przy dwóch ludziach. Potem daj się ujawnić i zabić, rozsyp ektoplazmę obok pierwszego lustra: \
		rewenant ma trafić do lustra z Mirror Talk, a rozbicie lustra go wypuścić. Drugie lustro jest nawiedzone od początku: rozbij je, ma wyjść nowy rewenant z ankiety."
	items = list(
		/mob/living/simple_animal/revenant = 1,
		/mob/living/carbon/human = 2,
		/obj/item/wrench = 1,
		/obj/item/screwdriver = 1,
		/obj/item/crowbar = 1,
		/obj/item/storage/box/survival = 1,
		/obj/item/nullrod = 1,
		/obj/structure/spirit_board = 1
	)

/datum/test_chamber_kit/pr_437/setup(list/spawned, list/turfs, turf/center, mob/user)
	for(var/mob/living/simple_animal/revenant/rev in spawned)
		rev.essence_excess = 500
		rev.essence_accumulated = 500
	var/list/far = turfs.Copy(min(length(items) + 1, length(turfs)))
	if(length(far) < 2)
		far = turfs
	var/obj/structure/mirror/empty_mirror = new(far[1])
	empty_mirror.name = "lustro na rewenanta"
	var/obj/structure/mirror/cursed_mirror = new(far[length(far)])
	cursed_mirror.name = "nawiedzone lustro"
	cursed_mirror.AddComponent(/datum/component/revenant_prison, create_on_release = TRUE)
