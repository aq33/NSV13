//Fluff components that are only used in building.
/obj/item/fighter_component/avionics
	name = "\improper Fighter Avionics"
	desc = "Avionics for a fighter"
	icon = 'nsv13/icons/obj/fighter_components.dmi'
	icon_state = "avionics"
	tier = null //Cannot be upgraded.

/obj/item/fighter_component/apu
	name = "\improper Fighter Auxiliary Power Unit"
	desc = "An Auxiliary Power Unit for a fighter"
	icon = 'nsv13/icons/obj/fighter_components.dmi'
	icon_state = "apu"

/obj/item/fighter_component/targeting_sensor
	name = "\improper Fighter Targeting Sensors"
	icon_state = "targeting_sensor"
	tier = null //Cannot be upgraded.

//Woe betide all ye who venture here.

#define LBS_CHASSIS 						0
#define LBS_CHASSIS_BOLT					1
#define LBS_CHASSIS_WELD					2
#define LBS_ENGINE							3
#define LBS_ENGINE_BOLT						4
#define LBS_APU								5
#define LBS_APU_WIRE						6
#define LBS_APU_SCREW						7
#define LBS_FUEL_TANK						8
#define LBS_FUEL_TANK_BOLT					9
#define LBS_AVIONICS						10
#define LBS_AVIONICS_WIRE					11
#define LBS_AVIONICS_SCREW					12
#define LBS_TARGETING_SENSOR				13
#define LBS_TARGETING_SENSOR_SCREW			14
#define LBS_COUNTERMEASURE_DISPENSER		15
#define LBS_COUNTERMEASURE_DISPENSER_BOLT	16
#define LBS_ARMOUR_PLATING					17
#define LBS_ARMOUR_PLATING_BOLT				18
#define LBS_ARMOUR_PLATING_WELD				19
#define LBS_PRIMARY							20
#define LBS_PRIMARY_BOLT					21
#define LBS_SECONDARY						22
#define LBS_SECONDARY_BOLT					23
#define LBS_PAINT_PRIMER					24
#define LBS_PAINT_DETAILING					25

/obj/structure/fighter_frame
	name = "\improper Light Fighter Frame"
	desc = "An Incomplete Su-818 Rapier Light Fighter. Just add elbow grease and a bunch of parts!"
	icon = 'nsv13/icons/overmap/nanotrasen/fighter_construction.dmi'
	icon_state = "fighter"
	pixel_x = -12
	pixel_y = -12
	density = TRUE
	anchored = FALSE
	var/build_state = LBS_CHASSIS
	var/building = FALSE
	var/output_path = /obj/structure/overmap/small_craft

/obj/structure/fighter_frame/heavy
	name = "\improper Heavy Fighter Frame"
	desc = "An Incomplete Su-410 Scimitar Heavy Fighter"
	icon = 'nsv13/icons/overmap/nanotrasen/heavyfighter_construction.dmi'
	icon_state = "heavy_fighter"
	pixel_x = -32
	pixel_y = -12
	output_path = /obj/structure/overmap/small_craft/combat/heavy

/obj/structure/fighter_frame/utility
	name = "\improper Utility Vessel Frame"
	desc = "An Incomplete Su-437 Sabre Utility Vessel"
	icon = 'nsv13/icons/overmap/nanotrasen/raptorconstruction.dmi'
	icon_state = "carrier"
	pixel_x = -32
	pixel_y = -12
	output_path = /obj/structure/overmap/small_craft/transport/sabre

/obj/structure/fighter_frame/update_icon()
	icon_state = "[initial(icon_state)][build_state]"

