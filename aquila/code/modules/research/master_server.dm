// AQUILA - Master R&D server and its source code HDD, port of yogstation13/Yogstation#20268 (tgstation/tgstation#61685).
// Our maps are not edited: the first R&D server loaded on the ship becomes the master one.

/// Default master server machine state. Use a screwdriver to get to the next state.
#define HDD_PANEL_CLOSED 0
/// Front master server HDD panel has been removed. Use a crowbar to get to the next state.
#define HDD_PANEL_OPEN 1
/// Master server HDD has been pried loose and is held in by only cables. Use wirecutters to finish stealing the objective.
#define HDD_PRIED 2
/// Master server HDD has been cut loose.
#define HDD_CUT_LOOSE 3
/// The ninja has blown the HDD up.
#define HDD_OVERLOADED 4

/datum/controller/subsystem/research
	/// All master servers. If none of these have a source code HDD, research point generation is lowered.
	var/list/obj/machinery/rnd/server/master/master_servers = list()
	/// Set once a master server got placed, so rebuilt servers never turn into a new one.
	var/master_server_placed = FALSE
	/// The multiplier to research points when no source code HDD is present.
	var/no_source_code_income_modifier = 0.5

/// Research income multiplier: halved once every master server lost its HDD.
/datum/controller/subsystem/research/proc/source_code_multiplier()
	if(!master_server_placed)
		return 1
	for(var/obj/machinery/rnd/server/master/master_server as anything in master_servers)
		if(master_server.source_code_hdd)
			return 1
	return no_source_code_income_modifier

/// Called from a mapped R&D server. The first one on the ship gets replaced with the master server.
/obj/machinery/rnd/server/proc/try_become_master_server()
	if(SSresearch.master_server_placed || !is_station_level(z))
		return FALSE
	SSresearch.master_server_placed = TRUE
	var/obj/machinery/rnd/server/master/master = new(loc)
	master.setDir(dir)
	return TRUE

/// Master R&D server. As long as it still holds the HDD for the theft objective, research points generate at normal speed.
/// Destroy it or let an antag steal the HDD and research runs at half speed for the rest of the round.
/obj/machinery/rnd/server/master
	var/obj/item/computer_hardware/hard_drive/cluster/hdd_theft/source_code_hdd
	var/deconstruction_state = HDD_PANEL_CLOSED
	var/front_panel_screws = 4
	var/hdd_wires = 6

/obj/machinery/rnd/server/master/Initialize(mapload)
	. = ..()
	name = "główny [name]"
	source_code_hdd = new(src)
	SSresearch.master_servers += src
	SSresearch.master_server_placed = TRUE
	add_overlay(mutable_appearance('aquila/icons/obj/machines/research_master.dmi', "RD-server-objective-stripes"))

/obj/machinery/rnd/server/master/Destroy()
	if(source_code_hdd)
		QDEL_NULL(source_code_hdd)
	SSresearch.master_servers -= src
	return ..()

/obj/machinery/rnd/server/master/examine(mob/user)
	. = ..()
	switch(deconstruction_state)
		if(HDD_PANEL_CLOSED)
			. += "Przedni panel jest zamknięty. Widać w nim wgłębienia, w których mogą być <b>śruby</b>."
		if(HDD_PANEL_OPEN)
			. += "Przedni panel zwisa otwarty. Dysk siedzi w zabezpieczonej obudowie, trzeba go <b>podważyć</b>."
		if(HDD_PRIED)
			. += "Przedni panel zwisa otwarty. Dysk wyrwano z obudowy, trzyma się już tylko na <b>kablach</b>."
		if(HDD_CUT_LOOSE)
			. += "Przedni panel zwisa otwarty. W środku zostały tylko przecięte kable i pogięty metal."
		if(HDD_OVERLOADED)
			. += "Przedni panel zwisa otwarty. Dysk w środku jest zniszczony, a kable spalone."

