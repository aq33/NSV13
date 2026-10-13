// AQUILA - pająki z tgstation

#define isspider(A) (istype(A, /mob/living/simple_animal/hostile/spider))

#define ROLE_SPIDER "Spider"

/// Pająk już wyssał te zwłoki, więcej wzbogaconych jaj z nich nie będzie
#define TRAIT_SPIDER_CONSUMED "spider_consumed"

/// Ile ładunków na jaja daje wyssanie jednego człowieka
#define SPIDER_EGG_CHARGES_PER_BODY 2

#define span_spiderbroodmother(str) ("<span class='spiderbroodmother'>" + str + "</span>")
#define span_spiderbreacher(str) ("<span class='spiderbreacher'>" + str + "</span>")
#define span_spiderscout(str) ("<span class='spiderscout'>" + str + "</span>")

/// Identyfikatory modyfikatorów prędkości pająków
#define MOVESPEED_ID_SPIDER_PLAYER "spider_player_speed"
#define MOVESPEED_ID_SPIDER_WEB_WALKER "spider_web_walker"
#define MOVESPEED_ID_SPIDER_DEFENSIVE "spider_viper_defensive"

/// Spowolnienie poza siecią (tg: /datum/movespeed_modifier/*_web)
#define SPIDER_WEB_SLOWDOWN_FAST 0.2
#define SPIDER_WEB_SLOWDOWN_SPIDERLING 0.7
#define SPIDER_WEB_SLOWDOWN_AVERAGE 1.2
#define SPIDER_WEB_SLOWDOWN_BELOW_AVERAGE 2.5
#define SPIDER_WEB_SLOWDOWN_SLOW 5
