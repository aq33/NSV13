//they are used for the maintenance spawn, for ling teratoma see changeling\teratoma.dm
/obj/effect/mob_spawn/teratomamonkey //spawning these is one of the downsides of overclocking the symptom
	name = "fleshy mass"
	desc = "A writhing mass of flesh."
	icon = 'icons/mob/blob.dmi'
	icon_state = "blob_spore_temp"
	density = FALSE
	anchored = FALSE

	antagonist_type = /datum/antagonist/teratoma/hugbox
	mob_type = /mob/living/carbon/monkey/tumor
	mob_name = "a living tumor"
	death = FALSE
	roundstart = FALSE
	use_cooldown = TRUE
	show_flavour = FALSE	//it's handled by antag datum
	short_desc = "You are a living tumor. By all accounts you should not exist."
	flavour_text = "Spread misery and chaos upon the station."
	important_info = "Avoid killing unprovoked, kill only in self defense!"

/obj/effect/mob_spawn/teratomamonkey/Initialize(mapload)
	. = ..()
	var/area/A = get_area(src)
	if(A)
		notify_ghosts("A living tumor has been born in [A.name].", 'sound/effects/splat.ogg', source = src, action = NOTIFY_ATTACK, flashwindow = FALSE)

/obj/effect/mob_spawn/teratomamonkey/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	to_chat(user, "<span class='notice'>Ew. It would be a bad idea to touch this. It could probably be destroyed with the extreme heat of a welder.</span>")

/obj/effect/mob_spawn/teratomamonkey/attackby(obj/item/W, mob/user, params)
	if(W.tool_behaviour == TOOL_WELDER && user.a_intent != INTENT_HARM)
		user.visible_message("<span class='warning'>[usr.name] destroys [src].</span>",
			"<span class='notice'>You hold the welder to [src] and it violently bursts!</span>",
			"<span class='italics'>You hear a gurgling noise.</span>")
		new /obj/effect/gibspawner/human(get_turf(src))
		qdel(src)
	else
		..()
