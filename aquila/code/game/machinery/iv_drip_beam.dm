// AQUILA - port of tgstation#88217: an attached IV drip shows a tube to the patient and pulls them a little closer.
// The core IV drip still tracks `attached`; every attach/detach path calls update_icon(), which syncs the attachment here.

/obj/machinery/iv_drip
	/// Tube and tug effects for whatever `attached` is
	var/datum/iv_drip_attachment/attachment

/obj/machinery/iv_drip/update_icon()
	. = ..()
	if(attached && attachment?.attached_to != attached)
		QDEL_NULL(attachment)
		attachment = new(src, attached)
	else if(!attached && attachment)
		QDEL_NULL(attachment)

/obj/machinery/iv_drip/Destroy()
	QDEL_NULL(attachment)
	return ..()

/// Information and effects about where an IV drip is attached to.
/// Lifetime is managed by the iv_drip, an iv_drip_attachment should never outlive its iv_drip.
/datum/iv_drip_attachment
	var/obj/machinery/iv_drip/iv_drip
	var/atom/attached_to
	var/datum/beam/beam
	var/datum/component/tug_towards/tug_to_me

/datum/iv_drip_attachment/New(obj/machinery/iv_drip/iv_drip, atom/attached_to)
	src.iv_drip = iv_drip
	src.attached_to = attached_to

	tug_to_me = attached_to.AddComponent(/datum/component/tug_towards, iv_drip)
	beam = iv_drip.Beam(attached_to, icon_state = "1-full", time = INFINITY, maxdistance = 3, beam_type = /obj/effect/ebeam/iv_tube)

/datum/iv_drip_attachment/Destroy(force)
	tug_to_me?.remove_tug_target(iv_drip)
	tug_to_me = null
	iv_drip = null
	attached_to = null
	QDEL_NULL(beam)
	return ..()

/// The IV tube between the drip and the patient
/obj/effect/ebeam/iv_tube
	color = COLOR_SILVER
	layer = BELOW_MOB_LAYER
