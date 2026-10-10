/obj/item/paper/contract/infernal/pleasure
	name = "paper- contract of pleasure"
	contractType = CONTRACT_PLEASURE

/obj/item/paper/contract/infernal/pleasure/update_text(signature = "____________", blood = 0)
	default_raw_text = "<center><B>Umowa rozkoszy</B></center><BR><BR><BR>Ja, [target], przy zdrowych zmysłach, niniejszym dobrowolnie oddaję swoją duszę piekłom za pośrednictwem piekielnego agenta [devil_datum.truename] w zamian za bezgraniczną rozkosz. Rozumiem, że po mojej śmierci moja dusza trafi do piekła, a mojego ciała nie będzie można wskrzesić, sklonować ani w inny sposób przywrócić do życia. Rozumiem też, że mój mózg nie będzie mógł zostać użyty w MMI.<BR><BR><BR>Podpisano, "
	if(blood)
		default_raw_text += "<font face=\"Nyala\" color=#600A0A size=6><i>[signature]</i></font>"
	else
		default_raw_text += "<i>[signature]</i>"

/obj/item/paper/contract/infernal/pleasure/fulfillContract(mob/living/user = target.current, blood = 0)
	if(!istype(user) || !user.mind)
		return -1
	user.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/touch/sex(null))
	return ..()
