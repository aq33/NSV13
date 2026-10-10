/datum/language/codespeak
	name = "Codespeak"
	desc = "Syndicate operatives can use a series of codewords to convey complex information, while sounding like random concepts and drinks to anyone listening in."
	key = "t"
	default_priority = 0
	flags = TONGUELESS_SPEECH | LANGUAGE_HIDE_ICON_IF_NOT_UNDERSTOOD
	icon_state = "codespeak"

/datum/language/codespeak/scramble(input)
	var/lookup = check_cache(input)
	if(lookup)
		return lookup

	. = ""
	var/list/words = list()
	while(length_char(.) < length_char(input))
		words += generate_code_phrase(return_list=TRUE)
		. = jointext(words, ", ")

	. = capitalize(.)

	var/input_ending = copytext_char(input, -1)

	var/static/list/endings
	if(!endings)
		endings = list("!", "?", ".")

	if(input_ending in endings)
		. += input_ending

	add_to_cache(input, .)

/obj/item/codespeak_manual
	name = "codespeak manual"
	desc = "The book's cover reads: \"Codespeak(tm) - Secure your communication with metaphors so elaborate, they seem randomly generated!\""
	icon = 'icons/obj/library.dmi'
	icon_state = "book2"
	var/charges = 1

/obj/item/codespeak_manual/attack_self(mob/living/user)
	if(!isliving(user))
		return

	if(user.has_language(/datum/language/codespeak))
		to_chat(user, "<span class='boldannounce'>Zaczynasz kartkować [src], ale już znasz Kodomowę.</span>")
		return

	to_chat(user, "<span class='boldannounce'>Zaczynasz kartkować [src] i nagle twój umysł wypełniają słowa kodowe i odzewy.</span>")
	user.grant_language(/datum/language/codespeak, TRUE, TRUE, LANGUAGE_MIND)

	use_charge(user)

/obj/item/codespeak_manual/attack(mob/living/M, mob/living/user)
	if(!istype(M) || !istype(user))
		return
	if(M == user)
		attack_self(user)
		return

	playsound(loc, "punch", 25, 1, -1)

	if(M.stat == DEAD)
		M.visible_message("<span class='danger'>[user] okłada bezwładne zwłoki [M] [src].</span>", "<span class='userdanger'>[user] okłada twoje bezwładne zwłoki [src].</span>", "<span class='italics'>Słyszysz plaskanie.</span>")
	else if(M.has_language(/datum/language/codespeak))
		M.visible_message("<span class='danger'>[user] wali [M] po głowie [src]!</span>", "<span class='userdanger'>[user] wali cię po głowie [src]!</span>", "<span class='italics'>Słyszysz plaskanie.</span>")
	else
		M.visible_message("<span class='notice'>[user] uczy [M], waląc go po głowie [src]!</span>", "<span class='boldnotice'>Gdy [user] uderza cię [src], przez twój umysł przepływają słowa kodowe i odzewy.</span>", "<span class='italics'>Słyszysz plaskanie.</span>")
		M.grant_language(/datum/language/codespeak, TRUE, TRUE, LANGUAGE_MIND)
		use_charge(user)

/obj/item/codespeak_manual/proc/use_charge(mob/user)
	charges--
	if(!charges)
		var/turf/T = get_turf(src)
		T.visible_message("<span class='warning'>Okładka i treść [src] zaczynają się przesuwać i zmieniać!</span>")

		qdel(src)
		var/obj/item/book/manual/random/book = new(T)
		user.put_in_active_hand(book)

/obj/item/codespeak_manual/unlimited
	name = "deluxe codespeak manual"
	charges = INFINITY
