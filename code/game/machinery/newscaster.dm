GLOBAL_DATUM_INIT(news_network, /datum/newscaster/feed_network, new)
GLOBAL_LIST_EMPTY(allCasters)

/datum/newscaster

/datum/newscaster/feed_comment
	var/author = ""
	var/body = ""
	var/time_stamp = ""

/datum/newscaster/feed_message
	var/author =""
	var/body =""
	var/list/authorCensorTime = list()
	var/list/bodyCensorTime = list()
	var/is_admin_message = 0
	var/icon/img = null
	var/time_stamp = ""
	var/list/datum/newscaster/feed_comment/comments = list()
	var/locked = FALSE
	var/caption = ""
	var/creationTime
	var/authorCensor
	var/bodyCensor
	var/photo_file

/datum/newscaster/feed_message/proc/returnAuthor(censor)
	if(censor == -1)
		censor = authorCensor
	var/txt = "[GLOB.news_network.redactedText]"
	if(!censor)
		txt = author
	return txt

/datum/newscaster/feed_message/proc/returnBody(censor)
	if(censor == -1)
		censor = bodyCensor
	var/txt = "[GLOB.news_network.redactedText]"
	if(!censor)
		txt = body
	return txt

/datum/newscaster/feed_message/proc/toggleCensorAuthor()
	if(authorCensor)
		authorCensorTime.Add(GLOB.news_network.lastAction*-1)
	else
		authorCensorTime.Add(GLOB.news_network.lastAction)
	authorCensor = !authorCensor
	GLOB.news_network.lastAction ++

/datum/newscaster/feed_message/proc/toggleCensorBody()
	if(bodyCensor)
		bodyCensorTime.Add(GLOB.news_network.lastAction*-1)
	else
		bodyCensorTime.Add(GLOB.news_network.lastAction)
	bodyCensor = !bodyCensor
	GLOB.news_network.lastAction ++

/datum/newscaster/feed_channel
	var/channel_name = ""
	var/list/datum/newscaster/feed_message/messages = list()
	var/locked = FALSE
	var/author = ""
	var/censored = 0
	var/list/authorCensorTime = list()
	var/list/DclassCensorTime = list()
	var/authorCensor
	var/is_admin_channel = 0

/datum/newscaster/feed_channel/proc/returnAuthor(censor)
	if(censor == -1)
		censor = authorCensor
	var/txt = "[GLOB.news_network.redactedText]"
	if(!censor)
		txt = author
	return txt

/datum/newscaster/feed_channel/proc/toggleCensorDclass()
	if(censored)
		DclassCensorTime.Add(GLOB.news_network.lastAction*-1)
	else
		DclassCensorTime.Add(GLOB.news_network.lastAction)
	censored = !censored
	GLOB.news_network.lastAction ++

/datum/newscaster/feed_channel/proc/toggleCensorAuthor()
	if(authorCensor)
		authorCensorTime.Add(GLOB.news_network.lastAction*-1)
	else
		authorCensorTime.Add(GLOB.news_network.lastAction)
	authorCensor = !authorCensor
	GLOB.news_network.lastAction ++

/datum/newscaster/wanted_message
	var/active
	var/criminal
	var/body
	var/scannedUser
	var/isAdminMsg
	var/icon/img
	var/photo_file

/datum/newscaster/feed_network
	var/list/datum/newscaster/feed_channel/network_channels = list()
	var/datum/newscaster/wanted_message/wanted_issue
	var/lastAction
	var/redactedText = "\[REDACTED\]"

/datum/newscaster/feed_network/New()
	CreateFeedChannel("Station Announcements", "SS13", 1)
	wanted_issue = new /datum/newscaster/wanted_message

/datum/newscaster/feed_network/proc/CreateFeedChannel(channel_name, author, locked, adminChannel = 0)
	var/datum/newscaster/feed_channel/newChannel = new /datum/newscaster/feed_channel
	newChannel.channel_name = channel_name
	newChannel.author = author
	newChannel.locked = locked
	newChannel.is_admin_channel = adminChannel
	network_channels += newChannel

/datum/newscaster/feed_network/proc/SubmitArticle(msg, author, channel_name, datum/picture/picture, adminMessage = 0, allow_comments = 1)
	var/datum/newscaster/feed_message/newMsg = new /datum/newscaster/feed_message
	newMsg.author = author
	newMsg.body = msg
	newMsg.time_stamp = "[station_time_timestamp()]"
	newMsg.is_admin_message = adminMessage
	newMsg.locked = !allow_comments
	if(picture)
		newMsg.img = picture.picture_image
		newMsg.caption = picture.caption
		newMsg.photo_file = save_photo(picture.picture_image)
	for(var/datum/newscaster/feed_channel/FC in network_channels)
		if(FC.channel_name == channel_name)
			FC.messages += newMsg
			break
	for(var/obj/machinery/newscaster/NEWSCASTER in GLOB.allCasters)
		NEWSCASTER.newsAlert(channel_name)
	lastAction ++
	newMsg.creationTime = lastAction

/datum/newscaster/feed_network/proc/submitWanted(criminal, body, scanned_user, datum/picture/picture, adminMsg = 0, newMessage = 0)
	wanted_issue.active = 1
	wanted_issue.criminal = criminal
	wanted_issue.body = body
	wanted_issue.scannedUser = scanned_user
	wanted_issue.isAdminMsg = adminMsg
	if(picture)
		wanted_issue.img = picture.picture_image
		wanted_issue.photo_file = save_photo(picture.picture_image)
	if(newMessage)
		for(var/obj/machinery/newscaster/N in GLOB.allCasters)
			N.newsAlert()
			N.update_icon()

/datum/newscaster/feed_network/proc/deleteWanted()
	wanted_issue.active = 0
	wanted_issue.criminal = null
	wanted_issue.body = null
	wanted_issue.scannedUser = null
	wanted_issue.img = null
	for(var/obj/machinery/newscaster/NEWSCASTER in GLOB.allCasters)
		NEWSCASTER.update_icon()

/datum/newscaster/feed_network/proc/save_photo(icon/photo)
	var/photo_file = copytext_char(md5("/icon[photo]"), 1, 6)
	if(!fexists("[GLOB.log_directory]/photos/[photo_file].png"))
		//Clean up repeated frames
		var/icon/clean = new /icon()
		clean.Insert(photo, "", SOUTH, 1, 0)
		fcopy(clean, "[GLOB.log_directory]/photos/[photo_file].png")
	return photo_file

/obj/item/wallframe/newscaster
	name = "newscaster frame"
	desc = "Used to build newscasters, just secure to the wall."
	icon_state = "newscaster"
	materials = list(/datum/material/iron=14000, /datum/material/glass=8000)
	result_path = /obj/machinery/newscaster


/obj/machinery/newscaster
	name = "newscaster"
	desc = "A standard Nanotrasen-licensed newsfeed handler for use in commercial space stations. All the news you absolutely have no use for, in one place!"
	icon = 'icons/obj/terminals.dmi'
	icon_state = "newscaster_normal"
	verb_say = "pika"
	verb_ask = "pika"
	verb_exclaim = "pika"
	armor = list("melee" = 50, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 30, "stamina" = 0)
	max_integrity = 200
	integrity_failure = 50
	layer = ABOVE_WINDOW_LAYER
	var/screen = 0
	var/paper_remaining = 15
	var/securityCaster = 0
	var/unit_no = 0
	var/alert_delay = 500
	var/alert = FALSE
	var/scanned_user = "Unknown"
	var/msg = ""
	var/datum/picture/picture
	var/channel_name = ""
	var/c_locked=0
	var/datum/newscaster/feed_channel/viewing_channel = null
	var/allow_comments = 1
	light_color = LIGHT_COLOR_GREEN
	light_power = 1.5

