#define STATION_RENAME_TIME_LIMIT 3000

/obj/item/station_charter
	name = "station charter"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "scroll2"
	desc = "An official document entrusting the governance of the station \
		and surrounding space to the Captain."
	var/used = FALSE
	var/name_type = "station"

	var/unlimited_uses = FALSE
	var/ignores_timeout = FALSE
	var/response_timer_id = null
	var/approval_time = 600

	var/static/regex/standard_station_regex

/obj/item/station_charter/Initialize(mapload)
	. = ..()
	if(!standard_station_regex)
		var/prefixes = jointext(GLOB.station_prefixes, "|")
		var/names = jointext(GLOB.station_names, "|")
		var/suffixes = jointext(GLOB.station_suffixes, "|")
		var/numerals = jointext(GLOB.station_numerals, "|")
		var/regexstr = "^(([prefixes]) )?(([names]) ?)([suffixes]) ([numerals])$"
		standard_station_regex = new(regexstr)

/obj/item/station_charter/attack_self(mob/living/user)
	if(used)
		to_chat(user, "[name_type] ma już nazwę.")
		return
	if(!ignores_timeout && (world.time-SSticker.round_start_time > STATION_RENAME_TIME_LIMIT)) //5 minutes
		to_chat(user, "Załoga już przyzwyczaiła się do zmiany. Lepiej teraz nie zmieniać nazwy ([name_type]).")
		return
	if(response_timer_id)
		to_chat(user, "Wciąż czekasz na zgodę pracodawców na proponowaną zmianę nazwy, lepiej na razie zaczekać.")
		return

	var/new_name = stripped_input(user, message="Jak chcesz nazwać [station_name()]? Pamiętaj, że szczególnie okropne nazwy mogą zostać odrzucone przez pracodawców, a nazwy w standardowym formacie zostaną zaakceptowane automatycznie.", max_length=MAX_CHARTER_LEN)

	if(response_timer_id)
		to_chat(user, "Wciąż czekasz na zgodę pracodawców na proponowaną zmianę nazwy, lepiej na razie zaczekać.")
		return

	if(!new_name)
		return

	if(CHAT_FILTER_CHECK(new_name))
		to_chat(user, "<span class='warning'>Twoja nazwa została automatycznie odrzucona. Zawiera zakazane słowa.</span>")
		return

	log_game("[key_name(user)] has proposed to name the station as \
		[new_name]")

	if(standard_station_regex.Find(new_name))
		to_chat(user, "Twoja nazwa została automatycznie zaakceptowana.")
		rename_station(new_name, user.name, user.real_name, key_name(user))
		return

	to_chat(user, "Twoja nazwa została wysłana do pracodawców do zatwierdzenia.")
	// Autoapproves after a certain time
	response_timer_id = addtimer(CALLBACK(src, PROC_REF(rename_station), new_name, user.name, user.real_name, key_name(user)), approval_time, TIMER_STOPPABLE)
	to_chat(GLOB.admins, "<span class='adminnotice'><b><font color=orange>CUSTOM STATION RENAME:</font></b>[ADMIN_LOOKUPFLW(user)] proposes to rename the [name_type] to [new_name] (will autoapprove in [DisplayTimeText(approval_time)]). [ADMIN_SMITE(user)] (<A HREF='byond://?_src_=holder;[HrefToken(TRUE)];reject_custom_name=[REF(src)]'>REJECT</A>) [ADMIN_CENTCOM_REPLY(user)]</span>")

/obj/item/station_charter/proc/reject_proposed(user)
	if(!user)
		return
	if(!response_timer_id)
		return
	var/turf/T = get_turf(src)
	T.visible_message("<span class='warning'>Proponowane zmiany znikają z [src]; wygląda na to, że zostały odrzucone.</span>")
	var/m = "[key_name(user)] has rejected the proposed station name."

	message_admins(m)
	log_admin(m)

	deltimer(response_timer_id)
	response_timer_id = null

/obj/item/station_charter/proc/rename_station(designation, uname, ureal_name, ukey)
	set_station_name(designation)
	minor_announce("[ureal_name] nadaje waszemu statkowi nazwę [station_name()]", "Captain's Charter", 0) //NSV13
	log_game("[ukey] has renamed the station as [station_name()].")

	name = "station charter for [station_name()]"
	desc = "An official document entrusting the governance of \
		[station_name()] and surrounding space to Captain [uname]."
	SSblackbox.record_feedback("text", "station_renames", 1, "[station_name()]")
	if(!unlimited_uses)
		used = TRUE

/obj/item/station_charter/admin
	unlimited_uses = TRUE
	ignores_timeout = TRUE


/obj/item/station_charter/flag
	name = "\improper Nanotrasen banner"
	icon = 'icons/obj/banner.dmi'
	name_type = "planet"
	icon_state = "banner"
	item_state = "banner"
	lefthand_file = 'icons/mob/inhands/equipment/banners_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/banners_righthand.dmi'
	desc = "A cunning device used to claim ownership of planets."
	w_class = 5
	force = 15

/obj/item/station_charter/flag/rename_station(designation, uname, ureal_name, ukey)
	set_station_name(designation)
	minor_announce("[ureal_name] nadaje planecie nazwę [station_name()]", "Captain's Banner", 0)
	log_game("[ukey] has renamed the planet as [station_name()].")
	name = "banner of [station_name()]"
	desc = "The banner bears the official coat of arms of Nanotrasen, signifying that [station_name()] has been claimed by Captain [uname] in the name of the company."
	SSblackbox.record_feedback("text", "station_renames", 1, "[station_name()]")
	if(!unlimited_uses)
		used = TRUE

#undef STATION_RENAME_TIME_LIMIT
