/obj/item/teleportation_scroll
	name = "scroll of teleportation"
	desc = "A scroll for moving around."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "scroll"
	var/uses = 4
	w_class = WEIGHT_CLASS_SMALL
	item_state = "paper"
	throw_speed = 3
	throw_range = 7
	resistance_flags = FLAMMABLE

/obj/item/teleportation_scroll/apprentice
	name = "lesser scroll of teleportation"
	uses = 1



/obj/item/teleportation_scroll/attack_self(mob/user)
	user.set_machine(src)
	var/dat = "<B>Zwój teleportacji:</B><BR>"
	dat += "Liczba użyć: [src.uses]<BR>"
	dat += "<HR>"
	dat += "<B>Cztery użycia, wykorzystaj je mądrze:</B><BR>"
	dat += "<A href='byond://?src=[REF(src)];spell_teleport=1'>Teleport</A><BR>"
	dat += "Z wyrazami szacunku,<br>Federacja Czarodziejów<br><br>PS Nie zapomnij zabrać ekwipunku, będzie ci potrzebny do rzucania większości zaklęć.<HR>"
	user << browse(dat, "window=scroll")
	onclose(user, "scroll")
	return

/obj/item/teleportation_scroll/Topic(href, href_list)
	..()
	if (usr.stat || usr.restrained() || src.loc != usr)
		return
	if (!ishuman(usr))
		return 1
	var/mob/living/carbon/human/H = usr
	if(H.is_holding(src))
		H.set_machine(src)
		if (href_list["spell_teleport"])
			if(uses)
				teleportscroll(H)
	if(H)
		attack_self(H)
	return

/obj/item/teleportation_scroll/proc/teleportscroll(mob/user)

	var/A

	A = input(user, "Obszar docelowy", "BOOYEA", A) as null|anything in GLOB.teleportlocs
	if(!src || QDELETED(src) || !user || !user.is_holding(src) || user.incapacitated() || !A || !uses)
		return
	var/area/thearea = GLOB.teleportlocs[A]

	var/datum/effect_system/smoke_spread/smoke = new
	smoke.set_up(2, user.loc)
	smoke.attach(user)
	smoke.start()
	var/list/L = list()
	for(var/turf/T in get_area_turfs(thearea.type))
		if(!is_blocked_turf(T))
			L += T

	if(!L.len)
		to_chat(user, "Matryca zaklęcia z nieznanego powodu nie zdołała znaleźć odpowiedniego celu teleportacji. Przepraszamy.")
		return

	if(do_teleport(user, pick(L), channel = TELEPORT_CHANNEL_MAGIC, forced = TRUE))
		smoke.start()
		uses--
	else
		to_chat(user, "Coś w pobliżu celu zakłóciło matrycę zaklęcia.")
