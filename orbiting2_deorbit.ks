declare parameter finalStage.
declare parameter degFromNorth.
declare parameter atmosphereFactor to 0.9.

run once common.

set targetHeight to SHIP:ORBIT:BODY:ATM:HEIGHT * atmosphereFactor.

LOG_INFO("Deorbiting."). 
LOCK STEERING TO RETROGRADE.
run orbiting2_lowerPeriapsisNow(targetHeight, degFromNorth, finalStage + 1).
LOG_INFO("Staging up to stage " + finalStage).
LOCK THROTTLE TO 0.0.
UNTIL STAGE:NUMBER = finalStage { safe_stage(true, 0.0). }
UNLOCK STEERING.
LOG_INFO("Orbit terminal.").