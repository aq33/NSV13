GLOBAL_VAR_INIT(hhStorageTurf, null)
GLOBAL_VAR_INIT(hhmysteryRoomNumber, 1337)

// Someone for the love of god kill whoever indented this with spaces
/obj/item/hilbertshotel
    name = "Hilbert's Hotel"
    desc = "A sphere of what appears to be an intricate network of bluespace. Observing it in detail seems to give you a headache as you try to comprehend the infinite amount of infinitesimally distinct points on its surface."
    icon_state = "hilbertshotel"
    w_class = WEIGHT_CLASS_SMALL
    resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
    var/datum/map_template/hilbertshotel/hotelRoomTemp
    var/datum/map_template/hilbertshotel/empty/hotelRoomTempEmpty
    var/datum/map_template/hilbertshotel/lore/hotelRoomTempLore
    var/list/activeRooms = list()
    var/list/storedRooms = list()
    var/storageTurf
    //Lore Stuff
    var/ruinSpawned = FALSE
    var/mysteryRoom

/obj/item/hilbertshotel/Initialize(mapload)
    . = ..()
    //Load templates
    hotelRoomTemp = new()
    hotelRoomTempEmpty = new()
    hotelRoomTempLore = new()
    var/area/currentArea = get_area(src)
    if(currentArea.type == /area/ruin/space/has_grav/hilbertresearchfacility)
        ruinSpawned = TRUE

/obj/item/hilbertshotel/Destroy()
    ejectRooms()
    return ..()

/obj/item/hilbertshotel/attack(mob/living/M, mob/living/user)
    if(M.mind)
        to_chat(user, "<span class='notice'>Zapraszasz [M] do hotelu.</span>")
        promptAndCheckIn(M)
    else
        to_chat(user, "<span class='warning'>[M] nie jest dość inteligentny, by zrozumieć, jak używać tego urządzenia!</span>")

/obj/item/hilbertshotel/attack_self(mob/user)
    . = ..()
    promptAndCheckIn(user)

/obj/item/hilbertshotel/proc/promptAndCheckIn(mob/user)
    var/chosenRoomNumber = input(user, "W którym pokoju chcesz się zameldować?", "Numer pokoju") as null|num
    if(!chosenRoomNumber)
        return
    if(chosenRoomNumber > SHORT_REAL_LIMIT)
        to_chat(user, "<span class='warning'>Musisz zameldować się w pierwszych [SHORT_REAL_LIMIT] pokojach, zanim przejdziesz do pokoju o wyższym numerze!</span>")
        return
    if((chosenRoomNumber < 1) || (chosenRoomNumber != round(chosenRoomNumber)))
        to_chat(user, "<span class='warning'>To nie jest prawidłowy numer pokoju!</span>")
        return
    if(ismob(loc))
        if(user == loc) //Not always the same as user
            forceMove(get_turf(user))
    if(!storageTurf) //Blame subsystems for not allowing this to be in Initialize
        if(!GLOB.hhStorageTurf)
            var/datum/map_template/hilbertshotelstorage/storageTemp = new()
            var/datum/turf_reservation/storageReservation = SSmapping.RequestBlockReservation(3, 3)
            storageTemp.load(locate(storageReservation.bottom_left_coords[1], storageReservation.bottom_left_coords[2], storageReservation.bottom_left_coords[3]))
            GLOB.hhStorageTurf = locate(storageReservation.bottom_left_coords[1]+1, storageReservation.bottom_left_coords[2]+1, storageReservation.bottom_left_coords[3])
        else
            storageTurf = GLOB.hhStorageTurf
    if(tryActiveRoom(chosenRoomNumber, user))
        return
    if(tryStoredRoom(chosenRoomNumber, user))
        return
    sendToNewRoom(chosenRoomNumber, user)


