// aq33/AquilaStation#445 - Cowiek Maupa zamiast trupa w szafie

/datum/test_chamber_kit/pr_445
	name = "PR 445: Cowiek Maupa"
	pr = "aq33/AquilaStation#445"
	description = "Szafka elektryczna z cowiekiem maupą w środku (tak jak w evencie). Otwórz ją zapasowym ID kapitana albo rozwal - ma wyskoczyć z rykiem i zaatakować. \
		W walce czasem ryczy. Zabij go laserem: ma się przewrócić i mieć krzyżyki w oczach. Sam event: Admin -> Trigger Event -> Cowiek Maupa."
	items = list(
		/obj/structure/closet/secure_closet/engineering_electrical = 1,
		/obj/item/card/id/captains_spare = 1,
		/obj/item/gun/energy/laser/captain = 1,
	)

/datum/test_chamber_kit/pr_445/setup(list/spawned, list/turfs, turf/center, mob/user)
	var/obj/structure/closet/locker = locate(/obj/structure/closet/secure_closet/engineering_electrical) in spawned
	if(locker)
		new /mob/living/simple_animal/hostile/cowiek_maupa(locker)
