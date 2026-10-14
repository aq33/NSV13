// AQUILA - darkspawn: zdolności i ulepszenia do kupienia w Psi Web (port z Yogstation)

// Ofensywne: wojownik

/datum/psi_web/shadow_crash
	name = "Szarża cienia"
	desc = "Szarżujesz w wybranym kierunku, odrzucając i na chwilę paraliżując każdego, w kogo uderzysz."
	icon_state = "shadow_crash"
	willpower_cost = 1
	shadow_flags = DARKSPAWN_FIGHTER
	menu_tab = STORE_OFFENSE
	learned_abilities = list(/datum/action/cooldown/spell/pointed/shadow_crash)

/datum/psi_web/demented_outburst
	name = "Obłąkany wybuch"
	desc = "Po pięciu sekundach ładowania ogłusza i dezorientuje słuchaczy, odrzucając wszystkich w pobliżu."
	icon_state = "demented_outburst"
	willpower_cost = 2
	shadow_flags = DARKSPAWN_FIGHTER
	menu_tab = STORE_OFFENSE
	learned_abilities = list(/datum/action/cooldown/spell/aoe/demented_outburst)

/datum/psi_web/taunt
	name = "Podburzenie"
	desc = "Zmusza wszystkich w pobliżu, żeby szli w twoją stronę, ale na chwilę nie możesz atakować."
	icon_state = "incite"
	willpower_cost = 2
	shadow_flags = DARKSPAWN_FIGHTER
	menu_tab = STORE_OFFENSE
	learned_abilities = list(/datum/action/cooldown/spell/aoe/taunt)

/datum/psi_web/ability_upgrade/twin_tendrils
	name = "Sigile dwoistości"
	desc = "Macki tworzą się w obu rękach naraz, jeśli to możliwe, i obie atakują."
	lore_description = "Na rękach wyryte są sigile Kqx'xpk, oznaczające dwoistość."
	icon_state = "duality"
	willpower_cost = 4
	shadow_flags = DARKSPAWN_FIGHTER
	menu_tab = STORE_OFFENSE
	flag_to_add = TENDRIL_UPGRADE_TWIN

/datum/psi_web/ability_upgrade/cleaving_tendrils
	name = "Sigile rozszczepienia"
	desc = "Macki tną też wrogów stojących obok celu."
	lore_description = "Na rękach wyryte są sigile Akvryt, oznaczające przebicie."
	icon_state = "cleave"
	willpower_cost = 2
	shadow_flags = DARKSPAWN_FIGHTER
	menu_tab = STORE_OFFENSE
	flag_to_add = TENDRIL_UPGRADE_CLEAVE

// Ofensywne: zwiadowca

/datum/psi_web/permafrost
	name = "Wieczna zmarzlina"
	desc = "Wysysasz ciepło z otoczenia, w jednej chwili zamrażając podłogę."
	lore_description = "Otwiera szczelinę w zasłonie, która gwałtownie wysysa ciepło z okolicy."
	icon_state = "permafrost"
	willpower_cost = 3
	shadow_flags = DARKSPAWN_SCOUT
	menu_tab = STORE_OFFENSE
	learned_abilities = list(/datum/action/cooldown/spell/aoe/permafrost)

/datum/psi_web/shadow_caster
	name = "Miotacz cieni"
	desc = "Zamieniasz rękę w łuk, który strzela strzałami z czystej ciemności."
	icon_state = "shadow_caster"
	willpower_cost = 4 // jedna z najmocniejszych i najpewniejszych zdolności
	shadow_flags = DARKSPAWN_SCOUT
	menu_tab = STORE_OFFENSE
	learned_abilities = list(/datum/action/cooldown/spell/toggle/shadow_caster)

/datum/psi_web/damage_trap
	name = "Pułapka psi (rany)"
	desc = "Stawiasz pułapkę, która rani każdego wroga, który na nią wejdzie."
	lore_description = "Na ziemi wyryty jest sigil Shash, oznaczający niebezpieczeństwo."
	icon_state = "psi_trap_damage"
	willpower_cost = 2
	shadow_flags = DARKSPAWN_SCOUT
	menu_tab = STORE_OFFENSE
	learned_abilities = list(/datum/action/cooldown/spell/pointed/darkspawn_build/trap/damage)