/obj/structure/fighter_frame/examine(mob/user)
	. = ..()
	switch(build_state)
		if(LBS_CHASSIS)
			. += "<span class='notice'>Przykręć podwozie śrubami.</span>"
		if(LBS_CHASSIS_BOLT)
			. += "<span class='notice'>Wzmocnij połączenia podwozia spawarką.</span>"
		if(LBS_CHASSIS_WELD)
			. += "<span class='notice'>Zainstaluj silnik w gnieździe B.</span>"
		if(LBS_ENGINE)
			. += "<span class='notice'>Przykręć silnik do podwozia śrubami.</span>"
		if(LBS_ENGINE_BOLT)
			. += "<span class='notice'>Zainstaluj pomocniczą jednostkę zasilania w gnieździe S.</span>"
		if(LBS_APU)
			. += "<span class='notice'>Zgodnie ze schematem okablowania połącz pomocniczą jednostkę zasilania z silnikiem.</span>"
		if(LBS_APU_WIRE)
			. += "<span class='notice'>Przykręć połączenia pomocniczej jednostki zasilania wkrętami.</span>"
		if(LBS_APU_SCREW)
			. += "<span class='notice'>Zainstaluj zbiornik paliwa w gnieździe G.</span>"
		if(LBS_FUEL_TANK)
			. += "<span class='notice'>Przykręć zbiornik paliwa do podwozia śrubami.</span>"
		if(LBS_FUEL_TANK_BOLT)
			. += "<span class='notice'>Zainstaluj awionikę w gnieździe _S</span>"
		if(LBS_AVIONICS)
			. += "<span class='notice'>Zgodnie ze schematem okablowania połącz awionikę ze sterami lotu i silnikami manewrowymi.</span>"
		if(LBS_AVIONICS_WIRE)
			. += "<span class='notice'>Przykręć połączenia awioniki wkrętami.</span>"
		if(LBS_AVIONICS_SCREW)
			. += "<span class='notice'>Zainstaluj czujnik celowniczy w gnieździe U.</span>"
		if(LBS_TARGETING_SENSOR)
			. += "<span class='notice'>Przykręć czujnik celowniczy do podwozia wkrętami.</span>"
		if(LBS_TARGETING_SENSOR_SCREW)
			. += "<span class='notice'>Zainstaluj dozownik środków przeciwdziałania w gnieździe X</span>"
		if(LBS_COUNTERMEASURE_DISPENSER)
			. += "<span class='notice'>Przykręć dozownik środków przeciwdziałania do podwozia śrubami.</span>"
		if(LBS_COUNTERMEASURE_DISPENSER_BOLT)
			. += "<span class='notice'>Zainstaluj płyty pancerza we wszystkich wskazanych na schemacie miejscach.</span>"
		if(LBS_ARMOUR_PLATING)
			. += "<span class='notice'>Przykręć płyty pancerza do podwozia śrubami.</span>"
		if(LBS_ARMOUR_PLATING_BOLT)
			. += "<span class='notice'>Wzmocnij połączenia płyt pancerza z podwoziem spawarką.</span>"
		if(LBS_ARMOUR_PLATING_WELD)
			. += "<span class='notice'>Zainstaluj moduł broni głównej w przednim punkcie mocowania.</span>"
		if(LBS_PRIMARY)
			. += "<span class='notice'>Przykręć moduł broni głównej do przedniego punktu mocowania śrubami.</span>"
		if(LBS_PRIMARY_BOLT)
			. += "<span class='notice'>Zainstaluj moduł broni dodatkowej w dodatkowym punkcie mocowania.</span>"
		if(LBS_SECONDARY)
			. += "<span class='notice'>Przykręć moduł broni dodatkowej do dodatkowego punktu mocowania śrubami.</span>"
		if(LBS_SECONDARY_BOLT)
			. += "<span class='notice'>Pomaluj powierzchnię [src] podkładem.</span>"
		if(LBS_PAINT_PRIMER)
			. += "<span class='notice'>Pomaluj powierzchnię [src] i nanieś zatwierdzone zdobienia zgodnie ze schematami.</span>"
		if(LBS_PAINT_DETAILING)
			. += "<span class='notice'>Dokończ myśliwiec, klikając go pustą ręką, i dodaj brakujące komponenty do świeżo przygotowanego myśliwca.</span>"

