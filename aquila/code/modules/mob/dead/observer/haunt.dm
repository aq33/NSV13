// Nawiedzenie: duch raz na minutę mruga pobliskimi światłami, puszcza straszny dźwięk i na chwilę zostawia blady zarys ducha.
// Pozwala duchom dać żywym znać, że ktoś tu jest, bez mówienia czegokolwiek. Przycisk na HUD-zie ducha.

/// Jak często jeden duch może nawiedzać
#define GHOST_HAUNT_COOLDOWN (1 MINUTES)
/// Jak często można nawiedzać ten sam obszar, żeby kilka duchów naraz nie zrobiło dyskoteki
#define GHOST_HAUNT_AREA_COOLDOWN (20 SECONDS)
/// Zasięg mrugania światłami
#define GHOST_HAUNT_LIGHT_RANGE 4
/// Zasięg, w którym żywi czują chłód
#define GHOST_HAUNT_CHILL_RANGE 5

/mob/dead/observer
	COOLDOWN_DECLARE(haunt_cooldown)

/area
	COOLDOWN_DECLARE(haunt_cooldown)

/mob/dead/observer/proc/haunt()
	if(!client)
		return FALSE
	if(!SSticker.HasRoundStarted())
		to_chat(src, "<span class='warning'>Runda jeszcze się nie zaczęła.</span>")
		return FALSE
	if(!COOLDOWN_FINISHED(src, haunt_cooldown))
		to_chat(src, "<span class='warning'>Nie masz jeszcze siły, żeby znowu straszyć. Spróbuj za [DisplayTimeText(COOLDOWN_TIMELEFT(src, haunt_cooldown))].</span>")
		return FALSE
	var/turf/haunted = get_turf(src)
	var/area/haunted_area = get_area(src)
	if(!haunted || !haunted_area)
		return FALSE
	if(!COOLDOWN_FINISHED(haunted_area, haunt_cooldown))
		to_chat(src, "<span class='warning'>Ktoś już tu niedawno straszył. Poczekaj chwilę albo poszukaj innego miejsca.</span>")
		return FALSE
	var/list/witnesses = list()
	for(var/mob/living/living in hearers(GHOST_HAUNT_CHILL_RANGE, haunted))
		if(living.client && living.stat == CONSCIOUS)
			witnesses += living
	if(!length(witnesses))
		to_chat(src, "<span class='warning'>W pobliżu nie ma nikogo, kogo dałoby się nastraszyć.</span>")
		return FALSE

	COOLDOWN_START(src, haunt_cooldown, GHOST_HAUNT_COOLDOWN)
	COOLDOWN_START(haunted_area, haunt_cooldown, GHOST_HAUNT_AREA_COOLDOWN)

	for(var/obj/machinery/light/light in range(GHOST_HAUNT_LIGHT_RANGE, haunted))
		light.flicker(rand(4, 8))
	var/static/list/haunt_sounds = list(
		'sound/spookoween/ghost_whisper.ogg',
		'sound/spookoween/ghosty_wind.ogg',
		'sound/spookoween/chain_rattling.ogg',
		'sound/spookoween/insane_low_laugh.ogg',
		'sound/hallucinations/wail.ogg',
	)
	playsound(haunted, pick(haunt_sounds), 50, TRUE, -2)
	new /obj/effect/temp_visual/ghost_haunt(haunted)
	for(var/mob/living/living as anything in witnesses)
		to_chat(living, "<span class='warning'>[pick("Przechodzi cię zimny dreszcz...", "Masz wrażenie, że ktoś na ciebie patrzy.", "Czujesz nagły chłód na karku.", "Coś tu jest...")]</span>")
	to_chat(src, "<span class='notice'>Nawiedzasz [haunted_area.name]. Żywi w pobliżu poczuli twoją obecność.</span>")
	log_game("[key_name(src)] nawiedził [AREACOORD(haunted)]")

	var/atom/movable/screen/ghost/haunt/button = locate() in hud_used?.static_inventory
	button?.start_cooldown(GHOST_HAUNT_COOLDOWN)
	return TRUE

/// Blady, ogólny zarys ducha (nie wygląd postaci, żeby nie zdradzać, kto zginął)
/obj/effect/temp_visual/ghost_haunt
	icon = 'icons/mob/mob.dmi'
	icon_state = "ghost"
	// Świeci w ciemności, bo światła wokół właśnie mrugają
	plane = ABOVE_LIGHTING_PLANE
	layer = ABOVE_LIGHTING_LAYER
	randomdir = FALSE
	duration = 2 SECONDS
	alpha = 0

/obj/effect/temp_visual/ghost_haunt/Initialize(mapload)
	. = ..()
	animate(src, alpha = 70, pixel_y = 4, time = 1 SECONDS)
	animate(alpha = 0, pixel_y = 8, time = 1 SECONDS)

/atom/movable/screen/ghost/haunt
	name = "Nawiedź"
	desc = "Mrugnij pobliskimi światłami i nastrasz żywych. Raz na minutę."
	icon_state = null

/atom/movable/screen/ghost/haunt/Initialize(mapload)
	. = ..()
	icon = ghost_button_frame()
	var/mutable_appearance/bulb = mutable_appearance('icons/obj/lighting.dmi', "lbulb")
	var/list/center_offset = icon_center_offset('icons/obj/lighting.dmi', "lbulb")
	bulb.pixel_x = center_offset[1]
	bulb.pixel_y = center_offset[2]
	add_overlay(bulb)

/atom/movable/screen/ghost/haunt/Click()
	var/mob/dead/observer/ghost = usr
	if(istype(ghost))
		ghost.haunt()

/// Przyciemnia przycisk do końca odnowienia
/atom/movable/screen/ghost/haunt/proc/start_cooldown(duration)
	color = "#666666"
	addtimer(CALLBACK(src, PROC_REF(end_cooldown)), duration, TIMER_UNIQUE | TIMER_OVERRIDE)

/atom/movable/screen/ghost/haunt/proc/end_cooldown()
	color = null

#undef GHOST_HAUNT_COOLDOWN
#undef GHOST_HAUNT_AREA_COOLDOWN
#undef GHOST_HAUNT_LIGHT_RANGE
#undef GHOST_HAUNT_CHILL_RANGE
