//Components: Used in scripture.
/obj/item/clockwork/component
	name = "meme component"
	desc = "A piece of a famous meme."
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	var/component_id //What the component is identified as
	var/cultist_message = "Nie jesteś godny tego mema." //Showed to Nar'Sian cultists if they pick up the component in addition to chaplains
	var/list/servant_of_ratvar_messages = list("ayy" = FALSE, "lmao" = TRUE) //Fluff, shown to servants of Ratvar on a low chance, if associated value is TRUE, will automatically apply ratvarian
	var/message_span = "heavy_brass"

/obj/item/clockwork/component/pickup(mob/living/user)
	..()
	if(iscultist(user) || (user.mind?.holy_role))
		to_chat(user, "<span class='[message_span]'>[cultist_message]</span>")
		if(user.mind?.holy_role)
			to_chat(user, "<span class='boldannounce'>Moc twojej wiary roztapia [src]!</span>")
			var/obj/item/stack/ore/slag/wrath = new /obj/item/stack/ore/slag
			qdel(src)
			user.put_in_active_hand(wrath)

/obj/item/clockwork/component/belligerent_eye
	name = "belligerent eye"
	desc = "A brass construct with a rotating red center. It's as though it's looking for something to hurt."
	icon_state = "belligerent_eye"
	cultist_message = "Oko obrzuca cię intensywnie nienawistnym spojrzeniem."
	servant_of_ratvar_messages = list("\"...\"" = FALSE, "Na chwilę twój umysł zalewają skrajnie brutalne myśli." = FALSE, "\"...Zgiń.\"" = TRUE)
	message_span = "neovgre"

/obj/item/clockwork/component/belligerent_eye/blind_eye
	name = "blind eye"
	desc = "A heavy brass eye, its red iris fallen dark."
	icon_state = "blind_eye"
	cultist_message = "Oko łypie na ciebie z intensywną nienawiścią, po czym gaśnie."
	servant_of_ratvar_messages = list("Oko migocze, po czym gaśnie." = FALSE, "Czujesz się obserwowany." = FALSE, "\"...\"" = FALSE)
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/clockwork/component/belligerent_eye/lens_gem
	name = "lens gem"
	desc = "A tiny pinkish gem. It catches the light oddly, almost glowing."
	icon_state = "lens_gem"
	cultist_message = "Klejnot na chwilę czernieje i zimnieje, po czym wraca jego zwykły blask."
	servant_of_ratvar_messages = list("\"Obrzydliwa porażka.\"" = TRUE, "Czujesz się badany wzrokiem." = FALSE, "\"Słabeusze.\"" = TRUE, "\"Żałosna obrona.\"" = TRUE)
	w_class = WEIGHT_CLASS_TINY
	light_range = 1.4
	light_power = 0.4
	light_color = "#F42B9D"

/obj/item/clockwork/component/vanguard_cogwheel
	name = "vanguard cogwheel"
	desc = "A sturdy brass cog with a faintly glowing blue gem in its center."
	icon_state = "vanguard_cogwheel"
	cultist_message = "\"Módl się do swojego boga, byśmy nigdy się nie spotkali.\""
	servant_of_ratvar_messages = list("\"Uważaj na siebie, dziecko.\"" = FALSE, "Czujesz niewytłumaczalną otuchę." = FALSE, "\"Nigdy nie zapominaj: ból jest chwilowy. To, co robisz dla Sędziego, jest wieczne.\"" = FALSE)
	message_span = "inathneq"

