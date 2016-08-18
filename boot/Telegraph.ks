// copying files for launch sequence
copypath("0:/lifters/mercury_launch_files.ks","1:/lifters/mercury_launch_files.ks").
copypath("0:/utils/deployAntenna.ks","1:/utils/deployAntenna.ks").
run once "lifters/mercury_launch_files.ks".

ENABLE_DEBUG_MODE().

countdown(5).
run "lifters/mercury_launch.ks".

LOG_INFO("Boot script complete.").
