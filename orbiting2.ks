copy common from 0.
run once common.

// estimation based on v for circular orbit at target height
function guesstimateHeightChangeBurnTime { 
	parameter targetHeight.
	parameter currentHeight. // height at which we start the burn
	parameter planet.

	set vt to SQRT(planet:MU / (currentHeight + planet:RADIUS)).
	set vAtBurn to SQRT(planet:MU * (2 / (planet:RADIUS + currentHeight) - 1 / SHIP:ORBIT:SEMIMAJORAXIS)).
	set a to SHIP:MAXTHRUST / SHIP:MASS. // thrust is in kN and mass is in tons
	set dV to vt - vAtBurn.
	if dV < 0 { set dV to -dV. }
	return dV / a.	
}.

function burnStep {
	parameter degFromNorth.
	parameter thrttl.
	parameter autoStage.
	LOCK STEERING TO HEADING(degFromNorth, 0).
	if autoStage { safe_stage(MAXTHRUST = 0, thrttl). }
}. 

function getOppositeHeight {
	// look at the current etas. The one closest to half the orbit period is the one opposite from us
	if ABS(ETA:APOAPSIS - SHIP:ORBIT:PERIOD / 2) > ABS(ETA:PERIAPSIS - SHIP:ORBIT:PERIOD / 2) { return PERIAPSIS. }
	else { return APOAPSIS. }
}.

function getOrbitNormal {
	set n to SHIP:NORTH:FOREVECTOR:NORMALIZED. set u to SHIP:UP:FOREVECTOR:NORMALIZED.
	set f to VCRS(u, n).
	return -f * sin(SHIP:ORBIT:INCLINATION) + n * cos(SHIP:ORBIT:INCLINATION).
}.

// burns until target periapsis is reached. If target periapsis is higher than apoapsis
// we will keep burning until apoapsis is target height
function raisePeriapsis {
	parameter r.
	parameter degFromNorth.
	parameter autoStage is True.
	parameter burnSettings is list().
	
	LOG_INFO("Raising periapsis to " + r).

	if burnSettings:EMPTY {
		set burnSettings to list(
			list(0.80, 1.0),
			list(0.90, 0.5),
			list(0.95, 0.1),
			list(1.00, 0.05)	
		).
	}
	
	set burnSegment to 0.
	set currentHeight to MAX(0, getOppositeHeight()).
	UNTIL currentHeight < burnSettings[burnSegment][0] * r OR burnSegment >= burnSettings:LENGTH - 1 {
		set burnSegment to burnSegment + 1.
	}

	set estBurn to guesstimateHeightChangeBurnTime(r, APOAPSIS, SHIP:BODY).
	WAIT UNTIL ETA:APOAPSIS < estBurn / 2 + 10.
	LOCK STEERING TO HEADING(degFromNorth, 0).	
	WAIT UNTIL ETA:APOAPSIS < estBurn / 2.

	UNTIL burnSegment = burnSettings:LENGTH {
		LOCK THROTTLE TO burnSettings[burnSegment][1].
		// burn until the opposing point is at the target height 
		UNTIL getOppositeHeight() >= r * burnSettings[burnSegment][0] { burnStep(degFromNorth, burnSettings[burnSegment][1], autoStage). }
		set burnSegment to burnSegment + 1.
	}
	UNLOCK STEERING.
	LOCK THROTTLE TO 0.0.		
}. 

// burns until target periapsis is reached.
function lowerPeriapsis {
	parameter r.
	parameter degFromNorth.
	parameter autoStage is True.
	parameter burnSettings is list().

	LOG_INFO("Lowering periapsis to " + r).

	if burnSettings:EMPTY {
		set burnSettings to list(
			list(1.20, 1.0),
			list(1.10, 0.5),
			list(1.05, 0.1),
			list(1.00, 0.05)	
		).
	}
	
	set burnSegment to 0.
	set currentHeight to MAX(0, getOppositeHeight()).
	UNTIL currentHeight > burnSettings[burnSegment][0] * r OR burnSegment >= burnSettings:LENGTH - 1 {
		set burnSegment to burnSegment + 1.
	}

	set estBurn to guesstimateHeightChangeBurnTime(r, APOAPSIS, SHIP:BODY).
	WAIT UNTIL ETA:APOAPSIS < estBurn / 2 + 10.
	LOCK STEERING TO HEADING(-degFromNorth, 0).	
	WAIT UNTIL ETA:APOAPSIS < estBurn / 2.

	UNTIL burnSegment = burnSettings:LENGTH {
		LOCK THROTTLE TO burnSettings[burnSegment][1].
		UNTIL getOppositeHeight() >= r * burnSettings[burnSegment][0] { burnStep(degFromNorth, burnSettings[burnSegment][1], autoStage). }
		set burnSegment to burnSegment + 1.
	}
	UNLOCK STEERING.
	LOCK THROTTLE TO 0.0.		
}. 

