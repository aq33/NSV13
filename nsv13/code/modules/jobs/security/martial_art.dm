#define MARTIALART_JUJITSU "ju jitsu"
#define TAKEDOWN_COMBO "DG"
#define JUDO_THROW "HHG"
#define ARMLOCKING "DHGG"

/obj/item/book/granter/martial/jujitsu
	martial = /datum/martial_art/jujitsu
	name = "surviving edged weapons"
	oneuse = TRUE
	martialname = "Ju jitsu"
	icon = 'nsv13/icons/obj/library.dmi'
	icon_state = "edgedweapons"
	desc = "An instructional manual produced in the 2180s which instructs police officers in how to survive attacks by edged weapons and more. (Comes with a FREE Martian war commemorative knife!)"
	greet = "<span class='sciradio'> Nagle czujesz się o wiele mniej bezbronny wobec ataków nożem... Potrafisz teraz wykonywać chwyty obezwładniające podejrzanych. Więcej o swojej nowej sztuce dowiesz się z czasownika Recall police training w zakładce ju-jitsu.</span>"
	remarks = list("Podejrzany z nożem może pokonać 7 kroków i zadać śmiertelny cios w mniej niż półtorej sekundy...", "W razie satanistycznych rytuałów zaaplikuj sprawcy pełny magazynek...", "Podczas przeszukania zdejmij mu czapkę i obejrzyj włosy, nie dotykając ich...", "Niech partner przeszukuje cel, podczas gdy ty go obezwładniasz...", "O co chodzi z tą kulturą noża?...", "Aby zareagować, oddać co najmniej 2 strzały i mieć czas zejść z linii ataku, potrzebny jest minimalny dystans reakcji 21 stóp...")

/obj/item/book/granter/martial/jujitsu/onlearned(mob/living/carbon/user)
	..()
	if(oneuse)
		desc = "The pages are too thicky encrusted with coffee stains and donut residue to be legibile anymore..."

/datum/martial_art/jujitsu
	name = "Ju jitsu"
	id = MARTIALART_JUJITSU
	deflection_chance = 0
	no_guns = FALSE
	allow_temp_override = FALSE
	help_verb = /mob/living/carbon/human/proc/jujitsu_help
	smashes_tables = FALSE
	reroute_deflection = FALSE
	var/cooldown = 5 SECONDS //While sec should be proficient at hand to hand, they shouldn't be able to simultaneously ju jitsu 10 different targets...
	var/last_move = 0

/mob/living/carbon/human/proc/jujitsu_help()
	set name = "Recall Police Training"
	set desc = "Remember your police academy martial arts training."
	set category = "Jujitsu"
	to_chat(usr, "<span class='notice'>Combos:</span>")
	to_chat(usr, "<span class='warning'><b>Rozbrojenie, chwyt</b> powala cel, jeśli wcześniej został spowolniony / osłabiony</span>")
	to_chat(usr, "<span class='warning'><b>Krzywda, krzywda, chwyt</b> wykonuje rzut judo na cel, po którym lądujesz na nim w pozycji przygważdżającej. Pod warunkiem że w ostatnim kroku trzymasz go w chwycie...</span>")
	to_chat(usr, "<span class='warning'><b>Rozbrojenie, krzywda, chwyt, chwyt</b> zakłada celowi dźwignię na rękę, rzucając was oboje na ziemię. Z tej pozycji masz jednak większą swobodę ruchu niż sprawca.</span>")

	to_chat(usr, "<b><i>Ponadto masz krótką chwilę na brutalne chwycenie sprawcy podczas dźwigni.</i></b>")