/obj/item/clockwork/component/vanguard_cogwheel/onyx_prism
	name = "onyx prism"
	desc = "An onyx prism with a small aperture. It's very heavy."
	icon_state = "onyx_prism"
	cultist_message = "Pryzmat robi się w twoich dłoniach boleśnie gorący."
	servant_of_ratvar_messages = list("Pryzmat wcale nie robi się lżejszy." = FALSE, "\"A więc... jeszcze nie zawiodłeś. Miej nadzieję, dziecko.\"" = TRUE, \
	"\"Lepiej, żeby zepsuły się te maszyny niż ty.\"" = TRUE)
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/clockwork/component/geis_capacitor
	name = "geis capacitor"
	desc = "A curiously cold brass doodad. It seems as though it really doesn't appreciate being held."
	icon_state = "geis_capacitor"
	cultist_message = "\"Postaraj się nie postradać zmysłów - będą mi potrzebne. He he...\""
	servant_of_ratvar_messages = list("\"Obrzydliwe.\"" = FALSE, "\"No proszę, ale z ciebie ciekawski.\"" = FALSE, "Plugawa obecność przenika twój umysł, po czym znika." = FALSE, \
	"\"To przerażające, że Ratvar musi polegać na takich prostaczkach jak ty.\"" = FALSE)
	message_span = "sevtug"

/obj/item/clockwork/component/geis_capacitor/fallen_armor
	name = "fallen armor"
	desc = "Lifeless chunks of armor. They're designed in a strange way and won't fit on you."
	icon_state = "fallen_armor"
	cultist_message = "Z oka maski bucha czerwony płomień, po czym gaśnie."
	servant_of_ratvar_messages = list("Część zbroi na chwilę odpływa od reszty." = FALSE, "W napierśniku pojawia się czerwony płomień, po czym gaśnie." = FALSE)
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/clockwork/component/geis_capacitor/antennae
	name = "mania motor antennae"
	desc = "A pair of dented and bent antennae. They constantly emit a static hiss."
	icon_state = "mania_motor_antennae"
	cultist_message = "Twoją głowę wypełnia wybuch szumu."
	servant_of_ratvar_messages = list("\"Kto to zepsuł.\"" = TRUE, "\"SAM to poodłamywałeś?\"" = TRUE, "\"Właściwie po co daliśmy to takim prostaczkom?\"" = TRUE, \
	"\"Przynajmniej do czegoś się to przyda - w przeciwieństwie do ciebie.\"" = TRUE)

/obj/item/clockwork/component/replicant_alloy
	name = "replicant alloy"
	desc = "A seemingly strong but very malleable chunk of metal. It seems as though it wants to be molded into something greater."
	icon_state = "replicant_alloy"
	cultist_message = "Stop na chwilę przybiera wygląd krzyczącej twarzy."
	servant_of_ratvar_messages = list("\"Zawsze jest coś do zrobienia. Do roboty.\"" = FALSE, "\"Bezczynne ręce są gorsze od połamanych. Do pracy.\"" = FALSE, \
	"W stopie na chwilę pojawia się szczegółowy wizerunek Ratvara." = FALSE)
	message_span = "nezbere"

/obj/item/clockwork/component/replicant_alloy/smashed_anima_fragment
	name = "smashed anima fragment"
	desc = "Shattered chunks of metal. Damaged beyond repair and completely unusable."
	icon_state = "smashed_anime_fragment"
	cultist_message = "Odłamki na chwilę wibrują w twoich dłoniach."
	servant_of_ratvar_messages = list("\"...wciąż walczę...\"" = FALSE, "\"...gdzie ja jestem...?\"" = FALSE, "\"...sprowadź mnie... z powrotem...\"" = FALSE)
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/clockwork/component/replicant_alloy/replication_plate
	name = "replication plate"
	desc = "A flat, heavy disc of metal with a triangular formation on its surface."
	icon_state = "replication_plate"
	cultist_message = "Płyta drży w twoich dłoniach, jakby próbowała uciec."
	servant_of_ratvar_messages = list("\"Włóż to do płyty i wracaj do pracy.\"" = FALSE, "\"Gorsi słudzy od ciebie to trzymali.\"" = TRUE, \
	"\"Mądrze byłoby lepiej tego pilnować, przyjacielu.\"" = TRUE)
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/clockwork/component/hierophant_ansible
	name = "hierophant ansible"
	desc = "Some sort of transmitter? It seems as though it's trying to say something."
	icon_state = "hierophant_ansible"
	cultist_message = "\"Gur obff fnlf vg'f abg ntnvafg gur ehyrf gb-xvyy lbh.\""
	servant_of_ratvar_messages = list("\"Wygnanie jest takie nudne. Nie ma tu na co polować.\"" = TRUE, "\"Na co czekasz? Chcę iść coś zabić.\"" = TRUE, \
	"\"HEHEHEHEHEHEH!\"" = FALSE, "\"Gdybym cię zabił dość szybko, myślisz, że szef by zauważył?\"" = TRUE)
	message_span = "nzcrentr"

