#define FABRIC_PER_SHEET 4


///This is a loom. It's usually made out of wood and used to weave fabric like durathread or cotton into their respective cloth types.
/obj/structure/loom
	name = "loom"
	desc = "A simple device used to weave cloth and other thread-based fabrics together into usable material."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "loom"
	density = TRUE
	anchored = TRUE

/obj/structure/loom/attackby(obj/item/I, mob/user)
	if(weave(I, user))
		return
	return ..()

/obj/structure/loom/wrench_act(mob/living/user, obj/item/I)
	..()
	default_unfasten_wrench(user, I, 5)
	return TRUE

///Handles the weaving.
/obj/structure/loom/proc/weave(obj/item/stack/sheet/cotton/W, mob/user)
	if(!istype(W))
		return FALSE
	if(!anchored)
		user.show_message("<span class='notice'>Krosno musi zostać przykręcone.</span>", MSG_VISUAL)
		return FALSE
	if(W.amount < FABRIC_PER_SHEET)
		user.show_message("<span class='notice'>Zanim tego użyjesz, potrzebujesz przynajmniej [FABRIC_PER_SHEET] jednostek tkaniny.</span>", MSG_VISUAL)
		return FALSE
	user.show_message("<span class='notice'>Zaczynasz przeplatać [W.name] przez krosno..</span>", MSG_VISUAL)
	if(W.use_tool(src, user, W.pull_effort))
		if(W.amount >= FABRIC_PER_SHEET)
			new W.loom_result(drop_location())
			W.use(FABRIC_PER_SHEET)
			user.show_message("<span class='notice'>Przerabiasz [W.name] na tkaninę nadającą się do obróbki.</span>", MSG_VISUAL)
	return TRUE

#undef FABRIC_PER_SHEET
