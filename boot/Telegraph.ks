set isInFinalOrbit to APOAPSIS > 2800000 and PERIAPSIS > 2800000.
set isInOrbit to PERIAPSIS > 70000.

if isInOrbit <> True {
	// copying files for launch sequence
	copypath("0:/lifters/mercury_launch_files.ks","1:/lifters/mercury_launch_files.ks").
	copypath("0:/utils/deployAntenna.ks","1:/utils/deployAntenna.ks").
	copypath("0:/orbiting/orbiting2base.ks","1:/orbiting/orbiting2base.ks").
	run once "lifters/mercury_launch_files.ks".
	run once "orbiting/orbiting2base.ks".
	
	countdown(5).
	run "lifters/mercury_launch.ks".
	runpath("orbiting/raisePeriapsisNow.ks", 100000, -1).
	runpath("utils/deployAntenna.ks").
} 
if isInFinalOrbit <> True {
	run once "common/common.ks".
	// at this point we should have an 100km x 75km orbit.
	runpath("orbiting/stabilizeOrbit.ks", 2863300, 2863300, -1, True, 6, 0.01).
	LOG_INFO("Boot script complete.").
}




