/mob/living/death(gibbed)
	var/was_dead_before = stat == DEAD
	. = ..()
	if(!was_dead_before && client && mind?.current)
		INVOKE_ASYNC(src, PROC_REF(show_death_info))

///Okienko z informacją, że gracz umarł i jak może wrócić do gry
/mob/living/proc/show_death_info()
	var/list/dat = list()
	dat += "<h2>Nie żyjesz.</h2>"
	dat += "<p>To jeszcze nie koniec rundy dla ciebie. Do gry możesz wrócić na kilka sposobów.</p>"

	dat += "<h3>Ożywienie twojego ciała</h3>"
	dat += "<ul>"
	dat += "<li><b>Defibrylator</b> – działa do [DEFIB_TIME_LIMIT / 60] minut od śmierci, jeśli ciało nie jest zbyt zniszczone.</li>"
	dat += "<li><b>Strange Reagent</b> – ożywia ciało, które nie ma ciężkich obrażeń ani nie jest wyschnięte (husk).</li>"
	dat += "<li><b>Klonowanie</b> – jeśli medbay ma cię w bazie skanów.</li>"
	dat += "<li><b>MMI</b> – twój mózg można włożyć do cyborga, mecha albo rdzenia AI.</li>"
	dat += "</ul>"
	dat += "<p>Gdy ktoś cię ożywi, wróć do ciała przyciskiem <b>Reenter corpse</b>. Nie klikaj <b>Do Not Resuscitate</b>, bo wtedy nie da się cię już ożywić.</p>"

	dat += "<h3>Nowa postać jako duch</h3>"
	dat += "<ul>"
	dat += "<li><b>Spawners Menu</b> (przycisk na ekranie ducha) – lista wolnych ról dla duchów.</li>"
	dat += "<li><b>pAI Setup</b> – zgłoś się jako osobisty asystent AI.</li>"
	dat += "<li><b>Positroniczny mózg</b> – kliknij go jako duch, gdy ktoś go aktywuje.</li>"
	dat += "<li><b>Possess a mouse</b> – zostań myszą na statku.</li>"
	dat += "<li><b>Wydarzenia</b> – w trakcie rundy mogą pojawiać się okienka z propozycją roli (abordaż, piraci, obce formy życia i inne). Włącz je w preferencjach.</li>"
	dat += "</ul>"

	dat += "<h3>Posiłki wzywane przez załogę</h3>"
	dat += "<ul>"
	dat += "<li><b>Drużyna szybkiej reakcji (ERT)</b> – kapitan, szef ochrony albo AI mogą poprosić o nią w konsoli komunikacyjnej. Jeśli Centrala ją wyśle, duchy dostaną okienko z propozycją dołączenia.</li>"
	dat += "<li><b>Wybudzenie załogi z kriostazy</b> – te same osoby mogą w konsoli komunikacyjnej wybudzić załogę. Duchy dostaną wtedy okienko i mogą wrócić jako Majtek z losową postacią.</li>"
	dat += "</ul>"

	if(CONFIG_GET(flag/norespawn))
		dat += "<p>Powrót do lobby (respawn) jest wyłączony. Jeśli nic z powyższych nie zadziała, zagrasz w następnej rundzie.</p>"

	var/datum/browser/popup = new(src, "death_info", "Nie żyjesz", 500, 680)
	popup.set_content(dat.Join())
	popup.open(FALSE)
