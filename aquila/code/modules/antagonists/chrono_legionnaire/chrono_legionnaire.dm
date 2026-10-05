// AQUILA - Chrono Legionnaire: a time agent sent to erase a player who named their character after a historical tyrant.
// Uses the existing Timeline Eradication Agent gear (chronosuit + T.E.D.). Spawned by the event in
// aquila/code/modules/events/chrono_legionnaire.dm, only when somebody on the server has such a name.

/// Name fragments the legion hunts for, mapped to the historical figure they stand for.
/// Matched against the character name after aquila_chrono_normalize_name(), so write them in lowercase a-z only.
/// Admins can add more at runtime through View Variables on GLOB.
GLOBAL_LIST_INIT(aquila_chrono_historical_names, list(
	// Adolf Hitler
	"hitler" = "Adolf Hitler",
	"hittler" = "Adolf Hitler",
	"hitller" = "Adolf Hitler",
	"hiitler" = "Adolf Hitler",
	"hytler" = "Adolf Hitler",
	"hitlr" = "Adolf Hitler",
	"hidler" = "Adolf Hitler",
	"gitler" = "Adolf Hitler",
	"schicklgruber" = "Adolf Hitler",
	"schickelgruber" = "Adolf Hitler",
	"shicklgruber" = "Adolf Hitler",
	"fuhrer" = "Adolf Hitler",
	"fuehrer" = "Adolf Hitler",
	// Józef Stalin
	"stalin" = "Józef Stalin",
	"stalyn" = "Józef Stalin",
	"sztalin" = "Józef Stalin",
	"dzugaszwili" = "Józef Stalin",
	"dzhugashvili" = "Józef Stalin",
	"dzugashvili" = "Józef Stalin",
	"djugashvili" = "Józef Stalin",
	"jugashvili" = "Józef Stalin",
	"dzugasvili" = "Józef Stalin",
	"dschugaschwili" = "Józef Stalin",
))

/// Innocent words that happen to contain a hunted fragment, cut out of the name before matching
GLOBAL_LIST_INIT(aquila_chrono_name_exceptions, list(
	"crystalin",
	"kristalin",
	"krystalin",
))

/// Lowercases a name, folds Polish/German letters and leetspeak to plain a-z and drops everything else
/proc/aquila_chrono_normalize_name(name)
	var/static/list/replacements = list(
		"ą" = "a", "Ą" = "a", "ć" = "c", "Ć" = "c", "ę" = "e", "Ę" = "e", "ł" = "l", "Ł" = "l",
		"ń" = "n", "Ń" = "n", "ó" = "o", "Ó" = "o", "ś" = "s", "Ś" = "s", "ź" = "z", "Ź" = "z",
		"ż" = "z", "Ż" = "z", "ä" = "a", "Ä" = "a", "ö" = "o", "Ö" = "o", "ü" = "u", "Ü" = "u",
		"ß" = "ss", "0" = "o", "1" = "i", "3" = "e", "4" = "a", "5" = "s", "7" = "t",
		"$" = "s", "@" = "a", "!" = "i", "|" = "i",
	)
	var/static/regex/non_letters = regex(@"[^a-z]", "g")
	. = lowertext(name)
	for(var/from in replacements)
		. = replacetext(., from, replacements[from])
	. = non_letters.Replace(., "")

/// Returns the historical figure a name refers to, or null if it is an ordinary name
/proc/aquila_chrono_historical_figure(name)
	var/normalized = aquila_chrono_normalize_name(name)
	if(!normalized)
		return null
	for(var/exception in GLOB.aquila_chrono_name_exceptions)
		normalized = replacetext(normalized, exception, "")
	for(var/fragment in GLOB.aquila_chrono_historical_names)
		if(findtext(normalized, fragment))
			return GLOB.aquila_chrono_historical_names[fragment]
	return null

