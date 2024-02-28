/obj/item/nullrod
	/var/list/holy_weapons_aquila = list(
		/obj/item/clothing/neck/crucifix/krucyfiks_egzorcysty
	)

/obj/item/storage/box/holy/egzorcysta
	name = "Zestaw egzorcysty"

/obj/item/storage/box/holy/egzorcysta/PopulateContents()
	new /obj/item/gun/ballistic/shotgun/egzorcysta(src)
	new /obj/item/clothing/suit/jacket/leather(src)
	new /obj/item/clothing/under/pants/jeans(src)
	new /obj/item/clothing/shoes/aquila/laceup_brown(src)
	for(var/i in 1 to 4)
		// breneka żeby było śmiesznie, 4 w strzelbie i 4 zapasowe
		new /obj/item/ammo_casing/shotgun(src)

/obj/item/gun/ballistic/shotgun/egzorcysta
	name = "stara strzelba"
	desc = "Raczej nie masz na nią pozwolenia. Ale chuj, działalność gospodarcza też jest na lewo."
	spread_multiplier = 2
	spread = 65
	mag_type = /obj/item/ammo_box/magazine/internal/shot/slug

/obj/item/gun/ballistic/shotgun/egzorcysta/process_fire(atom/target, mob/living/carbon/user, message, params, zone_override, bonus_spread)
	if (istype(user, /mob/living/carbon))
		bonus_spread -= user.drunkenness
	. = ..()

/obj/item/clothing/neck/crucifix/krucyfiks_egzorcysty
	name = "krucyfiks"
	desc = "Jakby nie był Ci potrzebny to już dawno byś go przepił."
	icon = 'aquila/icons/obj/clothing/neck.dmi'
	worn_icon = 'aquila/icons/mob/neck.dmi'
	icon_state = "krucyfiks"

// Funkcjonalność jak null roda jeśli chodzi o blokowanie magii i usuwanie run kultystów itp.
/obj/item/clothing/neck/crucifix/krucyfix_egzorcysty/Initialize()
	. = ..()
	AddComponent(/datum/component/anti_magic, TRUE, TRUE, null, FALSE)
	AddComponent(/datum/component/effect_remover, \
	success_feedback = "Egzorcycmujesz %THEEFFECT swoim krucyfiksem.", \
	success_forcesay = "Dwie stówy się należy!", \
	on_clear_callback = CALLBACK(src, PROC_REF(on_cult_rune_removed)), \
	effects_we_clear = list(/obj/effect/rune, /obj/effect/heretic_rune))

/obj/item/clothing/neck/crucifix/krucyfix_egzorcysty/proc/on_cult_rune_removed(obj/effect/target, mob/living/user)
	if(!istype(target, /obj/effect/rune))
		return

	var/obj/effect/rune/target_rune = target
	if(target_rune.log_when_erased)
		log_game("[target_rune.cultist_name] rune erased by [key_name(user)] using a null rod.")
		message_admins("[ADMIN_LOOKUPFLW(user)] erased a [target_rune.cultist_name] rune with a null rod.")
	SSshuttle.shuttle_purchase_requirements_met[SHUTTLE_UNLOCK_NARNAR] = TRUE
