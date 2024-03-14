/obj/item/banner/polski_sztandar
	name = "polski sztandar"
	desc = "Za ojczyznę!"
	icon = 'aquila/icons/obj/banners.dmi'
	icon_state = "aq_banner_polska"
	item_state = "aq_banner_polska"
	lefthand_file = 'aquila/icons/mob/inhands/equipment/banners_lefthand.dmi'
	righthand_file = 'aquila/icons/mob/inhands/equipment/banners_righthand.dmi'
	job_loyalties = null
	warcry = "ZA OJCZYZNĘ!"

/obj/item/banner/polski_sztandar/mundane
	inspiration_available = FALSE

/datum/crafting_recipe/polski_sztandar
	name = "polski sztandar"
	result = /obj/item/banner/polski_sztandar/mundane
	time = 40
	reqs = list(/obj/item/stack/rods = 2,
				/obj/item/clothing/under/color/red,
				/obj/item/clothing/under/color/white)
	category = CAT_MISC
