
///////////////////////////////////////////////Condiments
//Notes by Darem: The condiments food-subtype is for stuff you don't actually eat but you use to modify existing food. They all
//	leave empty containers when used up and can be filled/re-filled with other items. Formatting for first section is identical
//	to mixed-drinks code. If you want an object that starts pre-loaded, you need to make it in addition to the other code.

//Food items that aren't eaten normally and leave an empty container behind.
/obj/item/reagent_containers/food/condiment
	name = "condiment bottle"
	desc = "Just your average condiment bottle."
	icon = 'icons/obj/food/containers.dmi'
	icon_state = "bottle"
	item_state = "beer" //Generic held-item sprite until unique ones are made.
	lefthand_file = 'icons/mob/inhands/misc/food_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/food_righthand.dmi'
	reagent_flags = OPENCONTAINER
	obj_flags = UNIQUE_RENAME
	possible_transfer_amounts = list(1, 5, 10, 15, 20, 25, 30, 50)
	volume = 50
	fill_icon_thresholds = list(0, 10, 25, 50, 75, 100)
	/// Icon (icon_state) to be used when container becomes empty (no change if falsy)
	var/icon_empty
	/// Holder for original icon_state value if it was overwritten by icon_emty to change back to
	var/icon_preempty

/obj/item/reagent_containers/food/condiment/update_icon_state()
	. = ..()
	if (reagents.reagent_list.len)
		if (icon_preempty)
			icon_state = icon_preempty
			icon_preempty = null
	else
		if (icon_empty && !icon_preempty)
			icon_preempty = icon_state
			icon_state = icon_empty

/obj/item/reagent_containers/food/condiment/suicide_act(mob/living/carbon/user)
	user.visible_message("<span class='suicide'>[user] próbuje zjeść całe [src]! Wygląda na to, że zapomniał, jak działa jedzenie!</span>")
	return OXYLOSS

/obj/item/reagent_containers/food/condiment/attack(mob/M, mob/user, def_zone)

	if(!reagents || !reagents.total_volume)
		to_chat(user, "<span class='warning'>[src] już się skończyło, o nie!</span>")
		return 0

	if(!canconsume(M, user))
		return 0

	if(M == user)
		user.visible_message("<span class='notice'>[user] połyka trochę zawartości [src].</span>", \
			"<span class='notice'>Połykasz trochę zawartości [src].</span>")
	else
		M.visible_message("<span class='warning'>[user] próbuje nakarmić [M] z [src].</span>", \
			"<span class='warning'>[user] próbuje nakarmić cię z [src].</span>")
		if(!do_mob(user, M))
			return
		if(!reagents || !reagents.total_volume)
			return // The condiment might be empty after the delay.
		M.visible_message("<span class='warning'>[user] karmi [M] z [src].</span>", \
			"<span class='warning'>[user] karmi cię z [src].</span>")
		log_combat(user, M, "fed", reagents.log_list())

	var/fraction = min(10/reagents.total_volume, 1)
	reagents.reaction(M, INGEST, fraction)
	reagents.trans_to(M, 10, transfered_by = user)
	playsound(M.loc,'sound/items/drink.ogg', rand(10,50), 1)
	return 1

/obj/item/reagent_containers/food/condiment/afterattack(obj/target, mob/user , proximity)
	. = ..()
	if(!proximity)
		return
	if(istype(target, /obj/structure/reagent_dispensers)) //A dispenser. Transfer FROM it TO us.

		if(!target.reagents.total_volume)
			to_chat(user, "<span class='warning'>[target] jest pusty!</span>")
			return

		if(reagents.total_volume >= reagents.maximum_volume)
			to_chat(user, "<span class='warning'>[src] jest pełny!</span>")
			return

		var/trans = target.reagents.trans_to(src, amount_per_transfer_from_this, transfered_by = user)
		to_chat(user, "<span class='notice'>Napełniasz [src] zawartością [target] ([trans] j.).</span>")

	//Something like a glass or a food item. Player probably wants to transfer TO it.
	else if(target.is_drainable() || IS_EDIBLE(target))
		if(!reagents.total_volume)
			to_chat(user, "<span class='warning'>[src] jest pusty!</span>")
			return
		if(target.reagents.total_volume >= target.reagents.maximum_volume)
			to_chat(user, "<span class='warning'>Nie możesz już nic dodać do [target]!</span>")
			return
		var/trans = src.reagents.trans_to(target, amount_per_transfer_from_this, transfered_by = user)
		to_chat(user, "<span class='notice'>Przelewasz [trans] j. przyprawy do [target].</span>")

