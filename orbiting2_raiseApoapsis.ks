declare parameter r.
declare parameter degFromNorth.
declare parameter finalStage.
declare parameter autoStage is True.
declare parameter burnSettings is list().

run once common.

// burns until target apoapsis is reached. Keeps burning if we surpass periapsis
LOG_INFO("Raising apoapsis to " + r + " at periapsis").

set estBurn to guesstimateHeightChangeBurnTime(r, PERIAPSIS, SHIP:BODY).
WAIT UNTIL ETA:PERIAPSIS < estBurn / 2 + 5.
run orbiting2_raiseApoapsisNow(r, degFromNorth, finalStage, autoStage, burnSettings).
LOG_INFO("Apoapsis raised.").