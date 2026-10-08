/datum/food_processor_process
	var/input
	var/output
	var/time = 40
	var/required_machine = /obj/machinery/processor

/datum/food_processor_process/meat
	input = /obj/item/food/meat/slab
	output = /obj/item/food/meatball

/datum/food_processor_process/bacon
	input = /obj/item/food/meat/rawcutlet
	output = /obj/item/food/meat/rawbacon

/datum/food_processor_process/potatowedges
	input = /obj/item/food/grown/potato/wedges
	output = /obj/item/food/fries

/datum/food_processor_process/sweetpotato
	input = /obj/item/food/grown/potato/sweet
	output = /obj/item/food/yakiimo

/datum/food_processor_process/potato
	input = /obj/item/food/grown/potato
	output = /obj/item/food/tatortot

/datum/food_processor_process/carrot
	input = /obj/item/food/grown/carrot
	output = /obj/item/food/carrotfries

/datum/food_processor_process/soybeans
	input = /obj/item/food/grown/soybeans
	output = /obj/item/food/soydope

/datum/food_processor_process/spaghetti
	input = /obj/item/food/doughslice
	output = /obj/item/food/spaghetti/raw

/datum/food_processor_process/corn
	input = /obj/item/food/grown/corn
	output = /obj/item/food/tortilla

/datum/food_processor_process/tortilla
	input = /obj/item/food/tortilla
	output = /obj/item/food/cornchips

/datum/food_processor_process/parsnip
	input = /obj/item/food/grown/parsnip
	output = /obj/item/food/roastparsnip

/datum/food_processor_process/mob/slime
	input = /mob/living/simple_animal/slime
	output = null
	required_machine = /obj/machinery/processor/slime

/datum/food_processor_process/fish
	input = /obj/item/fish
	output = /obj/item/food/fishmeat

/datum/food_processor_process/bluemix
	input = /obj/item/food/cheesemix_heated/blue
	output = /obj/item/food/cheese/wheel/blue

/datum/food_processor_process/briemix
	input = /obj/item/food/cheesemix_heated/brie
	output = /obj/item/food/cheese/wheel/brie

/datum/food_processor_process/cheddarmix
	input = /obj/item/food/cheesemix_heated/cheddar
	output = /obj/item/food/cheese/wheel/cheddar

/datum/food_processor_process/fetamix
	input = /obj/item/food/cheesemix_heated/feta
	output = /obj/item/food/cheese/wheel/feta

/datum/food_processor_process/goatmix
	input = /obj/item/food/cheesemix_heated/goat
	output = /obj/item/food/cheese/wheel/goat

/datum/food_processor_process/halloumimix
	input = /obj/item/food/cheesemix_heated/halloumi
	output = /obj/item/food/cheese/wheel/halloumi

/datum/food_processor_process/mozzarellamix
	input = /obj/item/food/cheesemix_heated/mozzarella
	output = /obj/item/food/cheese/wheel/mozzarella

/datum/food_processor_process/parmesanmix
	input = /obj/item/food/cheesemix_heated/parmesan
	output = /obj/item/food/cheese/preparmesan

/datum/food_processor_process/swissmix
	input = /obj/item/food/cheesemix_heated/swiss
	output = /obj/item/food/cheese/wheel/swiss
