#define BRASS_POWER_COST 10

/obj/item/clockwork/replica_fabricator
	name = "replica fabricator"
	icon = 'icons/obj/clockwork_objects.dmi'
	icon_state = "replica_fabricator"
	desc = "A strange, brass device with many twisting cogs and vents."
	clockwork_desc = "Urządzenie do szybkiego wytwarzania mosiądzu."

/obj/item/clockwork/replica_fabricator/examine(mob/user)
	. = ..()
	if(is_servant_of_ratvar(user))
		. += "Użyj na mosiądzu, żeby zamienić go w energię."
		. += "Użyj na innych materiałach, żeby zamienić je w mosiądz."
		. += "Użyj na pustej podłodze, żeby wytworzyć mosiądz za 10 W/arkusz"
		. += "Użyj na uszkodzonych mechanicznych strukturach, żeby je naprawić."

/obj/item/clockwork/replica_fabricator/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!proximity_flag || !is_servant_of_ratvar(user))
		return
	if(istype(target, /obj/item/stack/tile/brass/cyborg))	//nooooO!!!! you can't just suck up your cyborg brass!!! nooooo!!!!!!
		return
	if(istype(target, /obj/item/stack/tile/brass))
		var/obj/item/stack/tile/brass/B = target
		qdel(B)
		GLOB.clockcult_power += B.amount * BRASS_POWER_COST
		playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
		to_chat(user, "<span class='nzcrentr'>Zamieniasz [B.amount] mosiądzu w [B.amount * BRASS_POWER_COST] W energii.</span>")
	else if(istype(target, /obj/item/stack/sheet))
		var/obj/item/stack/S = target
		var/obj/item/stack/tile/brass/B = new(get_turf(S))
		B.amount = FLOOR(S.amount * 0.5, 1)
		playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
		to_chat(user, "<span class='nzcrentr'>Zamieniasz [S.amount] [S] w [S.amount] mosiądzu.</span>")
		qdel(target)
	else if(isopenturf(target))
		fabricate_sheets(target, user)
	else if(istype(target, /obj/structure/destructible/clockwork))
		var/obj/structure/destructible/clockwork/C = target
		if(!C.can_be_repaired)
			to_chat(user, "<span class='nzcrentr'>Nie możesz naprawić [C]!</span>")
			return
		if(GLOB.clockcult_power < 200)
			to_chat(user, "<span class='nzcrentr'>Potrzebujesz jeszcze [200 - GLOB.clockcult_power] W, żeby naprawić [C]...</span>")
			return
		if(C.max_integrity == C.obj_integrity)
			to_chat(user, "<span class='nzcrentr'>[C] jest już naprawiony!</span>")
			return
		to_chat(user, "<span class='nzcrentr'>Zaczynasz naprawiać [C]...</span>")
		if(do_after(user, 60, target=target))
			if(C.max_integrity == C.obj_integrity)
				to_chat(user, "<span class='nzcrentr'>[C] jest już naprawiony!</span>")
				return
			if(GLOB.clockcult_power < 200)
				to_chat(user, "<span class='nzcrentr'>Potrzebujesz jeszcze [200 - GLOB.clockcult_power] W, żeby naprawić [C]...</span>")
				return
			GLOB.clockcult_power -= 200
			to_chat(user, "<span class='nzcrentr'>Naprawiasz część uszkodzeń [C].</span>")
			C.obj_integrity = CLAMP(C.obj_integrity + 15, 0, C.max_integrity)
		else
			to_chat(user, "<span class='nzcrentr'>Nie udaje ci się naprawić uszkodzeń [C]...</span>")

/obj/item/clockwork/replica_fabricator/proc/fabricate_sheets(turf/target, mob/user)
	var/sheets = FLOOR(CLAMP(GLOB.clockcult_power / BRASS_POWER_COST, 0, 50), 1)
	if(sheets == 0)
		return
	GLOB.clockcult_power -= sheets * BRASS_POWER_COST
	new /obj/item/stack/tile/brass(target, sheets)
	playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
	to_chat(user, "<span class='brass'>Wytwarzasz [sheets] mosiądzu.</span>")