/obj/machinery/newscaster/security_unit
	name = "security newscaster"
	securityCaster = 1

/obj/machinery/newscaster/Initialize(mapload, ndir, building)
	. = ..()
	if(building)
		setDir(ndir)
		pixel_x = (dir & 3)? 0 : (dir == 4 ? -32 : 32)
		pixel_y = (dir & 3)? (dir ==1 ? -32 : 32) : 0

	GLOB.allCasters += src
	unit_no = GLOB.allCasters.len
	update_icon()

/obj/machinery/newscaster/Destroy()
	GLOB.allCasters -= src
	viewing_channel = null
	picture = null
	return ..()

/obj/machinery/newscaster/update_icon()
	cut_overlays()
	if(machine_stat & (NOPOWER|BROKEN))
		icon_state = "newscaster_off"
		set_light(0)
	else
		if(GLOB.news_network.wanted_issue.active)
			icon_state = "newscaster_wanted"
		else
			icon_state = "newscaster_normal"
			if(alert)
				add_overlay("newscaster_alert")
		set_light(2, l_color = "#00aeffff") // AQ EDIT oryginał: set_light(1)
	var/hp_percent = obj_integrity * 100 /max_integrity
	switch(hp_percent)
		if(75 to 100)
			return
		if(50 to 75)
			add_overlay("crack1")
		if(25 to 50)
			add_overlay("crack2")
		else
			add_overlay("crack3")


/obj/machinery/newscaster/power_change()
	if(machine_stat & BROKEN)
		return
	if(powered())
		set_machine_stat(machine_stat & ~NOPOWER)
		update_icon()
	else
		spawn(rand(0, 15))
			set_machine_stat(machine_stat | NOPOWER)
			update_icon()

/obj/machinery/newscaster/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir)
	. = ..()
	update_icon()