/obj/item/reagent_containers/food/condiment/enzyme
	name = "universal enzyme"
	desc = "Used in cooking various dishes."
	icon_state = "enzyme"
	list_reagents = list(/datum/reagent/consumable/enzyme = 50)
	fill_icon_thresholds = null

/obj/item/reagent_containers/food/condiment/enzyme/examine(mob/user)
	. = ..()
	var/datum/chemical_reaction/recipe = get_chemical_reaction(/datum/chemical_reaction/food/american) //NSV13 - our milk + enzyme cheese reaction
	var/milk_required = recipe.required_reagents[/datum/reagent/consumable/milk]
	var/enzyme_required = recipe.required_catalysts[/datum/reagent/consumable/enzyme]
	. += "<span class='notice'>[milk_required] mleka i [enzyme_required] enzymu – i masz ser.</span>"
	. += "<span class='warning'>Pamiętaj, enzym się nie zużywa, więc wlej go z powrotem do butelki, głąbie!</span>"

/obj/item/reagent_containers/food/condiment/sugar
	name = "sugar sack"
	desc = "Tasty spacey sugar!"
	icon_state = "sugar"
	item_state = "carton"
	lefthand_file = 'icons/mob/inhands/equipment/kitchen_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/kitchen_righthand.dmi'
	list_reagents = list(/datum/reagent/consumable/sugar = 50)
	fill_icon_thresholds = null

/obj/item/reagent_containers/food/condiment/sugar/examine(mob/user)
	. = ..()
	var/datum/chemical_reaction/recipe = get_chemical_reaction(/datum/chemical_reaction/food/cakebatter)
	var/flour_required = recipe.required_reagents[/datum/reagent/consumable/flour]
	var/eggyolk_required = recipe.required_reagents[/datum/reagent/consumable/eggyolk]
	var/sugar_required = recipe.required_reagents[/datum/reagent/consumable/sugar]
	. += "<span class='notice'>[flour_required] mąki, [eggyolk_required] żółtka (lub mleka sojowego) i [sugar_required] cukru daje ciasto na tort. Można z niego zrobić ciasto na placek.</span>"

/obj/item/reagent_containers/food/condiment/saltshaker		//Separate from above since it's a small shaker rather then
	name = "salt shaker"											//	a large one.
	desc = "Salt. From space oceans, presumably."
	icon_state = "saltshakersmall"
	icon_empty = "emptyshaker"
	item_state = ""
	possible_transfer_amounts = list(1,20) //for clown turning the lid off
	amount_per_transfer_from_this = 1
	volume = 20
	list_reagents = list(/datum/reagent/consumable/sodiumchloride = 20)
	fill_icon_thresholds = null

/obj/item/reagent_containers/food/condiment/saltshaker/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] zaczyna zamieniać się formą z solniczką! Wygląda na to, że próbuje popełnić samobójstwo!</span>")
	var/newname = "[name]"
	name = "[user.name]"
	user.name = newname
	user.real_name = newname
	desc = "Salt. From dead crew, presumably."
	return (TOXLOSS)