/obj/item/hilbertshotel/proc/tryActiveRoom(var/roomNumber, var/mob/user)
    if(activeRooms["[roomNumber]"])
        var/datum/turf_reservation/roomReservation = activeRooms["[roomNumber]"]
        do_sparks(3, FALSE, get_turf(user))
        user.forceMove(locate(roomReservation.bottom_left_coords[1] + hotelRoomTemp.landingZoneRelativeX, roomReservation.bottom_left_coords[2] + hotelRoomTemp.landingZoneRelativeY, roomReservation.bottom_left_coords[3]))
        return TRUE
    else
        return FALSE

/obj/item/hilbertshotel/proc/tryStoredRoom(var/roomNumber, var/mob/user)
    if(storedRooms["[roomNumber]"])
        var/datum/turf_reservation/roomReservation = SSmapping.RequestBlockReservation(hotelRoomTemp.width, hotelRoomTemp.height)
        hotelRoomTempEmpty.load(locate(roomReservation.bottom_left_coords[1], roomReservation.bottom_left_coords[2], roomReservation.bottom_left_coords[3]))
        var/turfNumber = 1
        for(var/i=0, i<hotelRoomTemp.width, i++)
            for(var/j=0, j<hotelRoomTemp.height, j++)
                for(var/atom/movable/A in storedRooms["[roomNumber]"][turfNumber])
                    if(istype(A.loc, /obj/item/abstracthotelstorage))//Don't want to recall something thats been moved
                        A.forceMove(locate(roomReservation.bottom_left_coords[1] + i, roomReservation.bottom_left_coords[2] + j, roomReservation.bottom_left_coords[3]))
                turfNumber++
        for(var/obj/item/abstracthotelstorage/S in storageTurf)
            if((S.roomNumber == roomNumber) && (S.parentSphere == src))
                qdel(S)
        storedRooms -= "[roomNumber]"
        activeRooms["[roomNumber]"] = roomReservation
        linkTurfs(roomReservation, roomNumber)
        do_sparks(3, FALSE, get_turf(user))
        user.forceMove(locate(roomReservation.bottom_left_coords[1] + hotelRoomTemp.landingZoneRelativeX, roomReservation.bottom_left_coords[2] + hotelRoomTemp.landingZoneRelativeY, roomReservation.bottom_left_coords[3]))
        return TRUE
    else
        return FALSE

/obj/item/hilbertshotel/proc/sendToNewRoom(var/roomNumber, var/mob/user)
    var/datum/turf_reservation/roomReservation = SSmapping.RequestBlockReservation(hotelRoomTemp.width, hotelRoomTemp.height)
    if(ruinSpawned)
        mysteryRoom = GLOB.hhmysteryRoomNumber
        if(roomNumber == mysteryRoom)
            hotelRoomTempLore.load(locate(roomReservation.bottom_left_coords[1], roomReservation.bottom_left_coords[2], roomReservation.bottom_left_coords[3]))
        else
            hotelRoomTemp.load(locate(roomReservation.bottom_left_coords[1], roomReservation.bottom_left_coords[2], roomReservation.bottom_left_coords[3]))
    else
        hotelRoomTemp.load(locate(roomReservation.bottom_left_coords[1], roomReservation.bottom_left_coords[2], roomReservation.bottom_left_coords[3]))
    activeRooms["[roomNumber]"] = roomReservation
    linkTurfs(roomReservation, roomNumber)
    do_sparks(3, FALSE, get_turf(user))
    user.forceMove(locate(roomReservation.bottom_left_coords[1] + hotelRoomTemp.landingZoneRelativeX, roomReservation.bottom_left_coords[2] + hotelRoomTemp.landingZoneRelativeY, roomReservation.bottom_left_coords[3]))