/obj/machinery/newscaster/ui_interact(mob/user)
	. = ..()
	if(ishuman(user) || issilicon(user))
		var/mob/living/human_or_robot_user = user
		var/dat
		scan_user(human_or_robot_user)
		switch(screen)
			if(0)
				dat += "Witaj w jednostce newscastera nr [unit_no].<BR> Interfejs i sieci informacyjne działają."
				dat += "<BR><FONT SIZE=1>Własność Nanotrasen Inc</FONT>"
				if(GLOB.news_network.wanted_issue.active)
					dat+= "<HR><A href='byond://?src=[REF(src)];view_wanted=1'>Przeczytaj list gończy</A>"
				dat+= "<HR><BR><A href='byond://?src=[REF(src)];create_channel=1'>Utwórz kanał</A>"
				dat+= "<BR><A href='byond://?src=[REF(src)];view=1'>Przeglądaj kanały</A>"
				dat+= "<BR><A href='byond://?src=[REF(src)];create_feed_story=1'>Dodaj nowy artykuł</A>"
				dat+= "<BR><A href='byond://?src=[REF(src)];menu_paper=1'>Drukuj gazetę</A>"
				dat+= "<BR><A href='byond://?src=[REF(src)];refresh=1'>Zeskanuj ponownie użytkownika</A>"
				dat+= "<BR><BR><A href='byond://?src=[REF(human_or_robot_user)];mach_close=newscaster_main'>Exit</A>"
				if(securityCaster)
					var/wanted_already = 0
					if(GLOB.news_network.wanted_issue.active)
						wanted_already = 1
					dat+="<HR><B>Funkcje bezpieczeństwa kanałów:</B><BR>"
					dat+="<BR><A href='byond://?src=[REF(src)];menu_wanted=1'>[(wanted_already) ? ("Zarządzaj listem") : ("Opublikuj list")] \"gończym\"</A>"
					dat+="<BR><A href='byond://?src=[REF(src)];menu_censor_story=1'>Cenzuruj artykuły</A>"
					dat+="<BR><A href='byond://?src=[REF(src)];menu_censor_channel=1'>Oznacz kanał zakazem D Nanotrasen</A>"
				dat+="<BR><HR>Newscaster rozpoznaje cię jako: <FONT COLOR='green'>[scanned_user]</FONT>"
			if(1)
				dat+= "Kanały stacji<HR>"
				if(!length(GLOB.news_network.network_channels) )
					dat+="<I>Nie znaleziono aktywnych kanałów...</I>"
				else
					for(var/datum/newscaster/feed_channel/CHANNEL in GLOB.news_network.network_channels)
						if(CHANNEL.is_admin_channel)
							dat+="<B><FONT style='BACKGROUND-COLOR: LightGreen '><A href='byond://?src=[REF(src)];show_channel=[REF(CHANNEL)]'>[CHANNEL.channel_name]</A></FONT></B><BR>"
						else
							dat+="<B><A href='byond://?src=[REF(src)];show_channel=[REF(CHANNEL)]'>[CHANNEL.channel_name]</A> [(CHANNEL.censored) ? ("<FONT COLOR='red'>***</FONT>") : ""]<BR></B>"
				dat+="<BR><HR><A href='byond://?src=[REF(src)];refresh=1'>Refresh</A>"
				dat+="<BR><A href='byond://?src=[REF(src)];setScreen=[0]'>Back</A>"
			if(2)
				dat+="Tworzenie nowego kanału..."
				dat+="<HR><B><A href='byond://?src=[REF(src)];set_channel_name=1'>Nazwa kanału</A>:</B> [channel_name]<BR>"
				dat+="<B>Autor kanału:</B> <FONT COLOR='green'>[scanned_user]</FONT><BR>"
				dat+="<B><A href='byond://?src=[REF(src)];set_channel_lock=1'>Przyjmuje publiczne artykuły</A>:</B> [(c_locked) ? ("NIE") : ("TAK")]<BR><BR>"
				dat+="<BR><A href='byond://?src=[REF(src)];submit_new_channel=1'>Wyślij</A><BR><BR><A href='byond://?src=[REF(src)];setScreen=[0]'>Anuluj</A><BR>"
			if(3)
				dat+="Tworzenie nowego artykułu..."
				dat+="<HR><B><A href='byond://?src=[REF(src)];set_channel_receiving=1'>Kanał docelowy</A>:</B> [channel_name]<BR>"
				dat+="<B>Autor artykułu:</B> <FONT COLOR='green'>[scanned_user]</FONT><BR>"
				dat+="<B><A href='byond://?src=[REF(src)];set_new_message=1'>Treść artykułu</A>:</B> <BR><font face=\"[PEN_FONT]\">[parsemarkdown(msg, user)]</font><BR>"
				dat+="<B><A href='byond://?src=[REF(src)];set_attachment=1'>Załącz zdjęcie</A>:</B>  [(picture ? "Załączono zdjęcie" : "Brak zdjęcia")]</BR>"
				dat+="<B><A href='byond://?src=[REF(src)];set_comment=1'>Comments [allow_comments ? "Enabled" : "Disabled"]</A></B><BR>"
				dat+="<BR><A href='byond://?src=[REF(src)];submit_new_message=1'>Wyślij</A><BR><BR><A href='byond://?src=[REF(src)];setScreen=[0]'>Anuluj</A><BR>"
			if(4)
				dat+="Artykuł został pomyślnie wysłany do kanału [channel_name].<BR><BR>"
				dat+="<BR><A href='byond://?src=[REF(src)];setScreen=[0]'>Return</A><BR>"
			if(5)
				dat+="Kanał [channel_name] został pomyślnie utworzony.<BR><BR>"
				dat+="<BR><A href='byond://?src=[REF(src)];setScreen=[0]'>Return</A><BR>"
			if(6)
				dat+="<B><FONT COLOR='maroon'>BŁĄD: nie udało się wysłać artykułu do sieci.</B></FONT><HR><BR>"
				if(channel_name=="")
					dat+="<FONT COLOR='maroon'>Nieprawidłowa nazwa kanału docelowego.</FONT><BR>"
				if(scanned_user=="Unknown")
					dat+="<FONT COLOR='maroon'>Autor kanału niezweryfikowany.</FONT><BR>"
				if(msg == "" || msg == "\[REDACTED\]")
					dat+="<FONT COLOR='maroon'>Nieprawidłowa treść artykułu.</FONT><BR>"
				dat+="<BR><A href='byond://?src=[REF(src)];setScreen=[3]'>Return</A><BR>"
			if(7)
				dat+="<B><FONT COLOR='maroon'>BŁĄD: nie udało się wysłać kanału do sieci.</B></FONT><HR><BR>"
				var/list/existing_authors = list()
				for(var/datum/newscaster/feed_channel/FC in GLOB.news_network.network_channels)
					if(FC.authorCensor)
						existing_authors += GLOB.news_network.redactedText
					else
						existing_authors += FC.author
				if(scanned_user in existing_authors)
					dat+="<FONT COLOR='maroon'>Już istnieje kanał pod twoim nazwiskiem.</FONT><BR>"
				if(channel_name=="" || channel_name == "\[REDACTED\]")
					dat+="<FONT COLOR='maroon'>Nieprawidłowa nazwa kanału.</FONT><BR>"
				var/check = 0
				for(var/datum/newscaster/feed_channel/FC in GLOB.news_network.network_channels)
					if(FC.channel_name == channel_name)
						check = 1
						break
				if(check)
					dat+="<FONT COLOR='maroon'>Nazwa kanału jest już zajęta.</FONT><BR>"
				if(scanned_user=="Unknown")
					dat+="<FONT COLOR='maroon'>Autor kanału niezweryfikowany.</FONT><BR>"
				dat+="<BR><A href='byond://?src=[REF(src)];setScreen=[2]'>Return</A><BR>"
			if(8)
				var/total_num=length(GLOB.news_network.network_channels)
				var/active_num=total_num
				var/message_num=0
				for(var/datum/newscaster/feed_channel/FC in GLOB.news_network.network_channels)
					if(!FC.censored)
						message_num += length(FC.messages)
					else
						active_num--
				dat+="Sieć obsługuje łącznie [total_num] kanałów, z czego [active_num] aktywnych, oraz łącznie [message_num] artykułów."
				dat+="<BR><BR><B>Pozostały płynny papier:</B> [(paper_remaining) *100 ] cm^3"
				dat+="<BR><BR><A href='byond://?src=[REF(src)];print_paper=[0]'>Drukuj papier</A>"
				dat+="<BR><A href='byond://?src=[REF(src)];setScreen=[0]'>Cancel</A>"
			if(9)
				dat+="<B>[viewing_channel.channel_name]: </B><FONT SIZE=1>\[created by: <FONT COLOR='maroon'>[viewing_channel.returnAuthor(-1)]</FONT>\]</FONT><HR>"
				if(viewing_channel.censored)
					dat+="<FONT COLOR='red'><B>UWAGA: </B></FONT>Ten kanał uznano za zagrażający dobru stacji i oznaczono zakazem D Nanotrasen.<BR>"
					dat+="Póki obowiązuje zakaz D, nie można dodawać kolejnych artykułów.</FONT><BR><BR>"
				else
					if( !length(viewing_channel.messages) )
						dat+="<I>W kanale nie znaleziono artykułów...</I><BR>"
					else
						var/i = 0
						for(var/datum/newscaster/feed_message/MESSAGE in viewing_channel.messages)
							i++
							dat+="-[MESSAGE.returnBody(-1)] <BR>"
							if(MESSAGE.img)
								usr << browse_rsc(MESSAGE.img, "tmp_photo[i].png")
								dat+="<img src='tmp_photo[i].png' width = '180'><BR>"
								if(MESSAGE.caption)
									dat+="[MESSAGE.caption]<BR>"
								dat+="<BR>"
							dat+="<FONT SIZE=1>\[Story by <FONT COLOR='maroon'>[MESSAGE.returnAuthor(-1)] </FONT>\] - ([MESSAGE.time_stamp])</FONT><BR>"
							dat+="<b><font size=1>[MESSAGE.comments.len] comment[MESSAGE.comments.len > 1 ? "s" : ""]</font></b><br>"
							for(var/datum/newscaster/feed_comment/comment in MESSAGE.comments)
								dat+="<font size=1><small>[comment.body]</font><br><font size=1><small><small><small>[comment.author] [comment.time_stamp]</small></small></small></small></font><br>"
							if(MESSAGE.locked)
								dat+="<b>Komentarze zablokowane</b><br>"
							else
								dat+="<a href='byond://?src=[REF(src)];new_comment=[REF(MESSAGE)]'>Comment</a><br>"
				dat+="<BR><HR><A href='byond://?src=[REF(src)];refresh=1'>Refresh</A>"
				dat+="<BR><A href='byond://?src=[REF(src)];setScreen=[1]'>Back</A>"
			if(10)
				dat+="<B>Narzędzie cenzury kanałów Nanotrasen</B><BR>"
				dat+="<FONT SIZE=1>UWAGA: ze względu na naturę kanałów całkowite usunięcie artykułu nie jest możliwe.<BR>"
				dat+="Pamiętaj, że użytkownicy próbujący zobaczyć ocenzurowany artykuł zobaczą nad nim tag \[UTAJNIONO\].</FONT>"
				dat+="<HR>Wybierz kanał, z którego chcesz pobrać artykuły:<BR>"
				if(!length(GLOB.news_network.network_channels))
					dat+="<I>Nie znaleziono aktywnych kanałów...</I><BR>"
				else
					for(var/datum/newscaster/feed_channel/CHANNEL in GLOB.news_network.network_channels)
						dat+="<A href='byond://?src=[REF(src)];pick_censor_channel=[REF(CHANNEL)]'>[CHANNEL.channel_name]</A> [(CHANNEL.censored) ? ("<FONT COLOR='red'>***</FONT>") : ""]<BR>"
				dat+="<BR><A href='byond://?src=[REF(src)];setScreen=[0]'>Cancel</A>"
			if(11)
				dat+="<B>Obsługa zakazów D Nanotrasen</B><HR>"
				dat+="<FONT SIZE=1>Zakaz D nakłada się na kanał, jeśli odpowiedzialna władza uzna go za szkodliwy dla"
				dat+="morale, integralności lub dyscypliny stacji. Zakaz D uniemożliwia komukolwiek aktualizowanie kanału, nie usuwając"
				dat+="artykułów, które może w danej chwili zawierać. Możesz w każdej chwili znieść zakaz D, jeśli masz wymagany dostęp.</FONT><HR>"
				if(!length(GLOB.news_network.network_channels))
					dat+="<I>Nie znaleziono aktywnych kanałów...</I><BR>"
				else
					for(var/datum/newscaster/feed_channel/CHANNEL in GLOB.news_network.network_channels)
						dat+="<A href='byond://?src=[REF(src)];pick_d_notice=[REF(CHANNEL)]'>[CHANNEL.channel_name]</A> [(CHANNEL.censored) ? ("<FONT COLOR='red'>***</FONT>") : ""]<BR>"
				dat+="<BR><A href='byond://?src=[REF(src)];setScreen=[0]'>Back</A>"
			if(12)
				dat+="<B>[viewing_channel.channel_name]: </B><FONT SIZE=1>\[ created by: <FONT COLOR='maroon'>[viewing_channel.returnAuthor(-1)]</FONT> \]</FONT><BR>"
				dat+="<FONT SIZE=2><A href='byond://?src=[REF(src)];censor_channel_author=[REF(viewing_channel)]'>[(viewing_channel.authorCensor) ? ("Undo Author censorship") : ("Censor channel Author")]</A></FONT><HR>"
				if(!length(viewing_channel.messages))
					dat+="<I>W kanale nie znaleziono artykułów...</I><BR>"
				else
					for(var/datum/newscaster/feed_message/MESSAGE in viewing_channel.messages)
						dat+="-[MESSAGE.returnBody(-1)] <BR><FONT SIZE=1>\[Story by <FONT COLOR='maroon'>[MESSAGE.returnAuthor(-1)]</FONT>\]</FONT><BR>"
						dat+="<FONT SIZE=2><A href='byond://?src=[REF(src)];censor_channel_story_body=[REF(MESSAGE)]'>[(MESSAGE.bodyCensor) ? ("Undo story censorship") : ("Censor story")]</A>  -  <A href='byond://?src=[REF(src)];censor_channel_story_author=[REF(MESSAGE)]'>[(MESSAGE.authorCensor) ? ("Undo Author Censorship") : ("Censor message Author")]</A></FONT><BR>"
						dat+="[MESSAGE.comments.len] comment[MESSAGE.comments.len > 1 ? "s" : ""]: <a href='byond://?src=[REF(src)];lock_comment=[REF(MESSAGE)]'>[MESSAGE.locked ? "Unlock" : "Lock"]</a><br>"
						for(var/datum/newscaster/feed_comment/comment in MESSAGE.comments)
							dat+="[comment.body] <a href='byond://?src=[REF(src)];del_comment=[REF(comment)];del_comment_msg=[REF(MESSAGE)]'>X</a><br><font size=1>[comment.author] [comment.time_stamp]</font><br>"
				dat+="<BR><A href='byond://?src=[REF(src)];setScreen=[10]'>Back</A>"
			if(13)
				dat+="<B>[viewing_channel.channel_name]: </B><FONT SIZE=1>\[ created by: <FONT COLOR='maroon'>[viewing_channel.returnAuthor(-1)]</FONT> \]</FONT><BR>"
				dat+="Poniżej wiadomości z kanału. Jeśli uznasz je za niebezpieczne dla stacji, możesz <A href='byond://?src=[REF(src)];toggle_d_notice=[REF(viewing_channel)]'>nałożyć na kanał zakaz D</A>.<HR>"
				if(viewing_channel.censored)
					dat+="<FONT COLOR='red'><B>UWAGA: </B></FONT>Ten kanał uznano za zagrażający dobru stacji i oznaczono zakazem D Nanotrasen.<BR>"
					dat+="Póki obowiązuje zakaz D, nie można dodawać kolejnych artykułów.</FONT><BR><BR>"
				else
					if(!length(viewing_channel.messages))
						dat+="<I>W kanale nie znaleziono artykułów...</I><BR>"
					else
						for(var/datum/newscaster/feed_message/MESSAGE in viewing_channel.messages)
							dat+="-[MESSAGE.returnBody(-1)] <BR><FONT SIZE=1>\[Story by <FONT COLOR='maroon'>[MESSAGE.returnAuthor(-1)]</FONT>\]</FONT><BR>"
				dat+="<BR><A href='byond://?src=[REF(src)];setScreen=[11]'>Back</A>"
			if(14)
				dat+="<B>Obsługa listów gończych:</B>"
				var/wanted_already = 0
				var/end_param = 1
				if(GLOB.news_network.wanted_issue.active)
					wanted_already = 1
					end_param = 2
				if(wanted_already)
					dat+="<FONT SIZE=2><BR><I>List gończy jest już w obiegu. Możesz go poniżej edytować lub anulować.</FONT></I>"
				dat+="<HR>"
				dat+="<A href='byond://?src=[REF(src)];set_wanted_name=1'>Imię przestępcy</A>: [channel_name] <BR>"
				dat+="<A href='byond://?src=[REF(src)];set_wanted_desc=1'>Description</A>: [msg] <BR>"
				dat+="<A href='byond://?src=[REF(src)];set_attachment=1'>Załącz zdjęcie</A>: [(picture ? "Załączono zdjęcie" : "Brak zdjęcia")]</BR>"
				if(wanted_already)
					dat+="<B>List gończy wystawił:</B><FONT COLOR='green'>[GLOB.news_network.wanted_issue.scannedUser]</FONT><BR>"
				else
					dat+="<B>List gończy zostanie wystawiony przez oskarżyciela:</B><FONT COLOR='green'>[scanned_user]</FONT><BR>"
				dat+="<BR><A href='byond://?src=[REF(src)];submit_wanted=[end_param]'>[(wanted_already) ? ("Edit Issue") : ("Submit")]</A>"
				if(wanted_already)
					dat+="<BR><A href='byond://?src=[REF(src)];cancel_wanted=1'>Wycofaj list</A>"
				dat+="<BR><A href='byond://?src=[REF(src)];setScreen=[0]'>Cancel</A>"
			if(15)
				dat+="<FONT COLOR='green'>List gończy za [channel_name] jest teraz w obiegu sieci.</FONT><BR><BR>"
				dat+="<BR><A href='byond://?src=[REF(src)];setScreen=[0]'>Return</A><BR>"
			if(16)
				dat+="<B><FONT COLOR='maroon'>BŁĄD: sieć odrzuciła list gończy.</B></FONT><HR><BR>"
				if(channel_name=="" || channel_name == "\[REDACTED\]")
					dat+="<FONT COLOR='maroon'>Nieprawidłowe imię poszukiwanej osoby.</FONT><BR>"
				if(scanned_user=="Unknown")
					dat+="<FONT COLOR='maroon'>Autor listu niezweryfikowany.</FONT><BR>"
				if(msg == "" || msg == "\[REDACTED\]")
					dat+="<FONT COLOR='maroon'>Nieprawidłowy opis.</FONT><BR>"
				dat+="<BR><A href='byond://?src=[REF(src)];setScreen=[0]'>Return</A><BR>"
			if(17)
				dat+="<B>List gończy usunięty z obiegu</B><BR>"
				dat+="<BR><A href='byond://?src=[REF(src)];setScreen=[0]'>Return</A><BR>"
			if(18)
				if(GLOB.news_network.wanted_issue.active)
					dat+="<B><FONT COLOR ='maroon'>-- OGÓLNOSTACYJNY LIST GOŃCZY --</B></FONT><BR><FONT SIZE=2>\[Wystawił: <FONT COLOR='green'>[GLOB.news_network.wanted_issue.scannedUser]</FONT>\]</FONT><HR>"
					dat+="<B>Criminal</B>: [GLOB.news_network.wanted_issue.criminal]<BR>"
					dat+="<B>Description</B>: [GLOB.news_network.wanted_issue.body]<BR>"
					dat+="<B>Photo:</B>: "
					if(GLOB.news_network.wanted_issue.img)
						usr << browse_rsc(GLOB.news_network.wanted_issue.img, "tmp_photow.png")
						dat+="<BR><img src='tmp_photow.png' width = '180'>"
					else
						dat+="None"
				else
					dat+="Nie znaleziono aktualnego listu gończego.<BR><BR>"
				dat+="<BR><BR><A href='byond://?src=[REF(src)];setScreen=[0]'>Back</A><BR>"
			if(19)
				dat+="<FONT COLOR='green'>List gończy za [channel_name] został pomyślnie zmieniony.</FONT><BR><BR>"
				dat+="<BR><A href='byond://?src=[REF(src)];setScreen=[0]'>Return</A><BR>"
			if(20)
				dat+="<FONT COLOR='green'>Drukowanie zakończone. Odbierz gazetę z dołu maszyny.</FONT><BR><BR>"
				dat+="<A href='byond://?src=[REF(src)];setScreen=[0]'>Return</A>"
			if(21)
				dat+="<FONT COLOR='maroon'>Nie można wydrukować gazety. Za mało papieru. Powiadom personel techniczny o konieczności uzupełnienia.</FONT><BR><BR>"
				dat+="<A href='byond://?src=[REF(src)];setScreen=[0]'>Return</A>"
		var/datum/browser/popup = new(human_or_robot_user, "newscaster_main", "Jednostka newscastera nr [unit_no]", 400, 600)
		popup.set_content(dat)
		popup.open()

