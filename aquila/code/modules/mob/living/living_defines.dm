/mob/living
	// how badly this guy needs to shit
	// if it reaches
	var/defecation = DEFECATION_NONE // set in Initialize to a random value up to DEFECATION_SOMEWHAT

	/// How hydrated the mob is.
	/// Lower = more thirsty. Higher = less thirsty.
	var/hydration = HYDRATION_LEVEL_START_MIN // randomized in Initialize()
