LOG_INFO("Mercury launch sequence initiated...").
set numStages to STAGE:NUMBER.
set numLifterStages to 4. // pre launch stage included
set finalStage to numStages - numLifterStages.
LOG_DEBUG("NumStages: " + numStages).
LOG_DEBUG("Final Stage: " + finalStage).

stepped_gravity_launch(finalStage, 100000, 90, 0.7, 0.0, 0.7).
runpath("orbiting/raisePeriapsis.ks", 65000, finalStage, True).

LOG_INFO("Mercury launch sequence complete.").
