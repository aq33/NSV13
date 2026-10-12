/obj/item/pipe_painter
	name = "pipe painter"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "labeler1"
	item_state = "flight"
	item_flags = NOBLUDGEON
	var/paint_color = "grey"

	materials = list(/datum/material/iron=5000, /datum/material/glass=2000)

/obj/item/pipe_painter/afterattack(atom/A, mob/user, proximity_flag)
	. = ..()
	//Make sure we only paint adjacent items
	if(!proximity_flag)
		return

	if(!istype(A, /obj/machinery/atmospherics/pipe))
		return

	var/obj/machinery/atmospherics/pipe/P = A
	if(P.paint(GLOB.pipe_paint_colors[paint_color]))
		playsound(src, 'sound/machines/click.ogg', 50, 1)
		user.visible_message("<span class='notice'>[user] maluje [P] na kolor: [paint_color].</span>","<span class='notice'>Malujesz [P] na kolor: [paint_color].</span>")

/obj/item/pipe_painter/attack_self(mob/user)
	paint_color = input("Jakiego koloru chcesz użyć?","Malarz rur") in GLOB.pipe_paint_colors

/obj/item/pipe_painter/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Ustawiony kolor: [paint_color].</span>"
