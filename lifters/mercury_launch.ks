declare parameter degToNorth is 90.

LOG_INFO("Mercury launch sequence initiated...").
set numStages to STAGE:NUMBER.
set numLifterStages to 4. 
set finalStage to numStages - numLifterStages.
LOG_DEBUG("NumStages: " + numStages).
LOG_DEBUG("Final Stage: " + finalStage).

//stepped_gravity_launch(finalStage, 100000, 90, 0.7, 0.0, 0.7).
set pitchOverAngle to 85.
set targetTWR to 1.6.
set targetETA to 40.0.
set upperAtmoTransition to 45000.
set thrustAdjustmentThreshold to 10000.
set thrustAdjustmentAggressiveness to 0.1. // no thrust adjustment
TCGT_launch(finalStage, 100000, degToNorth, pitchOverAngle, targetTWR, targetETA, upperAtmoTransition, thrustAdjustmentThreshold, thrustAdjustmentAggressiveness).

if STAGE:NUMBER > finalStage {
	runpath("orbiting/raisePeriapsis.ks", 65000, finalStage, True).
	stageUpTo(finalStage).
}

LOG_INFO("Mercury launch sequence complete.").
