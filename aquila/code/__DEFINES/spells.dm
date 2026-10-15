// AQUILA - definicje systemu zaklęć /datum/action/cooldown/spell (port z tgstation przez Yogstation)

/// Akcja wymaga wolnych rąk (nie skuty, może używać przedmiotów)
#define AB_CHECK_HANDS_BLOCKED (1<<4)
/// Akcja wymaga możliwości ruchu
#define AB_CHECK_IMMOBILE (1<<5)

#define INVOCATION_NONE "none"

// Wymagania zaklęcia (spell_requirements)
/// Tylko na stacji
#define SPELL_REQUIRES_STATION (1<<0)
/// Tylko z umysłem
#define SPELL_REQUIRES_MIND (1<<1)
/// Tylko jako człowiek
#define SPELL_REQUIRES_HUMAN (1<<2)
/// Nie da się rzucić z ochroną antymagiczną
#define SPELL_REQUIRES_NO_ANTIMAGIC (1<<3)
/// Da się rzucić w zmaterializowanej formie (jaunt itp.)
#define SPELL_CASTABLE_WHILE_PHASED (1<<4)
/// Da się rzucić jako mózg w MMI
#define SPELL_CASTABLE_AS_BRAIN (1<<5)
/// Da się rzucić bez wypowiadania inkantacji
#define SPELL_CASTABLE_WITHOUT_INVOCATION (1<<6)

// Wynik before_cast()
/// Przerywa rzucanie
#define SPELL_CANCEL_CAST (1<<0)
/// Bez inkantacji i dźwięku
#define SPELL_NO_FEEDBACK (1<<1)
/// Bez odnowienia od razu po rzuceniu (np. zaklęcia dotyku)
#define SPELL_NO_IMMEDIATE_COOLDOWN (1<<2)

// Rodzaje ochrony antymagicznej (antimagic_flags)
#define MAGIC_RESISTANCE (1<<0)
/// Ochrona umysłu (czapka z folii)
#define MAGIC_RESISTANCE_MIND (1<<1)
#define MAGIC_RESISTANCE_HOLY (1<<2)

/// Zasób antagonisty płacony za zaklęcia (psi darkspawna)
#define ANTAG_RESOURCE_DARKSPAWN "psi"

/// Z umysłu: czy stać nas na koszt (resource, amount) - zwraca TRUE, jeśli tak
#define COMSIG_MIND_CHECK_ANTAG_RESOURCE "mind_check_antag_resource"
/// Z umysłu: zapłać koszt (list/resource_costs)
#define COMSIG_MIND_SPEND_ANTAG_RESOURCE "mind_spend_antag_resource"

/// Z moba: zdolność zaczyna działać (datum/action/cooldown/spell)
#define COMSIG_MOB_ABILITY_STARTED "mob_ability_base_started"
	#define COMPONENT_BLOCK_ABILITY_START (1<<0)
/// Z zaklęcia przed rzuceniem (atom/cast_on), może zwrócić flagi SPELL_*
#define COMSIG_SPELL_BEFORE_CAST "spell_before_cast"
/// Z zaklęcia po rzuceniu (atom/cast_on)
#define COMSIG_SPELL_AFTER_CAST "spell_after_cast"

/// Krótsze odnowienie zaklęć (x0.66)
#define TRAIT_FAST_COOLDOWNS "fast_cooldowns"
