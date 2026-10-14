//this needs to come after the job_types subfolder to keep the correct ordering

#define JOB_MODIFICATION_MAP_NAME "NSV Shrike"
#include "..\..\..\..\_maps\map_files\Shrike\job_changes.dm"

//AQ EDIT START - our maps are renamed in their .json, so the upstream map_names ("NSV Atlas", "DLV Serendipity") never match them
#define JOB_MODIFICATION_MAP_NAME "NSV Aquilas"
#include "..\..\..\..\_maps\map_files\Atlas\job_changes.dm"

#define JOB_MODIFICATION_MAP_NAME "DLV Trawnik"
#include "..\..\..\..\_maps\map_files\Serendipity\job_changes.dm"
//AQ EDIT END