/datum/martial_art/jujitsu/proc/check_streak(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(findtext(streak,TAKEDOWN_COMBO))
		streak = ""
		takedown(A,D)
		return TRUE
	if(findtext(streak, JUDO_THROW))
		streak = ""
		judo_throw(A,D)
		return TRUE
	if(findtext(streak,ARMLOCKING))
		streak = ""
		armlocking(A, D)
		return TRUE
	return FALSE

/datum/martial_art/jujitsu/proc/takedown(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(world.time < last_move+cooldown)
		to_chat(A, "<span class='sciradio'>Jesteś zbyt zmęczony, by teraz wykonać ten ruch...</span>")
		return FALSE
	if(D.total_multiplicative_slowdown() < 2) //They have to be slowed by something
		A.visible_message("<span class='warning'>[A] próbuje podciąć [D], ale ten robi unik!</span>","<span class='warning'>[D] unika twojego ataku! Najpierw go spowolnij.</span>")
		return FALSE
	A.do_attack_animation(D, ATTACK_EFFECT_KICK)
	D.visible_message("<span class='userdanger'>[A] podcina [D] i przygważdża go do ziemi!</span>", "<span class='userdanger'>[A] przygważdża cię do ziemi!</span>")
	playsound(get_turf(D), 'nsv13/sound/effects/judo_throw.ogg', 100, TRUE)
	D.Paralyze(2 SECONDS)
	D.Knockdown(7 SECONDS)
	A.shake_animation(10)
	D.shake_animation(20)
	D.adjustOxyLoss(10) // you smashed him into the ground
	A.forceMove(get_turf(D))
	if(A.mobility_flags & MOBILITY_STAND) //Fixes permanent slowdown
		A.start_pulling(D, supress_message = FALSE)
		A.setGrabState(GRAB_AGGRESSIVE)
	last_move = world.time

/datum/martial_art/jujitsu/proc/judo_throw(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(world.time < last_move+cooldown)
		to_chat(A, "<span class='sciradio'>Jesteś zbyt zmęczony, by teraz wykonać ten ruch...</span>")
		return FALSE
	if(!A.pulling || A.pulling != D) //You have to have an active grab on them for this to work!
		A.shake_animation(10)
		var/newdir = turn(A.dir, 180)
		var/turf/target = get_turf(get_step(A, newdir))
		if(is_blocked_turf(target)) //Prevents translocation (sorry coreflare :( )
			target = get_turf(A)
		D.forceMove(target)
		A.setDir(newdir)
		D.dropItemToGround(D.get_active_held_item()) // yeet
		if(A.mobility_flags & MOBILITY_STAND) //Fixes permanent slowdown
			A.start_pulling(D, supress_message = FALSE)
			A.setGrabState(GRAB_AGGRESSIVE)
		D.adjustOxyLoss(40) // YOU THREW HIM, THREW HIM!!
		D.Paralyze(7 SECONDS) //Equivalent to a clown PDA
		D.visible_message("<span class='userdanger'>[A] przerzuca [D] przez ramię i go przygważdża!</span>", "<span class='userdanger'>[A] przerzuca cię przez ramię i przygważdża do ziemi!</span>")
		playsound(get_turf(D), 'nsv13/sound/effects/judo_throw.ogg', 100, TRUE)
		last_move = world.time

// Armlock state removal after 5s
/datum/martial_art/jujitsu/proc/drop_armlocking()
	armlockstate = FALSE

// Armlock
/datum/martial_art/jujitsu/proc/armlocking(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return FALSE
	if(world.time < last_move+cooldown)
		to_chat(A, "<span class='sciradio'>Jesteś zbyt zmęczony, by teraz wykonać ten ruch...</span>")
		return FALSE
	if(!D.stat)
		D.visible_message("<span class='warning'>[A] zakłada [D] dźwignię na rękę!</span>", \
							"<span class='userdanger'>[A] zakłada ci dźwignię na rękę!</span>")
		A.Knockdown(20) // knockdown officer with the perp
		A.adjustStaminaLoss(15)
		D.adjustStaminaLoss(30)
		D.Paralyze(70)
		D.shake_animation(50)
		A.start_pulling(D, supress_message = FALSE)
		armlockstate = TRUE
		addtimer(CALLBACK(src, PROC_REF(drop_armlocking)), 50, TIMER_UNIQUE) // you get 3 seconds after standing up to grab the perp
		A.do_attack_animation(D, ATTACK_EFFECT_DISARM)
		playsound(get_turf(D), 'nsv13/sound/effects/judo_throw.ogg', 100, TRUE)
		last_move = world.time
	return TRUE

/datum/martial_art/jujitsu/grab_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return FALSE
	if(A==D)
		return FALSE //prevents grabbing yourself
	if(A.a_intent == INTENT_GRAB && A.mobility_flags & MOBILITY_STAND) //Fixes permanent slowdown and missfire
		if(armlockstate == TRUE) // neck grabs if armlocked
			A.setGrabState(GRAB_NECK)
			D.visible_message("<span class='warning'>[A] z pozycji dźwigni chwyta [D] za szyję!</span>", \
							"<span class='userdanger'>[A] z pozycji dźwigni chwyta cię za szyję!</span>")
			armlockstate = FALSE
		add_to_streak("G",D)
		if(check_streak(A,D)) //doing combos is prioritized over upgrading grabs
			return TRUE
	return FALSE

/datum/martial_art/jujitsu/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	var/obj/item/bodypart/affecting = D.get_bodypart(ran_zone(A.zone_selected))
	var/def_check = D.getarmor(BODY_ZONE_CHEST, "melee")
	var/bonus_damage = 0
	if((armlockstate == TRUE)) // disable chosen arm temporarily when armlocked
		if(A.zone_selected == BODY_ZONE_L_ARM)
			D.apply_damage(100, STAMINA, BODY_ZONE_L_ARM, def_check)
			D.visible_message("<span class ='danger'>[A] łamie [D] rękę!</span>", "<span class ='danger'>[A] łamie ci rękę, wywołując przeszywający ból!</span>")
			armlockstate = FALSE
		if(A.zone_selected == BODY_ZONE_R_ARM)
			D.apply_damage(100, STAMINA, BODY_ZONE_R_ARM, def_check)
			D.visible_message("<span class ='danger'>[A] łamie [D] rękę!</span>", "<span class ='danger'>[A] łamie ci rękę, wywołując przeszywający ból!</span>")
			armlockstate = FALSE
		return FALSE
	if((A.grab_state >= GRAB_AGGRESSIVE))
		bonus_damage += 5
	D.apply_damage(rand(2,3) + bonus_damage, A.dna.species.attack_type, affecting, def_check) // bonus damage when grabbing at least aggressively if required to kill
	if((D.mobility_flags & MOBILITY_STAND))
		A.do_attack_animation(D, ATTACK_EFFECT_PUNCH) // makes punch be default if he's standing
	if(!can_use(A))
		return FALSE
	add_to_streak("H",D)
	if(check_streak(A,D))
		return TRUE
	return FALSE

/datum/martial_art/jujitsu/disarm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	var/bonus_stam = 0
	if((A.grab_state >= GRAB_AGGRESSIVE)) // If you shove during agressive grab it deals bonus stam
		bonus_stam = 20
		if(!(D.mobility_flags & MOBILITY_STAND)) // If you shove while perp is on ground and aggressive grabbing, it deals even more stam
			bonus_stam += 10
	D.adjustStaminaLoss(10 + bonus_stam) // deals minor stam damage with scaling dependant on grab and perp standing
	A.do_attack_animation(D, ATTACK_EFFECT_DISARM)
	if(A.pulling == D && A.grab_state >= GRAB_NECK) // LV3 hold minimum
		D.visible_message("<span class='danger'>[A] zakłada [D] duszenie!</span>", \
							"<span class='userdanger'>[A] zakłada ci duszenie!</span>")
		playsound(get_turf(D), 'nsv13/sound/weapons/chokehold.ogg', 50, 1, 1)
		D.SetSleeping(200)
		return FALSE
	if(!can_use(A))
		return FALSE
	add_to_streak("D",D)
	if(check_streak(A,D))
		return TRUE
	return FALSE
