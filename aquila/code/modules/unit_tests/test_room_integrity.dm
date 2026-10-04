/// AQUILA - runs after the normal tests and checks that the shared test room (_maps/templates/unit_tests.dmm) is still whole.
/// Something that explodes or scrapes it during cleanup (e.g. deleting a sealed vehicle, see /obj/vehicle/sealed/Destroy) turns
/// the floor into plating or space a tick later, and then every following test fails in New(). This names the damaged turfs.
/datum/unit_test/test_room_integrity
	priority = TEST_DEFAULT + 1

/datum/unit_test/test_room_integrity/Run()
	var/obj/effect/landmark/unit_test_bottom_left/bottom_left = locate() in GLOB.landmarks_list
	var/obj/effect/landmark/unit_test_top_right/top_right = locate() in GLOB.landmarks_list
	if(!bottom_left?.loc || !top_right?.loc)
		return Fail("Test room landmarks are missing")
	var/list/damaged = list()
	// Plasteel floor inside, a ring of walls around it
	for(var/turf/T as anything in block(locate(bottom_left.x - 1, bottom_left.y - 1, bottom_left.z), locate(top_right.x + 1, top_right.y + 1, top_right.z)))
		var/edge = T.x < bottom_left.x || T.x > top_right.x || T.y < bottom_left.y || T.y > top_right.y
		var/expected = edge ? /turf/closed/wall : /turf/open/floor/plasteel
		if(T.type != expected || !istype(T.loc, /area/testroom))
			damaged += "[T.x],[T.y] is [T.type] in [T.loc.type], expected [expected]"
	if(length(damaged))
		Fail("The shared test room was damaged by an earlier test:\n[damaged.Join("\n")]")
