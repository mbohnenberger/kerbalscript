// copying files for launch sequence
copypath("0:/lifters/mercury_launch_files.ks","1:/lifters/mercury_launch_files.ks").
copypath("0:/orbiting/orbiting2base.ks","1:/orbiting/orbiting2base.ks").
run once "lifters/mercury_launch_files.ks".
run once "orbiting/orbiting2base.ks".

countdown(5).
runpath("lifters/mercury_launch.ks", 0).
runpath("orbiting/raisePeriapsisNow.ks", 80000, 1).
LOG_INFO("Boot script complete.").
