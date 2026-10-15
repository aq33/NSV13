// AQUILA - port aq33/tgstation#564: zabawkowy chaingun na kulki dla mechów, szybszy disabler
/obj/item/mecha_parts/mecha_equipment/weapon/energy/disabler
	equip_cooldown = 3

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/BBchaingun
	name = "\improper LCG-4-BB \"Ratat\" BB Chaingun"
	desc = "Zabawkowy chaingun na kulki dla egzoszkieletów. Ale frajda!"
	icon = 'aquila/icons/mecha/mecha_equipment.dmi'
	icon_state = "mecha_toychaingun"
	equip_cooldown = 5
	projectile = /obj/item/projectile/bullet/reusable/foam_dart
	fire_sound = 'aquila/sound/weapons/chaingun.ogg'
	projectiles = 100
	projectile_energy_cost = 10
	projectiles_per_shot = 5
	variance = 5
	randomspread = 1
	projectile_delay = 1
	harmful = FALSE
