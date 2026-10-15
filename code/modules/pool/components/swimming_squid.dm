/datum/component/swimming/squid
	slowdown = 0.7

/datum/component/swimming/squid/enter_pool()
	to_chat(parent, "<span class='notice'>Czujesz się swobodnie w swoim naturalnym środowisku!</span>")

/datum/component/swimming/squid/is_drowning(mob/living/victim)
	return FALSE