/datum/psi_web/cuff_trap
	name = "Pułapka psi (unieruchomienie)"
	desc = "Stawiasz pułapkę, która chwyta nogi każdego wroga, który na nią wejdzie."
	lore_description = "Na ziemi wyryty jest sigil Hh'rt, oznaczający pęta."
	icon_state = "psi_trap_bear"
	willpower_cost = 2
	shadow_flags = DARKSPAWN_SCOUT
	menu_tab = STORE_OFFENSE
	learned_abilities = list(/datum/action/cooldown/spell/pointed/darkspawn_build/trap/legcuff)

/datum/psi_web/nausea_trap
	name = "Pułapka psi (mdłości)"
	desc = "Stawiasz pułapkę, po której każdy wróg dostaje mdłości."
	lore_description = "Na ziemi wyryty jest sigil Vxb'rt, oznaczający zakłócenie."
	icon_state = "psi_trap_nausea"
	willpower_cost = 2
	shadow_flags = DARKSPAWN_SCOUT
	menu_tab = STORE_OFFENSE
	learned_abilities = list(/datum/action/cooldown/spell/pointed/darkspawn_build/trap/nausea)

/datum/psi_web/teleport_trap
	name = "Pułapka psi (teleport)"
	desc = "Stawiasz pułapkę, która przenosi każdego wroga w losowe miejsce na stacji."
	lore_description = "Na ziemi wyryty jest sigil Vxb'xki, oznaczający przemieszczenie."
	icon_state = "psi_trap_teleport"
	willpower_cost = 2
	shadow_flags = DARKSPAWN_SCOUT
	menu_tab = STORE_OFFENSE
	learned_abilities = list(/datum/action/cooldown/spell/pointed/darkspawn_build/trap/teleport)

// Ofensywne: czarnoksiężnik

/datum/psi_web/seize
	name = "Pochwycenie"
	desc = "Pętasz umysł celu. Z bliska nie może się ruszać ani mówić, z daleka opada z sił."
	icon_state = "seize"
	willpower_cost = 2
	shadow_flags = DARKSPAWN_WARLOCK
	menu_tab = STORE_OFFENSE
	learned_abilities = list(/datum/action/cooldown/spell/pointed/seize)

/datum/psi_web/ability_upgrade/staff_confusion
	name = "Znak dezorientacji"
	desc = "Pociski laski dezorientują trafionych wrogów."
	lore_description = "Na lasce wyryty jest sigil Vxb'rt, oznaczający zakłócenie."
	icon_state = "confusion_sign"
	willpower_cost = 1
	shadow_flags = DARKSPAWN_WARLOCK
	menu_tab = STORE_OFFENSE
	flag_to_add = STAFF_UPGRADE_CONFUSION

/datum/psi_web/ability_upgrade/staff_light_eater
	name = "Znak pożeracza światła"
	desc = "Pociski laski pożerają światło wszystkiego, w co trafią."
	lore_description = "Na lasce wyryty jest sigil Aaah'ryt, oznaczający pochłanianie."
	icon_state = "lighteater_sign"
	willpower_cost = 1
	shadow_flags = DARKSPAWN_WARLOCK
	menu_tab = STORE_OFFENSE
	flag_to_add = STAFF_UPGRADE_LIGHTEATER

/datum/psi_web/mass_hallucination
	name = "Masowa halucynacja"
	desc = "Wywołuje u wszystkich wrogów w pobliżu krótkie majaczenie."
	icon_state = "mass_hallucination"
	willpower_cost = 2
	shadow_flags = DARKSPAWN_WARLOCK
	menu_tab = STORE_OFFENSE
	learned_abilities = list(/datum/action/cooldown/spell/aoe/mass_hallucination)

/datum/psi_web/mindblast
	name = "Wybuch umysłu"
	desc = "Skupiasz psioniczną energię w pocisk, który zadaje fizyczne obrażenia. Można go też wystrzelić z umysłu sojusznika."
	icon_state = "mind_blast"
	willpower_cost = 2
	shadow_flags = DARKSPAWN_WARLOCK
	menu_tab = STORE_OFFENSE
	learned_abilities = list(/datum/action/cooldown/spell/pointed/mindblast)

/datum/psi_web/extract
	name = "Ekstrakcja"
	desc = "Wysysasz siły życiowe celu albo oddajesz je sojusznikowi."
	icon_state = "extract"
	willpower_cost = 2
	shadow_flags = DARKSPAWN_WARLOCK
	menu_tab = STORE_OFFENSE
	learned_abilities = list(/datum/action/cooldown/spell/pointed/extract)

