// AQUILA - ślady prochu (GSR)
// Strzał z broni prochowej zostawia kaliber na broni, na dłoni strzelca (albo na rękawicach lub rękawach skafandra)
// i z szansą GSR_FLOOR_CHANCE na podłodze pod nim. Zmywa je zwykłe mycie, a same słabną i znikają z czasem.

/obj/item/ammo_casing
	/// Czy strzał tą amunicją zostawia ślady prochu i sygnaturę balistyczną
	var/leaves_residue = TRUE

/obj/item/ammo_casing/energy
	leaves_residue = FALSE
/obj/item/ammo_casing/magic
	leaves_residue = FALSE
/obj/item/ammo_casing/caseless/arrow
	leaves_residue = FALSE
/obj/item/ammo_casing/caseless/foam_dart
	leaves_residue = FALSE
/obj/item/ammo_casing/caseless/gumball
	leaves_residue = FALSE
/obj/item/ammo_casing/caseless/laser
	leaves_residue = FALSE
/obj/item/ammo_casing/caseless/mime
	leaves_residue = FALSE
/obj/item/ammo_casing/caseless/pimple
	leaves_residue = FALSE
/obj/item/ammo_casing/caseless/rocket
	leaves_residue = FALSE
/obj/item/ammo_casing/chemgun
	leaves_residue = FALSE
/obj/item/ammo_casing/dnainjector
	leaves_residue = FALSE
/obj/item/ammo_casing/syringegun
	leaves_residue = FALSE
/obj/item/ammo_casing/bee
	leaves_residue = FALSE
/obj/item/ammo_casing/tazer
	leaves_residue = FALSE
/obj/item/ammo_casing/shotgun/dart
	leaves_residue = FALSE
/obj/item/ammo_casing/shotgun/ion
	leaves_residue = FALSE
/obj/item/ammo_casing/shotgun/laserslug
	leaves_residue = FALSE
/obj/item/ammo_casing/shotgun/pulseslug
	leaves_residue = FALSE
// działa okrętowe NSV
/obj/item/ammo_casing/anti_air
	leaves_residue = FALSE
/obj/item/ammo_casing/flak
	leaves_residue = FALSE
/obj/item/ammo_casing/heavy_cannon
	leaves_residue = FALSE
/obj/item/ammo_casing/light_cannon
	leaves_residue = FALSE
/obj/item/ammo_casing/pdc
	leaves_residue = FALSE

/obj/item/ammo_casing/fire_casing(atom/target, mob/living/user, params, distro, quiet, zone_override, spread, spread_mult = 1, atom/fired_from)
	. = ..()
	if(. && leaves_residue)
		leave_gunshot_residue(user, fired_from)

/obj/item/ammo_casing/proc/leave_gunshot_residue(mob/living/user, atom/fired_from)
	var/residue = caliber || "nieznany"
	if(isitem(fired_from))
		fired_from.add_gunshot_residue(residue)
	if(!istype(user) || (isitem(fired_from) && fired_from.loc != user))
		return
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		// Najbardziej zewnętrzna warstwa na dłoniach: skafander, potem rękawice
		if(H.wear_suit && (H.wear_suit.body_parts_covered & HANDS))
			H.wear_suit.add_gunshot_residue(residue)
		else if(H.gloves)
			H.gloves.add_gunshot_residue(residue)
		else
			H.add_gunshot_residue(residue)
	else
		user.add_gunshot_residue(residue)
	if(prob(GSR_FLOOR_CHANCE))
		var/turf/T = get_turf(user)
		if(isopenturf(T) && !isspaceturf(T))
			T.add_gunshot_residue(residue)
