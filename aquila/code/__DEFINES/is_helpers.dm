
#define is_infiltrator(M) (M.mind && M.mind.has_antag_datum(/datum/antagonist/infiltrator))
// is_traitor/is_blood_brother/is_nukeop from the Yog version don't exist here, so check the antag datums directly
#define is_syndicate(M) (isliving(M) && M.mind && (M.mind.has_antag_datum(/datum/antagonist/traitor) || M.mind.has_antag_datum(/datum/antagonist/brother) || M.mind.has_antag_datum(/datum/antagonist/nukeop) || M.mind.has_antag_datum(/datum/antagonist/incursion) || M.mind.has_antag_datum(/datum/antagonist/infiltrator)))
#define is_sinfuldemon(M) (M.mind && M.mind.has_antag_datum(/datum/antagonist/sinfuldemon))
