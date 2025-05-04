/client/proc/process_aquila_endround_metacoin()
	if(!mob)    return
	var/mob/M = mob
	if(M.mind && !isnewplayer(M))
		if(M.stat != DEAD && !isbrain(M))
			if(EMERGENCY_ESCAPED_OR_ENDGAMED)
				if(M.onCentCom() || M.onSyndieBase())
					if(CONFIG_GET(flag/allow_endround_bank_balance_metacoin_conversion) && ishuman(M))
						var/mob/living/carbon/human/H = M
						var/datum/bank_account/banking_details = H.get_bank_account()
						var/coeff = CONFIG_GET(number/bank_balance_metacoin_conversion_coefficient)
						if(!coeff)
							coeff = 0
						if(banking_details)
							inc_metabalance(FLOOR(banking_details.account_balance * coeff, 1), reason="Bank account balance converted to [CONFIG_GET(string/metacurrency_name)]\s.")
							if(banking_details.welfare)
								inc_metabalance(2 * PAYCHECK_WELFARE, reason="Bank account balance conversion welfare bonus.")
