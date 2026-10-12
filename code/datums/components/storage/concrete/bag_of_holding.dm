/datum/component/storage/concrete/bluespace/bag_of_holding/handle_item_insertion(obj/item/W, prevent_warning = FALSE, mob/living/user)
	var/atom/A = parent
	if(A == W)		//don't put yourself into yourself.
		return
	var/list/obj/item/storage/backpack/holding/matching = typecache_filter_list(W.GetAllContents(), typecacheof(/obj/item/storage/backpack/holding))
	matching -= A
	if(istype(W, /obj/item/storage/backpack/holding) || matching.len)
		INVOKE_ASYNC(src, PROC_REF(recursive_insertion), W, user)
		return
	. = ..()

/datum/component/storage/concrete/bluespace/bag_of_holding/proc/recursive_insertion(obj/item/W, mob/living/user)
	var/atom/A = parent
	var/safety = alert(user, "Zrobienie tego będzie miało wyjątkowo poważne konsekwencje dla stacji i jej załogi. Upewnij się, że wiesz, co robisz.", "Włożyć [A.name]?", "Abort", "Proceed")
	if(safety != "Proceed" || QDELETED(A) || QDELETED(W) || QDELETED(user) || !user.canUseTopic(A, BE_CLOSE, iscarbon(user)) || !(W in user.contents)) // need to be holding the bag you're "inserting"
		return
	var/turf/loccheck = get_turf(A)
	if(is_reebe(loccheck.z))
		user.visible_message("<span class='warning'>Niewidzialna siła powala [user] na ziemię!</span>", "<span class='big_brass'>\"Chyba nie!\"</span>")
		user.Paralyze(60)
		return
	to_chat(user, "<span class='danger'>Interfejsy bluespace obu urządzeń katastrofalnie zawodzą!</span>")
	qdel(W)
	playsound(loccheck,'sound/effects/supermatter.ogg', 200, 1)

	message_admins("[ADMIN_LOOKUPFLW(user)] detonated a bag of holding at [ADMIN_VERBOSEJMP(loccheck)].")
	log_game("[key_name(user)] detonated a bag of holding at [loc_name(loccheck)].")

	user.gib(TRUE, TRUE, TRUE)
	new/obj/boh_tear(loccheck)
	qdel(A)

