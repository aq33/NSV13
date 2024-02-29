
#define is_infiltrator(M) (M.mind && M.mind.has_antag_datum(/datum/antagonist/infiltrator))
#define is_syndicate(M) (istype(M, /mob/living) && is_traitor(M) || is_blood_brother(M) || is_nukeop(M) || is_infiltrator(M))
#define is_sinfuldemon(M) (M.mind && M.mind.has_antag_datum(/datum/antagonist/sinfuldemon))
