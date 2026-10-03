// AQUILA - polskie flagi (aq33/NSV13#304, sprite: Reprimann)
// buildable_sign = FALSE: odkręcona flaga zamieniłaby się w sign_backing bez swojego sprite'a
/obj/structure/sign/flag
	name = "flagbłąd"
	desc = "Flaga, która nie jest flagą, a jest błędem. Jeżeli to widzisz, to ktoś zawalił sprawę."
	icon = 'aquila/icons/obj/flags.dmi'
	icon_state = "aq_flaga_kotwica"
	buildable_sign = FALSE

/obj/structure/sign/flag/polska_kotwica
	name = "biało-czerwona flaga z kotwicą"
	desc = "Flaga używana przez polskie statki kosmiczne, zgodna z obowiązującym wzorem wymienionym w Załączniku 6 do 'Nanotrasen Military Unit Designation Act'."
	icon_state = "aq_flaga_kotwica"

/obj/structure/sign/flag_wide // 64x32 pikseli, zajmują dwa pola
	name = "flagbłąd"
	desc = "Flaga, która nie jest flagą, a jest błędem. Jeżeli to widzisz, to ktoś zawalił sprawę."
	icon = 'aquila/icons/obj/flags_64.dmi'
	icon_state = "aq_flaga_pl_1"
	buildable_sign = FALSE

/obj/structure/sign/flag_wide/polska
	name = "flaga Polski"
	desc = "Flaga używana przez Polaków, zgodna z obowiązującym wzorem wymienionym w Załączniku 3 do 'Nanotrasen National Minorities Rights Act'."
	icon_state = "aq_flaga_pl_1"

/obj/structure/sign/flag_wide/polska_orzel
	name = "biało-czerwona flaga z orzełkiem"
	desc = "Flaga używana zwyczajowo przez Polaków, niezgodna ze wzorem wymienionym w Załączniku 3 do 'Nanotrasen National Minorities Rights Act'."
	icon_state = "aq_flaga_pl_2"
