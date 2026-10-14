// AQUILA - zarobki załogi w rundzie, raport na koniec rundy i ranking zarobków między rundami (baza danych)
//
// Zarobek to każdy wpływ na konto gracza (wypłaty, zlecenia, sprzedaż, napiwki), z wyjątkiem:
// startowych wypłat, wpłat gotówki, przelewów od innych graczy i zwrotów - żeby nie dało się nabić rankingu przelewami.

/// Ile pozycji pokazuje ranking i raport rundy
#define EARNINGS_REPORT_SIZE 5
#define EARNINGS_LEADERBOARD_SIZE 10
/// Plik zapasowy rankingu, gdy baza danych nie działa
#define EARNINGS_FALLBACK_FILE "data/economy_leaderboard.json"

/datum/bank_account
	/// Ile konto zarobiło w tej rundzie
	var/round_income = 0
	/// Gdy > 0, wpływy nie liczą się jako zarobek (przelewy między graczami, wpłaty gotówki, zwroty)
	var/income_suppressed = 0
	/// ckey gracza, do którego należy konto
	var/owner_ckey
	/// Praca przy tworzeniu konta, do raportu
	var/owner_job

/datum/bank_account/adjust_money(amt)
	. = ..()
	if(. && amt > 0 && !income_suppressed)
		round_income += amt

/datum/bank_account/transfer_money(datum/bank_account/from, amount)
	// pieniądze od innego gracza to nie zarobek - inaczej dwie osoby nabijałyby sobie ranking przelewami
	var/from_player = from && !istype(from, /datum/bank_account/department)
	if(from_player)
		income_suppressed++
	. = ..()
	if(from_player)
		income_suppressed--

/datum/bank_account/payday(amt_of_paychecks, free = FALSE)
	// darmowe wypłaty to startowe pieniądze przy tworzeniu postaci
	if(free)
		income_suppressed++
	. = ..()
	if(free)
		income_suppressed--

/obj/item/card/id/insert_money(obj/item/I, mob/user)
	var/datum/bank_account/account = registered_account
	account?.income_suppressed++
	. = ..()
	account?.income_suppressed--

/obj/item/card/id/mass_insert_money(list/money, mob/user)
	var/datum/bank_account/account = registered_account
	account?.income_suppressed++
	. = ..()
	account?.income_suppressed--

/// Wpływ, który nie jest zarobkiem (np. zwrot pieniędzy)
/datum/bank_account/proc/refund_money(amount)
	income_suppressed++
	. = adjust_money(amount)
	income_suppressed--

/datum/job/after_spawn(mob/living/H, mob/M, latejoin = FALSE)
	. = ..()
	if(!ishuman(H) || !M?.ckey)
		return
	var/mob/living/carbon/human/human = H
	var/datum/bank_account/account = find_bank_account_by_id(human.account_id)
	if(account)
		account.owner_ckey = M.ckey
		account.owner_job = title

/proc/find_bank_account_by_id(account_id)
	if(!account_id)
		return null
	for(var/datum/bank_account/account as anything in SSeconomy.bank_accounts)
		if(account.account_id == account_id)
			return account
	return null

/// Ranking zarobków z poprzednich rund, odświeżany na starcie i na końcu rundy
GLOBAL_LIST_EMPTY(economy_leaderboard)
/// Czy zarobki tej rundy zostały już zapisane
GLOBAL_VAR_INIT(economy_earnings_saved, FALSE)
/// Czy ranking był już wczytany w tej rundzie (żeby czasownik nie pytał bazy przy każdym kliknięciu)
GLOBAL_VAR_INIT(economy_leaderboard_loaded, FALSE)

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
			`earned` INT UNSIGNED NOT NULL,
			`datetime` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
			PRIMARY KEY (`id`),
			KEY `idx_ckey` (`ckey`),
			KEY `idx_round` (`round_id`)
		) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
	"})
	var/success = query_create.Execute()
	qdel(query_create)
	return success

/// Konta graczy z tej rundy, posortowane od największego zarobku
/proc/economy_round_earners()
	var/list/earners = list()
	for(var/datum/bank_account/account as anything in SSeconomy.bank_accounts)
		if(account.round_income > 0)
			earners += account
	return sortTim(earners, GLOBAL_PROC_REF(cmp_bank_round_income))

