//These objects are used in the cardinal sin-themed ruins (i.e. Gluttony, Pride...)

/obj/structure/cursed_slot_machine //Greed's slot machine: Used in the Greed ruin. Deals clone damage on each use, with a successful use giving a d20 of fate.
	name = "greed's slot machine"
	desc = "High stakes, high rewards."
	icon = 'icons/obj/economy.dmi'
	icon_state = "slots1"
	anchored = TRUE
	density = TRUE
	var/win_prob = 5

/obj/structure/cursed_slot_machine/interact(mob/living/carbon/human/user)
	if(!istype(user))
		return
	if(obj_flags & IN_USE)
		return
	if(isipc(user))
		user.visible_message("<span class='warning'> Gdy [user] próbuje pociągnąć dźwignię [src], maszyna zdaje się nieco wahać.</span>", "<span class='warning'>Czujesz się, jakbyś próbował postawić na szali coś, czego nawet nie masz...\ Nagle czujesz, że twój umysł jest... nieoptymalny?</span>")
		user.adjustOrganLoss(ORGAN_SLOT_BRAIN, 10)
	else
		user.adjustCloneLoss(20)
	obj_flags |= IN_USE

	if(user.stat)
		to_chat(user, "<span class='userdanger'>Nie... jeszcze tylko jedna próba...</span>")
		user.gib()
	else
		user.visible_message("<span class='warning'>[user] pociąga dźwignię [src] z błyskiem w oczach!</span>", "<span class='warning'>Pociągając dźwignię, czujesz, jak coś z ciebie uchodzi, ale wiesz, że będzie warto.</span>")
	icon_state = "slots2"
	playsound(src, 'sound/lavaland/cursed_slot_machine.ogg', 50, 0)
	addtimer(CALLBACK(src, PROC_REF(determine_victor), user), 50)

/obj/structure/cursed_slot_machine/proc/determine_victor(mob/living/user)
	icon_state = "slots1"
	obj_flags &= ~IN_USE
	if(prob(win_prob))
		playsound(src, 'sound/lavaland/cursed_slot_machine_jackpot.ogg', 50, 0)
		new/obj/structure/cursed_money(get_turf(src))
		if(user)
			to_chat(user, "<span class='boldwarning'>Trafiłeś główną wygraną. Wokół rozbrzmiewa śmiech, a w miejscu maszyny pojawia się twoja nagroda.</span>")
		qdel(src)
	else
		if(user)
			to_chat(user, "<span class='boldwarning'>Pieprzona maszyna! Musi być ustawiona. Ale... jedna próba więcej nie zaszkodzi, prawda?</span>")


/obj/structure/cursed_money
	name = "bag of money"
	desc = "RICH! YES! YOU KNEW IT WAS WORTH IT! YOU'RE RICH! RICH! RICH!"
	icon = 'icons/obj/storage.dmi'
	icon_state = "moneybag"
	anchored = FALSE
	density = TRUE

/obj/structure/cursed_money/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(collapse)), 600)

/obj/structure/cursed_money/proc/collapse()
	visible_message("<span class='warning'>[src] zapada się w sobie, płótno gnije, a zawartość znika.</span>")
	qdel(src)

/obj/structure/cursed_money/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	user.visible_message("<span class='warning'>[user] otwiera worek i wyjmuje z niego kość. Worek znika.</span>",
		"<span class='boldwarning'>Otwierasz worek...!</span>\n<span class='danger'>I widzisz worek pełen kości. Zdezorientowany bierzesz jedną... a worek znika.</span>")
	var/turf/T = get_turf(user)
	var/obj/item/dice/d20/fate/one_use/critical_fail = new(T)
	user.put_in_hands(critical_fail)
	qdel(src)

/obj/effect/gluttony //Gluttony's wall: Used in the Gluttony ruin. Only lets the overweight through.
	name = "gluttony's wall"
	desc = "Only those who truly indulge may pass."
	anchored = TRUE
	density = TRUE
	icon_state = "blob"
	icon = 'icons/mob/blob.dmi'
	color = rgb(145, 150, 0)

/obj/effect/gluttony/CanAllowThrough(atom/movable/mover, turf/target)//So bullets will fly over and stuff.
	. = ..()
	if(ishuman(mover))
		var/mob/living/carbon/human/H = mover
		if(H.nutrition >= NUTRITION_LEVEL_FAT)
			H.visible_message("<span class='warning'>[H] przepycha się przez [src]!</span>", "<span class='notice'>Widziałeś i jadłeś gorsze rzeczy.</span>")
			return TRUE
		else
			to_chat(H, "<span class='warning'>Brzydzi cię sam widok [src]. Tylko świnia zmusiłaby się, żeby przez to przejść.</span>")
	if(istype(mover, /mob/living/simple_animal/hostile/morph))
		return TRUE

/obj/structure/mirror/magic/pride //Pride's mirror: Used in the Pride ruin.
	name = "pride's mirror"
	desc = "Pride cometh before the..."
	icon_state = "magic_mirror"

/obj/structure/mirror/magic/pride/New()
	for(var/speciestype in subtypesof(/datum/species))
		var/datum/species/S = speciestype
		if(initial(S.changesource_flags) & MIRROR_PRIDE)
			choosable_races += initial(S.id)
	..()

/obj/structure/mirror/magic/pride/curse(mob/user)
	user.visible_message("<span class='danger'><B>Ziemia rozstępuje się pod [user], gdy jego dłoń odrywa się od lustra!</B></span>", \
	"<span class='notice'>Idealnie. O wiele lepiej! Teraz <i>nikt</i> nie będzie w stanie ci się opr-</span>")

	var/turf/T = get_turf(user)
	var/list/levels = SSmapping.levels_by_trait(ZTRAIT_DYNAMIC_LEVEL)
	var/turf/dest
	if (levels.len)
		dest = locate(T.x, T.y, pick(levels))

	T.ChangeTurf(/turf/open/chasm, flags = CHANGETURF_INHERIT_AIR)
	var/turf/open/chasm/C = T
	C.set_target(dest)
	C.drop(user)

//can't be bothered to do sloth right now, will make later

/obj/item/kitchen/knife/envy //Envy's knife: Found in the Envy ruin. Attackers take on the appearance of whoever they strike.
	name = "envy's knife"
	desc = "Their success will be yours."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "render"
	item_state = "knife"
	lefthand_file = 'icons/mob/inhands/equipment/kitchen_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/kitchen_righthand.dmi'
	force = 18
	throwforce = 10
	w_class = WEIGHT_CLASS_NORMAL
	hitsound = 'sound/weapons/bladeslice.ogg'

/obj/item/kitchen/knife/envy/afterattack(atom/movable/AM, mob/living/carbon/human/user, proximity)
	. = ..()
	if(!proximity)
		return
	if(!istype(user))
		return
	if(ishuman(AM))
		var/mob/living/carbon/human/H = AM
		if(user.real_name != H.dna.real_name)
			user.real_name = H.dna.real_name
			H.dna.transfer_identity(user, transfer_SE=1)
			user.updateappearance(mutcolor_update=1)
			user.domutcheck()
			user.visible_message("<span class='warning'>Wygląd [user] zmienia się w wygląd [H]!</span>", \
			"<span class='boldannounce'>Myśli, że jest <i>dużo</i> lepszy od ciebie. Już nie będzie.</span>")
