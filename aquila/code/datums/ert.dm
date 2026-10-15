// AQUILA - port BeeStation/BeeStation-Hornet#11415 (ERT: admin w briefingu, doświadczony lider, losowe nazwiska, nowe składy)

/datum/ert
	/// TRUE daje członkom nazwy w stylu "[rola] [losowe nazwisko]"
	var/random_names = TRUE
	/// TRUE spawnuje admina tworzącego ERT (jeśli jest duchem) jako oficera odprawy
	var/spawn_admin = FALSE
	/// TRUE wybiera lidera spośród najbardziej doświadczonych zgłoszonych graczy
	var/leader_experience = TRUE

/datum/ert/centcom_official
	random_names = FALSE
	leader_experience = FALSE

/datum/ert/intern
	random_names = FALSE

/datum/ert/intern/unarmed
	roles = list(/datum/antagonist/ert/intern/unarmed)
	leader_role = /datum/antagonist/ert/intern/leader/unarmed
	rename_team = "Unarmed Horde of Interns"

/datum/ert/bounty_hunters
	roles = list(/datum/antagonist/ert/bounty_armor, /datum/antagonist/ert/bounty_hook, /datum/antagonist/ert/bounty_synth)
	leader_role = /datum/antagonist/ert/bounty_armor
	teamsize = 3
	opendoors = FALSE
	rename_team = "Bounty Hunters"
	mission = "Assist the station in catching perps, dead or alive."
	polldesc = "a Centcom-hired bounty hunting gang"
	random_names = FALSE