/proc/cmp_bank_round_income(datum/bank_account/a, datum/bank_account/b)
	return b.round_income - a.round_income

/// Zapisuje zarobki rundy do bazy (albo pliku zapasowego); raz na rundę
/proc/economy_save_round_earnings()
	if(GLOB.economy_earnings_saved)
		return
	GLOB.economy_earnings_saved = TRUE
	var/list/earners = list()
	for(var/datum/bank_account/account as anything in economy_round_earners())
		if(account.owner_ckey)
			earners += account
	if(!length(earners))
		return

	if(economy_ensure_table() && GLOB.round_id)
		var/list/rows = list()
		for(var/datum/bank_account/account as anything in earners)
			rows += list(list(
				"round_id" = text2num(GLOB.round_id),
				"ckey" = account.owner_ckey,
				"character_name" = copytext(account.account_holder, 1, 64),
				"job" = copytext(account.owner_job || account.account_job?.title || "", 1, 64),
				"earned" = round(account.round_income),
			))
		SSdbcore.MassInsert(format_table_name("economy_earnings"), rows, warn = TRUE, async = FALSE)
		return

	// bez bazy: sumy per ckey w pliku
	var/list/totals = economy_load_fallback()
	for(var/datum/bank_account/account as anything in earners)
		var/list/entry = totals[account.owner_ckey] || list("total" = 0, "best" = 0, "rounds" = 0)
		entry["total"] += round(account.round_income)
		entry["best"] = max(entry["best"], round(account.round_income))
		entry["rounds"] += 1
		totals[account.owner_ckey] = entry
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
			SELECT ckey, SUM(earned) AS total, MAX(earned) AS best, COUNT(*) AS rounds
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

/proc/cmp_leaderboard_total(list/a, list/b)
	return b["total"] - a["total"]

/// Część raportu końca rundy: najwięcej zarabiający w rundzie i ranking wszech czasów
/datum/controller/subsystem/ticker/proc/economy_report()
	var/list/earners = economy_round_earners()
	economy_save_round_earnings()
	var/list/leaderboard = economy_load_leaderboard()
	if(!length(earners) && !length(leaderboard))
		return ""

	var/list/parts = list()
	parts += "<span class='header'>Najwięcej zarobili w tej rundzie:</span>"
	if(length(earners))
		for(var/i in 1 to min(EARNINGS_REPORT_SIZE, length(earners)))
			var/datum/bank_account/account = earners[i]
			var/job = account.owner_job || account.account_job?.title
			parts += "[i]. <b>[account.account_holder]</b>[job ? " ([job])" : ""] - [round(account.round_income)] kr"
	else
		parts += "Nikt niczego nie zarobił."

	if(length(leaderboard))
		parts += "<br><span class='header'>Ranking zarobków wszech czasów:</span>"
		var/position = 0
		for(var/list/entry as anything in leaderboard)
			position++
			parts += "[position]. <b>[entry["ckey"]]</b> - [entry["total"]] kr w [entry["rounds"]] rundach (rekord rundy: [entry["best"]] kr)"
	return "<div class='panel stationborder'>[parts.Join("<br>")]</div>"

/// Ranking zarobków dostępny w każdej chwili z zakładki OOC
/client/verb/economy_leaderboard()
	set name = "Ranking zarobków"
	set category = "OOC"
	set desc = "Pokazuje graczy, którzy zarobili najwięcej we wszystkich rundach."

	if(!GLOB.economy_leaderboard_loaded)
		economy_load_leaderboard()
	var/list/lines = list("<b>Ranking zarobków wszech czasów</b><br><br>")
	if(!length(GLOB.economy_leaderboard))
		lines += "Ranking jest jeszcze pusty."
	var/position = 0
	for(var/list/entry as anything in GLOB.economy_leaderboard)
		position++
		lines += "[position]. <b>[entry["ckey"]]</b> - [entry["total"]] kr w [entry["rounds"]] rundach (rekord rundy: [entry["best"]] kr)<br>"
	var/datum/browser/popup = new(usr, "economy_leaderboard", "Ranking zarobków", 450, 450)
	popup.set_content(lines.Join(""))
	popup.open()

#undef EARNINGS_REPORT_SIZE
#undef EARNINGS_LEADERBOARD_SIZE
#undef EARNINGS_FALLBACK_FILE
