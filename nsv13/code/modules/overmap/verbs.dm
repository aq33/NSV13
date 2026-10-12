//Holds all the overmap ship panel verbs

/obj/structure/overmap/proc/verb_check(mob/user, require_pilot = TRUE)
	if(!user)
		user = usr
	if(user != pilot)
		to_chat(user, "<span class='notice'>Stąd nie sięgasz do sterów</span>")
		return FALSE
	return !user.incapacitated() && isliving(user)

//Control Scheme Verbs
/obj/structure/overmap/verb/toggle_brakes()
	set name = "Toggle Handbrake"
	set category = "Ship"
	set src = usr.loc

	if(!verb_check() || !can_brake())
		return
	brakes = !brakes
	to_chat(usr, "<span class='notice'>[brakes ? "Włączasz" : "Zwalniasz"] hamulce.</span>")

/obj/structure/overmap/verb/toggle_inertia()
	set name = "Toggle IAS"
	set category = "Ship"
	set src = usr.loc

	if(!verb_check() || !can_brake())
		return
	if(!toggle_dampeners(user = usr))
		return
	to_chat(usr, "<span class='notice'>System wspomagania bezwładnościowego [inertial_dampeners ? "WŁĄCZONY" : "WYŁĄCZONY"].</span>")

/obj/structure/overmap/verb/toggle_move_mode()
	set name = "Change movement mode"
	set category = "Ship"
	set src = usr.loc

	if(!verb_check())
		return
	move_by_mouse = !move_by_mouse
	to_chat(usr, "<span class='notice'>[move_by_mouse ? "Włączasz" : "Wyłączasz"] laserowy system sterowania ruchem [src].</span>")

//General Overmap Verbs
/obj/structure/overmap/verb/show_dradis()
	set name = "Show DRADIS"
	set category = "Ship"
	set src = usr.loc

	if(!verb_check() || !dradis)
		return
	dradis.attack_hand(usr)

/obj/structure/overmap/verb/cycle_firemode(mob/M)
	set name = "Switch firemode"
	set category = "Ship"
	set src = usr.loc
	var/checking_target = M ? M : usr
	if(checking_target != gunner && checking_target != pilot)
		return
	increment_selected_weapon(checking_target)

//Small Craft Specific Verbs
/obj/structure/overmap/small_craft/verb/show_control_panel()
	set name = "Show control panel"
	set category = "Ship"
	set src = usr.loc

	if(!verb_check())
		return
	ui_interact(usr)

/obj/structure/overmap/small_craft/verb/change_name()
	set name = "Change name"
	set category = "Ship"
	set src = usr.loc

	if(!verb_check())
		return
	var/new_name = stripped_input(usr, message="Jak chcesz nazwać swój myśliwiec? Pamiętaj, że szczególnie okropne nazwy mogą zostać odrzucone przez pracodawców.", max_length=MAX_CHARTER_LEN)
	if(!new_name || length(new_name) <= 0)
		return
	message_admins("[key_name_admin(usr)] renamed a fighter to [new_name] [ADMIN_LOOKUPFLW(src)].")
	name = new_name

/obj/structure/overmap/verb/toggle_safety()
	set name = "Toggle Gun Safeties"
	set category = "Ship"
	set src = usr.loc

	if(!verb_check() || !can_change_safeties())
		return
	weapon_safety = !weapon_safety
	to_chat(usr, "<span class='notice'>[weapon_safety ? "Włączasz" : "Wyłączasz"] zabezpieczenia broni [src].</span>")

/obj/structure/overmap/small_craft/verb/countermeasure()
	set name = "Deploy Countermeasures"
	set category = "Ship"
	set src = usr.loc
	set waitfor = FALSE

	if(!verb_check())
		return

	fire_countermeasure()

//Large Craft Specifc Verbs
/obj/structure/overmap/verb/show_tactical()
	set name = "Show Tactical"
	set category = "Ship"
	set src = usr.loc

	if(!verb_check() || !tactical)
		return

	tactical.ui_interact(usr)
