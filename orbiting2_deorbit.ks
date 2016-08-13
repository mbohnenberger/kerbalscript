declare parameter finalStage.
declare parameter degFromNorth
declare parameter atmosphereFactor to 0.9.

run once common.

set targetHeight to SHIP:ORBIT:BODY:ATM:HEIGHT * factor.

LOG_INFO("Deorbiting."). 
LOCK STEERING TO RETROGRADE.
run orbiting2_lowerPeriapsisNow(targetHeight, degFromNorth, finalStage).
UNLOCK STEERING.
LOG_INFO("Orbit terminal.").