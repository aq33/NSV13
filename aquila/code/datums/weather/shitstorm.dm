//Radiation storms occur when the station passes through an irradiated area, and irradiate anyone not standing in protected areas (maintenance, emergency storage, etc.)
/datum/weather/shit_storm
	name = "shitstorm"
	desc = "A cloud of intense radiation passes through the area dealing rad damage to those who are unprotected."

	telegraph_duration = 400
	telegraph_message = null

	weather_message = "<span class='userdanger'><i>Czujesz fale gorąca spływające po tobie! Znajdź schronienie!</i></span>"
	weather_overlay = "ash_storm"
	weather_duration_lower = 600
	weather_duration_upper = 1500
	weather_color = "#7A5901"
	weather_sound = 'sound/misc/bloblarm.ogg'

	end_duration = 100
	end_message = "<span class='notice'>Promieniowanie ustaje pozostawiając po sobie charakterystyczny odór.</span>"

	area_type = /area
	protected_areas = list(/area/maintenance, /area/ai_monitored/turret_protected/ai_upload, /area/ai_monitored/turret_protected/ai_upload_foyer,
	/area/ai_monitored/turret_protected/ai, /area/storage/emergency/starboard, /area/storage/emergency/port, /area/shuttle, /area/security/prison/asteroid/shielded,
	/area/security/prison/asteroid/service, /area/space/nearstation)
	target_trait = ZTRAIT_STATION

	immunity_type = "shit"

/datum/weather/shit_storm/New(z_levels)
	if(!CONFIG_GET(flag/shitting_enabled))
		qdel(src)
		return
	. = ..()

/datum/weather/shit_storm/telegraph()
	..()
	status_alarm(TRUE)


/datum/weather/shit_storm/weather_act(mob/living/L)
	if(HAS_TRAIT(L, TRAIT_NOSHITTING))
		return
	if(prob(80))
		if(ishuman(L))
			var/mob/living/carbon/human/H = L
			var/shit = 10
			shit *= H.physiology.defecation_mod
			if(H.dna)
				shit *= H.dna.species.shitmod
			H.adjust_defecation(shit)

	if(prob(10))
		if(ishuman(L))
			L.actually_shit_myself()


/datum/weather/shit_storm/end()
	if(..())
		return
	priority_announce("Zagrożenie rozstrajające minęło. Proszę powrócić na stanowiska pracy.", "Alarm: Anomalia", SSstation.announcer.get_rand_alert_sound())
	status_alarm(FALSE)

/datum/weather/shit_storm/proc/status_alarm(active)	//Makes the status displays show the radiation warning for those who missed the announcement.
	var/datum/radio_frequency/frequency = SSradio.return_frequency(FREQ_STATUS_DISPLAYS)
	if(!frequency)
		return

	var/datum/signal/signal = new
	if (active)
		signal.data["command"] = "alert"
		signal.data["picture_state"] = "radiation"
	else
		signal.data["command"] = "shuttle"

	var/atom/movable/virtualspeaker/virt = new(null)
	frequency.post_signal(virt, signal)