/// Living, connected players whose character is named after a historical tyrant
/proc/aquila_chrono_find_targets()
	. = list()
	for(var/mob/living/carbon/human/player in GLOB.player_list)
		if(!player.client || !player.mind || player.stat == DEAD)
			continue
		if(player.mind.has_antag_datum(/datum/antagonist/chrono_legionnaire))
			continue
		if(aquila_chrono_historical_figure(player.real_name))
			. += player

/datum/antagonist/chrono_legionnaire
	name = "Chrono Legionnaire"
	roundend_category = "Chrono Legionnaires"
	antagpanel_category = "Chrono Legionnaire"
	banning_key = ROLE_CHRONO_LEGIONNAIRE
	show_in_antagpanel = FALSE // needs a target named after a tyrant, spawned by the event only
	show_name_in_check_antagonists = TRUE
	show_to_ghosts = TRUE
	count_against_dynamic_roll_chance = FALSE
	/// Weakref to the mind the legionnaire was sent to erase
	var/datum/weakref/target_ref
	/// Who the target is named after, for the flavour text
	var/historical_figure
	/// Set once the target is gone and the recall is on its way
	var/recalling = FALSE

/datum/antagonist/chrono_legionnaire/on_gain()
	owner.special_role = ROLE_CHRONO_LEGIONNAIRE
	owner.assigned_role = ROLE_CHRONO_LEGIONNAIRE
	return ..()

/datum/antagonist/chrono_legionnaire/on_removal()
	if(owner.special_role == ROLE_CHRONO_LEGIONNAIRE)
		owner.special_role = null
	stop_tracking()
	return ..()

/datum/antagonist/chrono_legionnaire/Destroy()
	stop_tracking()
	target_ref = null
	return ..()

/datum/antagonist/chrono_legionnaire/greet()
	owner.current.playsound_local(get_turf(owner.current), 'sound/magic/timeparadox2.ogg', 50, FALSE, pressure_affected = FALSE)
	to_chat(owner, "<span class='userdanger'>Jesteś Legionistą Czasu!</span>")
	to_chat(owner, "<B>Legion Czasu strzeże linii czasu przed powrotem największych tyranów historii. Ktoś na tym statku nosi imię, które nie może się powtórzyć.</B>")
	to_chat(owner, "<B>Twój T.E.D. na plecach wymazuje cel z linii czasu: włącz go, trafiaj wiązką i trzymaj cel w zasięgu, aż zniknie. Chronoskafander pozwala ci przemieszczać się przez czasoprzestrzeń.</B>")
	to_chat(owner, "<B>Interesuje cię tylko twój cel. Po jego wyeliminowaniu zostaniesz wycofany do swojej epoki.</B>")

/// Gives the legionnaire their erase objective and starts watching the target
/datum/antagonist/chrono_legionnaire/proc/set_target(datum/mind/target_mind, figure)
	target_ref = WEAKREF(target_mind)
	historical_figure = figure

	var/datum/objective/assassinate/chrono_erase/erase = new
	erase.owner = owner
	erase.historical_figure = figure
	erase.set_target(target_mind)
	erase.update_explanation_text()
	objectives += erase
	log_objective(owner, erase.explanation_text)

	if(target_mind.current)
		RegisterSignal(target_mind.current, list(COMSIG_MOB_DEATH, COMSIG_PARENT_QDELETING), PROC_REF(on_target_gone))

	owner.announce_objectives()
	owner.current.client?.tgui_panel?.give_antagonist_popup("Legionista Czasu",
		"Wyeliminuj [target_mind.name], nim [figure] powróci do historii.")

/datum/antagonist/chrono_legionnaire/proc/stop_tracking()
	var/datum/mind/target_mind = target_ref?.resolve()
	if(target_mind?.current)
		UnregisterSignal(target_mind.current, list(COMSIG_MOB_DEATH, COMSIG_PARENT_QDELETING))

/datum/antagonist/chrono_legionnaire/proc/on_target_gone(mob/living/source)
	SIGNAL_HANDLER
	UnregisterSignal(source, list(COMSIG_MOB_DEATH, COMSIG_PARENT_QDELETING))
	if(recalling)
		return
	recalling = TRUE
	to_chat(owner, "<span class='notice'><b>Cel wyeliminowany. Linia czasu stabilizuje się, Legion wycofa cię za kilka sekund.</b></span>")
	addtimer(CALLBACK(src, PROC_REF(recall)), 10 SECONDS)