/obj/item/hilbertshotel/proc/linkTurfs(var/datum/turf_reservation/currentReservation, var/currentRoomnumber)
    var/area/hilbertshotel/currentArea = get_area(locate(currentReservation.bottom_left_coords[1], currentReservation.bottom_left_coords[2], currentReservation.bottom_left_coords[3]))
    currentArea.name = "Hilbert's Hotel Room [currentRoomnumber]"
    currentArea.parentSphere = src
    currentArea.storageTurf = storageTurf
    currentArea.roomnumber = currentRoomnumber
    currentArea.reservation = currentReservation
    currentArea.virtual_z_value = get_new_virtual_z()
    for(var/turf/closed/indestructible/hoteldoor/door in currentArea)
        door.parentSphere = src
        door.desc = "The door to this hotel room. The placard reads 'Room [currentRoomnumber]'. Strange, this door doesnt even seem openable. The doorknob, however, seems to buzz with unusual energy...<br /><span class='info'>Alt-Click to look through the peephole.</span>"
    for(var/turf/open/space/bluespace/BSturf in currentArea)
        BSturf.parentSphere = src

/obj/item/hilbertshotel/proc/ejectRooms()
    if(activeRooms.len)
        for(var/x in activeRooms)
            var/datum/turf_reservation/room = activeRooms[x]
            for(var/i=0, i<hotelRoomTemp.width, i++)
                for(var/j=0, j<hotelRoomTemp.height, j++)
                    for(var/atom/movable/A in locate(room.bottom_left_coords[1] + i, room.bottom_left_coords[2] + j, room.bottom_left_coords[3]))
                        if(ismob(A))
                            var/mob/M = A
                            if(M.mind)
                                to_chat(M, "<span class='warning'>Gdy sfera się rozpada, nagle zostajesz wyrzucony w głąb kosmosu!")
                        var/max = world.maxx-TRANSITIONEDGE
                        var/min = 1+TRANSITIONEDGE
                        var/list/possible_transtitons = list()
                        for(var/AZ in SSmapping.z_list)
                            var/datum/space_level/D = AZ
                            if (D.linkage == CROSSLINKED)
                                possible_transtitons += D.z_value
                        var/_z = pick(possible_transtitons)
                        var/_x = rand(min,max)
                        var/_y = rand(min,max)
                        var/turf/T = locate(_x, _y, _z)
                        A.forceMove(T)
            qdel(room)

    if(storedRooms.len)
        for(var/x in storedRooms)
            var/list/atomList = storedRooms[x]
            for(var/atom/movable/A in atomList)
                var/max = world.maxx-TRANSITIONEDGE
                var/min = 1+TRANSITIONEDGE
                var/list/possible_transtitons = list()
                for(var/AZ in SSmapping.z_list)
                    var/datum/space_level/D = AZ
                    if (D.linkage == CROSSLINKED)
                        possible_transtitons += D.z_value
                var/_z = pick(possible_transtitons)
                var/_x = rand(min,max)
                var/_y = rand(min,max)
                var/turf/T = locate(_x, _y, _z)
                A.forceMove(T)

//Template Stuff
/datum/map_template/hilbertshotel
    name = "Hilbert's Hotel Room"
    mappath = '_maps/templates/hilbertshotel.dmm'
    var/landingZoneRelativeX = 2
    var/landingZoneRelativeY = 8

/datum/map_template/hilbertshotel/empty
    name = "Empty Hilbert's Hotel Room"
    mappath = '_maps/templates/hilbertshotelempty.dmm'

/datum/map_template/hilbertshotel/lore
    name = "Doctor Hilbert's Deathbed"
    mappath = '_maps/templates/hilbertshotellore.dmm'

/datum/map_template/hilbertshotelstorage
    name = "Hilbert's Hotel Storage"
    mappath = '_maps/templates/hilbertshotelstorage.dmm'


//Turfs and Areas
/turf/closed/indestructible/hotelwall
	name = "hotel wall"
	desc = "A wall designed to protect the security of the hotel's guests."
	icon_state = "hotelwall"
	canSmoothWith = list(/turf/closed/indestructible/hotelwall)
	explosion_block = INFINITY