/obj/item/reagent_containers/food/condiment/saltshaker/afterattack(obj/target, mob/living/user, proximity)
	. = ..()
	if(!proximity)
		return
	if(isturf(target))
		if(!reagents.has_reagent(/datum/reagent/consumable/sodiumchloride, 2))
			to_chat(user, "<span class='warning'>Masz za mało soli, by usypać kupkę!</span>")
			return
		user.visible_message("<span class='notice'>[user] sypie trochę soli na [target].</span>", "<span class='notice'>Sypiesz trochę soli na [target].</span>")
		reagents.remove_reagent(/datum/reagent/consumable/sodiumchloride, 2)
		new/obj/effect/decal/cleanable/food/salt(target)
		return

/obj/item/reagent_containers/food/condiment/peppermill
	name = "pepper mill"
	desc = "Often used to flavor food or make people sneeze."
	icon_state = "peppermillsmall"
	icon_empty = "emptyshaker"
	item_state = ""
	possible_transfer_amounts = list(1,20) //for clown turning the lid off
	amount_per_transfer_from_this = 1
	volume = 20
	list_reagents = list(/datum/reagent/consumable/blackpepper = 20)
	fill_icon_thresholds = null

/obj/item/reagent_containers/food/condiment/mesophilic
	name = "bottle of mesophilic culture"
	desc = "A mixture of mesophilic bacteria used to make most cheeses."
	icon_state = "mixedcondiments"
	amount_per_transfer_from_this = 1
	volume = 30
	list_reagents = list(/datum/reagent/consumable/mesophilicculture = 30)

/obj/item/reagent_containers/food/condiment/pcandidum
	name = "bottle of penicillium candidum"
	desc = "A special bacterium used to make brie."
	icon_state = "mixedcondiments"
	amount_per_transfer_from_this = 1
	volume = 30
	list_reagents = list(/datum/reagent/consumable/penicilliumcandidum = 30)

/obj/item/reagent_containers/food/condiment/proqueforti
	name = "bottle of penicillium roqueforti"
	desc = "A special bacterium used to make blue cheese."
	icon_state = "mixedcondiments"
	amount_per_transfer_from_this = 1
	volume = 30
	list_reagents = list(/datum/reagent/consumable/penicilliumroqueforti = 30)

/obj/item/reagent_containers/food/condiment/thermophilic
	name = "bottle of thermophilic culture"
	desc = "A mixture of thermophilic bacteria used to make some cheeses."
	icon_state = "mixedcondiments"
	amount_per_transfer_from_this = 1
	volume = 30
	list_reagents = list(/datum/reagent/consumable/thermophilicculture = 30)

/obj/item/reagent_containers/food/condiment/milk
	name = "space milk"
	desc = "It's milk. White and nutritious goodness!"
	icon_state = "milk"
	item_state = "carton"
	lefthand_file = 'icons/mob/inhands/equipment/kitchen_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/kitchen_righthand.dmi'
	list_reagents = list(/datum/reagent/consumable/milk = 50)
	fill_icon_thresholds = null

/obj/item/reagent_containers/food/condiment/milk/examine(mob/user)
	. = ..()
	var/datum/chemical_reaction/recipe = get_chemical_reaction(/datum/chemical_reaction/food/american) //NSV13 - our milk + enzyme cheese reaction
	var/milk_required = recipe.required_reagents[/datum/reagent/consumable/milk]
	var/enzyme_required = recipe.required_catalysts[/datum/reagent/consumable/enzyme]
	. += "<span class='notice'>[milk_required] mleka i [enzyme_required] enzymu – i masz ser.</span>"
	. += "<span class='warning'>Pamiętaj, enzym się nie zużywa, więc wlej go z powrotem do butelki, głąbie!</span>"

/obj/item/reagent_containers/food/condiment/flour
	name = "flour sack"
	desc = "A big bag of flour. Good for baking!"
	icon_state = "flour"
	item_state = "carton"
	lefthand_file = 'icons/mob/inhands/equipment/kitchen_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/kitchen_righthand.dmi'
	list_reagents = list(/datum/reagent/consumable/flour = 50)
	fill_icon_thresholds = null

