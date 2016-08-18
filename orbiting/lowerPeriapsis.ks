declare parameter r.
declare parameter finalStage.
declare parameter autoStage is True.
declare parameter burnSettings is list().

// burns until target apoapsis is reached. Keeps burning if we surpass periapsis
LOG_INFO("Lowering preiapsis to " + r + " at apoapsis").

set estBurn to guesstimateHeightChangeBurnTime(r, APOAPSIS, SHIP:BODY).
WAIT UNTIL ETA:APOAPSIS < estBurn / 2 + 5.
runpath("orbiting/lowerPeriapsisNow.ks", r, finalStage, autoStage, burnSettings).
LOG_INFO("Periapsis lowered.").
