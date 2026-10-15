// Black market (port of tgstation code/__DEFINES/market.dm)

// Shipping methods

/// The BEST way of shipping items: accurate, "undetectable"
#define SHIPPING_METHOD_LTSRBT "LTSRBT"
/// Picks a random area to teleport the item to and gives you a minute to get there before it is sent.
#define SHIPPING_METHOD_TELEPORT "Teleport"
/// Throws the item from somewhere at the station.
#define SHIPPING_METHOD_LAUNCH "Launch"
/// Sends a supply pod to the buyer's location, showy.
#define SHIPPING_METHOD_SUPPLYPOD "Supply Pod"

/// The percentage on gains that's removed when selling an item through the blackmarket with the LTSRBT
#define MARKET_WITHHOLDING_TAX 0.15

/// tg prices are written in crate values, a crate is worth 200 credits there
#define MARKET_CRATE_VALUE 200
/// tg PAYCHECK_LOWER
#define MARKET_PAYCHECK_LOWER 25
/// tg PAYCHECK_CREW
#define MARKET_PAYCHECK_CREW 50

//Black Market Uplink categories
#define BLACKMARKET_CATEGORY_CLOTHING "Ubrania"
#define BLACKMARKET_CATEGORY_CONSUMABLES "Używki"
#define BLACKMARKET_CATEGORY_LOCAL_GOODS "Towary lokalne"
#define BLACKMARKET_CATEGORY_MISC "Różne"
#define BLACKMARKET_CATEGORY_FENCED_GOODS "Paserka"
#define BLACKMARKET_CATEGORY_TOOLS "Narzędzia"
#define BLACKMARKET_CATEGORY_WEAPONS "Broń"

///From /datum/market_item/spawn_item(): (uplink, shipping_method, shipping_loc)
#define COMSIG_MARKET_ITEM_SPAWNED "market_item_spawned"
