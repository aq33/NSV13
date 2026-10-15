// AQUILA - kryminalistyka: luminol, ślady prochu (GSR), balistyka

/// Jak długo świecą ślady ujawnione luminolem
#define LUMINOL_DURATION (60 SECONDS)
/// Kolor świecenia luminolu
#define LUMINOL_COLOR "#66ffff"

/// Od tej siły czyszczenia znika także "zmyta" (utajona) krew. Zwykłe sprzątanie jej nie usuwa, robi to sterilizine.
#define CLEAN_STRENGTH_LATENT_BLOOD CLEAN_GOD
/// Od tej siły czyszczenia znikają ślady prochu (zlew, prysznic, środek czyszczący, mop)
#define CLEAN_STRENGTH_RESIDUE CLEAN_WEAK

/// Po takim czasie ślady prochu słabną
#define GSR_FAINT_TIME (10 MINUTES)
/// Po takim czasie ślady prochu znikają całkiem
#define GSR_FADE_TIME (20 MINUTES)
/// Szansa, że strzał zostawi ślady prochu na podłodze pod strzelcem
#define GSR_FLOOR_CHANCE 30

/// Szansa, że pocisk, który zranił człowieka, utknie w ciele jako fragment
#define BULLET_FRAGMENT_LODGE_CHANCE 30
/// Szansa, że pocisk trafiający w ścianę lub gęsty obiekt zostawi zdeformowaną kulę na podłodze
#define BULLET_FRAGMENT_WALL_CHANCE 25
/// Szansa, że pocisk, który doleciał do końca zasięgu, zostawi kulę na podłodze
#define BULLET_FRAGMENT_RANGE_CHANCE 15
/// Czas spiłowywania numeru seryjnego
#define SERIAL_FILE_TIME (6 SECONDS)
