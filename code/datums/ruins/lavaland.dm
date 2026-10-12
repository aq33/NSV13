// Hey! Listen! Update \config\lavaruinblacklist.txt with your new ruins!

/datum/map_template/ruin/lavaland
	prefix = "_maps/RandomRuins/LavaRuins/"

/datum/map_template/ruin/lavaland/biodome
	cost = 5
	allow_duplicates = FALSE

/datum/map_template/ruin/lavaland/biodome/beach
	name = "Biodome Beach"
	id = "biodome-beach"
	description = "Ta plaża, jakby wyjęta z tropikalnego kurortu, jest spokojna i chłodna, a w tle cicho szumią słone fale. W zestawie rustykalny drewniany bar i barman o skłonnościach samobójczych."
	suffix = "lavaland_biodome_beach.dmm"

/datum/map_template/ruin/lavaland/biodome/winter
	name = "Biodome Winter"
	id = "biodome-winter"
	description = "Na wypady, gdy chcesz wrócić do natury, ale nie chcesz opuszczać ufortyfikowanego kompleksu wojskowego, w którym spędzasz dni. W zestawie unikalna(*) gablota z pistoletem laserowym i niedawno wprowadzony I.C.E(tm)."
	suffix = "lavaland_surface_biodome_winter.dmm"

/datum/map_template/ruin/lavaland/biodome/clown
	name = "Biodome Clown Planet"
	id = "biodome-clown"
	description = "WITAMY NA PLANECIE KLAUNÓW! HONK HONK HONK itd.!"
	suffix = "lavaland_biodome_clown_planet.dmm"

/datum/map_template/ruin/lavaland/cube
	name = "The Wishgranter Cube"
	id = "wishgranter-cube"
	description = "Nic dobrego z tego nie wyniknie. Ucz się na ich błędach i zawróć."
	suffix = "lavaland_surface_cube.dmm"
	cost = 10
	allow_duplicates = FALSE

/datum/map_template/ruin/lavaland/seed_vault
	name = "Seed Vault"
	id = "seed-vault"
	description = "Twórcy tych krypt byli wysoko rozwiniętą i życzliwą rasą i wysłali wiele z nich w gwiazdy, chcąc pomóc raczkującym cywilizacjom. Mieszkańcy jednak zajmują się tylko uprawą narkotyków i broni."
	suffix = "lavaland_surface_seed_vault.dmm"
	cost = 10
	allow_duplicates = FALSE

/datum/map_template/ruin/lavaland/ash_walker
	name = "Ash Walker Nest"
	id = "ash-walker"
	description = "Mieszka tu rasa nieoddychających jaszczurów, które biegają szybciej od ludzi, czczą zrujnowane, martwe miasto i potrafią się rozmnażać czymś z udziałem macek? Lepiej się trzymać z daleka."
	suffix = "lavaland_surface_ash_walker1.dmm"
	cost = 20
	allow_duplicates = FALSE

/datum/map_template/ruin/lavaland/syndicate_base
	name = "Syndicate Lava Base"
	id = "lava-base"
	description = "Tajna baza badająca nielegalną broń biologiczną, pilnie strzeżona przez elitarny zespół agentów Syndykatu."
	suffix = "lavaland_surface_syndicate_base1.dmm"
	cost = 20
	allow_duplicates = FALSE

/datum/map_template/ruin/lavaland/free_golem
	name = "Free Golem Ship"
	id = "golem-ship"
	description = "Lumbering humanoids, made out of precious metals, move inside this ship. They frequently leave to mine more minerals, which they somehow turn into more of them. \
	Seem very intent on research and individual liberty, and also geology based naming?"
	cost = 20
	suffix = "lavaland_surface_golem_ship.dmm"
	allow_duplicates = FALSE

/datum/map_template/ruin/lavaland/animal_hospital
	name = "Animal Hospital"
	id = "animal-hospital"
	description = "Starożytny szpital dla zwierząt, którego prawdziwy cel dawno zapomniano. Lekarze budzą się z jednym celem: leczyć umierających, chorych i rannych mieszkańców otaczających ich pustkowi."
	cost = 5
	suffix = "lavaland_surface_animal_hospital.dmm"
	allow_duplicates = FALSE

/datum/map_template/ruin/lavaland/sin
	cost = 10
	allow_duplicates = FALSE

/datum/map_template/ruin/lavaland/sin/envy
	name = "Ruin of Envy"
	id = "envy"
	description = "Gdy zdobędziesz to, co oni mają, w końcu będziesz szczęśliwy."
	suffix = "lavaland_surface_envy.dmm"

/datum/map_template/ruin/lavaland/sin/gluttony
	name = "Ruin of Gluttony"
	id = "gluttony"
	description = "Jeśli zjesz dość, jedzenie będzie wszystkim, co robisz."
	suffix = "lavaland_surface_gluttony.dmm"

/datum/map_template/ruin/lavaland/sin/greed
	name = "Ruin of Greed"
	id = "greed"
	description = "Jasne, nie potrzebujesz magicznych mocy, ale ich CHCESZ, i to się liczy."
	suffix = "lavaland_surface_greed.dmm"

/datum/map_template/ruin/lavaland/sin/pride
	name = "Ruin of Pride"
	id = "pride"
	description = "Pasy ratunkowe z tunelami są dla FRAJERÓW, a ty jesteś od nich lepszy."
	suffix = "lavaland_surface_pride.dmm"

/datum/map_template/ruin/lavaland/sin/sloth
	name = "Ruin of Sloth"
	id = "sloth"
	description = "..."
	suffix = "lavaland_surface_sloth.dmm"
	// Generates nothing but atmos runtimes and salt
	cost = 0