/datum/psi_web/abyssal_call
	name = "Zew otchłani"
	desc = "Przyzywasz we wskazane miejsce macki, które chwytają wroga."
	lore_description = "Przyzywa macki otchłani zza zasłony."
	icon_state = "abyssal_call"
	willpower_cost = 2
	shadow_flags = DARKSPAWN_WARLOCK
	menu_tab = STORE_OFFENSE
	learned_abilities = list(/datum/action/cooldown/spell/pointed/darkspawn_build/abyssal_call)

/datum/psi_web/shadowflame
	name = "Wylew cienistego płomienia"
	desc = "Wypuszczasz falę cienistego płomienia, który błyskawicznie wysysa ciepło z każdego."
	lore_description = "Ohydne odwrócenie praw termodynamiki."
	icon_state = "veiling_touch"
	willpower_cost = 2
	shadow_flags = DARKSPAWN_WARLOCK
	menu_tab = STORE_OFFENSE
	learned_abilities = list(/datum/action/cooldown/spell/cone/staggered/shadowflame)

/datum/psi_web/shadow_beam
	name = "Promień pustki"
	desc = "Po krótkiej chwili wystrzeliwuje ogromny promień pustki przez całą stację."
	lore_description = "Na krótko wyrywa w pustkę pas rzeczywistości."
	icon_state = "shadow_beam"
	willpower_cost = 3
	shadow_flags = DARKSPAWN_WARLOCK
	menu_tab = STORE_OFFENSE
	learned_abilities = list(/datum/action/cooldown/spell/pointed/shadow_beam)

/datum/psi_web/null_burst
	name = "Zerowy wybuch"
	desc = "Po krótkiej chwili we wskazanym miejscu wybucha pustka."
	lore_description = "Na krótko wyrywa w pustkę kawałek rzeczywistości."
	icon_state = "null_burst"
	willpower_cost = 3
	shadow_flags = DARKSPAWN_WARLOCK
	menu_tab = STORE_OFFENSE
	learned_abilities = list(/datum/action/cooldown/spell/pointed/null_burst)

// Ofensywne: kilka klas

/datum/psi_web/icyveins
	name = "Lodowe żyły"
	desc = "W jednej chwili mrozi krew ludzi w pobliżu, spowalniając ich i gwałtownie wychładzając."
	icon_state = "icy_veins"
	willpower_cost = 2
	shadow_flags = DARKSPAWN_SCOUT | DARKSPAWN_WARLOCK
	menu_tab = STORE_OFFENSE
	learned_abilities = list(/datum/action/cooldown/spell/aoe/icyveins)

// Użytkowe: wojownik

/datum/psi_web/deluge
	name = "Potop"
	desc = "Oblewa wszystkich w pobliżu wodą, gasząc ich i chroniąc przed ogniem."
	lore_description = "Przyzywa nieskończone głębiny, by oblały wszystkich zaświatami."
	icon_state = "deluge"
	willpower_cost = 2
	shadow_flags = DARKSPAWN_FIGHTER
	menu_tab = STORE_UTILITY
	learned_abilities = list(/datum/action/cooldown/spell/aoe/deluge)

/datum/psi_web/creep
	name = "Całun"
	desc = "Póki działa, światło cię nie pali. Można włączać i wyłączać."
	lore_description = "Psioniczną mocą formujesz z ciemności ulotny płaszcz."
	icon_state = "encroach"
	willpower_cost = 2
	shadow_flags = DARKSPAWN_FIGHTER
	menu_tab = STORE_UTILITY
	learned_abilities = list(/datum/action/cooldown/spell/toggle/creep)

/datum/psi_web/time_dilation
	name = "Dylatacja czasu"
	desc = "Znacznie przyspiesza reakcje i działania oraz daje odporność na spowolnienie."
	lore_description = "Sterujesz ciałem bezpośrednio psioniczną mocą, zamiast polegać na prymitywnej biologii."
	icon_state = "time_dilation"
	willpower_cost = 4
	shadow_flags = DARKSPAWN_FIGHTER
	menu_tab = STORE_UTILITY
	learned_abilities = list(/datum/action/cooldown/spell/time_dilation)

