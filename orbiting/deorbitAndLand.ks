declare parameter finalStage.
declare parameter atmosphereFactor to 0.9.

runpath("orbiting/deorbit.ks", finalStage, atmosphereFactor).
run orbiting2_deorbit(finalStage, atmosphereFactor).
LOCK STEERING TO RETROGRADE.
run utils_deployParachutes.
UNLOCK STEERING.
LOG_INFO("Deorbit and land sequence complete.").