/// Pulls the legionnaire and their gear back out of this timeline
/datum/antagonist/chrono_legionnaire/proc/recall()
	var/mob/living/carbon/human/legionnaire = owner?.current
	if(!istype(legionnaire) || legionnaire.stat == DEAD)
		return
	var/turf/T = get_turf(legionnaire)
	legionnaire.visible_message("<span class='warning'>[legionnaire] rozpływa się w rozbłysku czasoprzestrzeni!</span>", \
		"<span class='notice'>Linia czasu cię wciąga. Misja zakończona.</span>")
	if(T)
		new /obj/effect/temp_visual/desynchronizer(T)
		playsound(T, 'sound/magic/timeparadox2.ogg', 50, TRUE)
	log_game("[key_name(legionnaire)] was recalled by the Chrono Legion after their target was eliminated.")
	legionnaire.ghostize(FALSE)
	for(var/obj/item/gear in legionnaire.get_equipped_items(TRUE) + legionnaire.held_items)
		qdel(gear)
	qdel(legionnaire)

/datum/antagonist/chrono_legionnaire/roundend_report_header()
	return "<span class='header'>Legion Czasu odwiedził statek!</span><br>"

/datum/objective/assassinate/chrono_erase
	name = "chrono erase"
	/// Who the target is named after
	var/historical_figure

/datum/objective/assassinate/chrono_erase/update_explanation_text()
	..()
	if(!target?.current)
		explanation_text = "Cel dowolny"
		return
	explanation_text = "Wyeliminuj [target.name], [!target_role_type ? target.assigned_role : target.special_role]. To imię nie może dać [historical_figure || "tyranowi"] drugiej szansy w historii. Nie krzywdź nikogo innego, chyba że musisz."

/datum/outfit/chrono_legionnaire
	name = "Chrono Legionnaire"
	uniform = /obj/item/clothing/under/color/white
	suit = /obj/item/clothing/suit/space/chronos
	back = /obj/item/chrono_eraser
	head = /obj/item/clothing/head/helmet/space/chronos
	mask = /obj/item/clothing/mask/breath
	suit_store = /obj/item/tank/internals/oxygen
	shoes = /obj/item/clothing/shoes/sneakers/white
	gloves = /obj/item/clothing/gloves/color/white
	ears = /obj/item/radio/headset

/// Builds a legionnaire for the given ghost key, hunting the given target. Returns the new body.
/proc/create_chrono_legionnaire(key, mob/living/carbon/human/target, turf/location)
	var/mob/living/carbon/human/legionnaire = new(location)
	randomize_human(legionnaire)
	legionnaire.fully_replace_character_name(null, "Legionista [pick(GLOB.greek_letters)]-[rand(100, 999)]")
	legionnaire.dna.update_dna_identity()
	legionnaire.equipOutfit(/datum/outfit/chrono_legionnaire)

	var/datum/mind/player_mind = new /datum/mind(key)
	player_mind.active = TRUE
	player_mind.transfer_to(legionnaire)

	var/figure = aquila_chrono_historical_figure(target.real_name)
	var/datum/antagonist/chrono_legionnaire/legion = player_mind.add_antag_datum(/datum/antagonist/chrono_legionnaire)
	legion.set_target(target.mind, figure)

	new /obj/effect/temp_visual/desynchronizer(location)
	playsound(location, 'sound/magic/timeparadox2.ogg', 50, TRUE)
	message_admins("[ADMIN_LOOKUPFLW(legionnaire)] has been made into a Chrono Legionnaire hunting [ADMIN_LOOKUPFLW(target)] ([figure]).")
	log_game("[key_name(legionnaire)] was spawned as a Chrono Legionnaire hunting [key_name(target)] ([figure]).")
	return legionnaire