/datum/psi_web/indomitable
	name = "Niezłomność"
	desc = "Daje odporność na ogłuszenia i powalenia, ale zmusza do chodzenia."
	lore_description = "Przyszywasz się do ziemi samymi cieniami."
	icon_state = "indomitable"
	willpower_cost = 2
	shadow_flags = DARKSPAWN_FIGHTER
	menu_tab = STORE_UTILITY
	learned_abilities = list(/datum/action/cooldown/spell/toggle/indomitable)

// Użytkowe: zwiadowca

/datum/psi_web/void_jump
	name = "Skok przez pustkę"
	desc = "Krótki teleport we wskazane miejsce."
	lore_description = "Jeden krok przez zasłonę."
	icon_state = "shadow_jump"
	willpower_cost = 2
	shadow_flags = DARKSPAWN_SCOUT
	menu_tab = STORE_UTILITY
	learned_abilities = list(/datum/action/cooldown/spell/pointed/void_jump)

/datum/psi_web/void_jaunt
	name = "Wędrówka przez pustkę"
	desc = "Na chwilę przechodzisz przez zasłonę, niewidoczny dla śmiertelnych oczu i odporny na światło."
	lore_description = "Zasłona bywa zdradliwa dla nieprzygotowanych, ale potrafi dać wytchnienie."
	icon_state = "void_jaunt"
	willpower_cost = 3
	shadow_flags = DARKSPAWN_SCOUT
	menu_tab = STORE_UTILITY
	learned_abilities = list(/datum/action/cooldown/spell/void_jaunt)

/datum/psi_web/darkness_smoke
	name = "Oślepiające miazmaty"
	desc = "Wypluwasz chmurę dymu, która oślepia wrogów i chroni przed światłem."
	lore_description = "Wypuszczasz kieszeń ciemności ukrytą w ciele."
	icon_state = "blinding_miasma"
	willpower_cost = 3
	shadow_flags = DARKSPAWN_SCOUT
	menu_tab = STORE_UTILITY
	learned_abilities = list(/datum/action/cooldown/spell/darkness_smoke)

// Użytkowe: czarnoksiężnik

/datum/psi_web/ability_upgrade/efficiency
	name = "Znak sprawności"
	desc = "Strzał z laski kosztuje o połowę mniej Psi."
	lore_description = "Na lasce wyryty jest sigil Akylia, oznaczający sprawność."
	icon_state = "efficiency_sign"
	willpower_cost = 2
	shadow_flags = DARKSPAWN_WARLOCK
	menu_tab = STORE_UTILITY
	flag_to_add = STAFF_UPGRADE_EFFICIENCY

/datum/psi_web/ability_upgrade/heal
	name = "Znak odnowy"
	desc = "Pociski laski leczą trafionych sojuszników."
	lore_description = "Na lasce wyryty jest sigil Kalak, oznaczający wieczność."
	icon_state = "recovery_sign"
	willpower_cost = 2
	shadow_flags = DARKSPAWN_WARLOCK
	menu_tab = STORE_UTILITY
	flag_to_add = STAFF_UPGRADE_HEAL

/datum/psi_web/ability_upgrade/extinguish
	name = "Znak duszenia"
	desc = "Pociski laski gaszą płonących sojuszników."
	lore_description = "Na lasce wyryty jest sigil Khophg, oznaczający duszenie."
	icon_state = "extinguish_sign"
	willpower_cost = 1
	shadow_flags = DARKSPAWN_WARLOCK
	menu_tab = STORE_UTILITY
	flag_to_add = STAFF_UPGRADE_EXTINGUISH

/datum/psi_web/extinguish
	name = "Zgaszenie"
	desc = "Gasisz wszystkie światła wokół siebie."
	lore_description = "Przypomnij wszystkiemu, co świeci, że jest tylko małą częścią rzeczywistości."
	icon_state = "extinguish"
	willpower_cost = 3
	shadow_flags = DARKSPAWN_WARLOCK
	menu_tab = STORE_UTILITY
	learned_abilities = list(/datum/action/cooldown/spell/aoe/extinguish)

/datum/psi_web/thrall_heal
	name = "Regeneracja thralli"
	desc = "Leczy wszystkich thralli w obszarze 9x9 wokół wskazanego miejsca."
	lore_description = "Thralle są do wymiany, ale do czegoś się przydają."
	icon_state = "heal_veils"
	willpower_cost = 1
	shadow_flags = DARKSPAWN_WARLOCK
	menu_tab = STORE_UTILITY
	learned_abilities = list(/datum/action/cooldown/spell/pointed/thrallbuff/heal)

