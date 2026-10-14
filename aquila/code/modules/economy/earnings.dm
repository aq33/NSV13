// AQUILA - raport najbogatszych na koniec rundy i ranking między rundami (baza danych)
//
// Liczy się saldo konta z karty ID na koniec rundy, na tych samych zasadach co aquilosy:
// tylko żywa postać, która się ewakuowała (patrz /client/proc/get_endround_bank_account).

/// Ile pozycji pokazuje raport rundy i ranking
#define EARNINGS_REPORT_SIZE 5
#define EARNINGS_LEADERBOARD_SIZE 10
/// Plik zapasowy rankingu, gdy baza danych nie działa
#define EARNINGS_FALLBACK_FILE "data/economy_leaderboard.json"

/// Wyniki tej rundy: lista list("ckey", "name", "job", "balance")
GLOBAL_LIST_EMPTY(economy_round_results)
/// Ranking z poprzednich rund, wczytany z bazy albo pliku
GLOBAL_LIST_EMPTY(economy_leaderboard)
/// Czy wyniki tej rundy zostały już zapisane
GLOBAL_VAR_INIT(economy_results_saved, FALSE)
/// Czy ranking był już wczytany w tej rundzie (żeby czasownik nie pytał bazy przy każdym kliknięciu)
GLOBAL_VAR_INIT(economy_leaderboard_loaded, FALSE)

/// Zapisuje saldo z karty gracza na koniec rundy (wołane z declare_completion obok aquilosów).
/// Zapisuje każdego gracza z postacią; do rankingu (counted) liczą się tylko ewakuowani, jak przy aquilosach.
/client/proc/record_endround_balance()
	var/datum/mind/player_mind = mob?.mind
	var/mob/living/carbon/human/body = player_mind?.current
	if(!ishuman(body))
		return
	var/datum/bank_account/account = body.get_bank_account() || find_bank_account_by_id(body.account_id)
	if(!account)
		return
	for(var/list/result as anything in GLOB.economy_round_results)
		if(result["ckey"] == ckey)
			return
	var/counted = (get_endround_bank_account() == account)
	GLOB.economy_round_results += list(list(
		"ckey" = ckey,
		"name" = account.account_holder,
		"job" = player_mind.assigned_role || account.account_job?.title || "",
		"balance" = round(account.account_balance),
		"counted" = counted,
		"alive" = body.stat != DEAD,
	))

/proc/find_bank_account_by_id(account_id)
	if(!account_id)
		return null
	for(var/datum/bank_account/account as anything in SSeconomy.bank_accounts)
		if(account.account_id == account_id)
			return account
	return null

/// Wyniki rundy, które liczą się do rankingu
/proc/economy_counted_results()
	. = list()
	for(var/list/result as anything in GLOB.economy_round_results)
		if(result["counted"] && result["balance"] > 0)
			. += list(result)

/proc/cmp_economy_result_balance(list/a, list/b)
	return b["balance"] - a["balance"]

/proc/cmp_leaderboard_total(list/a, list/b)
	return b["total"] - a["total"]

