/obj/item/clockwork/integration_cog
	name = "integration cog"
	desc = "A small cog that seems to spin by its own acord when left alone."
	icon_state = "integration_cog"
	clockwork_desc = "Ostra zębatka, którą można przeciąć APC i włożyć do środka, by czerpać energię dla bramy."

/obj/item/clockwork/integration_cog/attack_obj(obj/O, mob/living/user)
	if(!is_servant_of_ratvar(user))
		return ..()
	if(!istype(O, /obj/machinery/power/apc))
		return ..()
	var/obj/machinery/power/apc/A = O
	if(A.integration_cog)
		to_chat(user, "<span class='brass'>W [A] już jest [src].</span>")
		return
	if(!A.panel_open)
		//Cut open the panel
		to_chat(user, "<span class='notice'>Zaczynasz rozcinać [A].</span>")
		if(do_after(user, 50, target=A))
			to_chat(user, "<span class='brass'>Rozcinasz [A] za pomocą [src].</span>")
			A.panel_open = TRUE
			A.update_icon()
			return
		return
	//Insert the cog
	to_chat(user, "<span class='notice'>Zaczynasz wkładać [src] do [A].</span>")
	if(do_after(user, 40, target=A))
		A.integration_cog = src
		forceMove(A)
		A.panel_open = FALSE
		A.update_icon()
		to_chat(user, "<span class='notice'>Wkładasz [src] do [A].</span>")
		playsound(get_turf(user), 'sound/machines/clockcult/integration_cog_install.ogg', 20)
		if(!A.clock_cog_rewarded)
			GLOB.installed_integration_cogs ++
			A.clock_cog_rewarded = TRUE
			hierophant_message("<b>[user]</b> instaluje zębatkę integracyjną w [A]", span="<span class='nzcrentr'>", use_sanitisation=FALSE)
			//Update the cog counts
			for(var/obj/item/clockwork/clockwork_slab/S in GLOB.clockwork_slabs)
				S.update_integration_cogs()
			if(GLOB.clockcult_eminence)
				var/mob/living/simple_animal/eminence/eminence = GLOB.clockcult_eminence
				eminence.cog_change()