/datum/psi_web/thrall_speed
	name = "Ożywienie thralli"
	desc = "Daje chwilowe przyspieszenie wszystkim thrallom w obszarze 9x9 wokół wskazanego miejsca."
	lore_description = "Thralle są do wymiany, więc wyciśnij z nich wszystko."
	icon_state = "speedboost_veils"
	willpower_cost = 1
	shadow_flags = DARKSPAWN_WARLOCK
	menu_tab = STORE_UTILITY
	learned_abilities = list(/datum/action/cooldown/spell/pointed/thrallbuff/speed)

/datum/psi_web/elucidate
	name = "Olśnienie"
	desc = "Przepuszczasz przez sojusznika ogromną moc: mocno go leczy, zdejmuje ogłuszenia i przyspiesza. Z bliska wskrzesza martwych sojuszników."
	icon_state = "elucidate"
	willpower_cost = 2
	shadow_flags = DARKSPAWN_WARLOCK
	menu_tab = STORE_UTILITY
	learned_abilities = list(/datum/action/cooldown/spell/pointed/elucidate)

/datum/psi_web/null_charge
	name = "Pusty ładunek"
	desc = "Przez sprawne APC mieszasz w sieci energetycznej, na jakiś czas wyłączając prąd na całej stacji. APC przy tym się psuje."
	icon_state = "null_charge"
	willpower_cost = 3
	shadow_flags = DARKSPAWN_WARLOCK
	menu_tab = STORE_UTILITY
	learned_abilities = list(/datum/action/cooldown/spell/touch/null_charge)

/datum/psi_web/quantum_disruption
	name = "Kwantowe zakłócenie"
	desc = "Na krótko naginasz prawa rzeczywistości i swobodnie przechodzisz przez czasoprzestrzeń."
	lore_description = "Zaburza bieg możliwości: gdzie jesteś, gdzie mógłbyś być."
	icon_state = "quantum_disruption"
	willpower_cost = 3
	shadow_flags = DARKSPAWN_WARLOCK
	menu_tab = STORE_UTILITY
	learned_abilities = list(/datum/action/cooldown/spell/quantum_disruption)

/datum/psi_web/fray_self
	name = "Rozszczepienie jaźni"
	desc = "Próbujesz oderwać kawałek swojej psyche w świadomą kopię samego siebie, która żyje, dopóki ktoś jej nie zniszczy."
	icon_state = "fray_self"
	willpower_cost = 3
	shadow_flags = DARKSPAWN_WARLOCK
	menu_tab = STORE_UTILITY
	learned_abilities = list(/datum/action/cooldown/spell/fray_self)

// Użytkowe: wszystkie klasy

/datum/psi_web/umbral_trespass
	name = "Wtargnięcie w cień"
	desc = "Wtapiasz się w cień celu i niewidocznie za nim podążasz."
	icon_state = "umbral_trespass"
	willpower_cost = 2
	shadow_flags = ALL_DARKSPAWN_CLASSES
	menu_tab = STORE_UTILITY
	learned_abilities = list(/datum/action/cooldown/spell/touch/umbral_trespass)

/datum/psi_web/simulacrum
	name = "Simulacrum"
	desc = "Tworzy iluzję łudząco do ciebie podobną, która przez 10 sekund walczy za ciebie."
	icon_state = "simulacrum"
	willpower_cost = 2
	shadow_flags = ALL_DARKSPAWN_CLASSES
	menu_tab = STORE_UTILITY
	learned_abilities = list(/datum/action/cooldown/spell/simulacrum)

/datum/psi_web/crawling_shadows
	name = "Pełzające cienie"
	desc = "Przybierasz cienistą postać, która przechodzi przez szyby wentylacyjne i szpary w drzwiach."
	icon_state = "crawling_shadows"
	willpower_cost = 3
	shadow_flags = ALL_DARKSPAWN_CLASSES
	menu_tab = STORE_UTILITY
	learned_abilities = list(/datum/action/cooldown/spell/crawling_shadows)

/datum/psi_web/silver_tongue
	name = "Srebrny język"
	desc = "Przy konsoli komunikacyjnej pozwala siłą nadać wiadomość do CentComu i odwołać prom."
	icon_state = "silver_tongue"
	willpower_cost = 2
	shadow_flags = ALL_DARKSPAWN_CLASSES
	menu_tab = STORE_UTILITY
	learned_abilities = list(/datum/action/cooldown/spell/touch/silver_tongue)

