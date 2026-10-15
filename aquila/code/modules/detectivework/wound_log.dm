// AQUILA - dziennik ran na kończynach (pomysł z Baya/Aurory): czym, ile i kiedy zraniono. Czyta go autopsja.

/// Ile wpisów pamięta jedna kończyna (najstarsze wypadają)
#define WOUND_LOG_MAX 15
/// Mniejsze obrażenia nie są zapisywane
#define WOUND_LOG_MIN_DAMAGE 1

/obj/item/bodypart
	/// Wpisy dziennika ran, gotowe linijki tekstu
	var/list/aq_wound_log

/obj/item/bodypart/proc/aq_add_wound_entry(text)
	LAZYADD(aq_wound_log, "[station_time_timestamp()] - [text]")
	if(length(aq_wound_log) > WOUND_LOG_MAX)
		aq_wound_log.Cut(1, 2)

/// Obrażenia każdej kończyny przed trafieniem: bodypart => list(brute, burn)
/mob/living/carbon/human/proc/aq_wound_snapshot()
	. = list()
	for(var/obj/item/bodypart/BP as anything in bodyparts)
		.[BP] = list(BP.brute_dam, BP.burn_dam)

/// Porównuje obrażenia z migawką i zapisuje różnicę na trafionych kończynach.
/// brute_kind / burn_kind - opis rany dla danego rodzaju obrażeń, source - czym zadano
/mob/living/carbon/human/proc/aq_wound_record(list/before, source, brute_kind = "uraz tępy", burn_kind = "oparzenie")
	if(!length(before))
		return
	for(var/obj/item/bodypart/BP as anything in bodyparts)
		var/list/old = before[BP]
		if(!old)
			continue
		var/brute = round(BP.brute_dam - old[1], 1)
		var/burn = round(BP.burn_dam - old[2], 1)
		if(brute >= WOUND_LOG_MIN_DAMAGE)
			BP.aq_add_wound_entry("[brute_kind] ([source]), [brute] obr.")
		if(burn >= WOUND_LOG_MIN_DAMAGE)
			BP.aq_add_wound_entry("[burn_kind] ([source]), [burn] obr.")

// Cios przedmiotem

/mob/living/carbon/human/attacked_by(obj/item/I, mob/living/user)
	var/list/before = aq_wound_snapshot()
	. = ..()
	aq_wound_record(before, I.name, I.is_sharp() ? "rana cięta/kłuta" : "uraz tępy")

// Pocisk

/mob/living/carbon/human/bullet_act(obj/item/projectile/P, def_zone, piercing_hit = FALSE)
	var/list/before = aq_wound_snapshot()
	. = ..()
	var/source = P.name
	var/brute_kind = "rana od pocisku"
	if(istype(P, /obj/item/projectile/bullet))
		brute_kind = "postrzał"
		if(P.ballistic_caliber)
			source = "kaliber [P.ballistic_caliber]"
			if(P.ballistic_id)
				source += ", sygnatura [P.ballistic_id]"
	aq_wound_record(before, source, brute_kind, "oparzenie od pocisku")

// Rzucony przedmiot

/mob/living/carbon/human/hitby(atom/movable/AM, skipcatch = FALSE, hitpush = TRUE, blocked = FALSE, datum/thrownthing/throwingdatum)
	var/list/before = aq_wound_snapshot()
	. = ..()
	var/sharp = FALSE
	if(isitem(AM))
		var/obj/item/I = AM
		sharp = I.is_sharp()
	aq_wound_record(before, "rzucony [AM.name]", sharp ? "rana cięta/kłuta" : "uraz tępy")

// Walka wręcz

/datum/species/harm(mob/living/carbon/human/user, mob/living/carbon/human/target, datum/martial_art/attacker_style)
	var/list/before = istype(target) ? target.aq_wound_snapshot() : null
	. = ..()
	if(before)
		target.aq_wound_record(before, "walka wręcz", "uraz tępy", "oparzenie")

/// Linijki do raportu z autopsji dla jednej kończyny
/obj/item/bodypart/proc/aq_autopsy_lines()
	. = list()
	for(var/entry in aq_wound_log)
		. += "Rana: [entry]"
	for(var/obj/item/bullet_fragment/fragment in src)
		. += "Pocisk w ciele: [fragment.caliber ? "kaliber [fragment.caliber]" : "nieznany kaliber"][fragment.ballistic_id ? ", sygnatura [fragment.ballistic_id]" : ""]"

#undef WOUND_LOG_MAX
#undef WOUND_LOG_MIN_DAMAGE
