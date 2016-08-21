set isInOrbit to PERIAPSIS > 70000.
set targetHeight to BODY("Mun"):ORBIT:SEMIMAJORAXIS * 0.5 + 1.1 * BODY("Mun"):RADIUS - BODY("Kerbin"):RADIUS. // height is from kerbin sea level
set isOrbitingMun to SHIP:BODY:NAME = "Mun".
set finishedMunarTransfer to APOAPSIS > targetHeight * 0.9 OR isOrbitingMun.
set isInSafeMunarOrbit to isOrbitingMun AND PERIAPSIS > 6000 AND PERIAPSIS < 200000 AND APOAPSIS > 6000 AND APOAPSIS < 200000.

if isInOrbit <> True {
	// copying files for launch sequence
	copypath("0:/lifters/mercuryII_launch_files.ks","1:/lifters/mercuryII_launch_files.ks").
	copypath("0:/orbiting/orbiting2base.ks","1:/orbiting/orbiting2base.ks").
	copypath("0:/transfers/munarTransfer.ks","1:/transfers/munarTransfer.ks").
	copypath("0:/utils/deployAntenna.ks","1:/utils/deployAntenna.ks").
	run once "orbiting/orbiting2base.ks".
	run once "lifters/mercuryII_launch_files.ks".

	countdown(5).
	run "lifters/mercuryII_launch.ks".
	runpath("orbiting/raisePeriapsisNow.ks", 80000, -1).
	runpath("utils/deployAntenna.ks", "Kerbin").
	LOG_INFO("Orbit established.").
}
if finishedMunarTransfer <> True {
	run once "common/common.ks".
	runpath("transfers/munarTransfer.ks", -1).
}
if isInSafeMunarOrbit <> True {
	run once "common/common.ks".
	LOG_INFO("Waiting until focus body is Mun").
	UNTIL SHIP:BODY:NAME = "Mun" { WAIT 5. }
	
	if SHIP:ORBIT:ECCENTRICITY > 0.95 {
		LOG_INFO("Eccentric orbit! Adjusting.").
		runpath("orbiting/raisePeriapsisNow.ks", 40000, -1, True).	
		runpath("orbiting/lowerApoapsis.ks", 100000, -1, True).	
	}
	runpath("orbiting/stabilizeOrbit.ks", 50000, 50000, -1, True, 6, 0.01).
}

LOG_INFO("Boot script complete.").
