// AQUILA - Hygiene additions (tgstation 2019 hygiene that NSV13 kept, plus what it left out), see aquila/code/modules/hygiene/

/// Miasma a living human at or below HYGIENE_LEVEL_DIRTY releases, in moles per second (tg: 0.002 per Life() tick)
#define MIASMA_HYGIENE_MOLES 0.001

/// Hygienebots (tgstation#49613, #55089)
#define HYGIENE_BOT (1<<7)
/// Hygiene a hygienebot restores per automated action while spraying someone
#define HYGIENEBOT_WASH_AMOUNT 50