/// Tworzy tabelę rankingu, jeśli jej nie ma (schemat jest też w SQL/beestation_schema.sql)
/proc/economy_ensure_table()
	if(!SSdbcore.Connect())
		return FALSE
	var/datum/DBQuery/query_create = SSdbcore.NewQuery({"
		CREATE TABLE IF NOT EXISTS [format_table_name("economy_earnings")] (
			`id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
			`round_id` INT UNSIGNED NOT NULL,
			`ckey` VARCHAR(32) NOT NULL,
			`character_name` VARCHAR(64) NOT NULL,
			`job` VARCHAR(64) NOT NULL,
			`balance` INT UNSIGNED NOT NULL,
			`datetime` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
			PRIMARY KEY (`id`),
			KEY `idx_ckey` (`ckey`),
			KEY `idx_round` (`round_id`)
		) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
	"})
	var/success = query_create.Execute()
	qdel(query_create)
	return success

/// Zapisuje wyniki rundy do bazy (albo pliku zapasowego); raz na rundę
/proc/economy_save_round_results()
	if(GLOB.economy_results_saved)
		return
	GLOB.economy_results_saved = TRUE
	var/list/counted_results = economy_counted_results()
	if(!length(counted_results))
		return

	if(GLOB.round_id && economy_ensure_table())
		var/list/rows = list()
		for(var/list/result as anything in counted_results)
			rows += list(list(
				"round_id" = text2num(GLOB.round_id),
				"ckey" = result["ckey"],
				"character_name" = copytext(result["name"], 1, 64),
				"job" = copytext(result["job"], 1, 64),
				"balance" = result["balance"],
			))
		SSdbcore.MassInsert(format_table_name("economy_earnings"), rows, warn = TRUE, async = FALSE)
		return

	// bez bazy: sumy per ckey w pliku
	var/list/totals = economy_load_fallback()
	for(var/list/result as anything in counted_results)
		var/list/entry = totals[result["ckey"]] || list("total" = 0, "best" = 0, "rounds" = 0)
		entry["total"] += result["balance"]
		entry["best"] = max(entry["best"], result["balance"])
		entry["rounds"] += 1
		totals[result["ckey"]] = entry
	rustg_file_write(json_encode(totals), EARNINGS_FALLBACK_FILE)

/proc/economy_load_fallback()
	if(!fexists(EARNINGS_FALLBACK_FILE))
		return list()
	var/list/data = json_decode(rustg_file_read(EARNINGS_FALLBACK_FILE))
	return islist(data) ? data : list()

/// Wczytuje ranking: lista list("ckey", "total", "best", "rounds"), od największej sumy
/proc/economy_load_leaderboard()
	var/list/leaderboard = list()
	if(SSdbcore.Connect() && economy_ensure_table())
		var/datum/DBQuery/query_leaderboard = SSdbcore.NewQuery({"
			SELECT ckey, SUM(balance) AS total, MAX(balance) AS best, COUNT(*) AS rounds
			FROM [format_table_name("economy_earnings")]
			GROUP BY ckey
			ORDER BY total DESC
			LIMIT [EARNINGS_LEADERBOARD_SIZE]
		"})
		if(query_leaderboard.Execute())
			while(query_leaderboard.NextRow())
				leaderboard += list(list(
					"ckey" = query_leaderboard.item[1],
					"total" = text2num(query_leaderboard.item[2]),
					"best" = text2num(query_leaderboard.item[3]),
					"rounds" = text2num(query_leaderboard.item[4]),
				))
		qdel(query_leaderboard)
	else
		var/list/totals = economy_load_fallback()
		for(var/player_ckey in totals)
			var/list/entry = totals[player_ckey]
			leaderboard += list(list("ckey" = player_ckey, "total" = entry["total"], "best" = entry["best"], "rounds" = entry["rounds"]))
		leaderboard = sortTim(leaderboard, GLOBAL_PROC_REF(cmp_leaderboard_total))
		if(length(leaderboard) > EARNINGS_LEADERBOARD_SIZE)
			leaderboard.Cut(EARNINGS_LEADERBOARD_SIZE + 1)
	GLOB.economy_leaderboard = leaderboard
	GLOB.economy_leaderboard_loaded = TRUE
	return leaderboard

/// Linijki rankingu wszech czasów
/proc/economy_leaderboard_lines()
	var/list/lines = list()
	var/position = 0
	for(var/list/entry as anything in GLOB.economy_leaderboard)
		position++
		lines += "[position]. <b>[entry["ckey"]]</b> - [entry["total"]] kr w [entry["rounds"]] rundach (rekord rundy: [entry["best"]] kr)"
	return lines

/// Część raportu końca rundy (wersja HTML do pliku poprzedniego raportu): saldo wszystkich graczy i ranking
/datum/controller/subsystem/ticker/proc/economy_report()
	var/list/results = sortTim(GLOB.economy_round_results.Copy(), GLOBAL_PROC_REF(cmp_economy_result_balance))
	economy_save_round_results()
	economy_load_leaderboard()
	if(!length(results) && !length(GLOB.economy_leaderboard))
		return ""

	var/list/parts = list()
	parts += "<span class='header'>Zarobki w tej rundzie (saldo z karty):</span>"
	if(length(results))
		var/position = 0
		for(var/list/result as anything in results)
			position++
			parts += "[position]. <b>[result["ckey"]]</b> jako [result["name"]][result["job"] ? " ([result["job"]])" : ""] - [result["balance"]] kr[result["counted"] ? "" : " <i>(nie liczy się do rankingu)</i>"]"
	else
		parts += "Nikt nie miał pieniędzy na koncie."

	if(length(GLOB.economy_leaderboard))
		parts += "<br><span class='header'>Ranking zarobków wszech czasów:</span>"
		parts += economy_leaderboard_lines()
	return "<div class='panel stationborder'>[parts.Join("<br>")]</div>"

/// Ranking zarobków dostępny w każdej chwili z zakładki OOC
/client/verb/economy_leaderboard()
	set name = "Ranking zarobków"
	set category = "OOC"
	set desc = "Pokazuje graczy, którzy zarobili najwięcej we wszystkich rundach."

	if(!GLOB.economy_leaderboard_loaded)
		economy_load_leaderboard()
	GLOB.economy_leaderboard_ui.ui_interact(mob)

#undef EARNINGS_REPORT_SIZE
#undef EARNINGS_LEADERBOARD_SIZE
#undef EARNINGS_FALLBACK_FILE