/obj/structure/fighter_frame/attackby(obj/item/W, mob/user, params)
	add_fingerprint(user)
	if(building)
		to_chat(user, "<span class='notice'>Już coś instalujesz w [src]!</span>")
		return
	if(istype(W, /obj/item/fighter_component/fuel_tank))
		if(build_state == LBS_APU_SCREW)
			to_chat(user, "<span class='notice'>Zaczynasz dodawać [W] do [src]...</span>")
			building = TRUE
			if(!do_after(user, 5 SECONDS, target=src) || !Adjacent(user))
				building = FALSE
				return
			to_chat(user, "<spawn class='notice'>Dodajesz [W] do [src].</span>")
			build_state = LBS_FUEL_TANK
			update_icon()
			W.forceMove(src)
			building = FALSE
	else if(istype(W, /obj/item/fighter_component/avionics))
		if(build_state == LBS_FUEL_TANK_BOLT)
			to_chat(user, "<span class='notice'>Zaczynasz dodawać [W] do [src]...</span>")
			building = TRUE
			if(!do_after(user, 5 SECONDS, target=src) || !Adjacent(user))
				building = FALSE
				return
			to_chat(user, "<spawn class='notice'>Dodajesz [W] do [src].</span>")
			build_state = LBS_AVIONICS
			update_icon()
			W.forceMove(src)
			building = FALSE
	else if(istype(W, /obj/item/fighter_component/apu))
		if(build_state == LBS_ENGINE_BOLT)
			to_chat(user, "<span class='notice'>Zaczynasz dodawać [W] do [src]...</span>")
			building = TRUE
			if(!do_after(user, 5 SECONDS, target=src) || !Adjacent(user))
				building = FALSE
				return
			to_chat(user, "<spawn class='notice'>Dodajesz [W] do [src].</span>")
			build_state = LBS_APU
			update_icon()
			W.forceMove(src)
			building = FALSE
	else if(istype(W, /obj/item/fighter_component/armour_plating))
		if(build_state == LBS_COUNTERMEASURE_DISPENSER_BOLT)
			to_chat(user, "<span class='notice'>Zaczynasz dodawać [W] do [src]...</span>")
			building = TRUE
			if(!do_after(user, 5 SECONDS, target=src) || !Adjacent(user))
				building = FALSE
				return
			to_chat(user, "<spawn class='notice'>Dodajesz [W] do [src].</span>")
			build_state = LBS_ARMOUR_PLATING
			update_icon()
			W.forceMove(src)
			building = FALSE
	else if(istype(W, /obj/item/fighter_component/targeting_sensor))
		if(build_state == LBS_AVIONICS_SCREW)
			to_chat(user, "<span class='notice'>Zaczynasz dodawać [W] do [src]...</span>")
			building = TRUE
			if(!do_after(user, 5 SECONDS, target=src) || !Adjacent(user))
				building = FALSE
				return
			to_chat(user, "<spawn class='notice'>Dodajesz [W] do [src].</span>")
			build_state = LBS_TARGETING_SENSOR
			update_icon()
			W.forceMove(src)
			building = FALSE
	else if(istype(W, /obj/item/fighter_component/engine))
		if(build_state == LBS_CHASSIS_WELD)
			to_chat(user, "<span class='notice'>Zaczynasz dodawać [W] do [src]...</span>")
			building = TRUE
			if(!do_after(user, 5 SECONDS, target=src) || !Adjacent(user))
				building = FALSE
				return
			to_chat(user, "<spawn class='notice'>Dodajesz [W] do [src].</span>")
			build_state = LBS_ENGINE
			update_icon()
			W.forceMove(src)
			building = FALSE
	else if(istype(W, /obj/item/fighter_component/countermeasure_dispenser))
		if(build_state == LBS_TARGETING_SENSOR_SCREW)
			to_chat(user, "<span class='notice'>Zaczynasz dodawać [W] do [src]...</span>")
			building = TRUE
			if(!do_after(user, 5 SECONDS, target=src) || !Adjacent(user))
				building = FALSE
				return
			to_chat(user, "<spawn class='notice'>Dodajesz [W] do [src].</span>")
			build_state = LBS_COUNTERMEASURE_DISPENSER
			update_icon()
			W.forceMove(src)
			building = FALSE
	else if(istype(W, /obj/item/fighter_component/secondary))
		if(build_state == LBS_PRIMARY_BOLT)
			to_chat(user, "<span class='notice'>Zaczynasz dodawać [W] do [src]...</span>")
			building = TRUE
			if(!do_after(user, 5 SECONDS, target=src) || !Adjacent(user))
				building = FALSE
				return
			to_chat(user, "<spawn class='notice'>Dodajesz [W] do [src].</span>")
			build_state = LBS_SECONDARY
			update_icon()
			W.forceMove(src)
			building = FALSE
	else if(istype(W, /obj/item/fighter_component/primary))
		if(build_state == LBS_ARMOUR_PLATING_WELD)
			to_chat(user, "<span class='notice'>Zaczynasz dodawać [W] do [src]...</span>")
			building = TRUE
			if(!do_after(user, 5 SECONDS, target=src) || !Adjacent(user))
				building = FALSE
				return
			to_chat(user, "<spawn class='notice'>Dodajesz [W] do [src].</span>")
			build_state = LBS_PRIMARY
			update_icon()
			W.forceMove(src)
			building = FALSE
	else if(istype(W, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/C = W
		if(build_state == LBS_AVIONICS)
			if(C.get_amount() <5)
				to_chat(user, "<span class='notice'>Do okablowania [src] potrzebujesz przynajmniej pięciu kawałków kabla!</span>")
				return
			to_chat(user, "<span class='notice'>Zaczynasz okablowywać [src]...</span>")
			building = TRUE
			if(!do_after(user, 5 SECONDS, target=src) || !Adjacent(user))
				building = FALSE
				return
			W.use(5)
			to_chat(user, "<spawn class='notice'>Okablowujesz [src].</span>")
			build_state = LBS_AVIONICS_WIRE
			update_icon()
			building = FALSE
		if(build_state == LBS_APU)
			if(C.get_amount() <5)
				to_chat(user, "<span class='notice'>Do okablowania [src] potrzebujesz przynajmniej pięciu kawałków kabla!</span>")
				return
			to_chat(user, "<span class='notice'>Zaczynasz okablowywać [src]...</span>")
			building = TRUE
			if(!do_after(user, 5 SECONDS, target=src) || !Adjacent(user))
				building = FALSE
				return
			W.use(5)
			to_chat(user, "<spawn class='notice'>Okablowujesz [src].</span>")
			build_state = LBS_APU_WIRE
			update_icon()
			building = FALSE
	else if(istype(W, /obj/item/airlock_painter)) //replace with an aircraft painter
		if(build_state == LBS_SECONDARY_BOLT) //check mode later
			to_chat(user, "<span class='notice'>Zaczynasz nakładać podkład na [src]...</span>")
			building = TRUE
			if(!do_after(user, 5 SECONDS, target=src) || !Adjacent(user))
				building = FALSE
				return
			to_chat(user, "<spawn class='notice'>Nakładasz podkład na [src].</span>")
			playsound(src, 'sound/effects/spray.ogg', 100, 1)
			build_state = LBS_PAINT_PRIMER
			update_icon()
			building = FALSE
		else if(build_state == LBS_PAINT_PRIMER) //check mode later
			to_chat(user, "<span class='notice'>Zaczynasz malować zdobienia na [src]...</span>")
			building = TRUE
			if(!do_after(user, 5 SECONDS, target=src) || !Adjacent(user))
				building = FALSE
				return
			to_chat(user, "<spawn class='notice'>Kończysz malować [src].</span>")
			playsound(src, 'sound/effects/spray.ogg', 100, 1)
			build_state = LBS_PAINT_DETAILING
			update_icon()
			building = FALSE

/obj/structure/fighter_frame/wrench_act(mob/user, obj/item/tool)
	. = FALSE
	switch(build_state)
		if(LBS_CHASSIS)
			to_chat(user, "<span class='notice'>Zaczynasz skręcać podwozie...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>Skręcasz podwozie.</span>")
				build_state = LBS_CHASSIS_BOLT
				update_icon()
				return TRUE
		if(LBS_CHASSIS_BOLT)
			to_chat(user, "<span class='notice'>Zaczynasz rozkręcać podwozie.</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>Rozkręcasz podwozie.</span>")
				build_state = LBS_CHASSIS
				update_icon()
				return TRUE
		if(LBS_ENGINE)
			to_chat(user, "<span class='notice'>Zaczynasz przykręcać silnik do podwozia...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>Przykręcasz silnik do podwozia.</span>")
				build_state = LBS_ENGINE_BOLT
				update_icon()
				return TRUE
		if(LBS_ENGINE_BOLT)
			to_chat(user, "<span class='notice'>Zaczynasz odkręcać silnik od podwozia...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>Odkręcasz silnik od podwozia.</span>")
				build_state = LBS_ENGINE
				update_icon()
				return TRUE
		if(LBS_FUEL_TANK)
			to_chat(user, "<span class='notice'>Zaczynasz przykręcać zbiornik paliwa do podwozia...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>Przykręcasz zbiornik paliwa do podwozia.</span>")
				build_state = LBS_FUEL_TANK_BOLT
				update_icon()
				return TRUE
		if(LBS_FUEL_TANK_BOLT)
			to_chat(user, "<span class='notice'>Zaczynasz odkręcać zbiornik paliwa od podwozia...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>Odkręcasz zbiornik paliwa od podwozia.</span>")
				build_state = LBS_FUEL_TANK
				update_icon()
				return TRUE
		if(LBS_COUNTERMEASURE_DISPENSER)
			to_chat(user, "<span class='notice'>Zaczynasz przykręcać dozownik środków przeciwdziałania do podwozia...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>Przykręcasz dozownik środków przeciwdziałania do podwozia.</span>")
				build_state = LBS_COUNTERMEASURE_DISPENSER_BOLT
				update_icon()
				return TRUE
		if(LBS_COUNTERMEASURE_DISPENSER_BOLT)
			to_chat(user, "<span class='notice'>Zaczynasz odkręcać dozownik środków przeciwdziałania od podwozia...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>Odkręcasz dozownik środków przeciwdziałania od podwozia.</span>")
				build_state = LBS_COUNTERMEASURE_DISPENSER
				update_icon()
				return TRUE
		if(LBS_ARMOUR_PLATING)
			to_chat(user, "<span class='notice'>Zaczynasz przykręcać płyty pancerza do podwozia...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>Przykręcasz płyty pancerza do podwozia.</span>")
				build_state = LBS_ARMOUR_PLATING_BOLT
				update_icon()
				return TRUE
		if(LBS_ARMOUR_PLATING_BOLT)
			to_chat(user, "<span class='notice'>Zaczynasz przykręcać płyty pancerza do podwozia...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>Przykręcasz płyty pancerza do podwozia.</span>")
				build_state = LBS_ARMOUR_PLATING_BOLT
				update_icon()
				return TRUE
		if(LBS_PRIMARY)
			to_chat(user, "<span class='notice'>Zaczynasz przykręcać lekkie działko do podwozia...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>Przykręcasz lekkie działko do podwozia.</span>")
				build_state = LBS_PRIMARY_BOLT
				update_icon()
				return TRUE
		if(LBS_PRIMARY_BOLT)
			to_chat(user, "<span class='notice'>Zaczynasz odkręcać lekkie działko od podwozia...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>Odkręcasz lekkie działko od podwozia.</span>")
				build_state = LBS_PRIMARY
				update_icon()
				return TRUE
		if(LBS_SECONDARY)
			to_chat(user, "<span class='notice'>Zaczynasz przykręcać wyrzutnię rakiet do podwozia...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>Przykręcasz wyrzutnię rakiet do podwozia.</span>")
				build_state = LBS_SECONDARY_BOLT
				update_icon()
				return TRUE
		if(LBS_SECONDARY_BOLT)
			to_chat(user, "<span class='notice'>Zaczynasz odkręcać wyrzutnię rakiet od podwozia...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>Odkręcasz wyrzutnię rakiet od podwozia.</span>")
				build_state = LBS_SECONDARY
				update_icon()
				return TRUE

/obj/structure/fighter_frame/screwdriver_act(mob/user, obj/item/tool)
	. = FALSE
	switch(build_state)
		if(LBS_APU_WIRE)
			to_chat(user, "<span class='notice'>Zaczynasz przykręcać APU do podwozia...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>Przykręcasz APU do podwozia.</span>")
				build_state = LBS_APU_SCREW
				update_icon()
				return TRUE
		if(LBS_APU_SCREW)
			to_chat(user, "<span class='notice'>Zaczynasz odkręcać APU od podwozia...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>Odkręcasz APU od podwozia.</span>")
				build_state = LBS_APU_WIRE
				update_icon()
				return TRUE
		if(LBS_AVIONICS_WIRE)
			to_chat(user, "<span class='notice'>Zaczynasz przykręcać awionikę do podwozia...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>Przykręcasz awionikę do podwozia.</span>")
				build_state = LBS_AVIONICS_SCREW
				update_icon()
				return TRUE
		if(LBS_AVIONICS_SCREW)
			to_chat(user, "<span class='notice'>Zaczynasz odkręcać awionikę od podwozia...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>Odkręcasz awionikę od podwozia.</span>")
				build_state = LBS_AVIONICS_WIRE
				update_icon()
				return TRUE
		if(LBS_TARGETING_SENSOR)
			to_chat(user, "<span class='notice'>Zaczynasz przykręcać czujnik celowniczy do podwozia...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>Przykręcasz czujnik celowniczy do podwozia.</span>")
				build_state = LBS_TARGETING_SENSOR_SCREW
				update_icon()
				return TRUE
		if(LBS_TARGETING_SENSOR_SCREW)
			to_chat(user, "<span class='notice'>Zaczynasz odkręcać czujnik celowniczy od podwozia...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>Odkręcasz czujnik celowniczy od podwozia.</span>")
				build_state = LBS_TARGETING_SENSOR
				update_icon()
				return TRUE

/obj/structure/fighter_frame/welder_act(mob/user, obj/item/tool)
	. = FALSE
	switch(build_state)
		if(LBS_CHASSIS_BOLT)
			to_chat(user, "<span class='notice'>Zaczynasz zespawywać podwozie...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>Zespawujesz podwozie.</span>")
				build_state = LBS_CHASSIS_WELD
				update_icon()
				return TRUE
		if(LBS_CHASSIS_WELD)
			to_chat(user, "<span class='notice'>Zaczynasz rozcinać podwozie.</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>Rozcinasz podwozie.</span>")
				build_state = LBS_CHASSIS_BOLT
				update_icon()
				return TRUE
		if(LBS_ARMOUR_PLATING_BOLT)
			to_chat(user, "<span class='notice'>Zaczynasz przyspawywać płyty pancerza do podwozia...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>Przyspawujesz płyty pancerza do podwozia.</span>")
				build_state = LBS_ARMOUR_PLATING_WELD
				update_icon()
				return TRUE
		if(LBS_ARMOUR_PLATING_WELD)
			to_chat(user, "<span class='notice'>Zaczynasz odcinać płyty pancerza od podwozia...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>Odcinasz płyty pancerza od podwozia.</span>")
				build_state = LBS_ARMOUR_PLATING_BOLT
				update_icon()
				return TRUE

/obj/structure/fighter_frame/wirecutter_act(mob/user, obj/item/tool)
	. = FALSE
	switch(build_state)
		if(LBS_APU_WIRE)
			to_chat(user, "<span class='notice'>Zaczynasz przecinać okablowanie w [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>Przecinasz okablowanie w [src].</span>")
				var/obj/item/stack/cable_coil/C = new (loc, 5)
				C.add_fingerprint(user)
				build_state = LBS_APU
				update_icon()
				return TRUE
		if(LBS_AVIONICS_WIRE)
			to_chat(user, "<span class='notice'>Zaczynasz przecinać okablowanie w [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>Przecinasz okablowanie w [src].</span>")
				var/obj/item/stack/cable_coil/C = new (loc, 5)
				C.add_fingerprint(user)
				build_state = LBS_AVIONICS
				update_icon()
				return TRUE

/obj/structure/fighter_frame/attack_hand(mob/user)
	.=..()
	if(build_state == LBS_PAINT_DETAILING)
		if(alert(user, "Finalize [src]?",name,"Yes","No") == "Yes" && Adjacent(user))
			var/obj/structure/overmap/overmap_check = get_overmap(src)
			if(overmap_check && istype(overmap_check, /obj/structure/overmap/small_craft))	//NO.
				to_chat(user, "<span class='boldwarning'>No Sabreception.</span>")
				return
			var/list/components = list()
			for(var/obj/item/fighter_component/FC in contents)
				components += FC.type
				qdel(FC)
			new output_path(get_turf(src), components)
			qdel(src)

/**
 * Force Finishes a Fighter frame.
 * * This is a Debug proc.
 */
/obj/structure/fighter_frame/proc/fuck()
	var/list/components = list(/obj/item/fighter_component/fuel_tank,
						/obj/item/fighter_component/avionics,
						/obj/item/fighter_component/apu,
						/obj/item/fighter_component/armour_plating,
						/obj/item/fighter_component/targeting_sensor,
						/obj/item/fighter_component/engine,
						/obj/item/fighter_component/countermeasure_dispenser,
						/obj/item/fighter_component/secondary/ordnance_launcher,
						/obj/item/fighter_component/oxygenator,
						/obj/item/fighter_component/canopy,
						/obj/item/fighter_component/docking_computer,
						/obj/item/fighter_component/battery,
						/obj/item/fighter_component/primary/cannon)
	new output_path(get_turf(src), components)
	qdel(src)

#undef LBS_CHASSIS
#undef LBS_CHASSIS_BOLT
#undef LBS_CHASSIS_WELD
#undef LBS_ENGINE
#undef LBS_ENGINE_BOLT
#undef LBS_APU
#undef LBS_APU_WIRE
#undef LBS_APU_SCREW
#undef LBS_FUEL_TANK
#undef LBS_FUEL_TANK_BOLT
#undef LBS_AVIONICS
#undef LBS_AVIONICS_WIRE
#undef LBS_AVIONICS_SCREW
#undef LBS_TARGETING_SENSOR
#undef LBS_TARGETING_SENSOR_SCREW
#undef LBS_COUNTERMEASURE_DISPENSER
#undef LBS_COUNTERMEASURE_DISPENSER_BOLT
#undef LBS_ARMOUR_PLATING
#undef LBS_ARMOUR_PLATING_BOLT
#undef LBS_ARMOUR_PLATING_WELD
#undef LBS_PRIMARY
#undef LBS_PRIMARY_BOLT
#undef LBS_SECONDARY
#undef LBS_SECONDARY_BOLT
#undef LBS_PAINT_PRIMER
#undef LBS_PAINT_DETAILING

//God fucking help you if you have to read this. This was such a mess to fix. I never want to see it again ~K
