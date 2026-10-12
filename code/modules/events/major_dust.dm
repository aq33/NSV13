/datum/round_event_control/meteor_wave/major_dust
	name = "Major Space Dust"
	typepath = /datum/round_event/meteor_wave/major_dust
	weight = 10
	max_occurrences = 3

/datum/round_event/meteor_wave/major_dust
	wave_name = "space dust"

/datum/round_event/meteor_wave/major_dust/announce(fake)
	var/reason = pick(
		"Statek przelatuje przez chmurę odłamków, możliwe drobne uszkodzenia \
		zewnętrznych elementów i wyposażenia.",
		"Wydział Superbroni Nanotrasen testuje nowy prototyp: \
		[pick("field","projection","nova","super-colliding","reactive")] \
		[pick("cannon","artillery","tank","cruiser","\[REDACTED\]")], \
		możliwe niewielkie odłamki.",
		"Sąsiednia stacja rzuca w was kamieniami. (Może mają \
		dość waszych wiadomości.)")
	priority_announce(pick(reason), "Alarm kolizyjny", SSstation.announcer.get_rand_alert_sound())