/obj/machinery/newscaster/Topic(href, href_list)
	if(..())
		return
	if ((usr.contents.Find(src) || ((get_dist(src, usr) <= 1) && isturf(loc))) || issilicon(usr))
		usr.set_machine(src)
		scan_user(usr)
		if(href_list["set_channel_name"])
			channel_name = stripped_input(usr, "Podaj nazwę kanału", "Obsługa kanałów sieci", "", MAX_NAME_LEN)
			updateUsrDialog()
		else if(href_list["set_channel_lock"])
			c_locked = !c_locked
			updateUsrDialog()
		else if(href_list["submit_new_channel"])
			var/list/existing_authors = list()
			for(var/datum/newscaster/feed_channel/FC in GLOB.news_network.network_channels)
				if(FC.authorCensor)
					existing_authors += GLOB.news_network.redactedText
				else
					existing_authors += FC.author
			var/check = 0
			for(var/datum/newscaster/feed_channel/FC in GLOB.news_network.network_channels)
				if(FC.channel_name == channel_name)
					check = 1
					break
			if(channel_name == "" || channel_name == "\[REDACTED\]" || scanned_user == "Unknown" || check || (scanned_user in existing_authors) )
				screen=7
			else
				var/choice = alert("Potwierdź utworzenie kanału","Obsługa kanałów sieci","Confirm","Cancel")
				if(choice=="Confirm")
					scan_user(usr)
					GLOB.news_network.CreateFeedChannel(channel_name, scanned_user, c_locked)
					SSblackbox.record_feedback("text", "newscaster_channels", 1, "[channel_name]")
					screen=5
			updateUsrDialog()
		else if(href_list["set_channel_receiving"])
			var/list/available_channels = list()
			for(var/datum/newscaster/feed_channel/F in GLOB.news_network.network_channels)
				if( (!F.locked || F.author == scanned_user) && !F.censored)
					available_channels += F.channel_name
			channel_name = input(usr, "Wybierz kanał docelowy", "Obsługa kanałów sieci") in sortList(available_channels)
			updateUsrDialog()
		else if(href_list["set_new_message"])
			var/temp_message = trim(stripped_multiline_input(usr, "Napisz swój artykuł", "Obsługa kanałów sieci", msg))
			if(temp_message)
				msg = temp_message
				updateUsrDialog()
		else if(href_list["set_attachment"])
			AttachPhoto(usr)
			updateUsrDialog()
		else if(href_list["submit_new_message"])
			if(msg =="" || msg=="\[REDACTED\]" || scanned_user == "Unknown" || channel_name == "" )
				screen=6
			else
				GLOB.news_network.SubmitArticle("<font face=\"[PEN_FONT]\">[parsemarkdown(msg, usr)]</font>", scanned_user, channel_name, picture, 0, allow_comments)
				SSblackbox.record_feedback("amount", "newscaster_stories", 1)
				screen=4
				msg = ""
			updateUsrDialog()
		else if(href_list["create_channel"])
			screen=2
			updateUsrDialog()
		else if(href_list["create_feed_story"])
			screen=3
			updateUsrDialog()
		else if(href_list["menu_paper"])
			screen=8
			updateUsrDialog()
		else if(href_list["print_paper"])
			if(!paper_remaining)
				screen=21
			else
				print_paper()
				screen = 20
			updateUsrDialog()
		else if(href_list["menu_censor_story"])
			screen=10
			updateUsrDialog()
		else if(href_list["menu_censor_channel"])
			screen=11
			updateUsrDialog()
		else if(href_list["menu_wanted"])
			var/already_wanted = 0
			if(GLOB.news_network.wanted_issue.active)
				already_wanted = 1
			if(already_wanted)
				channel_name = GLOB.news_network.wanted_issue.criminal
				msg = GLOB.news_network.wanted_issue.body
			screen = 14
			updateUsrDialog()
		else if(href_list["set_wanted_name"])
			channel_name = stripped_input(usr, "Podaj imię poszukiwanej osoby", "Obsługa bezpieczeństwa sieci")
			updateUsrDialog()
		else if(href_list["set_wanted_desc"])
			msg = stripped_input(usr, "Podaj opis poszukiwanej osoby i inne szczegóły, które uznasz za ważne", "Obsługa bezpieczeństwa sieci")
			updateUsrDialog()
		else if(href_list["submit_wanted"])
			var/input_param = text2num(href_list["submit_wanted"])
			if(msg == "" || channel_name == "" || scanned_user == "Unknown")
				screen = 16
			else
				var/choice = alert("Potwierdź [(input_param==1) ? ("utworzenie") : ("edycję")] listu gończego.","Obsługa bezpieczeństwa sieci","Confirm","Cancel")
				if(choice=="Confirm")
					scan_user(usr)
					if(input_param==1)          //If input_param == 1 we're submitting a new wanted issue. At 2 we're just editing an existing one.
						GLOB.news_network.submitWanted(channel_name, msg, scanned_user, picture, 0 , 1)
						screen = 15
					else
						if(GLOB.news_network.wanted_issue.isAdminMsg)
							alert("List gończy został rozesłany przez wysoko postawioną osobę z Nanotrasen. Nie możesz go edytować.","Ok")
							return
						GLOB.news_network.submitWanted(channel_name, msg, scanned_user, picture)
						screen = 19
			updateUsrDialog()
		else if(href_list["cancel_wanted"])
			if(GLOB.news_network.wanted_issue.isAdminMsg)
				alert("List gończy został rozesłany przez wysoko postawioną osobę z Nanotrasen. Nie możesz go wycofać.","Ok")
				return
			var/choice = alert("Potwierdź usunięcie listu gończego","Obsługa bezpieczeństwa sieci","Confirm","Cancel")
			if(choice=="Confirm")
				GLOB.news_network.deleteWanted()
				screen=17
			updateUsrDialog()
		else if(href_list["view_wanted"])
			screen=18
			updateUsrDialog()
		else if(href_list["censor_channel_author"])
			var/datum/newscaster/feed_channel/FC = locate(href_list["censor_channel_author"]) in GLOB.news_network.network_channels
			if(FC.is_admin_channel)
				alert("Ten kanał utworzył funkcjonariusz Nanotrasen. Nie możesz go cenzurować.","Ok")
				return
			FC.toggleCensorAuthor()
			updateUsrDialog()
		else if(href_list["censor_channel_story_author"])
			var/datum/newscaster/feed_message/MSG = locate(href_list["censor_channel_story_author"]) in viewing_channel.messages
			if(MSG.is_admin_message)
				alert("Tę wiadomość utworzył funkcjonariusz Nanotrasen. Nie możesz cenzurować jej autora.","Ok")
				return
			MSG.toggleCensorAuthor()
			updateUsrDialog()
		else if(href_list["censor_channel_story_body"])
			var/datum/newscaster/feed_message/MSG = locate(href_list["censor_channel_story_body"]) in viewing_channel.messages
			if(MSG.is_admin_message)
				alert("Ten kanał utworzył funkcjonariusz Nanotrasen. Nie możesz go cenzurować.","Ok")
				return
			MSG.toggleCensorBody()
			updateUsrDialog()
		else if(href_list["pick_d_notice"])
			var/datum/newscaster/feed_channel/FC = locate(href_list["pick_d_notice"]) in GLOB.news_network.network_channels
			viewing_channel = FC
			screen=13
			updateUsrDialog()
		else if(href_list["toggle_d_notice"])
			var/datum/newscaster/feed_channel/FC = locate(href_list["toggle_d_notice"]) in GLOB.news_network.network_channels
			if(FC.is_admin_channel)
				alert("Ten kanał utworzył funkcjonariusz Nanotrasen. Nie możesz nałożyć na niego zakazu D.","Ok")
				return
			FC.toggleCensorDclass()
			updateUsrDialog()
		else if(href_list["view"])
			screen=1
			updateUsrDialog()
		else if(href_list["setScreen"])
			screen = text2num(href_list["setScreen"])
			if (screen == 0)
				scanned_user = "Unknown";
				msg = "";
				c_locked=0;
				channel_name="";
				viewing_channel = null
			updateUsrDialog()
		else if(href_list["show_channel"])
			var/datum/newscaster/feed_channel/FC = locate(href_list["show_channel"]) in GLOB.news_network.network_channels
			viewing_channel = FC
			screen = 9
			updateUsrDialog()
		else if(href_list["pick_censor_channel"])
			var/datum/newscaster/feed_channel/FC = locate(href_list["pick_censor_channel"]) in GLOB.news_network.network_channels
			viewing_channel = FC
			screen = 12
			updateUsrDialog()
		else if(href_list["new_comment"])
			var/datum/newscaster/feed_message/FM = locate(href_list["new_comment"]) in viewing_channel.messages
			var/cominput = stripped_input(usr, "Napisz swoją wiadomość:", "Nowy komentarz", null, 140)
			if(cominput)
				scan_user(usr)
				var/datum/newscaster/feed_comment/FC = new/datum/newscaster/feed_comment
				FC.author = scanned_user
				FC.body = cominput
				FC.time_stamp = station_time_timestamp()
				FM.comments += FC
				usr.log_message("(as [scanned_user]) commented on message [FM.returnBody(-1)] -- [FC.body]", LOG_COMMENT)
			updateUsrDialog()
		else if(href_list["del_comment"])
			var/datum/newscaster/feed_message/FM = locate(href_list["del_comment_msg"]) in viewing_channel.messages
			var/datum/newscaster/feed_comment/FC = locate(href_list["del_comment"]) in FM.comments
			if(istype(FC) && istype(FM))
				FM.comments -= FC
				qdel(FC)
				updateUsrDialog()
		else if(href_list["lock_comment"])
			var/datum/newscaster/feed_message/FM = locate(href_list["lock_comment"]) in viewing_channel.messages
			FM.locked ^= 1
			updateUsrDialog()
		else if(href_list["set_comment"])
			allow_comments ^= 1
			updateUsrDialog()
		else if(href_list["refresh"])
			updateUsrDialog()

