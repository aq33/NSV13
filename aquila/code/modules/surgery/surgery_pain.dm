// AQUILA - pain messages during surgery (tgstation#61252).
// A conscious patient feels each step and screams 30% of the time. Instead of a display_pain() call in every preop()
// the message is a var on the step and is shown when the step starts (play_preop_sound() runs right after preop()
// for every step). "%ZONE%" is replaced with the operated body part. Anesthesia (sleep) or morphine spares the patient.

/datum/surgery_step
	/// What a conscious patient feels when this step starts
	var/pain_message
	/// Robotic steps only make the patient feel something, no screaming
	var/mechanical_pain = FALSE

/datum/surgery_step/play_preop_sound(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	. = ..()
	if(pain_message)
		display_pain(target, replacetext(pain_message, "%ZONE%", strefa_pl(target_zone)), mechanical_pain)

/datum/surgery_step/proc/display_pain(mob/living/target, message, mechanical = FALSE)
	if(target.stat >= UNCONSCIOUS || HAS_TRAIT(target, TRAIT_FAKEDEATH))
		return
	if(target.reagents?.has_reagent(/datum/reagent/medicine/morphine))
		return
	to_chat(target, "<span class='userdanger'>[message]</span>")
	if(!mechanical && prob(30))
		target.emote("scream")

// Basic steps
/datum/surgery_step/incise
	pain_message = "Czujesz kłujący ból (%ZONE%)!"
/datum/surgery_step/clamp_bleeders
	pain_message = "Czujesz uszczypnięcie, krwawienie (%ZONE%) słabnie."
/datum/surgery_step/retract_skin
	pain_message = "Piekący ból rozlewa się (%ZONE%), gdy ktoś odciąga ci skórę!"
/datum/surgery_step/close
	pain_message = "Coś przypala ci ciało (%ZONE%)!"
/datum/surgery_step/saw
	pain_message = "Czujesz, jakby coś w środku pękło (%ZONE%)!"
/datum/surgery_step/drill
	pain_message = "Przeszywa cię straszny, świdrujący ból (%ZONE%)!"
/datum/surgery_step/incise_heart
	pain_message = "Czujesz potworny ból w sercu, prawie mdlejesz!"
/datum/surgery_step/coronary_bypass
	pain_message = "Ból w klatce piersiowej jest nie do zniesienia!"
/datum/surgery_step/manipulate_organs
	pain_message = "Czujesz, jak ktoś grzebie ci w środku (%ZONE%)!"
/datum/surgery_step/extract_organ
	pain_message = "Czujesz, jak coś wyrywają ci z ciała (%ZONE%)!"
/datum/surgery_step/handle_cavity
	pain_message = "Coś wciskają ci do środka (%ZONE%)!"
/datum/surgery_step/remove_object
	pain_message = "Coś wyciągają ci z ciała (%ZONE%), boli jak diabli!"
/datum/surgery_step/extract_implant
	pain_message = "Czujesz ostry ból (%ZONE%)!"
/datum/surgery_step/insert_pill
	pain_message = "Coś wciskają ci w ząb!"
/datum/surgery_step/sever_limb
	pain_message = "Czujesz makabryczny ból w stawie (%ZONE%)!"
/datum/surgery_step/replace_limb
	pain_message = "Czujesz straszny ból (%ZONE%)!"
/datum/surgery_step/add_prosthetic
	pain_message = "Czujesz straszny ból (%ZONE%)!"
/datum/surgery_step/fix_brain
	pain_message = "Głowa pęka ci z niewyobrażalnego bólu!"
/datum/surgery_step/lobotomize
	pain_message = "Głowa pęka ci z niewyobrażalnego bólu!"
/datum/surgery_step/bionecrosis
	pain_message = "Głowa pęka ci z niewyobrażalnego bólu!"
/datum/surgery_step/pacify
	pain_message = "Głowa pęka ci z niewyobrażalnego bólu!"
/datum/surgery_step/brainwash
	pain_message = "Głowa pulsuje ci straszliwym bólem!"
/datum/surgery_step/fix_eyes
	pain_message = "Czujesz kłujący ból w oczach!"
/datum/surgery_step/fix_ears
	pain_message = "Czujesz kłujący ból w uszach!"
/datum/surgery_step/gastrectomy
	pain_message = "Czujesz straszne dźgnięcie w brzuchu!"
/datum/surgery_step/hepatectomy
	pain_message = "Brzuch pali cię okropnym, kłującym bólem!"
/datum/surgery_step/lobectomy
	pain_message = "Czujesz ostre dźgnięcie w klatce, brakuje ci tchu!"
/datum/surgery_step/stomach_pump
	pain_message = "Czujesz okropne chlupotanie w żołądku, zaraz zwymiotujesz!"
/datum/surgery_step/filter_blood
	pain_message = "Czujesz pulsujący ból w klatce piersiowej!"
/datum/surgery_step/cut_fat
	pain_message = "Czujesz dźgnięcie (%ZONE%)!"
/datum/surgery_step/remove_fat
	pain_message = "Czujesz dziwnie bezbolesne szarpanie za tłuszcz."
/datum/surgery_step/reshape_face
	pain_message = "Czujesz tnący ból na twarzy!"
/datum/surgery_step/reshape_genitals
	pain_message = "Czujesz tnący ból w kroczu!"
/datum/surgery_step/heal
	pain_message = "Rany (%ZONE%) pieką jak diabli!"
/datum/surgery_step/dissection
	pain_message = "Czujesz, jak coś cię kroi na kawałki (%ZONE%)!"
/datum/surgery_step/viral_bond
	pain_message = "Piekące gorąco rozlewa ci się po klatce piersiowej!"
/datum/surgery_step/fold_cortex
	pain_message = "Głowa pulsuje ci makabrycznym bólem, ledwo to znosisz!"
/datum/surgery_step/imprint_cortex
	pain_message = "Głowa pulsuje ci makabrycznym bólem, ledwo to znosisz!"
/datum/surgery_step/reshape_ligaments
	pain_message = "Kończyny palą cię silnym bólem!"
/datum/surgery_step/reinforce_ligaments
	pain_message = "Kończyny palą cię silnym bólem!"
/datum/surgery_step/muscled_veins
	pain_message = "Całe ciało płonie ci z bólu!"
/datum/surgery_step/thread_veins
	pain_message = "Całe ciało płonie ci z bólu!"
/datum/surgery_step/ground_nerves
	pain_message = "Całe ciało ci drętwieje!"
/datum/surgery_step/splice_nerves
	pain_message = "Całe ciało ci drętwieje!"
/datum/surgery_step/gland_insert
	pain_message = "Coś wciskają ci do klatki piersiowej!"
/datum/surgery_step/aq_set_bone
	pain_message = "Kość (%ZONE%) przeskakuje z obrzydliwym chrupnięciem!"
/datum/surgery_step/aq_debride
	pain_message = "Ktoś wycina ci spaloną skórę (%ZONE%)!"

// Robotic steps: sensation only
/datum/surgery_step/mechanic_open
	pain_message = "Czujesz, jak %ZONE% drętwieje, gdy odkręcają panel czuciowy."
	mechanical_pain = TRUE
/datum/surgery_step/mechanic_close
	pain_message = "Czucie powoli wraca (%ZONE%), gdy panel zostaje przykręcony."
	mechanical_pain = TRUE
/datum/surgery_step/prepare_electronics
	pain_message = "Czujesz lekkie brzęczenie (%ZONE%), gdy elektronika się restartuje."
	mechanical_pain = TRUE
/datum/surgery_step/mechanic_unwrench
	pain_message = "Coś szarpie (%ZONE%), gdy śruby się luzują."
	mechanical_pain = TRUE
/datum/surgery_step/mechanic_wrench
	pain_message = "Coś szarpie (%ZONE%), gdy śruby się dokręcają."
	mechanical_pain = TRUE
/datum/surgery_step/open_hatch
	pain_message = "Ostatnie resztki czucia znikają (%ZONE%), gdy otwierają klapę."
	mechanical_pain = TRUE