// Pasywne: kilka klas

/datum/psi_web/medhud
	name = "Sigil medyczny"
	desc = "Daje ci medyczny HUD."
	lore_description = "Pod oczami wyryte są sigile Vxt, oznaczające wiedzę."
	icon_state = "medical"
	willpower_cost = 1
	menu_tab = STORE_PASSIVE
	shadow_flags = ALL_DARKSPAWN_CLASSES

/datum/psi_web/medhud/on_gain()
	var/datum/atom_hud/H = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	H.add_hud_to(shadowhuman)

/datum/psi_web/medhud/on_loss()
	var/datum/atom_hud/H = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	H.remove_hud_from(shadowhuman)

/datum/psi_web/xray
	name = "Sigil przenikania"
	desc = "Widzisz przez przedmioty i ściany."
	lore_description = "Pod oczami wyryte są sigile Akvryt, oznaczające przebicie."
	icon_state = "xray"
	willpower_cost = 3
	menu_tab = STORE_PASSIVE
	shadow_flags = ALL_DARKSPAWN_CLASSES

/datum/psi_web/xray/on_gain()
	ADD_TRAIT(shadowhuman, TRAIT_XRAY_VISION, type)
	shadowhuman.update_sight()

/datum/psi_web/xray/on_loss()
	REMOVE_TRAIT(shadowhuman, TRAIT_XRAY_VISION, type)
	shadowhuman.update_sight()

/datum/psi_web/psi_cap
	name = "Sigile psionicznej rezerwy"
	desc = "Zwiększa maksymalne Psi o 100."
	lore_description = "Na czole wyryty jest sigil Trin, oznaczający umysł."
	icon_state = "psi_reserve"
	willpower_cost = 2
	menu_tab = STORE_PASSIVE
	shadow_flags = ALL_DARKSPAWN_CLASSES
	infinite = TRUE

/datum/psi_web/psi_cap/on_gain()
	darkspawn.psi_cap += 100

/datum/psi_web/psi_cap/on_loss()
	darkspawn.psi_cap -= 100

/datum/psi_web/stamina_res
	name = "Sigile wigoru"
	desc = "Przyjmujesz o połowę mniej obrażeń wytrzymałości."
	lore_description = "Na nogach wyryte są sigile Kalak, oznaczające wieczność."
	icon_state = "vigor"
	willpower_cost = 2
	menu_tab = STORE_PASSIVE
	shadow_flags = DARKSPAWN_SCOUT | DARKSPAWN_FIGHTER

/datum/psi_web/stamina_res/on_gain()
	darkspawn.stam_mod *= 0.5

/datum/psi_web/stamina_res/on_loss()
	darkspawn.stam_mod /= 0.5

/datum/psi_web/dark_healing
	name = "Sigil gojenia"
	desc = "Szybciej leczysz się w ciemności."
	lore_description = "Na plecach wyryty jest sigil Kalak, oznaczający wieczność."
	icon_state = "mending"
	willpower_cost = 2
	menu_tab = STORE_PASSIVE
	shadow_flags = DARKSPAWN_FIGHTER | DARKSPAWN_SCOUT
	infinite = TRUE

/datum/psi_web/dark_healing/on_gain()
	darkspawn.dark_healing *= 1.25

// Yog miał tu omyłkowo drugie on_gain, przez co zwrot nic nie cofał
/datum/psi_web/dark_healing/on_loss()
	darkspawn.dark_healing /= 1.25

/datum/psi_web/low_light_resistance
	name = "Sigil osłony przed światłem"
	desc = "Przyćmione światło przestaje cię parzyć."
	lore_description = "Na plecach wyryty jest sigil Vvkatkz, oznaczający ochronę."
	icon_state = "light_ward"
	willpower_cost = 2
	menu_tab = STORE_PASSIVE
	shadow_flags = DARKSPAWN_FIGHTER | DARKSPAWN_SCOUT

/datum/psi_web/low_light_resistance/on_gain()
	ADD_TRAIT(darkspawn, TRAIT_DARKSPAWN_LIGHTRES, type)

/datum/psi_web/low_light_resistance/on_loss()
	REMOVE_TRAIT(darkspawn, TRAIT_DARKSPAWN_LIGHTRES, type)

