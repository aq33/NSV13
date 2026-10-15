// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - wall vitals monitor (tgstation#94704)
/datum/unit_test/aquila_vitals_reader

/datum/unit_test/aquila_vitals_reader/Run()
	var/obj/structure/table/optable/table = allocate(/obj/structure/table/optable)
	var/obj/machinery/vitals_reader/reader = allocate(/obj/machinery/vitals_reader, get_step(table, EAST))
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human, table.loc)
	var/mob/living/carbon/human/doctor = allocate(/mob/living/carbon/human, get_step(table, NORTH))

	reader.find_machine()
	TEST_ASSERT(reader.connected == table, "The monitor did not connect to the operating table next to it")

	table.set_patient(patient)
	reader.process(2)
	TEST_ASSERT(reader.patient == patient, "The monitor does not track the patient on the table")
	var/list/readout = reader.examine(doctor)
	TEST_ASSERT(length(readout) > 2, "Examining the monitor shows no scan")

	table.set_patient(null)
	reader.process(2)
	TEST_ASSERT(isnull(reader.patient), "The monitor still tracks a patient after they left")

#undef TEST_ASSERT
