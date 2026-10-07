//this needs to come after the job_types subfolder to keep the correct ordering

#define JOB_MODIFICATION_MAP_NAME "NSV Tycoon"
#include "..\..\..\..\_maps\map_files\Tycoon\job_changes.dm"

#define JOB_MODIFICATION_MAP_NAME "SGV Aetherwhisp"
#include "..\..\..\..\_maps\map_files\Aetherwhisp\job_changes.dm"

#define JOB_MODIFICATION_MAP_NAME "NSV Eclipse"
#include "..\..\..\..\_maps\map_files\Eclipse\job_changes.dm"

#define JOB_MODIFICATION_MAP_NAME "NSV Atlas"
#include "..\..\..\..\_maps\map_files\Atlas\job_changes.dm"

#define JOB_MODIFICATION_MAP_NAME "NSV Shrike"
#include "..\..\..\..\_maps\map_files\Shrike\job_changes.dm"

#define JOB_MODIFICATION_MAP_NAME "DLV Serendipity"
#include "..\..\..\..\_maps\map_files\Serendipity\job_changes.dm"

//AQ EDIT START - our maps are renamed in their .json, so the upstream map_name checks above never match them
// Kept above Galactica: its job_changes.dm has no #undef, the #undef at the end of this file cleans up after it
#define JOB_MODIFICATION_MAP_NAME "NSV Aquilas"
#include "..\..\..\..\_maps\map_files\Aquila_Atlas\job_changes.dm"

#define JOB_MODIFICATION_MAP_NAME "DLV Trawnik"
#include "..\..\..\..\_maps\map_files\Aquila_Serendipity\job_changes.dm"
//AQ EDIT END

#define JOB_MODIFICATION_MAP_NAME "NSV Galactica"
#include "..\..\..\..\_maps\map_files\Galactica\job_changes.dm"

#undef JOB_MODIFICATION_MAP_NAME