/obj/machinery/newscaster/attackby(obj/item/I, mob/living/user, params)
	if(I.tool_behaviour == TOOL_WRENCH)
		to_chat(user, "<span class='notice'>Zaczynasz [anchored ? "odczepiać" : "mocować"] [name]...</span>")
		I.play_tool_sound(src)
		if(I.use_tool(src, user, 60))
			playsound(loc, 'sound/items/deconstruct.ogg', 50, 1)
			if(machine_stat & BROKEN)
				to_chat(user, "<span class='warning'>Zniszczone szczątki [src] spadają na ziemię.</span>")
				new /obj/item/stack/sheet/iron(loc, 5)
				new /obj/item/shard(loc)
				new /obj/item/shard(loc)
			else
				to_chat(user, "<span class='notice'>[anchored ? "Odczepiasz" : "Mocujesz"] [name].</span>")
				new /obj/item/wallframe/newscaster(loc)
			qdel(src)
	else if(I.tool_behaviour == TOOL_WELDER && user.a_intent != INTENT_HARM)
		if(machine_stat & BROKEN)
			if(!I.tool_start_check(user, amount=0))
				return
			user.visible_message("[user] naprawia [src].", \
							"<span class='notice'>Zaczynasz naprawiać [src]...</span>", \
							"<span class='italics'>Słyszysz spawanie.</span>")
			if(I.use_tool(src, user, 40, volume=50))
				if(!(machine_stat & BROKEN))
					return
				to_chat(user, "<span class='notice'>Naprawiasz [src].</span>")
				obj_integrity = max_integrity
				set_machine_stat(machine_stat & ~BROKEN)
				update_icon()
		else
			to_chat(user, "<span class='notice'>[src] nie wymaga naprawy.</span>")
	else
		return ..()

