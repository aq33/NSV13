//lavaland_surface_syndicate_base1.dmm

/obj/machinery/vending/syndichem
	name = "\improper SyndiChem"
	desc = "A vending machine full of grenades and grenade accessories. Sponsored by DonkCo(tm)."
	req_access = list(ACCESS_SYNDICATE)
	products = list(/obj/item/stack/cable_coil = 5,
					/obj/item/assembly/igniter = 20,
					/obj/item/assembly/prox_sensor = 5,
					/obj/item/assembly/signaler = 5,
					/obj/item/assembly/timer = 5,
					/obj/item/assembly/voice = 5,
					/obj/item/assembly/health = 5,
					/obj/item/assembly/infra = 5,
					/obj/item/grenade/chem_grenade = 5,
	                /obj/item/grenade/chem_grenade/large = 5,
	                /obj/item/grenade/chem_grenade/pyro = 5,
	                /obj/item/grenade/chem_grenade/cryo = 5,
	                /obj/item/grenade/chem_grenade/adv_release = 5,
					/obj/item/reagent_containers/food/drinks/bottle/holywater = 1)
	product_slogans = "To nie piromania, jeśli ci za to płacą!;Czujesz to? Plazma, synu. Nic innego na świecie tak nie pachnie.;Uwielbiam zapach plazmy o poranku."
	resistance_flags = FIRE_PROOF

/obj/item/paper/fluff/ruins/syndicomms
	name = "paper - 'Communication Frequencies'"
	default_raw_text = "Witaj, agencie. Widzę, że obudziłeś się z kriogenicznego snu. Oznacza to, że albo nowy projekt kosmiczny Nanotrasen w pobliskim sektorze jest ukończony i działa, albo popielni wędrowcy zaatakowali naszą bazę. Zalecamy pozbyć się wszelkich szkodników i nie mylić ich z ludźmi.<br><br>Jeśli nie pamiętasz, jak wykonywać swoją pracę: potrzebujesz tylko sprzętu, który ci zapewniliśmy - maski kameleona, ID agenta i pobliskiego interkomu. Na pobliskiej półce znajdziesz nazwiska i stanowiska wszystkich obecnych pracowników Nanotrasen. Przypisz swojemu ID imię i stanowisko, a maska będzie naśladować głos osoby, pod którą się podszywasz.<br><br>Aha, jeszcze jedno. Oto lista częstotliwości, na których możesz trollować:<br><ul><li>145.9 - kanał ogólny</li><li>144.7 - prywatny kanał SI</li><li>135.9 - kanał ochrony</li><li>135.7 - kanał inżynierii</li><li>135.5 - kanał medyczny</li><li>135.3 - kanał dowództwa</li><li>135.1 - kanał naukowy</li><li>134.9 - kanał serwisu</li><li>134.7 - kanał zaopatrzenia</li><li>136.1 - kanał eksploracji</li>"
