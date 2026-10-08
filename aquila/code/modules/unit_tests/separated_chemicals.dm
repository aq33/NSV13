// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - Separated Chemicals (aq33/NSV13#263): reagents in the produce stay apart until it is squashed, then react once and splash
/datum/unit_test/separated_chemicals

/datum/unit_test/separated_chemicals/Run()
	var/turf/T = run_loc_floor_bottom_left
	// water + sodium + chlorine -> table salt, a plain reaction with no side effects; a salt pile only appears on a turf splashed with salt
	var/list/salt_parts = list(/datum/reagent/water = 0.1, /datum/reagent/sodium = 0.1, /datum/reagent/chlorine = 0.1)

	// The glow-berry carries the gene, its parent berry doesn't
	var/obj/item/seeds/glow_seed = allocate(/obj/item/seeds/berry/glow)
	TEST_ASSERT(glow_seed.get_gene(/datum/plant_gene/trait/noreact), "Glow-berry seeds don't have Separated Chemicals")
	var/obj/item/food/grown/glow_berry = allocate(/obj/item/food/grown/berries/glow)
	TEST_ASSERT(glow_berry.reagents.flags & NO_REACT, "Glow-berries don't keep their reagents separated")
	TEST_ASSERT(glow_berry.reagents.has_reagent(/datum/reagent/uranium), "Glow-berries lost their uranium")
	TEST_ASSERT(glow_berry.reagents.has_reagent(/datum/reagent/iodine), "Glow-berries lost their iodine")
	var/obj/item/seeds/berry_seed = allocate(/obj/item/seeds/berry)
	TEST_ASSERT(!berry_seed.get_gene(/datum/plant_gene/trait/noreact), "Plain berry seeds have Separated Chemicals")

	// Copying keeps the gene, and adding it to a copy leaves the original alone
	var/obj/item/seeds/glow_copy = glow_seed.Copy()
	allocated += glow_copy
	TEST_ASSERT(glow_copy.get_gene(/datum/plant_gene/trait/noreact), "Copied glow-berry seeds lost Separated Chemicals")
	TEST_ASSERT(glow_copy.get_gene(/datum/plant_gene/trait/noreact) != glow_seed.get_gene(/datum/plant_gene/trait/noreact), "Copied seeds share the gene instance")
	var/obj/item/seeds/berry_copy = berry_seed.Copy()
	allocated += berry_copy
	berry_copy.genes += new /datum/plant_gene/trait/noreact
	TEST_ASSERT(!berry_seed.get_gene(/datum/plant_gene/trait/noreact), "Adding the gene to a copy changed the original seed")

	// Without the gene, the reagents react as they are added
	var/obj/item/food/grown/plain = grow(salt_parts, FALSE)
	TEST_ASSERT(!(plain.reagents.flags & NO_REACT), "A plant without the gene has NO_REACT")
	TEST_ASSERT_EQUAL(plain.reagents.get_reagent_amount(/datum/reagent/consumable/sodiumchloride), 18, "A plant without the gene didn't react")
	TEST_ASSERT_EQUAL(plain.reagents.get_reagent_amount(/datum/reagent/water), 0, "A plant without the gene kept unreacted water")

	// With the gene, they sit side by side
	var/obj/item/food/grown/separated = grow(salt_parts, TRUE)
	TEST_ASSERT(separated.reagents.flags & NO_REACT, "A plant with the gene doesn't have NO_REACT")
	TEST_ASSERT_EQUAL(separated.reagents.get_reagent_amount(/datum/reagent/consumable/sodiumchloride), 0, "A separated plant reacted before being squashed")
	for(var/R in salt_parts)
		TEST_ASSERT_EQUAL(separated.reagents.get_reagent_amount(R), 6, "A separated plant has the wrong amount of [R]")

	// Squashing starts the mixing; nothing reacts or splashes until the delay is up
	separated.squash(T)
	TEST_ASSERT(!QDELETED(separated), "A separated plant was deleted as soon as it was squashed")
	TEST_ASSERT(separated.separated_mixing, "A squashed separated plant isn't mixing")
	TEST_ASSERT_EQUAL(separated.reagents.get_reagent_amount(/datum/reagent/consumable/sodiumchloride), 0, "A separated plant reacted before its contents mixed")
	var/smudges = count_on(T, /obj/effect/decal/cleanable/food/plant_smudge)
	// A second squash while mixing does nothing
	separated.squash(T)
	TEST_ASSERT_EQUAL(count_on(T, /obj/effect/decal/cleanable/food/plant_smudge), smudges, "A mixing plant was squashed twice")
	TEST_ASSERT(!(locate(/obj/effect/decal/cleanable/food/salt) in T), "A mixing plant splashed early")

	// The mix fires on its own timer: separation is lifted and the reagents react, then what's left splashes
	var/give_up = world.time + 5 SECONDS
	while(!QDELETED(separated) && world.time < give_up)
		sleep(1)
	TEST_ASSERT(QDELETED(separated), "A separated plant wasn't deleted after its contents mixed")
	TEST_ASSERT((locate(/obj/effect/decal/cleanable/food/salt) in T), "A separated plant splashed its reagents without reacting them")

	// The reaction itself: the right products, volume kept, NO_REACT gone, and it doesn't react twice
	var/obj/item/food/grown/reacting = grow(salt_parts, TRUE)
	var/datum/plant_gene/trait/noreact/gene = reacting.seed.get_gene(/datum/plant_gene/trait/noreact)
	gene.on_squashreact(reacting)
	TEST_ASSERT(!(reacting.reagents.flags & NO_REACT), "NO_REACT stayed on after squashing")
	TEST_ASSERT_EQUAL(reacting.reagents.get_reagent_amount(/datum/reagent/consumable/sodiumchloride), 18, "Squashing made the wrong amount of salt")
	TEST_ASSERT_EQUAL(reacting.reagents.total_volume, 18, "Squashing changed the total volume")
	gene.on_squashreact(reacting)
	TEST_ASSERT_EQUAL(reacting.reagents.get_reagent_amount(/datum/reagent/consumable/sodiumchloride), 18, "A second squash reacted again")

	// One reagent: nothing to react with, nothing changes
	var/obj/item/food/grown/single = grow(list(/datum/reagent/water = 0.1), TRUE)
	gene = single.seed.get_gene(/datum/plant_gene/trait/noreact)
	gene.on_squashreact(single)
	TEST_ASSERT_EQUAL(single.reagents.get_reagent_amount(/datum/reagent/water), 6, "A single-reagent separated plant changed when squashed")

	// No reagents at all: squashing and mixing must not runtime
	var/obj/item/food/grown/empty = grow(list(), TRUE)
	TEST_ASSERT_EQUAL(empty.reagents.total_volume, 0, "An empty plant has reagents")
	empty.squash(T)
	empty.squashreact()
	TEST_ASSERT(QDELETED(empty), "An empty separated plant wasn't deleted after mixing")

	// Decals are effects, which the test teardown leaves behind
	for(var/obj/effect/decal/cleanable/food/D in T)
		qdel(D)

/// Grows a berry at potency 50 with the given reagents (6u each at rate 0.1), with or without Separated Chemicals
/datum/unit_test/separated_chemicals/proc/grow(list/reagents_add, separated)
	var/obj/item/seeds/berry/seed = allocate(/obj/item/seeds/berry)
	seed.potency = 50
	seed.reagents_add = reagents_add.Copy()
	if(separated)
		seed.genes += new /datum/plant_gene/trait/noreact
	return allocate(/obj/item/food/grown/berries, null, seed)

/datum/unit_test/separated_chemicals/proc/count_on(turf/T, type)
	. = 0
	for(var/atom/A in T)
		if(istype(A, type))
			.++

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