/turf/open/indestructible/hotelwood
    desc = "Stylish dark wood with extra reinforcement. Secured firmly to the floor to prevent tampering."
    icon_state = "wood"
    footstep = FOOTSTEP_WOOD
    tiled_dirt = FALSE

/turf/open/indestructible/hoteltile
    desc = "Smooth tile with extra reinforcement. Secured firmly to the floor to prevent tampering."
    icon_state = "showroomfloor"
    footstep = FOOTSTEP_FLOOR
    tiled_dirt = FALSE

/turf/open/space/bluespace
    name = "\proper bluespace hyperzone"
    icon_state = "bluespace"
    baseturfs = /turf/open/space/bluespace
    flags_1 = NOJAUNT_1
    explosion_block = INFINITY
    var/obj/item/hilbertshotel/parentSphere

/turf/open/space/bluespace/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
    . = ..()
    arrived.forceMove(get_turf(parentSphere))
    do_sparks(3, FALSE, get_turf(arrived))

/turf/closed/indestructible/hoteldoor
    name = "Hotel Door"
    icon_state = "hoteldoor"
    explosion_block = INFINITY
    var/obj/item/hilbertshotel/parentSphere

/turf/closed/indestructible/hoteldoor/proc/promptExit(mob/living/user)
    if(!isliving(user))
        return
    if(!user.mind)
        return
    if(!parentSphere)
        to_chat(user, "<span class='warning'>Drzwi chyba się zepsuły i nie chcą działać!</span>")
        return
    if(alert(user, "Hotel Hilberta przypomina, że choć zrobimy wszystko, by chronić pozostawione przez ciebie rzeczy, nie gwarantujemy ich bezpieczeństwa podczas twojej nieobecności, zwłaszcza zdrowia żywych stworzeń. Mając to na uwadze, czy jesteś gotów wyjść?", "Exit", "Leave", "Stay") == "Leave")
        if(!(user.mobility_flags & MOBILITY_MOVE) || (get_dist(get_turf(src), get_turf(user)) > 1)) //no teleporting around if they're dead or moved away during the prompt.
            return
        user.forceMove(get_turf(parentSphere))
        do_sparks(3, FALSE, get_turf(user))

/turf/closed/indestructible/hoteldoor/attack_ghost(mob/dead/observer/user)
    if(!isobserver(user) || !parentSphere)
        return ..()
    user.forceMove(get_turf(parentSphere))

//If only this could be simplified...
/turf/closed/indestructible/hoteldoor/attack_tk(mob/user)
    return //need to be close.

/turf/closed/indestructible/hoteldoor/attack_hand(mob/user)
    promptExit(user)

/turf/closed/indestructible/hoteldoor/attack_animal(mob/user)
    promptExit(user)

/turf/closed/indestructible/hoteldoor/attack_paw(mob/user)
    promptExit(user)

/turf/closed/indestructible/hoteldoor/attack_hulk(mob/living/carbon/human/user, does_attack_animation)
    promptExit(user)

/turf/closed/indestructible/hoteldoor/attack_larva(mob/user)
    promptExit(user)

/turf/closed/indestructible/hoteldoor/attack_slime(mob/user)
    promptExit(user)

/turf/closed/indestructible/hoteldoor/attack_robot(mob/user)
    if(get_dist(get_turf(src), get_turf(user)) <= 1)
        promptExit(user)

/turf/closed/indestructible/hoteldoor/AltClick(mob/user)
    . = ..()
    if(get_dist(get_turf(src), get_turf(user)) <= 1)
        to_chat(user, "<span class='notice'>Zerkasz przez bluespace'owy wizjer w drzwiach...</span>")
        user.reset_perspective(parentSphere)
        user.set_machine(src)
        var/datum/action/peepholeCancel/PHC = new
        user.overlay_fullscreen("remote_view", /atom/movable/screen/fullscreen/impaired, 1)
        PHC.Grant(user)