/obj/machinery/newscaster/play_attack_sound(damage, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(machine_stat & BROKEN)
				playsound(loc, 'sound/effects/hit_on_shattered_glass.ogg', 100, 1)
			else
				playsound(loc, 'sound/effects/glasshit.ogg', 90, 1)
		if(BURN)
			playsound(src.loc, 'sound/items/welder.ogg', 100, 1)


/obj/machinery/newscaster/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		new /obj/item/stack/sheet/iron(loc, 2)
		new /obj/item/shard(loc)
		new /obj/item/shard(loc)
	qdel(src)

/obj/machinery/newscaster/obj_break(damage_flag)
	. = ..()
	if(.)
		playsound(loc, 'sound/effects/glassbr3.ogg', 100, TRUE)

/obj/machinery/newscaster/attack_paw(mob/user)
	if(user.a_intent != INTENT_HARM)
		to_chat(user, "<span class='warning'>Sterowanie newscasterem jest zbyt skomplikowane dla twojego malutkiego mózgu!</span>")
	else
		take_damage(5, BRUTE, "melee")

/obj/machinery/newscaster/proc/AttachPhoto(mob/user)
	var/obj/item/photo/photo = user.is_holding_item_of_type(/obj/item/photo)
	if(photo)
		picture = photo.picture
	if(issilicon(user))
		var/obj/item/camera/siliconcam/targetcam
		if(isAI(user))
			var/mob/living/silicon/ai/R = user
			targetcam = R.aicamera
		else if(ispAI(user))
			var/mob/living/silicon/pai/R = user
			targetcam = R.aicamera
		else if(iscyborg(user))
			var/mob/living/silicon/robot/R = user
			if(R.connected_ai)
				targetcam = R.connected_ai.aicamera
			else
				targetcam = R.aicamera
		else
			to_chat(user, "<span class='warning'>Nie możesz połączyć się z wgrywaniem zdjęć przez silikony!</span>")
		if(!targetcam.stored.len)
			to_chat(usr, "<span class='boldannounce'>Brak zapisanych zdjęć.</span>")
			return
		var/datum/picture/selection = targetcam.selectpicture(user)
		if(selection)
			picture = selection

/obj/machinery/newscaster/proc/scan_user(mob/living/user)
	if(ishuman(user))
		var/mob/living/carbon/human/human_user = user
		if(human_user.wear_id)
			if(istype(human_user.wear_id, /obj/item/modular_computer/tablet/pda))
				var/obj/item/modular_computer/tablet/pda/P = human_user.wear_id
				var/obj/item/card/id/ID = P.GetID()
				if(istype(ID))
					scanned_user = "[ID.registered_name] ([ID.assignment])"
				else
					scanned_user = "Unknown"
			else if(istype(human_user.wear_id, /obj/item/card/id) )
				var/obj/item/card/id/ID = human_user.wear_id
				scanned_user ="[ID.registered_name] ([ID.assignment])"
			else
				scanned_user ="Unknown"
		else
			scanned_user ="Unknown"
	else if(issilicon(user))
		var/mob/living/silicon/ai_user = user
		scanned_user = "[ai_user.name] ([ai_user.job])"
	else
		CRASH("Invalid user for this proc")

/obj/machinery/newscaster/proc/print_paper()
	SSblackbox.record_feedback("amount", "newspapers_printed", 1)
	var/obj/item/newspaper/NEWSPAPER = new /obj/item/newspaper
	for(var/datum/newscaster/feed_channel/FC in GLOB.news_network.network_channels)
		NEWSPAPER.news_content += FC
	if(GLOB.news_network.wanted_issue.active)
		NEWSPAPER.wantedAuthor = GLOB.news_network.wanted_issue.scannedUser
		NEWSPAPER.wantedCriminal = GLOB.news_network.wanted_issue.criminal
		NEWSPAPER.wantedBody = GLOB.news_network.wanted_issue.body
		if(GLOB.news_network.wanted_issue.img)
			NEWSPAPER.wantedPhoto = GLOB.news_network.wanted_issue.img
	NEWSPAPER.forceMove(drop_location())
	NEWSPAPER.creationTime = GLOB.news_network.lastAction
	paper_remaining--


/obj/machinery/newscaster/proc/remove_alert()
	alert = FALSE
	update_icon()

/obj/machinery/newscaster/proc/newsAlert(channel)
	if(channel)
		say("Najnowsze wiadomości z [channel]!") // AQ EDIT tłumaczenie
		alert = TRUE
		update_icon()
		addtimer(CALLBACK(src,PROC_REF(remove_alert)),alert_delay,TIMER_UNIQUE|TIMER_OVERRIDE)
		playsound(loc, 'aquila/sound/misc/ciu.ogg', 50, FALSE, 1) // AQ EDIT
	else
		say("UWAGA! OSOBA POSZUKIWANA!") // AQ EDIT tłumaczenie
		playsound(loc, 'aquila/sound/misc/rdr2_low_honor.ogg', 75, 1) // AQ EDIT


/obj/item/newspaper
	name = "newspaper"
	desc = "An issue of The Griffon, the newspaper circulating aboard Nanotrasen Space Stations."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "newspaper"
	lefthand_file = 'icons/mob/inhands/misc/books_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/books_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("pacnięciem trąca")
	resistance_flags = FLAMMABLE
	var/screen = 0
	var/pages = 0
	var/curr_page = 0
	var/list/datum/newscaster/feed_channel/news_content = list()
	var/scribble=""
	var/scribble_page = null
	var/wantedAuthor
	var/wantedCriminal
	var/wantedBody
	var/wantedPhoto
	var/creationTime

/obj/item/newspaper/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] intensywnie skupia się na [src]! Wygląda na to, że próbuje popełnić sudoku... aż nagle jego oczy rozbłyskują zrozumieniem!</span>")
	user.say(";DZIENNIKARSTWO TO MOJE POWOŁANIE! WSZYSCY DOCENIAJĄ BEZSTRONNE RELACJ-GLORF", forced="newspaper suicide")
	var/mob/living/carbon/human/H = user
	var/obj/W = new /obj/item/reagent_containers/food/drinks/bottle/whiskey(H.loc)
	playsound(H.loc, 'sound/items/drink.ogg', rand(10,50), 1)
	W.reagents.trans_to(H, W.reagents.total_volume, transfered_by = user)
	user.visible_message("<span class='suicide'>[user] wypija zawartość [W.name] jednym haustem! Trzeba było zostać przy sudoku!</span>")

	return(TOXLOSS)