/datum/psi_web/noslip
	name = "Sigil stabilności"
	desc = "Nie tracisz równowagi i się nie poślizgujesz."
	lore_description = "Na nogach wyryte są sigile Tr'bxv, oznaczające stabilność."
	icon_state = "stability"
	willpower_cost = 1
	menu_tab = STORE_PASSIVE
	shadow_flags = DARKSPAWN_FIGHTER | DARKSPAWN_SCOUT

/datum/psi_web/noslip/on_gain()
	ADD_TRAIT(shadowhuman, TRAIT_NOSLIPALL, type)

/datum/psi_web/noslip/on_loss()
	REMOVE_TRAIT(shadowhuman, TRAIT_NOSLIPALL, type)

/datum/psi_web/fast_cooldown
	name = "Sigil burzy"
	desc = "Twoje zaklęcia szybciej się odnawiają."
	lore_description = "Na czole wyryty jest sigil Zeras, oznaczający burzę."
	icon_state = "storm"
	willpower_cost = 2
	menu_tab = STORE_PASSIVE
	shadow_flags = DARKSPAWN_WARLOCK | DARKSPAWN_SCOUT

/datum/psi_web/fast_cooldown/on_gain()
	ADD_TRAIT(shadowhuman, TRAIT_FAST_COOLDOWNS, type)

/datum/psi_web/fast_cooldown/on_loss()
	REMOVE_TRAIT(shadowhuman, TRAIT_FAST_COOLDOWNS, type)

// Pasywne: wojownik

/datum/psi_web/sunglasses
	name = "Sigil oślepienia"
	desc = "Chroni przed silnymi błyskami światła."
	lore_description = "Pod oczami wyryte są sigile Vvkatkz, oznaczające ochronę."
	icon_state = "light_blind"
	willpower_cost = 1
	menu_tab = STORE_PASSIVE
	shadow_flags = DARKSPAWN_FIGHTER
	var/obj/item/organ/eyes/eyes
	var/old_flash_protect = 0

/datum/psi_web/sunglasses/on_gain()
	eyes = shadowhuman.getorganslot(ORGAN_SLOT_EYES)
	if(eyes)
		old_flash_protect = eyes.flash_protect
		eyes.flash_protect = max(eyes.flash_protect, 2)

/datum/psi_web/sunglasses/on_loss()
	if(eyes && !QDELETED(eyes))
		eyes.flash_protect = old_flash_protect
	eyes = null

/datum/psi_web/light_resistance
	name = "Sigil cienistej skóry"
	desc = "Światło zadaje ci mniej obrażeń."
	lore_description = "Na brzuchu wyryty jest sigil Xlynsh, oznaczający załamanie."
	icon_state = "shadow_skin"
	willpower_cost = 2
	menu_tab = STORE_PASSIVE
	shadow_flags = DARKSPAWN_FIGHTER
	infinite = TRUE

/datum/psi_web/light_resistance/on_gain()
	darkspawn.light_burning *= 0.8

/datum/psi_web/light_resistance/on_loss()
	darkspawn.light_burning /= 0.8

/datum/psi_web/brute_res
	name = "Sigil zrogowacenia"
	desc = "Przyjmujesz mniej obrażeń fizycznych."
	lore_description = "Na brzuchu wyryty jest sigil Hh'sha, oznaczający wytrwałość."
	icon_state = "callous"
	willpower_cost = 2
	menu_tab = STORE_PASSIVE
	shadow_flags = DARKSPAWN_FIGHTER
	infinite = TRUE

/datum/psi_web/brute_res/on_gain()
	darkspawn.brute_mod *= 0.8

/datum/psi_web/brute_res/on_loss()
	darkspawn.brute_mod /= 0.8

/datum/psi_web/burn_res
	name = "Sigil stłumienia"
	desc = "Przyjmujesz mniej oparzeń."
	lore_description = "Na brzuchu wyryty jest sigil Khophg, oznaczający duszenie."
	icon_state = "stifle"
	willpower_cost = 2
	menu_tab = STORE_PASSIVE
	shadow_flags = DARKSPAWN_FIGHTER
	infinite = TRUE

/datum/psi_web/burn_res/on_gain()
	darkspawn.burn_mod *= 0.85

/datum/psi_web/burn_res/on_loss()
	darkspawn.burn_mod /= 0.85