/turf/closed/indestructible/hoteldoor/check_eye(mob/user)
    if(get_dist(get_turf(src), get_turf(user)) >= 2)
        user.unset_machine()
        for(var/datum/action/peepholeCancel/PHC in user.actions)
            PHC.Trigger()

/datum/action/peepholeCancel
    name = "Cancel View"
    desc = "Stop looking through the bluespace peephole."
    button_icon_state = "cancel_peephole"

/datum/action/peepholeCancel/Trigger()
    . = ..()
    to_chat(owner, "<span class='warning'>Odsuwasz się od wizjera.</span>")
    owner.reset_perspective()
    owner.clear_fullscreen("remote_view", 0)
    qdel(src)

/area/hilbertshotel
    name = "Hilbert's Hotel Room"
    icon_state = "hilbertshotel"
    requires_power = FALSE
    has_gravity = TRUE
    teleport_restriction = TELEPORT_ALLOW_NONE
    area_flags = HIDDEN_AREA
    dynamic_lighting = DYNAMIC_LIGHTING_FORCED
    ambientsounds = list('sound/ambience/servicebell.ogg')
    var/roomnumber = 0
    var/obj/item/hilbertshotel/parentSphere
    var/datum/turf_reservation/reservation
    var/turf/storageTurf
    var/virtual_z_value

/area/hilbertshotel/get_virtual_z(turf/T)
    if(virtual_z_value)
        return virtual_z_value
    else
        return ..(T)

/area/hilbertshotel/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
    . = ..()
    if(istype(arrived, /obj/item/hilbertshotel))
        relocate(arrived)
    var/list/obj/item/hilbertshotel/hotels = arrived.GetAllContents(/obj/item/hilbertshotel)
    for(var/obj/item/hilbertshotel/H in hotels)
        if(parentSphere == H)
            relocate(H)

/area/hilbertshotel/proc/relocate(obj/item/hilbertshotel/H)
    if(prob(0.135685)) //Because screw you
        qdel(H)
        return
    var/turf/targetturf = find_safe_turf()
    if(!targetturf)
        if(GLOB.blobstart.len > 0)
            targetturf = get_turf(pick(GLOB.blobstart))
        else
            CRASH("Unable to find a blobstart landmark")
    var/turf/T = get_turf(H)
    var/area/A = T.loc
    log_game("[H] entered itself. Moving it to [loc_name(targetturf)].")
    message_admins("[H] entered itself. Moving it to [ADMIN_VERBOSEJMP(targetturf)].")
    for(var/mob/M in A)
        to_chat(M, "<span class='danger'>[H] niemal imploduje, ale szybko się odbija, wystrzeliwując w losowy punkt w kosmosie!</span>")
    H.forceMove(targetturf)

/area/hilbertshotel/Exited(atom/movable/gone, direction)
    . = ..()
    if(ismob(gone))
        var/mob/M = gone
        if(M.mind)
            var/stillPopulated = FALSE
            var/list/currentLivingMobs = GetAllContents(/mob/living) //Got to catch anyone hiding in anything
            for(var/mob/living/L in currentLivingMobs) //Check to see if theres any sentient mobs left.
                if(L.mind)
                    stillPopulated = TRUE
                    break
            if(!stillPopulated)
                storeRoom()

/area/hilbertshotel/proc/storeRoom()
    var/roomSize = (reservation.top_right_coords[1]-reservation.bottom_left_coords[1]+1)*(reservation.top_right_coords[2]-reservation.bottom_left_coords[2]+1)
    var/storage[roomSize]
    var/turfNumber = 1
    var/obj/item/abstracthotelstorage/storageObj = new(storageTurf)
    storageObj.roomNumber = roomnumber
    storageObj.parentSphere = parentSphere
    storageObj.name = "Room [roomnumber] Storage"
    for(var/i=0, i<parentSphere.hotelRoomTemp.width, i++)
        for(var/j=0, j<parentSphere.hotelRoomTemp.height, j++)
            var/list/turfContents = list()
            for(var/atom/movable/A in locate(reservation.bottom_left_coords[1] + i, reservation.bottom_left_coords[2] + j, reservation.bottom_left_coords[3]))
                if(ismob(A) && !isliving(A))
                    continue //Don't want to store ghosts
                turfContents += A
                A.forceMove(storageObj)
            storage[turfNumber] = turfContents
            turfNumber++
    parentSphere.storedRooms["[roomnumber]"] = storage
    parentSphere.activeRooms -= "[roomnumber]"
    qdel(reservation)

