// AQUILA - darkspawn: ulepszenia pasywne (Sakrament wymaga wszystkich)

/// +25% leczenia w ciemności, patrz /datum/species/darkspawn
/datum/darkspawn_upgrade/dark_healing
	name = "Sigil \"Naprawa\""
	id = "dark_healing"
	desc = "Sigil Naykranu, symbol wytrwałości, wyryty na plecach. Zwiększa leczenie w ciemności o 25%."
	lucidity_price = 1

/// Połowa obrażeń od światła i odporność na przyćmione światło, patrz /datum/species/darkspawn
/datum/darkspawn_upgrade/light_resistance
	name = "Sigil \"Osłona\""
	id = "light_resistance"
	desc = "Sigil Lnkpayp, symbol niewzruszoności, wyryty na brzuchu. Zmniejsza o połowę obrażenia od światła i chroni przed przyćmionym światłem."
	lucidity_price = 2

/datum/darkspawn_upgrade/psi_cap
	name = "Sigile \"Psi\""
	id = "psi_cap"
	desc = "Sigile Atlwjz, symbole Psi, wyryte na czole. Zwiększają maksymalne Psi o 25."
	lucidity_price = 2

/datum/darkspawn_upgrade/psi_cap/apply_effects()
	darkspawn.psi_cap += 25

/datum/darkspawn_upgrade/psi_regen
	name = "Sigil \"Odnowa\""
	id = "psi_regen"
	desc = "Sigil Mqeygjao, symbol szybkości, wyryty na czole. Psi zaczyna wracać 3 ticki wcześniej, a za jednym razem wraca do 25 zamiast 20."
	lucidity_price = 1

/datum/darkspawn_upgrade/psi_regen/apply_effects()
	darkspawn.psi_regen = 25
	darkspawn.psi_regen_delay -= 3

/// Odporność na światło gwiazd w kosmosie, patrz /datum/species/darkspawn
/datum/darkspawn_upgrade/spacewalking
	name = "Sigile \"Gwiazdy\""
	id = "spacewalking"
	desc = "Sigile Jaxqhw, symbole pustki, wyryte wiele razy na całym ciele. Pozwalają swobodnie chodzić w kosmosie bez obaw przed światłem gwiazd."
	lucidity_price = 3

/// Przejście tworzy macki w obu rękach, które biją razem i szybciej działają
/datum/darkspawn_upgrade/twin_tendrils
	name = "Sigile \"Dwoistość\""
	id = "twin_tendrils"
	desc = "Sigile Zkqxha, symbole dwoistości, wyryte na ramionach. Przejście tworzy macki w obu rękach, jeśli to możliwe, co wzmacnia jedne i drugie."
	lucidity_price = 1
