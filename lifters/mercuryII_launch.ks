LOG_INFO("Mercury II launch sequence initiated...").
ENABLE_DEBUG_MODE().
set numStages to STAGE:NUMBER.
set numLifterStages to 5. 
set finalStage to numStages - numLifterStages.
LOG_DEBUG("NumStages: " + numStages).
LOG_DEBUG("Final Stage: " + finalStage).

set booster1 to SHIP:PARTSTAGGED("mercurySolidBooster1")[0].
set fuelResource to booster1:RESOURCES[0].
lock solidFuelLeft to fuelResource:AMOUNT.
WHEN solidFuelLeft < 0.01 THEN { STAGE. }

//stepped_gravity_launch(finalStage, 100000, 90, 0.7, 0.0, 0.7).
set pitchOverAngle to 85.
set targetTWR to 1.7.
set targetETA to 60.0.
set upperAtmoTransition to 60000.
set thrustAdjustmentThreshold to 10000.
set thrustAdjustmentAggressiveness to 0.1. // no thrust adjustment
TCGT_launch(finalStage, 100000, 90, pitchOverAngle, targetTWR, targetETA, upperAtmoTransition, thrustAdjustmentThreshold, thrustAdjustmentAggressiveness).

runpath("orbiting/raisePeriapsis.ks", 65000, finalStage, True).
stageUpTo(finalStage).

LOG_INFO("Mercury II launch sequence complete.").