/area/hilbertshotelstorage
    name = "Hilbert's Hotel Storage Room"
    icon_state = "hilbertshotel"
    requires_power = FALSE
    area_flags = HIDDEN_AREA | UNIQUE_AREA
    has_gravity = TRUE
    teleport_restriction = TELEPORT_ALLOW_NONE

/obj/item/abstracthotelstorage
    anchored = TRUE
    invisibility = INVISIBILITY_ABSTRACT
    resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
    item_flags = ABSTRACT
    var/roomNumber
    var/obj/item/hilbertshotel/parentSphere

/obj/item/abstracthotelstorage/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
    . = ..()
    if(ismob(arrived))
        var/mob/M = arrived
        M.notransform = TRUE

/obj/item/abstracthotelstorage/Exited(atom/movable/gone, direction)
    . = ..()
    if(ismob(gone))
        var/mob/M = gone
        M.notransform = FALSE

//Space Ruin stuff
/area/ruin/space/has_grav/hilbertresearchfacility
    name = "Hilbert Research Facility"

/obj/item/analyzer/hilbertsanalyzer
    name = "custom rigged analyzer"
    desc = "A hand-held environmental scanner which reports current gas levels. This one seems custom rigged to additionally be able to analyze some sort of bluespace device."
    icon_state = "hilbertsanalyzer"

/obj/item/analyzer/hilbertsanalyzer/afterattack(atom/target, mob/user, proximity)
    . = ..()
    if(istype(target, /obj/item/hilbertshotel))
        if(!proximity)
            to_chat(user, "<span class='warning'>Jest za daleko, by to zeskanować!</span>")
            return
        var/obj/item/hilbertshotel/sphere = target
        if(sphere.activeRooms.len)
            to_chat(user, "Obecnie zajęte pokoje:")
            for(var/roomnumber in sphere.activeRooms)
                to_chat(user, roomnumber)
        else
            to_chat(user, "Brak zajętych pokoi.")
        if(sphere.storedRooms.len)
            to_chat(user, "Zwolnione pokoje:")
            for(var/roomnumber in sphere.storedRooms)
                to_chat(user, roomnumber)
        else
            to_chat(user, "Brak zwolnionych pokoi.")

/obj/effect/mob_spawn/human/doctorhilbert
	name = "Doctor Hilbert"
	mob_name = "Doctor Hilbert"
	mob_gender = "male"
	assignedrole = null
	ghost_usable = FALSE
	oxy_damage = 500
	mob_species = /datum/species/skeleton
	id_job = "Head Researcher"
	id_access = ACCESS_RESEARCH
	id_access_list = list(ACCESS_AWAY_GENERIC3, ACCESS_RESEARCH)
	instant = TRUE
	id = /obj/item/card/id/silver
	uniform = /obj/item/clothing/under/rank/rnd/research_director
	shoes = /obj/item/clothing/shoes/sneakers/brown
	back = /obj/item/storage/backpack/satchel/leather
	suit = /obj/item/clothing/suit/toggle/labcoat
	use_cooldown = TRUE
	banType = ROLE_HOTEL_STAFF

/obj/item/paper/crumpled/docslogs
	name = "Research Logs"