/datum/psi_web/undying
	name = "Sigile nieśmiertelności"
	desc = "Po śmierci po jakimś czasie w ciemności wstajesz z martwych."
	lore_description = "Na brzuchu wyryty jest sigil Kalak, oznaczający wieczność."
	icon_state = "undying"
	willpower_cost = 2
	menu_tab = STORE_PASSIVE
	shadow_flags = DARKSPAWN_FIGHTER

/datum/psi_web/undying/on_gain()
	ADD_TRAIT(darkspawn, TRAIT_DARKSPAWN_UNDYING, type)

/datum/psi_web/undying/on_loss()
	REMOVE_TRAIT(darkspawn, TRAIT_DARKSPAWN_UNDYING, type)

// Pasywne: zwiadowca

/datum/psi_web/shadow_walk
	name = "Sigile wędrówki cieni"
	desc = "W ciemności biegasz znacznie szybciej."
	lore_description = "Na nogach wyryte są sigile Mehlak, oznaczające podróż."
	icon_state = "shadow_walk"
	willpower_cost = 3
	menu_tab = STORE_PASSIVE
	shadow_flags = DARKSPAWN_SCOUT

/datum/psi_web/shadow_walk/on_gain()
	shadowhuman.AddComponent(/datum/component/darkspawn_shadow_step)

/datum/psi_web/shadow_walk/on_loss()
	qdel(shadowhuman?.GetComponent(/datum/component/darkspawn_shadow_step))

// Pasywne: czarnoksiężnik

/datum/psi_web/psi_regen_delay
	name = "Sigil psionicznej ulgi"
	desc = "Psi zaczyna się odnawiać 5 sekund wcześniej."
	lore_description = "Na czole wyryty jest sigil Kalak, oznaczający wieczność."
	icon_state = "psi_relief"
	willpower_cost = 2
	menu_tab = STORE_PASSIVE
	shadow_flags = DARKSPAWN_WARLOCK

/datum/psi_web/psi_regen_delay/on_gain()
	darkspawn.psi_regen_delay -= 5 SECONDS

/datum/psi_web/psi_regen_delay/on_loss()
	darkspawn.psi_regen_delay += 5 SECONDS

/datum/psi_web/psi_regen_speed
	name = "Sigil psionicznej regeneracji"
	desc = "Psi odnawia się dwa razy szybciej."
	lore_description = "Na czole wyryty jest sigil Ieaxki, oznaczający szybkość."
	icon_state = "psi_recovery"
	willpower_cost = 1
	menu_tab = STORE_PASSIVE
	shadow_flags = DARKSPAWN_WARLOCK
	infinite = TRUE

/datum/psi_web/psi_regen_speed/on_gain()
	darkspawn.psi_per_second *= 2

/datum/psi_web/psi_regen_speed/on_loss()
	darkspawn.psi_per_second /= 2

/datum/psi_web/more_thralls
	name = "Sigil kontroli"
	desc = "Możesz władać dwoma dodatkowymi thrallami."
	lore_description = "Na rękach wyryte są sigile Gryxah, oznaczające kontrolę."
	icon_state = "control"
	willpower_cost = 3
	menu_tab = STORE_PASSIVE
	shadow_flags = DARKSPAWN_WARLOCK

/datum/psi_web/more_thralls/on_gain()
	var/datum/team/darkspawn/team = darkspawn.get_team()
	if(team)
		team.max_thralls += 2

// Yog przy zwrocie omyłkowo dodawał thralli zamiast odejmować
/datum/psi_web/more_thralls/on_loss()
	var/datum/team/darkspawn/team = darkspawn.get_team()
	if(team)
		team.max_thralls -= 2

/datum/psi_web/buff_allies
	name = "Sigil jedności"
	desc = "Zdolności wspierające thralli działają też na innych darkspawnów."
	lore_description = "Na dłoniach wyryte są sigile Ahwelhe, oznaczające jedność."
	icon_state = "unity"
	willpower_cost = 1
	menu_tab = STORE_PASSIVE
	shadow_flags = DARKSPAWN_WARLOCK

/datum/psi_web/buff_allies/on_gain()
	ADD_TRAIT(darkspawn, TRAIT_DARKSPAWN_BUFFALLIES, type)

/datum/psi_web/buff_allies/on_loss()
	REMOVE_TRAIT(darkspawn, TRAIT_DARKSPAWN_BUFFALLIES, type)