/obj/item/reagent_containers/food/condiment/flour/examine(mob/user)
	. = ..()
	var/datum/chemical_reaction/recipe_dough = get_chemical_reaction(/datum/chemical_reaction/food/dough)
	var/datum/chemical_reaction/recipe_cakebatter = get_chemical_reaction(/datum/chemical_reaction/food/cakebatter)
	var/dough_flour_required = recipe_dough.required_reagents[/datum/reagent/consumable/flour]
	var/dough_water_required = recipe_dough.required_reagents[/datum/reagent/water]
	var/cakebatter_flour_required = recipe_cakebatter.required_reagents[/datum/reagent/consumable/flour]
	var/cakebatter_eggyolk_required = recipe_cakebatter.required_reagents[/datum/reagent/consumable/eggyolk]
	var/cakebatter_sugar_required = recipe_cakebatter.required_reagents[/datum/reagent/consumable/sugar]
	. += "<b><i>Zagłębiasz się w sobie i przypominasz sobie nauki o... Robieniu Ciasta...</i></b>"
	. += "<span class='notice'>[dough_flour_required] mąki i [dough_water_required] wody daje zwykłe ciasto. Można z niego zrobić płaskie ciasto.</span>"
	. += "<span class='notice'>[cakebatter_flour_required] mąki, [cakebatter_eggyolk_required] żółtka (lub mleka sojowego) i [cakebatter_sugar_required] cukru daje ciasto na tort. Można z niego zrobić ciasto na placek.</span>"

/obj/item/reagent_containers/food/condiment/soymilk
	name = "soy milk"
	desc = "It's soy milk. White and nutritious goodness!"
	icon_state = "soymilk"
	item_state = "carton"
	lefthand_file = 'icons/mob/inhands/equipment/kitchen_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/kitchen_righthand.dmi'
	list_reagents = list(/datum/reagent/consumable/soymilk = 50)
	fill_icon_thresholds = null

/obj/item/reagent_containers/food/condiment/rice
	name = "rice sack"
	desc = "A big bag of rice. Good for cooking!"
	icon_state = "rice"
	item_state = "carton"
	lefthand_file = 'icons/mob/inhands/equipment/kitchen_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/kitchen_righthand.dmi'
	list_reagents = list(/datum/reagent/consumable/rice = 50)
	fill_icon_thresholds = null

/*
/obj/item/reagent_containers/condiment/cornmeal
	name = "cornmeal box"
	desc = "A big box of cornmeal. Great for southern style cooking."
	icon_state = "cornmeal"
	inhand_icon_state = "carton"
	lefthand_file = 'icons/mob/inhands/items/drinks_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/drinks_righthand.dmi'
	list_reagents = list(/datum/reagent/consumable/cornmeal = 30)
	fill_icon_thresholds = null
*/

/obj/item/reagent_containers/food/condiment/bbqsauce
	name = "bbq sauce"
	desc = "Hand wipes not included."
	icon_state = "bbqsauce"
	list_reagents = list(/datum/reagent/consumable/bbqsauce = 50)

/obj/item/reagent_containers/food/condiment/soysauce
	name = "soy sauce"
	desc = "A salty soy-based flavoring."
	icon_state = "soysauce"
	list_reagents = list(/datum/reagent/consumable/soysauce = 50)
	fill_icon_thresholds = null

/obj/item/reagent_containers/food/condiment/mayonnaise
	name = "mayonnaise"
	desc = "An oily condiment made from egg yolks."
	icon_state = "mayonnaise"
	list_reagents = list(/datum/reagent/consumable/mayonnaise = 50)
	fill_icon_thresholds = null

/*
/obj/item/reagent_containers/condiment/vinegar
	name = "vinegar"
	desc = "Perfect for chips, if you're feeling Space British."
	icon_state = "vinegar"
	list_reagents = list(/datum/reagent/consumable/vinegar = 50)
	fill_icon_thresholds = null
*/

