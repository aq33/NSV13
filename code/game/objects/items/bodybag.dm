
/obj/item/bodybag
	name = "body bag"
	desc = "A folded bag designed for the storage and transportation of cadavers."
	icon = 'icons/obj/bodybag.dmi'
	icon_state = "bodybag_folded"
	w_class = WEIGHT_CLASS_SMALL
	var/unfoldedbag_path = /obj/structure/closet/body_bag

/obj/item/bodybag/attack_self(mob/user)
	if(isopenturf(user.loc))
		deploy_bodybag(user, user.loc)
	else
		to_chat(user, "<span class='warning'>Nie możesz rozłożyć [src] wewnątrz czegoś!</span>")

/obj/item/bodybag/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if(proximity)
		if(isopenturf(target))
			deploy_bodybag(user, target)

/obj/item/bodybag/proc/deploy_bodybag(mob/user, atom/location)
	var/obj/structure/closet/body_bag/R = new unfoldedbag_path(location)
	R.open(user)
	R.add_fingerprint(user)
	R.foldedbag_instance = src
	moveToNullspace()

/obj/item/bodybag/suicide_act(mob/user)
	if(isopenturf(user.loc))
		user.visible_message("<span class='suicide'>[user] wczołguje się do [src]! Wygląda na to, że próbuje popełnić samobójstwo!</span>")
		var/obj/structure/closet/body_bag/R = new unfoldedbag_path(user.loc)
		R.add_fingerprint(user)
		qdel(src)
		user.forceMove(R)
		playsound(src, 'sound/items/zip.ogg', 15, 1, -3)
		return (OXYLOSS)
	..()

// Bluespace bodybag

/obj/item/bodybag/bluespace
	name = "bluespace body bag"
	desc = "A folded bluespace body bag designed for the storage and transportation of cadavers."
	icon = 'icons/obj/bodybag.dmi'
	icon_state = "bluebodybag_folded"
	unfoldedbag_path = /obj/structure/closet/body_bag/bluespace
	w_class = WEIGHT_CLASS_SMALL
	item_flags = NO_MAT_REDEMPTION

/obj/item/bodybag/bluespace/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_ATOM_CANREACH, PROC_REF(CanReachReact))

/obj/item/bodybag/bluespace/examine(mob/user)
	. = ..()
	if(contents.len)
		. += "<span class='notice'>Przez materiał widać kształty przedmiotów: [contents.len].</span>"

/obj/item/bodybag/bluespace/Destroy()
	for(var/atom/movable/A in contents)
		A.forceMove(get_turf(src))
		if(isliving(A))
			to_chat(A, "<span class='notice'>Nagle czujesz, jak przestrzeń wokół ciebie się rozdziera! Jesteś wolny!</span>")
	return ..()

/obj/item/bodybag/bluespace/proc/CanReachReact(atom/movable/source, list/next)
	SIGNAL_HANDLER

	return COMPONENT_BLOCK_REACH

/obj/item/bodybag/bluespace/deploy_bodybag(mob/user, atom/location)
	var/obj/structure/closet/body_bag/R = new unfoldedbag_path(location)
	for(var/atom/movable/A in contents)
		A.forceMove(R)
		if(isliving(A))
			to_chat(A, "<span class='notice'>Nagle czujesz wokół siebie powietrze! Jesteś wolny!</span>")
	R.open(user)
	R.add_fingerprint(user)
	R.foldedbag_instance = src
	moveToNullspace()

/obj/item/bodybag/bluespace/container_resist(mob/living/user)
	if(user.incapacitated())
		to_chat(user, "<span class='warning'>Nie możesz się wydostać, będąc tak skrępowanym!</span>")
		return
	user.changeNext_move(CLICK_CD_BREAKOUT)
	user.last_special = world.time + CLICK_CD_BREAKOUT
	to_chat(user, "<span class='notice'>Drapiesz materiał [src], próbując go rozedrzeć...</span>")
	to_chat(loc, "<span class='warning'>Ktoś próbuje wydostać się z [src]!</span>")
	if(!do_after(user, 200, target = src))
		to_chat(loc, "<span class='warning'>Nacisk słabnie. Wygląda na to, że przestał się opierać...</span>")
		return
	loc.visible_message("<span class='warning'>[user] nagle pojawia się przed [loc]!</span>", "<span class='userdanger'>[user] wydostaje się z [src]!</span>")
	qdel(src)