/obj/item/clockwork/component/hierophant_ansible/obelisk
	name = "obelisk prism"
	desc = "A prism that occasionally glows brightly. It seems not-quite there."
	cultist_message = "Pryzmat dziko migocze w twoich dłoniach, po czym wraca do zwykłego blasku."
	servant_of_ratvar_messages = list("Przez chwilę słyszysz charakterystyczny dźwięk Sieci Hierofanta." = FALSE, "\"Awa'ria prze'ka'zu Hiero'fan'ta.\"" = TRUE, \
	"Obelisk dziko migocze, jakby próbował otworzyć bramę." = FALSE, "\"Awa'ria bra'my prze'strzen'nej.\"" = TRUE)
	icon_state = "obelisk_prism"
	w_class = WEIGHT_CLASS_NORMAL

//Shards of Alloy, suitable only as a source of power for a replica fabricator.
/obj/item/clockwork/alloy_shards
	name = "replicant alloy shards"
	desc = "Broken shards of some oddly malleable metal. They occasionally move and seem to glow."
	icon_state = "alloy_shards"
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	var/randomsinglesprite = FALSE
	var/randomspritemax = 2
	var/sprite_shift = 9

/obj/item/clockwork/alloy_shards/Initialize(mapload)
	. = ..()
	if(randomsinglesprite)
		replace_name_desc()
		icon_state = "[icon_state][rand(1, randomspritemax)]"
		pixel_x = rand(-sprite_shift, sprite_shift)
		pixel_y = rand(-sprite_shift, sprite_shift)

/obj/item/clockwork/alloy_shards/proc/replace_name_desc()
	name = "replicant alloy shard"
	desc = "A broken shard of some oddly malleable metal. It occasionally moves and seems to glow."

/obj/item/clockwork/alloy_shards/clockgolem_remains
	name = "clockwork golem scrap"
	desc = "A pile of scrap metal. It seems damaged beyond repair."
	icon_state = "clockgolem_dead"
	sprite_shift = 0

/obj/item/clockwork/alloy_shards/large
	w_class = WEIGHT_CLASS_TINY
	randomsinglesprite = TRUE
	icon_state = "shard_large"
	sprite_shift = 9

/obj/item/clockwork/alloy_shards/medium
	w_class = WEIGHT_CLASS_TINY
	randomsinglesprite = TRUE
	icon_state = "shard_medium"
	sprite_shift = 10

/obj/item/clockwork/alloy_shards/medium/gear_bit
	randomspritemax = 4
	icon_state = "gear_bit"
	sprite_shift = 12

/obj/item/clockwork/alloy_shards/medium/gear_bit/replace_name_desc()
	name = "gear bit"
	desc = "A broken chunk of a gear. You want it."

/obj/item/clockwork/alloy_shards/medium/gear_bit/large //gives more power

/obj/item/clockwork/alloy_shards/medium/gear_bit/large/replace_name_desc()
	..()
	name = "complex gear bit"

/obj/item/clockwork/alloy_shards/small
	w_class = WEIGHT_CLASS_TINY
	randomsinglesprite = TRUE
	randomspritemax = 3
	icon_state = "shard_small"
	sprite_shift = 12

/obj/item/clockwork/alloy_shards/pinion_lock
	name = "pinion lock"
	desc = "A dented and scratched gear. It's very heavy."
	icon_state = "pinion_lock"
