/datum/test_chamber_kit/pr_447
	name = "MULEboty i poczta rurowa"
	pr = "aq33/AquilaStation#447"
	description = "Testuj na prawdziwej mapie, komora daje tylko sprzęt. Zapakuj coś w papier, oznacz metkownicą i wrzuć do zsypu pocztowego w cargo: \
		paczka ma wylądować w wybranym dziale (Snake: wylot w każdym dziale; Atlas: kaplica, hangar, woźny, bar, kuchnia; Serendipity: kaplica). \
		Paczka wrzucona do zwykłego kosza ma trafić do cargo, a śmieci do utylizacji (Snake, Serendipity: nic nie krąży między koszami). \
		MULEbot: na Serendipity w cargo stoi „Furman”, na Atlasie są nowe cele (Engineering, Security, Science, Kitchen, Bridge); \
		wyślij go na drugi pokład - ma pojechać windą i rozładować się u celu."
	items = list(
		/obj/item/dest_tagger = 1,
		/obj/item/stack/package_wrap = 1,
		/obj/item/stack/wrapping_paper = 1,
		/obj/item/toy/plush/carpplushie = 3
	)
