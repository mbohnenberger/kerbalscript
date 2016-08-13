declare parameter r.
declare parameter degFromNorth.
declare parameter finalStage.
declare parameter autoStage is True.
declare parameter burnSettings is list().

run once common.

// burns until target apoapsis is reached. Keeps burning if we surpass periapsis
LOG_INFO("Lowering preiapsis to " + r + " at apoapsis").

set estBurn to guesstimateHeightChangeBurnTime(r, APOAPSIS, SHIP:BODY).
WAIT UNTIL ETA:APOAPSIS < estBurn / 2 + 5.
run orbiting2_lowerPeriapsisNow(r, degFromNorth, finalStage, autoStage, burnSettings).
LOG_INFO("Periapsis lowered.").