/*
transformative extracts:
	apply a permanent effect to a slime and all of its babies
*/
/obj/item/slimecross/transformative
	name = "transformative extract"
	desc = "It seems to stick to any slime it comes in contact with."
	icon_state = "transformative"
	effect = "transformative"
	var/effect_applied = SLIME_EFFECT_DEFAULT

/obj/item/slimecross/transformative/afterattack(atom/target, mob/user, proximity)
	if(!proximity || !isslime(target))
		return FALSE
	var/mob/living/simple_animal/slime/S = target
	if(S.stat)
		to_chat(user, "<span class='warning'>Szlam nie żyje!</span>")
	if(S.transformeffects & effect_applied)
		to_chat(user,"<span class='warning'>Na ten szlam nałożono już efekt transformacyjny [colour]!</span>")
		return FALSE
	to_chat(user,"<span class='notice'>Nakładasz [src] na [target].</span>")
	do_effect(S, user)
	S.transformeffects = effect_applied //S.transformeffects |= effect_applied
	qdel(src)

/obj/item/slimecross/transformative/proc/do_effect(mob/living/simple_animal/slime/S, mob/user)
	SHOULD_CALL_PARENT(TRUE)
	if(S.transformeffects & SLIME_EFFECT_LIGHT_PINK)
		S.remove_from_spawner_menu()
		S.master = null
	if(S.transformeffects & SLIME_EFFECT_METAL)
		S.maxHealth = round(S.maxHealth/1.3)
	if(S.transformeffects & SLIME_EFFECT_BLUESPACE)
		S.remove_verb(/mob/living/simple_animal/slime/proc/teleport)
	if(S.transformeffects & SLIME_EFFECT_PINK)
		var/datum/language_holder/LH = S.get_language_holder()
		LH.selected_language = /datum/language/slime

/obj/item/slimecross/transformative/grey
	colour = "grey"
	effect_applied = SLIME_EFFECT_GREY
	effect_desc = "Szlamy dzielą się na jednego dodatkowego szlama."

/obj/item/slimecross/transformative/orange
	colour = "orange"
	effect_applied = SLIME_EFFECT_ORANGE
	effect_desc = "Szlamy podpalają ludzi, gdy razi ich prądem."

/obj/item/slimecross/transformative/purple
	colour = "purple"
	effect_applied = SLIME_EFFECT_PURPLE
	effect_desc = "Szlamy powoli się regenerują."

/obj/item/slimecross/transformative/blue
	colour = "blue"
	effect_applied = SLIME_EFFECT_BLUE
	effect_desc = "Przy podziale szlam zawsze zachowuje szlama swojego pierwotnego koloru."

/obj/item/slimecross/transformative/metal
	colour = "metal"
	effect_applied = SLIME_EFFECT_METAL
	effect_desc = "Szlamy wytrzymają więcej obrażeń, zanim zginą."

/obj/item/slimecross/transformative/metal/do_effect(mob/living/simple_animal/slime/S)
	..()
	S.maxHealth = round(S.maxHealth*1.3)

/obj/item/slimecross/transformative/yellow
	colour = "yellow"
	effect_applied = SLIME_EFFECT_YELLOW
	effect_desc = "Szlamy szybciej zyskują ładunek elektryczny."

/obj/item/slimecross/transformative/darkpurple
	colour = "dark purple"
	effect_applied = SLIME_EFFECT_DARK_PURPLE
	effect_desc = "Szlam szybko przekształca plazmę z atmosfery w tlen, lecząc się przy tym."

/obj/item/slimecross/transformative/darkblue
	colour = "dark blue"
	effect_applied = SLIME_EFFECT_DARK_BLUE
	effect_desc = "Szlamy otrzymują mniejsze obrażenia od wody."

/obj/item/slimecross/transformative/silver
	colour = "silver"
	effect_applied = SLIME_EFFECT_SILVER
	effect_desc = "Szlamy nie tracą już z czasem składników odżywczych."

/obj/item/slimecross/transformative/bluespace
	colour = "bluespace"
	effect_applied = SLIME_EFFECT_BLUESPACE
	effect_desc = "Szlamy teleportują się do celów, gdy mają pełny ładunek elektryczny."

/obj/item/slimecross/transformative/bluespace/do_effect(mob/living/simple_animal/slime/S, mob/user)
	..()
	S.add_verb(/mob/living/simple_animal/slime/proc/teleport)

/obj/item/slimecross/transformative/sepia
	colour = "sepia"
	effect_applied = SLIME_EFFECT_SEPIA
	effect_desc = "Szlamy poruszają się szybciej."

/obj/item/slimecross/transformative/cerulean
	colour = "cerulean"
	effect_applied = SLIME_EFFECT_CERULEAN
	effect_desc = "Zamiast się dzielić, szlam tworzy kolejnego dorosłego z połową składników odżywczych."

/obj/item/slimecross/transformative/pyrite
	colour = "pyrite"
	effect_applied = SLIME_EFFECT_PYRITE
	effect_desc = "Szlam zawsze dzieli się na zupełnie losowe kolory, z wyjątkiem tęczowego. Nigdy nie da tęczowego szlama."

/obj/item/slimecross/transformative/red
	colour = "red"
	effect_applied = SLIME_EFFECT_RED
	effect_desc = "Szlamy zadają o 10% więcej obrażeń podczas żerowania i atakowania."

/obj/item/slimecross/transformative/green
	colour = "green"
	effect_applied = SLIME_EFFECT_GREEN
	effect_desc = "Szlamy jedzą zwłoki."

/obj/item/slimecross/transformative/pink
	colour = "pink"
	effect_applied = SLIME_EFFECT_PINK
	effect_desc = "Szlamy mówią we wspólnym języku zamiast w języku szlamów."

/obj/item/slimecross/transformative/pink/do_effect(mob/living/simple_animal/slime/S)
	..()
	S.grant_language(/datum/language/common, TRUE, TRUE)
	var/datum/language_holder/LH = S.get_language_holder()
	LH.selected_language = /datum/language/common

/obj/item/slimecross/transformative/gold
	colour = "gold"
	effect_applied = SLIME_EFFECT_GOLD
	effect_desc = "Ekstrakty z tych szlamów sprzedają się za podwójną cenę."

/obj/item/slimecross/transformative/oil
	colour = "oil"
	effect_applied = SLIME_EFFECT_OIL
	effect_desc = "Szlam oblewa paliwem spawalniczym wszystko, czym się żywi."

/obj/item/slimecross/transformative/black
	colour = "black"
	effect_applied = SLIME_EFFECT_BLACK
	effect_desc = "Szlam jest niemal przezroczysty."

/obj/item/slimecross/transformative/lightpink
	colour = "light pink"
	effect_applied = SLIME_EFFECT_LIGHT_PINK
	effect_desc = "Szlamy mogą zostać opętane przez siły nadprzyrodzone."

/obj/item/slimecross/transformative/lightpink/do_effect(mob/living/simple_animal/slime/S, mob/user)
	..()
	GLOB.poi_list |= S
	S.make_master(user)
	LAZYADD(GLOB.mob_spawners["[S.master.real_name]'s slime"], S)
	SSmobs.update_spawners()

/obj/item/slimecross/transformative/adamantine
	colour = "adamantine"
	effect_applied = SLIME_EFFECT_ADAMANTINE
	effect_desc = "Szlamy otrzymują mniejsze obrażenia od ataków fizycznych."

/obj/item/slimecross/transformative/rainbow
	colour = "rainbow"
	effect_applied = SLIME_EFFECT_RAINBOW
	effect_desc = "Szlam okresowo losowo zmienia kolor."
