declare parameter h1.
declare parameter h2.
declare parameter finalStage.
declare parameter autoStage.
declare parameter maxBurns is 6.
declare parameter err is 0.01.

if STAGE:NUMBER <= finalStage { LOG_WARN("Final stage reached. Not adjusting orbit."). }

set apo to 0. set peri to 0.
if h1 > h2 {
	set apo to h1. set peri to h2.
} else {
	set apo to h2. set peri to h1.
}

LOG_INFO("Stabilizing orbit with apoapsis/periapis: (" + apo + " - " + peri + ")"). 
if ETA:APOAPSIS > ETA:PERIAPSIS AND PERIAPSIS < SHIP:ORBIT:BODY:ATM:HEIGHT { 
	LOG_ERROR("Missed apoapsis with periapsis below atmosphere. FIX MANUALLY!"). 
}

set errorApo to ABS(APOAPSIS - apo).
set errorPeri to ABS(PERIAPSIS - peri).
set numBurns to 0.

LOG_DEBUG("Error Apo: " + errorApo).
LOG_DEBUG("Error Peri: " + errorPeri).

UNTIL (errorApo < err * APOAPSIS AND errorPeri < err * PERIAPSIS) OR STAGE:NUMBER <= finalStage OR numBurns >= maxBurns {
	if ETA:APOAPSIS < ETA:PERIAPSIS {
		if PERIAPSIS < peri {
			runpath("orbiting/raisePeriapsis.ks", peri, finalStage, autoStage).
		}
		else {
			runpath("orbiting/lowerPeriapsis.ks", peri, finalStage, autoStage).
		}
	}
	else {
		if APOAPSIS < apo {
			runpath("orbiting/raiseApoapsis.ks", apo, finalStage, autoStage).
		}
		else {
			runpath("orbiting/lowerApoapsis.ks", apo, finalStage, autoStage).
		}
	}
	set errorApo to ABS(APOAPSIS - apo).
	set errorPeri to ABS(PERIAPSIS - peri).
	set numBurns to numBurns + 1.
}

LOG_INFO("Orbit stabilized. ErrorA: " + errorApo + " ErrorP: " + errorPeri).