/obj/item/reagent_containers/food/condiment/vegetable_oil
	name = "cooking oil"
	desc = "For all your deep-frying needs."
	icon_state = "cooking_oil"
	list_reagents = list(/datum/reagent/consumable/nutriment/fat/oil = 50)
	fill_icon_thresholds = null

/obj/item/reagent_containers/condiment/olive_oil
	name = "quality oil"
	desc = "For the fancy chef inside everyone."
	icon_state = "oliveoil"
	list_reagents = list(/datum/reagent/consumable/nutriment/fat/oil/olive = 50)
	fill_icon_thresholds = null

/*
/obj/item/reagent_containers/condiment/yoghurt
	name = "yoghurt carton"
	desc = "Creamy and smooth."
	icon_state = "yoghurt"
	list_reagents = list(/datum/reagent/consumable/yoghurt = 50)
	fill_icon_thresholds = null

/obj/item/reagent_containers/condiment/peanut_butter
	name = "peanut butter"
	desc = "Tasty, fattening processed peanuts in a jar."
	icon_state = "peanutbutter"
	list_reagents = list(/datum/reagent/consumable/peanut_butter = 50)
	fill_icon_thresholds = null
*/

/obj/item/reagent_containers/food/condiment/cherryjelly
	name = "cherry jelly"
	desc = "A jar of super-sweet cherry jelly."
	icon_state = "cherryjelly"
	list_reagents = list(/datum/reagent/consumable/cherryjelly = 50)
	fill_icon_thresholds = null

/obj/item/reagent_containers/food/condiment/honey
	name = "honey"
	desc = "A jar of sweet and viscous honey."
	icon_state = "honey"
	list_reagents = list(/datum/reagent/consumable/honey = 50)
	fill_icon_thresholds = null

/obj/item/reagent_containers/food/condiment/ketchup
	name = "ketchup"
	// At time of writing, "ketchup" mechanically, is just ground tomatoes,
	// rather than // tomatoes plus vinegar plus sugar.
	desc = "A tomato slurry in a tall plastic bottle. Somehow still vaguely American."
	icon_state = "ketchup"
	list_reagents = list(/datum/reagent/consumable/ketchup = 50)
	fill_icon_thresholds = null

/obj/item/reagent_containers/food/condiment/hotsauce
	name = "hotsauce bottle"
	desc= "You can almost TASTE the stomach ulcers!"
	icon_state = "hotsauce"
	list_reagents = list(/datum/reagent/consumable/capsaicin = 50)

/obj/item/reagent_containers/food/condiment/coldsauce
	name = "coldsauce bottle"
	desc= "Leaves the tongue numb from its passage."
	icon_state = "coldsauce"
	list_reagents = list(/datum/reagent/consumable/frostoil = 50)

//Food packs. To easily apply deadly toxi... delicious sauces to your food!

