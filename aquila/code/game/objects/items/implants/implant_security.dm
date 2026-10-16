/obj/item/implant/security_down
	name = "security officer down implant"
	activated = 0

/obj/item/implant/security_down/get_data()
	var/dat = {"<b>Specyfikacja implantu:</b><BR><b>Nazwa:</b> Lokalny system powiadamiania o śmierci funkcjonariusza. <BR>Wydaje słyszalny dźwięk, gdy ustają funkcje życiowe użytkownika.<BR><b>Żywotność:</b> aktywuje się po śmierci.<BR>
				"}
	return dat

// Reaguje na faktyczną śmierć, a nie na emotkę *deathgasp, którą da się wywołać ręcznie
/obj/item/implant/security_down/implant(mob/living/target, mob/user, silent = FALSE, force = FALSE)
	. = ..()
	if(.)
		RegisterSignal(target, COMSIG_MOB_DEATH, PROC_REF(on_owner_death))

/obj/item/implant/security_down/removed(mob/living/source, silent = FALSE, special = 0)
	. = ..()
	if(.)
		UnregisterSignal(source, COMSIG_MOB_DEATH)

/obj/item/implant/security_down/proc/on_owner_death(mob/living/source, gibbed)
	SIGNAL_HANDLER
	playsound(source, 'aquila/sound/misc/security_down.ogg', 50, 0)

/obj/item/implanter/security_down
	name = "implanter (security officer down)"
	imp_type = /obj/item/implant/security_down

/obj/item/implantcase/security_down
	name = "implant case - 'security officer down'"
	desc = "A glass case containing a security officer down implant. Emits a loud burst of static if the implanted person dies."
	imp_type = /obj/item/implant/security_down
