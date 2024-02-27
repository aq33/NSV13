//A halfway point between Eclipse and highpop. (Now with 20% less spite) ~Kmc

/*

          _____                _____                    _____            _____                    _____
         /\    \              /\    \                  /\    \          /\    \                  /\    \
        /::\    \            /::\    \                /::\____\        /::\    \                /::\    \
       /::::\    \           \:::\    \              /:::/    /       /::::\    \              /::::\    \
      /::::::\    \           \:::\    \            /:::/    /       /::::::\    \            /::::::\    \
     /:::/\:::\    \           \:::\    \          /:::/    /       /:::/\:::\    \          /:::/\:::\    \
    /:::/__\:::\    \           \:::\    \        /:::/    /       /:::/__\:::\    \        /:::/__\:::\    \
   /::::\   \:::\    \          /::::\    \      /:::/    /       /::::\   \:::\    \       \:::\   \:::\    \
  /::::::\   \:::\    \        /::::::\    \    /:::/    /       /::::::\   \:::\    \    ___\:::\   \:::\    \
 /:::/\:::\   \:::\    \      /:::/\:::\    \  /:::/    /       /:::/\:::\   \:::\    \  /\   \:::\   \:::\    \
/:::/  \:::\   \:::\____\    /:::/  \:::\____\/:::/____/       /:::/  \:::\   \:::\____\/::\   \:::\   \:::\____\
\::/    \:::\  /:::/    /   /:::/    \::/    /\:::\    \       \::/    \:::\  /:::/    /\:::\   \:::\   \::/    /
 \/____/ \:::\/:::/    /   /:::/    / \/____/  \:::\    \       \/____/ \:::\/:::/    /  \:::\   \:::\   \/____/
          \::::::/    /   /:::/    /            \:::\    \               \::::::/    /    \:::\   \:::\    \
           \::::/    /   /:::/    /              \:::\    \               \::::/    /      \:::\   \:::\____\
           /:::/    /    \::/    /                \:::\    \              /:::/    /        \:::\  /:::/    /
          /:::/    /      \/____/                  \:::\    \            /:::/    /          \:::\/:::/    /
         /:::/    /                                 \:::\    \          /:::/    /            \::::::/    /
        /:::/    /                                   \:::\____\        /:::/    /              \::::/    /
        \::/    /                                     \::/    /        \::/    /                \::/    /
         \/____/                                       \/____/          \/____/                  \/____/


*/

//There is viro on atlas :)
//MAP_REMOVE_JOB(virologist)
//Civilian guys without an office
MAP_REMOVE_JOB(lawyer)
//Most of security - Because these guys aren't too useful in a brig this SMALL
MAP_REMOVE_JOB(deputy)
MAP_REMOVE_JOB(brig_phys)
//Munitions
//MAP_REMOVE_JOB(deck_tech)

/datum/uplink_item/explosives/syndicate_bomb/New()
    . = ..()

    if(SSmapping?.config?.map_name != JOB_MODIFICATION_MAP_NAME)
        return
    limited_stock = 0 //This ship is way too small for this shit.
    cant_discount = TRUE
    surplus = 0

/datum/job/pilot/New()
    ..()
    MAP_JOB_CHECK
    total_positions = 2
    spawn_positions = 2

/datum/job/bartender/New()
    ..()
    MAP_JOB_CHECK
    total_positions = 0
    spawn_positions = 0

/datum/job/geneticist/New()
    ..()
    MAP_JOB_CHECK
    total_positions = 1
    spawn_positions = 1

/datum/job/chemist/New()
    ..()
    MAP_JOB_CHECK
    total_positions = 1
    spawn_positions = 1

/datum/job/virologist/New()
    ..()
    MAP_JOB_CHECK
    total_positions = 1
    spawn_positions = 1

/datum/job/paramedic/New()
    ..()
    MAP_JOB_CHECK
    total_positions = 2
    spawn_positions = 2
	
/datum/job/medical_doctor/New()
    ..()
    MAP_JOB_CHECK
    total_positions = 3
    spawn_positions = 3
	
/datum/job/brig_physician/New()
    ..()
    MAP_JOB_CHECK
    total_positions = 1
    spawn_positions = 1

#undef JOB_MODIFICATION_MAP_NAME
