declare parameter r.
declare parameter finalStage.
declare parameter autoStage is True.
declare parameter autoWarp is True.
declare parameter burnSettings is list().

if STAGE:NUMBER <= finalStage { LOG_WARN("Final stage reached. Not adjusting orbit."). }

// burns until target apoapsis is reached. Keeps burning if we surpass periapsis
LOG_INFO("Raising periapsis to " + r + " at apoapsis").

set estBurn to guesstimateHeightChangeBurnTime(r, APOAPSIS, SHIP:BODY).
if autoWarp { warpToApoapsis(estBurn / 2 + 10). }
WAIT UNTIL ETA:APOAPSIS < estBurn / 2 + 5.
runpath("orbiting/raisePeriapsisNow.ks", r, finalStage, autoStage, burnSettings).
LOG_INFO("Periapsis raised.").
