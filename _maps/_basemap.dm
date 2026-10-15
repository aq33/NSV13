//#define LOWMEMORYMODE //uncomment this to load centcom and runtime station and thats it.

#include "map_files\generic\CentCom.dmm"

#ifndef LOWMEMORYMODE
	#ifdef ALL_MAPS
		//Debug/Special Maps
		#include "map_files\Mining\Lavaland.dmm"
		#include "map_files\debug\runtimestation.dmm"

		//Akwilas AQ EDIT - Aquila versions live under the upstream paths, so the webmap renders them
		#include "map_files\Atlas\atlas.dmm"
		#include "map_files\Atlas\atlas2.dmm"

		//Padalec
		#include "map_files\Snake\snake_lower.dmm"
		#include "map_files\Snake\snake_upper.dmm"
		//Trawnik
		#include "map_files\Serendipity\Serendipity1.dmm"
		#include "map_files\Serendipity\Serendipity2.dmm"
		#ifdef CIBUILDING
			#include "templates.dm"
		#endif
	#endif
#endif
