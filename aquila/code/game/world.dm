/// Our auxmos.dll (see tools/auxmos/README.md) pins itself, so a reboot or a stopped world can no longer unload it
/// from under its own worker threads (that crashed DreamDaemon). The library now outlives the world: this drops
/// everything the world put in it, so the next world in the same process starts as clean as a fresh load.
/// Called from /world/Reboot() and /world/Del(); nothing may touch atmos afterwards.
/// The Linux build (libauxmos.so) is upstream's: it has no reset proc, and calling it there would runtime and abort the reboot.
/// If libauxmos.so is ever rebuilt with our patch (which pins it on Linux too), drop the Windows check, or the next world gets stale ids.
/world/proc/auxmos_cleanup()
	if(system_type == MS_WINDOWS)
		__auxmos_reset()