/// Only antags know how to take this thing apart. Everyone else can't even deconstruct it.
/obj/machinery/rnd/server/master/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/computer_hardware/hard_drive/cluster/hdd_theft))
		balloon_alert(user, deconstruction_state == HDD_PANEL_CLOSED ? "nie ma gdzie go włożyć!" : "obudowa dysku jest zniszczona!")
		return TRUE
	if(!(I.tool_behaviour in list(TOOL_SCREWDRIVER, TOOL_CROWBAR, TOOL_WIRECUTTER)))
		return ..()
	if(!is_special_character(user))
		balloon_alert(user, "nie widzisz żadnej klapy serwisowej!")
		return TRUE
	switch(I.tool_behaviour)
		if(TOOL_SCREWDRIVER)
			unscrew_panel(user, I)
		if(TOOL_CROWBAR)
			pry_hdd(user, I)
		if(TOOL_WIRECUTTER)
			cut_hdd_wires(user, I)
	return TRUE

/obj/machinery/rnd/server/master/proc/unscrew_panel(mob/living/user, obj/item/tool)
	if(deconstruction_state != HDD_PANEL_CLOSED)
		return
	to_chat(user, "<span class='notice'>Widzisz [front_panel_screws] śrub. Zaczynasz je wykręcać...</span>")
	while(tool.use_tool(src, user, 7.5 SECONDS, volume = 100))
		front_panel_screws--
		if(front_panel_screws <= 0)
			deconstruction_state = HDD_PANEL_OPEN
			to_chat(user, "<span class='notice'>Wykręcasz ostatnią śrubę z przedniego panelu [src].</span>")
			add_overlay(mutable_appearance('aquila/icons/obj/machines/research_master.dmi', "RD-server-hdd-panel-open"))
			return
		to_chat(user, "<span class='notice'>Śruba pęka przy wykręcaniu. Zostało jeszcze [front_panel_screws]...</span>")

/obj/machinery/rnd/server/master/proc/pry_hdd(mob/living/user, obj/item/tool)
	if(deconstruction_state != HDD_PANEL_OPEN)
		return
	to_chat(user, "<span class='notice'>Za przednim panelem widzisz [source_code_hdd] w zabezpieczonej obudowie. Zaczynasz go podważać...</span>")
	if(tool.use_tool(src, user, 15 SECONDS, volume = 100))
		to_chat(user, "<span class='notice'>Rozbijasz obudowę i wyrywasz [source_code_hdd].</span>")
		deconstruction_state = HDD_PRIED

/obj/machinery/rnd/server/master/proc/cut_hdd_wires(mob/living/user, obj/item/tool)
	if(deconstruction_state != HDD_PRIED)
		return
	to_chat(user, "<span class='notice'>Do [source_code_hdd] podłączonych jest [hdd_wires] kabli. Zaczynasz je przecinać...</span>")
	while(tool.use_tool(src, user, 7.5 SECONDS, volume = 100))
		hdd_wires--
		if(hdd_wires <= 0)
			deconstruction_state = HDD_CUT_LOOSE
			to_chat(user, "<span class='notice'>Przecinasz ostatni kabel i wyjmujesz [source_code_hdd].</span>")
			message_admins("[ADMIN_LOOKUPFLW(user)] removed the source code HDD from [ADMIN_VERBOSEJMP(src)].")
			log_game("[key_name(user)] removed the source code HDD from [src].")
			user.put_in_hands(source_code_hdd)
			source_code_hdd = null
			return
		to_chat(user, "<span class='notice'>Ostrożnie przecinasz kabel. Zostało jeszcze [hdd_wires]...</span>")

/obj/machinery/rnd/server/master/on_deconstruction()
	if(source_code_hdd)
		var/mob/user = usr
		if(istype(user))
			message_admins("[ADMIN_LOOKUPFLW(user)] deconstructed [ADMIN_JMP(src)], destroying [source_code_hdd] inside.")
			log_game("[key_name(user)] deconstructed [src], destroying [source_code_hdd] inside.")
		else
			message_admins("[ADMIN_JMP(src)] has been deconstructed by an unknown user, destroying [source_code_hdd] inside.")
			log_game("[src] has been deconstructed by an unknown user, destroying [source_code_hdd] inside.")
	return ..()

/// Destroys the source_code_hdd if present and sets the machine state to overloaded.
/obj/machinery/rnd/server/master/proc/overload_source_code_hdd()
	if(source_code_hdd)
		QDEL_NULL(source_code_hdd)
	if(deconstruction_state == HDD_PANEL_CLOSED)
		add_overlay(mutable_appearance('aquila/icons/obj/machines/research_master.dmi', "RD-server-hdd-panel-open"))
	front_panel_screws = 0
	hdd_wires = 0
	deconstruction_state = HDD_OVERLOADED

