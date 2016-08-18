declare parameter finalStage.
declare parameter atmosphereFactor to 0.9.

set targetHeight to SHIP:ORBIT:BODY:ATM:HEIGHT * atmosphereFactor.

LOG_INFO("Deorbiting."). 
LOCK STEERING TO RETROGRADE.
runpath("orbiting/lowerPeriapsisNow.ks", targetHeight, finalStage).
LOG_INFO("Staging up to stage " + finalStage).
LOCK THROTTLE TO 0.0.
stageUpTo(finalStage).
UNLOCK STEERING.
LOG_INFO("Orbit terminal.").