// burns until target apoapsis is reached.
function raiseApoapsis {
	parameter r.
	parameter degFromNorth.
	parameter autoStage is True.
	parameter burnSettings is list().
	
	LOG_INFO("Raising apoapsis to " + r).

	if burnSettings:EMPTY {
		set burnSettings to list(
			list(0.80, 1.0),
			list(0.90, 0.5),
			list(0.95, 0.1),
			list(1.00, 0.05)	
		).
	}
	
	set burnSegment to 0.
	set currentHeight to MAX(0, getOppositeHeight()).
	UNTIL currentHeight < burnSettings[burnSegment][0] * r OR burnSegment >= burnSettings:LENGTH - 1 {
		set burnSegment to burnSegment + 1.
	}

	set estBurn to guesstimateHeightChangeBurnTime(r, PERIAPSIS, SHIP:BODY).
	WAIT UNTIL ETA:PERIAPSIS < estBurn / 2 + 10.
	LOCK STEERING TO HEADING(degFromNorth, 0).	
	WAIT UNTIL ETA:PERIAPSIS < estBurn / 2.

	UNTIL burnSegment = burnSettings:LENGTH {
		LOCK THROTTLE TO burnSettings[burnSegment][1].
		UNTIL getOppositeHeight() >= r * burnSettings[burnSegment][0] { burnStep(degFromNorth, burnSettings[burnSegment][1], autoStage). }
		set burnSegment to burnSegment + 1.
	}
	UNLOCK STEERING.
	LOCK THROTTLE TO 0.0.		
}. 

// burns until target apoapsis is reached. Keeps burning if we surpass periapsis
function lowerApoapsis {
	parameter r.
	parameter degFromNorth.
	parameter autoStage is True.
	parameter burnSettings is list().
	
	LOG_INFO("Lowering apoapsis to " + r).

	if burnSettings:EMPTY {
		set burnSettings to list(
			list(1.20, 1.0),
			list(1.10, 0.5),
			list(1.05, 0.1),
			list(1.00, 0.05)	
		).
	}
	
	set burnSegment to 0.
	set currentHeight to MAX(0, getOppositeHeight()).
	UNTIL currentHeight > burnSettings[burnSegment][0] * r OR burnSegment >= burnSettings:LENGTH - 1 {
		set burnSegment to burnSegment + 1.
	}

	set estBurn to guesstimateHeightChangeBurnTime(r, PERIAPSIS, SHIP:BODY).
	WAIT UNTIL ETA:PERIAPSIS < estBurn / 2 + 10.
	LOCK STEERING TO HEADING(-degFromNorth, 0).	
	WAIT UNTIL ETA:PERIAPSIS < estBurn / 2.

	UNTIL burnSegment = burnSettings:LENGTH {
		LOCK THROTTLE TO burnSettings[burnSegment][1].
		UNTIL getOppositeHeight() >= r * burnSettings[burnSegment][0] { burnStep(degFromNorth, burnSettings[burnSegment][1], autoStage). }
		set burnSegment to burnSegment + 1.
	}
	UNLOCK STEERING.
	LOCK THROTTLE TO 0.0.		
}. 