/obj/item/paper/crumpled/docslogs/Initialize(mapload)
	. = ..()
	GLOB.hhmysteryRoomNumber = rand(1, SHORT_REAL_LIMIT)
	default_raw_text = {"<h4><center>Dziennik badań</center></h4>
	Chyba jestem na tropie czegoś!<br>
	Dziwne, zakrzywiające przestrzeń właściwości bluespace są znane od dawna, ale być może jestem o krok od odkrycia nowego sposobu ich wykorzystania.<br>
	Za wcześnie, by mówić na pewno, ale może to być początek czegoś naprawdę ważnego!<br>
	Na pewno zapiszę każdy większy przełom. To może być dla mnie za dużo do ogarnięcia w pojedynkę, może jednak powinienem zatrudnić tego sekretarza...<br>
	<h4>Przełom!</h4>
	Nie mogę w to uwierzyć, ale udało mi się! Akurat gdy byłem pewien, że to niemożliwe, dokonałem ostatniego potrzebnego przełomu.<br>
	Wykorzystując efekty dylatacji przestrzeni wywoływane przez określone struktury bluespace w połączeniu z precyzyjnym rachunkiem geometrycznym, odkryłem sposób na powiązanie nieskończonej ilości przestrzeni ze skończonym obszarem!<br>
	Choć możliwe zastosowania są nieskończone, na razie wykorzystałem to w dość zgrabny sposób, projektując system, który rekurencyjnie tworzy pokoje podprzestrzenne i łączy je przestrzennie z dowolnym z nieskończenie wielu nieskończenie małych, różnych punktów na powierzchni sfery.<br>
	Nazywam go: Hotel Hilberta!<br>
	<h4>Żegnajcie</h4>
	Nie mogę już tego znieść. Wiem, co będzie dalej, a strach przed tym, co nadchodzi, nie pozwala mi dalej pracować.<br>
	Każdy głupiec w mojej dziedzinie słyszał te historie. Nie żebym w nie nie wierzył, po prostu... chyba nie doceniłem wagi własnych badań...<br>
	Robert zgłasza, że dziwni, wścibscy goście, którzy zadają pytania, do których nie mają prawa, przychodzą coraz częściej. Poprosiłem go, by trzymał wszystko pod ścisłą blokadą, i na stałe zwolniłem wszystkich pozostałych asystentów.<br>
	Poleciłem mu też używać metody szyfrowania, o której rozmawialiśmy, do wszystkich ważnych danych liczbowych. Biedny chłopak... chyba nie do końca rozumie, w co się wpakował...<br>
	Jasne jest, co będzie teraz. Pewnego dnia pojawią się nieproszeni i przywłaszczą sobie moje badania, a ze mnie zostaną tylko podziurawione kulami zwłoki dryfujące w kosmosie.<br>
	Nie mogę zostać i na to pozwolić.<br>
	Uciekam w to, co w ogóle sprowadziło na mnie wszystkie te kłopoty - do mojego hotelu.<br>
	Będę w <u>[uppertext(num2hex(GLOB.hhmysteryRoomNumber, 0))]</u> (zrozumie to każdy, kto powinien)<br>
	Przykro mi, że muszę odejść w ten sposób. Może pewnego dnia wszystko się zmieni i będzie można bezpiecznie wrócić... może...<br>
	Żegnajcie<br>
	<br>
	<i>Doktor Hilbert</i>"}

/obj/item/paper/crumpled/robertsworkjournal
	name = "Work Journal"
	default_raw_text = {"<h4>Pierwszy tydzień!</h4>
	Pierwszy tydzień w nowej pracy. To posada sekretarza, ale co tam, byle płacili rachunki. Poza tym wygląda na to, że dzieją się tu ciekawe rzeczy.<br>
	Doktor mówi, że najlepiej, żebym nie rozmawiał otwarcie z innymi o jego badaniach; chyba nie chce, żeby coś wyciekło. Parę razy złapałem się na tym, że coś mi się wymsknęło w rozmowie, trudno się nie chwalić czymś tak fajnym!<br>
	Sam nie wiem, czemu postanowiłem to spisywać. Doktor chyba zapisuje wszystko. Mówi, że na wypadek, gdyby odkrył coś ważnego.<br>
	Pewnie dlatego ja też to robię, zawsze chciałem być częścią czegoś ważnego.<br>
	Za nową pracę i za stanie się częścią czegoś ważnego!<br>
	<h4>Dziwne czasy...</h4>
	Robi się tu trochę dziwnie. Zaledwie kilka tygodni po niesamowitym przełomie Doktora zaczęli bez zapowiedzi pojawiać się dziwni goście, wypytujący o dziwne rzeczy związane z jego pracą.<br>
	Wiedziałem, że Doktor nie przepada za towarzystwem, ale nawet on wydawał się dziwnie zdenerwowany, gdy powiedziałem mu o gościach.<br>
	Powiedział, że od teraz musimy wszystko ściśle zabezpieczać, nawet przed innymi pracownikami.<br>
	Mówił też coś o zabezpieczaniu danych, coś o heksach. Co to znaczy? Jakaś klątwa? Doktor nigdy nie wydawał mi się typem od magii...<br>
	Często używa wielu wielkich naukowych słów, których za bardzo nie rozumiem, ale w sumie mi się to podoba, czuję się, jakbym był świadkiem czegoś wielkiego.<br>
	Mam nadzieję, że wszystko niedługo wróci do normy, ale chyba taka jest cena bycia częścią czegoś ważnego.<br>
	<h4>Chyba ostatni dzień?</h4>
	Oficjalnie robi się dla mnie za dziwnie.<br>
	Goście przychodzą coraz częściej i wszyscy wydają się coraz bardziej agresywni i wścibscy. Zaczynam rozumieć, czemu tak denerwowali Doktora, mnie też zaczynają przerażać.<br>
	Jakiś czas temu Doktor kazał mi trzymać to miejsce pod ścisłą blokadą i odmawiać wstępu wszystkim innym, łącznie z dawnymi pracownikami.<br>
	Ale co najdziwniejsze?<br>
	Od kilku dni nie widziałem Doktora. Nie jest niczym niezwykłym, że całymi dniami pracuje w laboratorium, ale gdy wczoraj tam zajrzałem - nigdzie go nie było! Nie ryzykowałem dalszego węszenia, przez ostatnie tygodnie Doktor miał zwyczaj zostawiać włączone systemy obronne.<br>
	Myślę, że może czas to rzucić. Bez szefa niewiele zrobię, a poza tym robi się podejrzanie. Chciałem być częścią czegoś ważnego, ale trzeba wiedzieć, kiedy grać bezpiecznie.<br>
	Jak zawsze mawiał mój tata: „Mądrzy zdobywają sławę, ale rozważni przeżywają...”<br>
	<br>
	<i>Robert P.</i>"}

/obj/item/paper/crumpled/bloody/docsdeathnote
	name = "note"
	default_raw_text = {"To już koniec, prawda?<br>
	Nikt nie przyjdzie z pomocą, tyle stało się jasne.<br>
	Jasne, jest samotnie, ale czy mam duży wybór? Przynajmniej zabrałem ze sobą analizator, bez niego nie powinni mnie znaleźć.<br>
	Kto wie, kto tam na mnie czeka. Albo zginę tam z ich rąk, albo umrę tu wolniejszą, nieco wygodniejszą śmiercią.<br>
	Każdego dnia czuję, jak coraz bardziej się wymykam, fizycznie i psychicznie. Kto wie, co będzie teraz...<br>
	Heh, więc to prawda, to musi być nieunikniona droga wszystkich wielkich umysłów... niech więc tak będzie.<br>
	<br>
	<br>
	<br>
	<i>Wybierz pokój, w sferę wejdź śmiało<br>
	Połóż głowę, a zrozumiesz niemało<br>
	Za każdym zakrętem miejsca jest więcej<br>
	Nie wszystko, co policzalne, kończy się wreszcie...<i>"}