/obj/item/newspaper/attack_self(mob/user)
	if(ishuman(user))
		var/mob/living/carbon/human/human_user = user
		var/dat
		pages = 0
		switch(screen)
			if(0) //Cover
				dat+="<DIV ALIGN='center'><B><FONT SIZE=6>The Griffon</FONT></B></div>"
				dat+="<DIV ALIGN='center'><FONT SIZE=2>Standardowa gazeta Nanotrasen, do użytku w obiektach kosmicznych Nanotrasen?</FONT></div><HR>"
				if(!length(news_content))
					if(wantedAuthor)
						dat+="Spis treści:<BR><ul><B><FONT COLOR='red'>**</FONT>Ważny komunikat ochrony<FONT COLOR='red'>**</FONT></B> <FONT SIZE=2>\[strona [pages+2]\]</FONT><BR></ul>"
					else
						dat+="<I>Poza tytułem reszta gazety jest niezadrukowana...</I>"
				else
					dat+="Contents:<BR><ul>"
					for(var/datum/newscaster/feed_channel/NP in news_content)
						pages++
					if(wantedAuthor)
						dat+="<B><FONT COLOR='red'>**</FONT>Ważny komunikat ochrony<FONT COLOR='red'>**</FONT></B> <FONT SIZE=2>\[strona [pages+2]\]</FONT><BR>"
					var/temp_page=0
					for(var/datum/newscaster/feed_channel/NP in news_content)
						temp_page++
						dat+="<B>[NP.channel_name]</B> <FONT SIZE=2>\[page [temp_page+1]\]</FONT><BR>"
					dat+="</ul>"
				if(scribble_page==curr_page)
					dat+="<BR><I>Pod koniec tej strony jest drobny dopisek... Brzmi: \"[scribble]\"</I>"
				dat+= "<HR><DIV STYLE='float:right;'><A href='byond://?src=[REF(src)];next_page=1'>Następna strona</A></DIV> <div style='float:left;'><A href='byond://?src=[REF(human_user)];mach_close=newspaper_main'>Koniec czytania</A></DIV>"
			if(1) // X channel pages inbetween.
				for(var/datum/newscaster/feed_channel/NP in news_content)
					pages++
				var/datum/newscaster/feed_channel/C = news_content[curr_page]
				dat += "<FONT SIZE=4><B>[C.channel_name]</B></FONT><FONT SIZE=1> \[created by: <FONT COLOR='maroon'>[C.returnAuthor(notContent(C.authorCensorTime))]</FONT>\]</FONT><BR><BR>"
				if(notContent(C.DclassCensorTime))
					dat+="Ten kanał uznano za niebezpieczny dla ogólnego dobra stacji i dlatego oznaczono go <B><FONT COLOR='red'>zakazem D</B></FONT>. Jego treść nie została przeniesiona do gazety w chwili druku."
				else
					if(!length(C.messages))
						dat+="Ten kanał nie zawiera żadnych artykułów..."
					else
						var/i = 0
						for(var/datum/newscaster/feed_message/MESSAGE in C.messages)
							if(MESSAGE.creationTime > creationTime)
								if(i == 0)
									dat+="Ten kanał nie zawiera żadnych artykułów..."
								break
							if(i == 0)
								dat+="<ul>"
							i++
							dat+="-[MESSAGE.returnBody(notContent(MESSAGE.bodyCensorTime))] <BR>"
							if(MESSAGE.img)
								user << browse_rsc(MESSAGE.img, "tmp_photo[i].png")
								dat+="<img src='tmp_photo[i].png' width = '180'><BR>"
							dat+="<FONT SIZE=1>\[Story by <FONT COLOR='maroon'>[MESSAGE.returnAuthor(notContent(MESSAGE.authorCensorTime))]</FONT>\]</FONT><BR><BR>"
						dat+="</ul>"
				if(scribble_page==curr_page)
					dat+="<BR><I>Pod koniec tej strony jest drobny dopisek... Brzmi: \"[scribble]\"</I>"
				dat+= "<BR><HR><DIV STYLE='float:left;'><A href='byond://?src=[REF(src)];prev_page=1'>Poprzednia strona</A></DIV> <DIV STYLE='float:right;'><A href='byond://?src=[REF(src)];next_page=1'>Następna strona</A></DIV>"
			if(2) //Last page
				for(var/datum/newscaster/feed_channel/NP in news_content)
					pages++
				if(wantedAuthor!=null)
					dat+="<DIV STYLE='float:center;'><FONT SIZE=4><B>List gończy:</B></FONT SIZE></DIV><BR><BR>"
					dat+="<B>Imię przestępcy</B>: <FONT COLOR='maroon'>[wantedCriminal]</FONT><BR>"
					dat+="<B>Description</B>: [wantedBody]<BR>"
					dat+="<B>Photo:</B>: "
					if(wantedPhoto)
						user << browse_rsc(wantedPhoto, "tmp_photow.png")
						dat+="<BR><img src='tmp_photow.png' width = '180'>"
					else
						dat+="None"
				else
					dat+="<I>Poza kilkoma nieciekawymi ogłoszeniami drobnymi na tej stronie nic nie ma...</I>"
				if(scribble_page==curr_page)
					dat+="<BR><I>Pod koniec tej strony jest drobny dopisek... Brzmi: \"[scribble]\"</I>"
				dat+= "<HR><DIV STYLE='float:left;'><A href='byond://?src=[REF(src)];prev_page=1'>Poprzednia strona</A></DIV>"
		dat+="<BR><HR><div align='center'>[curr_page+1]</div>"
		human_user << browse(dat, "window=newspaper_main;size=300x400")
		onclose(human_user, "newspaper_main")
	else
		to_chat(user, "Gazeta jest pełna niezrozumiałych symboli!")

