// AQUILA - Miasma (restores what BeeStation-Hornet#6445 removed, reworked for performance), see aquila/code/modules/miasma/
// GAS_MIASMA lives in code/__DEFINES/atmospherics.dm because core gas lists use it.

/// Miasma a rotting corpse emits, in moles per second
#define MIASMA_CORPSE_MOLES 0.02
/// Miasma a pile of gibs emits, in moles per second
#define MIASMA_GIBS_MOLES 0.005
/// Miasma released by a single fart (about 1.5 kPa on the farter's tile before it spreads)
#define MIASMA_FART_MOLES 1.5
/// How long a corpse stays fresh after death
#define MIASMA_CORPSE_GRACE_PERIOD (2 MINUTES)
/// Total miasma a corpse emits before it has fully rotted (20 minutes of rotting)
#define MIASMA_CORPSE_BUDGET (MIASMA_CORPSE_MOLES * 1200)
/// Total miasma a pile of gibs emits before it has fully rotted (10 minutes of rotting)
#define MIASMA_GIBS_BUDGET (MIASMA_GIBS_MOLES * 600)
/// Sources stop emitting onto a tile that already holds this much miasma (about 20 kPa at room temperature)
#define MIASMA_LOCAL_CAP_MOLES 20
/// Research points per mole of miasma burned by dry heat sterilization (40 on BeeStation)
#define MIASMA_RESEARCH_AMOUNT 10
/// Cargo value per mole of miasma in an exported canister (10 on BeeStation)
#define MIASMA_EXPORT_PRICE 2