/// Ninja: overloads the source code HDD of the master server, or wipes the research points on any other server.
/obj/machinery/rnd/server/master/ninjadrain_act(obj/item/clothing/suit/space/space_ninja/S, mob/living/carbon/human/H, obj/item/clothing/gloves/space_ninja/G)
	if(!S || !H || !G)
		return INVALID_DRAIN
	if(!source_code_hdd)
		return ..()
	. = DRAIN_RD_HACK_FAILED
	to_chat(H, "<span class='notice'>Hakowanie [src]...</span>")
	AI_notify_hack()
	to_chat(H, "<span class='notice'>Wykryto zaszyfrowany kod źródłowy. Przeciążanie nośnika...</span>")
	if(do_after(H, 30 SECONDS, target = src))
		overload_source_code_hdd()
		to_chat(H, "<span class='notice'>Sabotaż zakończony. Nośnik przeciążony.</span>")
		complete_ninja_research_sabotage(H)

/proc/complete_ninja_research_sabotage(mob/living/carbon/human/H)
	var/datum/antagonist/ninja/ninja_antag = H.mind?.has_antag_datum(/datum/antagonist/ninja)
	if(!ninja_antag)
		return
	var/datum/objective/research_secrets/objective = locate() in ninja_antag.objectives
	if(objective)
		objective.completed = TRUE

/// Ninja objective replacing the old research download.
/datum/objective/research_secrets
	name = "sabotaż badań"
	explanation_text = "Użyj rękawic na serwerze B+R, by zniszczyć postępy badań. Pamiętaj, że SI zostanie zaalarmowana, gdy tylko zaczniesz!"

/obj/item/computer_hardware/hard_drive/cluster/hdd_theft
	name = "dysk twardy serwera B+R"
	desc = "Z jakiegoś powodu ludzie bardzo chcą go ukraść. Kod źródłowy na tym dysku służy pewnie do czegoś okropnego!"
	icon = 'aquila/icons/obj/machines/research_master.dmi'
	icon_state = "hdd_theft"
	max_capacity = 512

/obj/item/paper/guides/antag/hdd_extraction
	name = "Kradzież kodu źródłowego dla opornych"
	default_raw_text = "<h1>Kradzież kodu źródłowego dla opornych - jak sparaliżować dział B+R Nanotrasenu</h1><br>\
	Według plotek Nanotrasen używa serwerów B+R do teoretycznych symulacji alternatywnych wszechświatów!<br>\
	Zebrali jedyny w swoim rodzaju skan takiego wszechświata w projekcie o kryptonimie <b>Projekt Aquila</b>.<br>\
	Nie możemy do tego dopuścić. Oto wszystko, co wiemy o kradzieży kodu źródłowego:<br>\
	<ul>\
	<li>Znajdź fizyczne serwery B+R. Według wywiadu stoją w specjalnie chłodzonych pomieszczeniach działu naukowego.</li>\
	<li>Nanotrasen nie słynie z subtelności. Główny serwer rozpoznasz po charakterystycznych oznaczeniach.</li>\
	<li>Narzędzia zdobądź na miejscu. Wystarczą śrubokręt, łom i przecinak.</li>\
	<li>Śruby przedniego panelu są schowane we wgłębieniach pod naklejkami.</li>\
	<li>Dysk będzie w zabezpieczonej obudowie. Trzeba go podważyć łomem.</li>\
	<li>Na koniec ostrożnie przetnij wszystkie kable dysku.</li>\
	</ul>\
	Wyjęcie dysku na pewno sparaliżuje ich badania, niezależnie od tego, co na nim jest.<br>\
	Dysk jest pewnie wlutowany na stałe, więc nie da się go włożyć z powrotem. Załoga będzie wściekła, jeśli się zorientuje!<br>\
	Przetrwaj zmianę i bezpiecznie wywieź dysk.<br>"

#undef HDD_PANEL_CLOSED
#undef HDD_PANEL_OPEN
#undef HDD_PRIED
#undef HDD_CUT_LOOSE
#undef HDD_OVERLOADED