/obj/item/newspaper/proc/notContent(list/L)
	if(!L.len)
		return 0
	for(var/i=L.len;i>0;i--)
		var/num = abs(L[i])
		if(creationTime <= num)
			continue
		else
			if(L[i] > 0)
				return 1
			else
				return 0
	return 0

/obj/item/newspaper/Topic(href, href_list)
	var/mob/living/U = usr
	..()
	if((src in U.contents) || (isturf(loc) && in_range(src, U)))
		U.set_machine(src)
		if(href_list["next_page"])
			if(curr_page == pages+1)
				return //Don't need that at all, but anyway.
			if(curr_page == pages) //We're at the middle, get to the end
				screen = 2
			else
				if(curr_page == 0) //We're at the start, get to the middle
					screen=1
			curr_page++
			playsound(loc, "pageturn", 50, 1)
		else if(href_list["prev_page"])
			if(curr_page == 0)
				return
			if(curr_page == 1)
				screen = 0
			else
				if(curr_page == pages+1) //we're at the end, let's go back to the middle.
					screen = 1
			curr_page--
			playsound(loc, "pageturn", 50, 1)
		if(ismob(loc))
			attack_self(loc)

/obj/item/newspaper/attackby(obj/item/W, mob/living/user, params)
	if(burn_paper_product_attackby_check(W, user))
		return

	if(istype(W, /obj/item/pen))
		if(!user.is_literate())
			to_chat(user, "<span class='notice'>Bazgrzesz nieczytelnie na [src]!</span>")
			return
		if(scribble_page == curr_page)
			to_chat(user, "<span class='notice'>Na tej stronie już jest dopisek... Nie chcesz chyba zrobić bałaganu, prawda?</span>")
		else
			var/s = stripped_input(user, "Napisz coś", "Newspaper")
			if (!s)
				return
			if(!user.canUseTopic(src, BE_CLOSE))
				return
			scribble_page = curr_page
			scribble = s
			attack_self(user)
			add_fingerprint(user)
	else
		return ..()

/obj/machinery/newscaster/directional/north //NSV13 Start - directional newscasters for mapping
	dir = NORTH
	pixel_y = 30

/obj/machinery/newscaster/directional/south
	dir = SOUTH
	pixel_y = -30

/obj/machinery/newscaster/directional/west
	dir = WEST
	pixel_x = -30

/obj/machinery/newscaster/directional/east
	dir = EAST
	pixel_x = 30

/obj/machinery/newscaster/security_unit/north
	dir = NORTH
	pixel_y = 30

/obj/machinery/newscaster/security_unit/south
	dir = SOUTH
	pixel_y = -30

/obj/machinery/newscaster/security_unit/west
	dir = WEST
	pixel_x = -30

/obj/machinery/newscaster/security_unit/east
	dir = EAST
	pixel_x = 30 //NSV13 End
