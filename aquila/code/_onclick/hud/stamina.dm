// Port BeeStation/BeeStation-Hornet#11521 (tgstation#53974, #64011, #71623): wskaźnik staminy na HUD-zie.
// Stamina znika przy tym ze wskaźnika zdrowia (AQ EDIT w /mob/living/carbon/human/update_health_hud()).
// Pozycja inna niż w Bee: u nas CENTER-3 zajmuje nastrój, a CENTER-4 lokalizator dowódcy oddziału.

/datum/hud
	var/atom/movable/screen/stamina/stamina

/datum/hud/human/New(mob/living/carbon/human/owner)
	. = ..()
	stamina = new /atom/movable/screen/stamina()
	stamina.hud = src
	infodisplay += stamina

/datum/hud/Destroy()
	stamina = null
	return ..()

/atom/movable/screen/stamina
	name = "stamina"
	icon = 'aquila/icons/hud/screen_stamina.dmi'
	icon_state = "stamina_full"
	screen_loc = ui_stamina

/// Changes the stamina HUD based on new information
/mob/proc/update_stamina_hud()
	return

/mob/living/carbon/update_stamina_hud(shown_stamina_loss)
	// Bez sprawdzania client jak w oryginale: hud_used i tak istnieje tylko u graczy, a test może go założyć sam
	if(!hud_used?.stamina)
		return

	if(stat == DEAD)
		hud_used.stamina.icon_state = "stamina_dead"
		return

	var/stam_crit_threshold = maxHealth - crit_threshold
	if(isnull(shown_stamina_loss))
		shown_stamina_loss = getStaminaLoss()

	if(shown_stamina_loss >= stam_crit_threshold)
		hud_used.stamina.icon_state = "stamina_crit"
	else if(shown_stamina_loss > maxHealth * 0.8)
		hud_used.stamina.icon_state = "stamina_5"
	else if(shown_stamina_loss > maxHealth * 0.6)
		hud_used.stamina.icon_state = "stamina_4"
	else if(shown_stamina_loss > maxHealth * 0.4)
		hud_used.stamina.icon_state = "stamina_3"
	else if(shown_stamina_loss > maxHealth * 0.2)
		hud_used.stamina.icon_state = "stamina_2"
	else if(shown_stamina_loss > 0)
		hud_used.stamina.icon_state = "stamina_1"
	else
		hud_used.stamina.icon_state = "stamina_full"

/mob/living/carbon/update_stamina(extend_stam_crit = FALSE)
	. = ..()
	update_stamina_hud()

/mob/living/carbon/updatehealth()
	. = ..()
	update_stamina_hud()
