/**
 * Puts looping client-time timers back into the queue once fire() has cut the invoked timers off the front.
 *
 * Reinserting them while still iterating clienttime_timers changed timeToRun of an entry that was still in the
 * invoked part of the list, so the list stopped being sorted. A later BINARY_INSERT could then land before the
 * loop index and the final Cut() left a spent, deleted timer at the front ("Invalid timer ... NO CALLBACK").
 */
/datum/controller/subsystem/timer/proc/requeue_clienttime_loop_timers(list/loop_timers)
	for(var/datum/timedevent/ctime_timer as anything in loop_timers)
		if(QDELETED(ctime_timer)) // deleted by its own callback (or another one in the same pass)
			continue
		ctime_timer.spent = 0
		ctime_timer.timeToRun = REALTIMEOFDAY + ctime_timer.wait
		BINARY_INSERT(ctime_timer, clienttime_timers, /datum/timedevent, ctime_timer, timeToRun, COMPARE_KEY)