/obj/item/reagent_containers/food/condiment/pack
	name = "condiment pack"
	desc = "A small plastic pack with condiments to put on your food."
	icon_state = "condi_empty"
	volume = 10
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list()
	/**
	  * List of possible styles (list(<icon_state>, <name>, <desc>)) for condiment packs.
	  * Since all of them differs only in color should probably be replaced with usual reagentfillings instead
	  */
	var/list/possible_states = list(
		/datum/reagent/consumable/ketchup = list("condi_ketchup", "Ketchup", "Już czujesz się bardziej amerykańsko."),
		/datum/reagent/consumable/capsaicin = list("condi_hotsauce", "Hotsauce", "Już niemal CZUJESZ SMAK wrzodów żołądka!"),
		/datum/reagent/consumable/soysauce = list("condi_soysauce", "Soy Sauce", "Słony dodatek smakowy na bazie soi"),
		/datum/reagent/consumable/frostoil = list("condi_frostoil", "Coldsauce", "Pozostawia zdrętwiały język"),
		/datum/reagent/consumable/sodiumchloride = list("condi_salt", "Salt Shaker", "Sól. Pewnie z kosmicznych oceanów"),
		/datum/reagent/consumable/blackpepper = list("condi_pepper", "Pepper Mill", "Często używany do przyprawiania jedzenia albo do wywoływania kichania"),
		/datum/reagent/consumable/nutriment/fat/oil = list("condi_cornoil", "Corn Oil", "Pyszny olej używany w kuchni. Z kukurydzy"),
		/datum/reagent/consumable/sugar = list("condi_sugar", "Sugar", "Smaczny kosmiczny cukier!"),
		/datum/reagent/consumable/astrotame = list("condi_astrotame", "Astrotame", "Słodycz tysiąca cukrów bez żadnych kalorii."),
		/datum/reagent/consumable/bbqsauce = list("condi_bbq", "BBQ sauce", "Chusteczki nawilżane nie są w zestawie."),
		//datum/reagent/consumable/peanut_butter = list("condi_peanutbutter", "Peanut Butter", "A creamy paste made from ground peanuts."),
		/datum/reagent/consumable/cherryjelly = list("condi_cherryjelly", "Cherry Jelly", "Słoik bardzo słodkiej galaretki wiśniowej."),
		/datum/reagent/consumable/mayonnaise = list("condi_mayo", "Mayonnaise", "To nie instrument."),
	)
	/// Can't use initial(name) for this. This stores the name set by condimasters.
	var/originalname = "condiment"

/obj/item/reagent_containers/food/condiment/pack/update_icon()
	return

/obj/item/reagent_containers/food/condiment/pack/attack(mob/M, mob/user, def_zone) //Can't feed these to people directly.
	return

/obj/item/reagent_containers/food/condiment/pack/afterattack(obj/target, mob/user , proximity)
	if(!proximity)
		return

	//You can tear the bag open above food to put the condiments on it, obviously.
	if(IS_EDIBLE(target))
		if(!reagents.total_volume)
			to_chat(user, "<span class='warning'>Rozrywasz [src], ale nic w nim nie ma.</span>")
			qdel(src)
			return
		if(target.reagents.total_volume >= target.reagents.maximum_volume)
			to_chat(user, "<span class='warning'>Rozrywasz [src], ale na [target] jest już tak wysoka sterta, że wszystko spływa!</span>" )
			qdel(src)
			return
		else
			to_chat(user, "<span class='notice'>Rozrywasz [src] nad [target], a przyprawa na nie skapuje.</span>")
			src.reagents.trans_to(target, amount_per_transfer_from_this, transfered_by = user)
			qdel(src)
			return
	. = ..()

/obj/item/reagent_containers/food/condiment/pack/on_reagent_change(changetype)
	if(reagents.reagent_list.len > 0)
		var/main_reagent = reagents.get_master_reagent_id()
		if(main_reagent in possible_states)
			var/list/temp_list = possible_states[main_reagent]
			icon_state = temp_list[1]
			desc = temp_list[3]
		else
			icon_state = "condi_mixed"
			desc = "A small condiment pack. The label says it contains [originalname]"
	else
		icon_state = "condi_empty"
		desc = "A small condiment pack. It is empty."

//Ketchup
/obj/item/reagent_containers/food/condiment/pack/ketchup
	name = "ketchup pack"
	originalname = "ketchup"
	list_reagents = list(/datum/reagent/consumable/ketchup = 10)

//Hot sauce
/obj/item/reagent_containers/food/condiment/pack/hotsauce
	name = "hotsauce pack"
	originalname = "hotsauce"
	list_reagents = list(/datum/reagent/consumable/capsaicin = 10)

/obj/item/reagent_containers/food/condiment/pack/astrotame
	name = "astrotame pack"
	originalname = "astrotame"
	list_reagents = list(/datum/reagent/consumable/astrotame = 5)

/obj/item/reagent_containers/food/condiment/pack/bbqsauce
	name = "bbq sauce pack"
	originalname = "bbq sauce"
	list_reagents = list(/datum/reagent/consumable/bbqsauce = 10)