function increaseInclination {
	parameter angle.
	parameter lgtAscendingNode.
	parameter autoStage is True.
	parameter burnSettings is list().

	set lgtDescendingNode to MOD(lgtAscendingNode + 180 + 180,360) - 180.
	LOG_DEBUG("Ascending Node: " + lgtAscendingNode).
	LOG_DEBUG("Descending Node: " + lgtDescendingNode).

	LOG_INFO("Increasing inclination to " + angle + " at longitude " + lgtAscendingNode).
	if burnSettings:EMPTY {
		set burnSettings to list(
			list(0.80, 1.0),
			list(0.90, 0.5),
			list(0.95, 0.1),
			list(1.00, 0.05)	
		).
	}
	
	set burnSegment to 0.
	UNTIL SHIP:ORBIT:INCLINATION < angle * burnSettings[burnSegment][0] OR burnSegment >= burnSettings:LENGTH - 1 {
		set burnSegment to burnSegment + 1.
	}
	
	set burnAtAsc to ABS(SHIP:LONGITUDE - lgtAscendingNode) < ABS(SHIP:LONGITUDE - lgtDescendingNode).
	
	set lastInc to SHIP:ORBIT:INCLINATION - 1.
	UNTIL burnSegment = burnSettings:LENGTH {
		if burnAtAsc {
			WAIT UNTIL ABS(SHIP:LONGITUDE - lgtAscendingNode) < 10.
			LOG_INFO("Closing in on ascending node. Locking steering.").
			VECDRAW(V(0,0,0), getOrbitNormal(), RED, "normal", 10, true, 0.1).
			LOCK STEERING TO getOrbitNormal().
			WAIT UNTIL ABS(SHIP:LONGITUDE - lgtAscendingNode) < 2.
			UNTIL SHIP:ORBIT:INCLINATION > angle * burnSettings[burnSegment][0] OR lastInc >= SHIP:ORBIT:INCLINATION {
				// stop burning if we are decreasing inclination
				set lastInc to SHIP:ORBIT:INCLINATION.
				LOCK THROTTLE TO burnSettings[burnSegment][1].
				LOCK STEERING TO getOrbitNormal().
				if autoStage { safe_stage(MAXTHRUST = 0, burnSettings[burnSegment][1]). }
				WAIT 0.2.
			}	
			if ABS(SHIP:LONGITUDE - lgtAscendingNode) >= 2 OR lastInc >= SHIP:ORBIT:INCLINATION { 
				LOG_INFO("Inclination is decreasing. Continuing burn at descending node.").
				LOCK THROTTLE TO 0.0. 
				UNLOCK STEERING. 
				set burnAtAsc to false. set lastInc to SHIP:ORBIT:INCLINATION - 1. 
			}
			CLEARVECDRAWS().
			if SHIP:ORBIT:INCLINATION > angle * burnSettings[burnSegment][0] { set burnSegment to burnSegment + 1. }
		} 
		else {
			WAIT UNTIL ABS(SHIP:LONGITUDE - lgtDescendingNode) < 10.
			LOG_INFO("Closing in on descending node. Locking steering.").
			VECDRAW(V(0,0,0), -getOrbitNormal(), RED, "anti-normal", 10, true, 0.1).
			LOCK STEERING TO -getOrbitNormal().
			WAIT UNTIL ABS(SHIP:LONGITUDE - lgtDescendingNode) < 2.
			UNTIL SHIP:ORBIT:INCLINATION > angle * burnSettings[burnSegment][0] OR lastInc >= SHIP:ORBIT:INCLINATION {
				set lastInc to SHIP:ORBIT:INCLINATION.
				LOCK THROTTLE TO burnSettings[burnSegment][1].
				LOCK STEERING TO -getOrbitNormal().
				if autoStage { safe_stage(MAXTHRUST = 0, burnSettings[burnSegment][1]). }
				WAIT 0.2.
			}	
			if ABS(SHIP:LONGITUDE - lgtDescendingNode) >= 2 OR lastInc >= SHIP:ORBIT:INCLINATION { 
				LOG_INFO("Inclination is decreasing. Continuing burn at descending node.").
				LOCK THROTTLE TO 0.0. 
				UNLOCK STEERING. 
				set burnAtAsc to true. set lastInc to SHIP:ORBIT:INCLINATION - 1. 
			}
			CLEARVECDRAWS().
			if SHIP:ORBIT:INCLINATION > angle * burnSettings[burnSegment][0] { set burnSegment to burnSegment + 1. }
		}
	}	
	UNLOCK STEERING.
	LOCK THROTTLE TO 0.0.
}.

