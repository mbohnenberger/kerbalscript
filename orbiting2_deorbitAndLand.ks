declare parameter finalStage.
declare parameter degFromNorth
declare parameter atmosphereFactor to 0.9.

run once common.

run orbiting2_deorbit(finalStage, degFromNorth, atmosphereFactor).
LOCK STEERING TO RETROGRADE.
run utils_deployParachutes.
WAIT UNTIL ALT:RADAR < 500.
UNLOCK STEERING.
LOG_INFO("Deorbit and land sequence complete.").