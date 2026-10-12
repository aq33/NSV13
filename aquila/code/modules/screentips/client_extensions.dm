// Port BeeStation/BeeStation-Hornet#11938
/// The atom that we are currently hovering over
/client/var/atom/hovered_atom = null
/// The atom that we are currently hovering over
/client/var/hover_queued = FALSE
/// The next in the queue for screentip processing
/client/var/client/screentip_next = null
/// Should extended screentips be shown? Set while the extended screentips key is held
/client/var/show_extended_screentips = FALSE

/client/Destroy()
	SSscreentips.on_client_disconnected(src)
	return ..()
