declare parameter finalStage.
declare parameter autoStage is True.
declare parameter burnSettings is list().

copypath("0:/orbiting/raiseApoapsisNow.ks","1:/orbiting/raiseApoapsisNow.ks").

run once "common/common.ks".

set targetAngle to getMunarInterceptAngle(PERIAPSIS).
set targetHeight to BODY("Mun"):ORBIT:SEMIMAJORAXIS * 0.5 + 1.1 * BODY("Mun"):RADIUS - BODY("Kerbin"):RADIUS. // height is from kerbin sea level
set tolerance to 2.5.

LOG_INFO("Waiting for munar transfer window.").
LOG_INFO("Mun needs to be " + targetAngle + " +/- " + tolerance + " deg ahead.").

// Assuming same inclination, circular orbit, prograde orbit.

UNTIL false {
	set pKerbin to BODY("Kerbin"):POSITION.
	set pShip to SHIP:POSITION.
	set pMun to BODY("Mun"):POSITION.
	set v1 to (pKerbin - pShip):NORMALIZED.
	set v2 to (pMun - pKerbin):NORMALIZED.
	set f to getHorizonPrograde().
	set angle to ARCCOS(VDOT(v1,v2)).
	set isMovingTowardsTarget to VDOT(v2,f) > 0.

	if DEBUG_MODE {
		drawVec(v1, RED, "target").
		drawVec(v2, BLUE, "current").
	} 
	CLEARVECDRAWS().
	
	LOG_INFO("Current angle: " + angle).
	if isMovingTowardsTarget {
		LOG_INFO("Mun is moving towards the target").
	} else {
		LOG_INFO("Mun is moving away from the target").
	}

	if isMovingTowardsTarget AND ABS(angle - targetAngle) < tolerance { BREAK. }	

	WAIT 5.
}

LOG_INFO("Mun is in target window. Starting burn.").
run orbiting2_raiseApoapsisNow(targetHeight, finalStage, autoStage, burnSettings).

