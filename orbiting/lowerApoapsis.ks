declare parameter r.
declare parameter finalStage.
declare parameter autoStage is True.
declare parameter burnSettings is list().

// burns until target apoapsis is reached. Keeps burning if we surpass periapsis
LOG_INFO("Lowering apoapsis to " + r + " at periapsis").

set estBurn to guesstimateHeightChangeBurnTime(r, PERIAPSIS, SHIP:BODY).
WAIT UNTIL ETA:PERIAPSIS < estBurn / 2 + 5.
runpath("orbiting/lowerApoapsisNow.ks", r, finalStage, autoStage, burnSettings).
LOG_INFO("Apoapsis lowered.").