function decreaseInclination {
	parameter angle.
	parameter lgtAscendingNode.
	parameter autoStage is True.
	parameter burnSettings is list().

	set lgtDescendingNode to MOD(lgtAscendingNode + 180 + 180,360) - 180.
	LOG_DEBUG("Ascending Node: " + lgtAscendingNode).
	LOG_DEBUG("Descending Node: " + lgtDescendingNode).

	LOG_INFO("Increasing inclination to " + angle + " at longitude " + lgtAscendingNode).
	if burnSettings:EMPTY {
		set burnSettings to list(
			list(1.20, 1.0),
			list(1.10, 0.5),
			list(1.05, 0.1),
			list(1.00, 0.05)	
		).
	}
	
	set burnSegment to 0.
	UNTIL SHIP:ORBIT:INCLINATION > angle * burnSettings[burnSegment][0] OR burnSegment >= burnSettings:LENGTH - 1 {
		set burnSegment to burnSegment + 1.
	}
	
	set burnAtAsc to ABS(SHIP:LONGITUDE - lgtAscendingNode) < ABS(SHIP:LONGITUDE - lgtDescendingNode).
	
	set lastInc to SHIP:ORBIT:INCLINATION + 1.
	UNTIL burnSegment = burnSettings:LENGTH {
		if burnAtAsc {
			WAIT UNTIL ABS(SHIP:LONGITUDE - lgtAscendingNode) < 10.
			LOG_INFO("Closing in on ascending node. Locking steering.").
			VECDRAW(V(0,0,0), -getOrbitNormal(), RED, "anti-normal", 10, true, 0.1).
			LOCK STEERING TO -getOrbitNormal().
			WAIT UNTIL ABS(SHIP:LONGITUDE - lgtAscendingNode) < 2.
			UNTIL SHIP:ORBIT:INCLINATION < angle * burnSettings[burnSegment][0] OR lastInc <= SHIP:ORBIT:INCLINATION {
				// stop burning if we are decreasing inclination
				set lastInc to SHIP:ORBIT:INCLINATION.
				LOCK THROTTLE TO burnSettings[burnSegment][1].
				LOCK STEERING TO -getOrbitNormal().
				if autoStage { safe_stage(MAXTHRUST = 0, burnSettings[burnSegment][1]). }
				WAIT 0.2.
			}	
			if ABS(SHIP:LONGITUDE - lgtAscendingNode) >= 2 OR lastInc <= SHIP:ORBIT:INCLINATION { 
				LOCK THROTTLE TO 0.0. 
				UNLOCK STEERING. 
				set burnAtAsc to false. set lastInc to SHIP:ORBIT:INCLINATION + 1. 
			}
			CLEARVECDRAWS().
			if SHIP:ORBIT:INCLINATION < angle * burnSettings[burnSegment][0] { set burnSegment to burnSegment + 1. }
		} 
		else {
			WAIT UNTIL ABS(SHIP:LONGITUDE - lgtDescendingNode) < 10.
			LOG_INFO("Closing in on descending node. Locking steering.").
			VECDRAW(V(0,0,0), getOrbitNormal(), RED, "normal", 10, true, 0.1).
			LOCK STEERING TO getOrbitNormal().
			WAIT UNTIL ABS(SHIP:LONGITUDE - lgtDescendingNode) < 2.
			UNTIL SHIP:ORBIT:INCLINATION < angle * burnSettings[burnSegment][0] OR lastInc <= SHIP:ORBIT:INCLINATION {
				set lastInc to SHIP:ORBIT:INCLINATION.
				LOCK THROTTLE TO burnSettings[burnSegment][1].
				LOCK STEERING TO getOrbitNormal().
				if autoStage { safe_stage(MAXTHRUST = 0, burnSettings[burnSegment][1]). }
				WAIT 0.2.
			}	
			if ABS(SHIP:LONGITUDE - lgtDescendingNode) >= 2 OR lastInc <= SHIP:ORBIT:INCLINATION { 
				LOCK THROTTLE TO 0.0. 
				UNLOCK STEERING. 
				set burnAtAsc to true. set lastInc to SHIP:ORBIT:INCLINATION + 1. 
			}
			CLEARVECDRAWS().
			if SHIP:ORBIT:INCLINATION < angle * burnSettings[burnSegment][0] { set burnSegment to burnSegment + 1. }
		}
		
	}	
	UNLOCK STEERING.
	LOCK THROTTLE TO 0.0.
}.

function stabilizeOrbit {
	parameter h1.
	parameter h2.
	parameter deg.
	parameter finalStage.
	parameter autoStage.
	parameter maxBurns is 6.
	parameter err is 0.01.

	set apo to 0. set peri to 0.
	if h1 > h2 {
		set apo to h1. set peri to h2.		
	} else {
		set apo to h2. set peri to h1.
	}

	LOG_INFO("Stabilizing orbit with apoapsis/periapis: (" + apo + " - " + peri + ")"). 
	if ETA:APOAPSIS > ETA:PERIAPSIS AND PERIAPSIS < SHIP:ORBIT:BODY:ATM:HEIGHT { 
		LOG_ERROR("Missed apoapsis with periapsis below atmosphere. FIX MANUALLY!"). 
		RETURN.
	}
        
    set errorApo to ABS(APOAPSIS - apo).
	set errorPeri to ABS(PERIAPSIS - peri).
	set numBurns to 0.

	LOG_DEBUG("Error Apo: " + errorApo).
	LOG_DEBUG("Error Peri: " + errorPeri).
	
	set d to 90.

	UNTIL (errorApo < err * APOAPSIS AND errorPeri < err * PERIAPSIS) OR STAGE:NUMBER < finalStage OR numBurns >= maxBurns {
		if ETA:APOAPSIS < ETA:PERIAPSIS {
			if PERIAPSIS < peri {
				raisePeriapsis(peri, deg, autoStage).
			}
			else {
				lowerPeriapsis(peri, deg, autoStage).
			}
		}
		else {
			if APOAPSIS < apo {
				raiseApoapsis(apo, deg, autoStage).
			}
			else {
				lowerApoapsis(apo, deg, autoStage).
			}
		}
    	set errorApo to ABS(APOAPSIS - apo).
		set errorPeri to ABS(PERIAPSIS - peri).
		set numBurns to numBurns + 1.
	}

	LOG_INFO("Orbit stabilized. ErrorA: " + errorApo + " ErrorP: " + errorPeri).
}.


