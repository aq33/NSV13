// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - Chrono Legionnaire: tyrant names are recognised through spelling tricks, ordinary names are left alone
/// The names are read from config/chrono_legionnaire_names.txt, which CI does not copy, so the test brings its own list
/datum/unit_test/aquila_chrono_legionnaire_names
	/// The real list, put back after the test
	var/list/saved_names

/datum/unit_test/aquila_chrono_legionnaire_names/Destroy()
	if(saved_names)
		GLOB.aquila_chrono_historical_names = saved_names
	return ..()

/datum/unit_test/aquila_chrono_legionnaire_names/Run()
	saved_names = GLOB.aquila_chrono_historical_names
	GLOB.aquila_chrono_historical_names = list(
		"hitler" = "Adolf Hitler",
		"schicklgruber" = "Adolf Hitler",
		"fuhrer" = "Adolf Hitler",
		"stalin" = "Józef Stalin",
		"dzugaszwili" = "Józef Stalin",
		"dzhugashvili" = "Józef Stalin",
	)
	var/list/tyrants = list(
		"Adolf Hitler" = "Adolf Hitler",
		"adolf hitler" = "Adolf Hitler",
		"H1tl3r" = "Adolf Hitler",
		"A. H-i-t-l-e-r" = "Adolf Hitler",
		"Adolfus Hitlerowski" = "Adolf Hitler",
		"Adolf Schicklgruber" = "Adolf Hitler",
		"Der Führer" = "Adolf Hitler",
		"Józef Stalin" = "Józef Stalin",
		"Joseph Stalin" = "Józef Stalin",
		"STALIN" = "Józef Stalin",
		"Józef Dżugaszwili" = "Józef Stalin",
		"Iosif Dzhugashvili" = "Józef Stalin",
		"$tal1n" = "Józef Stalin",
	)
	for(var/name in tyrants)
		TEST_ASSERT_EQUAL(aquila_chrono_historical_figure(name), tyrants[name], "for the name [name]")

	for(var/name in list("Jan Kowalski", "Kristalina Georgieva", "Crystaline Shard", "Adolf Kowalski", "Hilter Tuz", ""))
		TEST_ASSERT_EQUAL(aquila_chrono_historical_figure(name), null, "for the name [name]")

#undef TEST_ASSERT_EQUAL