/datum/map_template/ruin/lavaland/ratvar
	name = "Dead God"
	id = "ratvar"
	description = "Miejsce ostatniego spoczynku Ratvara."
	suffix = "lavaland_surface_dead_ratvar.dmm"
	cost = 0
	allow_duplicates = FALSE

/datum/map_template/ruin/lavaland/hierophant
	name = "Hierophant's Arena"
	id = "hierophant"
	description = "Dziwny, kwadratowy kawał metalu ogromnych rozmiarów. W środku czeka tylko śmierć i mnóstwo, mnóstwo kwadratów."
	suffix = "lavaland_surface_hierophant.dmm"
	always_place = TRUE
	allow_duplicates = FALSE

/datum/map_template/ruin/lavaland/blood_drunk_miner
	name = "Blood-Drunk Miner"
	id = "blooddrunk"
	description = "Dziwny układ kamiennych płytek i obłąkany, zwierzęcy górnik, który się nad nimi zastanawia."
	suffix = "lavaland_surface_blooddrunk1.dmm"
	cost = 0
	allow_duplicates = FALSE //will only spawn one variant of the ruin

/datum/map_template/ruin/lavaland/blood_drunk_miner/guidance
	name = "Blood-Drunk Miner (Guidance)"
	suffix = "lavaland_surface_blooddrunk2.dmm"

/datum/map_template/ruin/lavaland/blood_drunk_miner/hunter
	name = "Blood-Drunk Miner (Hunter)"
	suffix = "lavaland_surface_blooddrunk3.dmm"

/datum/map_template/ruin/lavaland/ufo_crash
	name = "UFO Crash"
	id = "ufo-crash"
	description = "Okazuje się, że utrzymywanie ofiar porwań w nieprzytomności jest naprawdę ważne. Kto by pomyślał?"
	suffix = "lavaland_surface_ufo_crash.dmm"
	cost = 5

/datum/map_template/ruin/lavaland/xeno_nest
	name = "Xenomorph Nest"
	id = "xeno-nest"
	description = "Te ksenomorfy znudziły się makabrycznym mordowaniem ludzi na stacjach kosmicznych i osiadły w przyjemnym, pełnym lawy piekle, by skupić się na tym, co w życiu naprawdę ważne. Na jakościowych memach."
	suffix = "lavaland_surface_xeno_nest.dmm"
	cost = 20

/datum/map_template/ruin/lavaland/fountain
	name = "Fountain Hall"
	id = "fountain"
	description = "Na boku fontanny jest ostrzeżenie. NIEBEZPIECZEŃSTWO: może mieć niezgłoszone skutki uboczne, które ujawniają się dopiero po użyciu."
	suffix = "lavaland_surface_fountain_hall.dmm"
	cost = 5

/datum/map_template/ruin/lavaland/survivalcapsule
	name = "Survival Capsule Ruins"
	id = "survivalcapsule"
	description = "To, co kiedyś było schronieniem zwykłego górnika, jest teraz jego grobowcem."
	suffix = "lavaland_surface_survivalpod.dmm"
	cost = 5

/datum/map_template/ruin/lavaland/pizza
	name = "Ruined Pizza Party"
	id = "pizza"
	description = "Urodzinowa impreza z pizzą małego Timmy'ego przybrała zły obrót, gdy przeszła obok anomalia bluespace."
	suffix = "lavaland_surface_pizzaparty.dmm"
	allow_duplicates = FALSE
	cost = 5

/datum/map_template/ruin/lavaland/cultaltar
	name = "Summoning Ritual"
	id = "cultaltar"
	description = "Miejsce plugawego kultu; krwawe bazgroły na środku niesamowicie świecą. W jaskiniach rozbrzmiewa demoniczny śmiech"
	suffix = "lavaland_surface_cultaltar.dmm"
	allow_duplicates = FALSE
	cost = 10

/datum/map_template/ruin/lavaland/hermit
	name = "Makeshift Shelter"
	id = "hermitcave"
	description = "Schronienie samotnego pustelnika, który z trudem dożywa kolejnego dnia."
	suffix = "lavaland_surface_hermit.dmm"
	allow_duplicates = FALSE
	cost = 10

/datum/map_template/ruin/lavaland/swarmer_boss
	name = "Crashed Shuttle"
	id = "swarmerboss"
	description = "Na promie Syndykatu był niefortunny pasażer na gapę..."
	suffix = "lavaland_surface_swarmer_crash.dmm"
	allow_duplicates = FALSE
	cost = 20

/datum/map_template/ruin/lavaland/miningripley
	name = "Ripley"
	id = "ripley"
	description = "Mocno uszkodzony górniczy Ripley, własność bardzo nieszczęśliwego górnika. Trochę pracy i może da się go naprawić."
	suffix = "lavaland_surface_random_ripley.dmm"
	allow_duplicates = FALSE
	cost = 5

/datum/map_template/ruin/lavaland/puzzle
	name = "Ancient Puzzle"
	id = "puzzle"
	description = "Zagadka do rozwiązania."
	suffix = "lavaland_surface_puzzle.dmm"
	cost = 5
  
/datum/map_template/ruin/lavaland/elite_tumor
	name = "Pulsating Tumor"
	id = "tumor"
	description = "Dziwny guz, w którym mieszka potężna bestia..."
	suffix = "lavaland_surface_elite_tumor.dmm"
	cost = 5
	always_place = TRUE
	allow_duplicates = TRUE
