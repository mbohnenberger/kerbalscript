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

// burns until target periapsis is reached. If target periapsis is higher than apoapsis
// we will keep burning until apoapsis is target height
function raisePeriapsis {
	parameter r.
	parameter degFromNorth.
	parameter autoStage is True.
	parameter burnSettings is list().
	
	if burnSettings:EMPTY {
		set burnSettings to list(
			list(0.80, 1.0),
			list(0.90, 0.5),
			list(0.95, 0.1),
			list(1.00, 0.05)	
		).
	}
	
	set burnSegment to 0.
	set currentHeight to PERIAPSIS.
	if r > APOAPSIS { set currentHeight to APOAPSIS. }
	if currentHeight < 0 { set currentHeight to 0. }
	UNTIL currentHeight < burnSettings[burnSegment][0] * r {
		set burnSegment to burnSegment + 1.
	}

	set estBurn to guesstimateHeightChangeBurnTime(r, APOAPSIS, SHIP:BODY).
	WAIT UNTIL ETA:APOAPSIS < estBurn / 2 + 10.
	LOCK STEERING TO HEADING(degFromNorth, 0).	
	WAIT UNTIL ETA:APOAPSIS < estBurn / 2.

	UNTIL burnSegment = burnSettings:LENGTH {
		LOCK THROTTLE TO burnSettings[burnSegment][1].
		if r > APOAPSIS {
			UNTIL APOAPSIS >= r * burnSettings[burnSegment][0] {
				burnStep(degFromNorth, burnSettings[burnSegment][1], autoStage).
			}
		} else {
			UNTIL PERIAPSIS >= r * burnSettings[burnSegment][0] {
				burnStep(degFromNorth, burnSettings[burnSegment][1], autoStage).
			}
		}
		set burnSegment to burnSegment + 1.
	}
	LOCK THROTTLE TO 0.0.		
}. 

// burns until target periapsis is reached.
function lowerPeriapsis {
	parameter r.
	parameter degFromNorth.
	parameter autoStage is True.
	parameter burnSettings is list().

	if burnSettings:EMPTY {
		set burnSettings to list(
			list(1.20, 1.0),
			list(1.10, 0.5),
			list(1.05, 0.1),
			list(1.00, 0.05)	
		).
	}
	
	set burnSegment to 0.
	set currentHeight to PERIAPSIS.
	if r > APOAPSIS { set currentHeight to APOAPSIS. }
	UNTIL currentHeight > burnSettings[burnSegment][0] * r {
		set burnSegment to burnSegment + 1.
	}

	set estBurn to guesstimateHeightChangeBurnTime(r, APOAPSIS, SHIP:BODY).
	WAIT UNTIL ETA:APOAPSIS < estBurn / 2 + 10.
	LOCK STEERING TO HEADING(-degFromNorth, 0).	
	WAIT UNTIL ETA:APOAPSIS < estBurn / 2.

	UNTIL burnSegment = burnSettings:LENGTH {
		LOCK THROTTLE TO burnSettings[burnSegment][1].
		UNTIL PERIAPSIS <= r * burnSettings[burnSegment][0] {
			burnStep(-degFromNorth, burnSettings[burnSegment][1], autoStage).
		}
		set burnSegment to burnSegment + 1.
	}
	LOCK THROTTLE TO 0.0.		
}. 

// burns until target apoapsis is reached.
function raiseApoapsis {
	parameter r.
	parameter degFromNorth.
	parameter autoStage is True.
	parameter burnSettings is list().

	if burnSettings:EMPTY {
		set burnSettings to list(
			list(0.80, 1.0),
			list(0.90, 0.5),
			list(0.95, 0.1),
			list(1.00, 0.05)	
		).
	}
	
	set burnSegment to 0.
	set currentHeight to PERIAPSIS.
	if r > APOAPSIS { set currentHeight to APOAPSIS. }
	UNTIL currentHeight < burnSettings[burnSegment][0] * r {
		set burnSegment to burnSegment + 1.
	}

	set estBurn to guesstimateHeightChangeBurnTime(r, PERIAPSIS, SHIP:BODY).
	WAIT UNTIL ETA:PERIAPSIS < estBurn / 2 + 10.
	LOCK STEERING TO HEADING(degFromNorth, 0).	
	WAIT UNTIL ETA:PERIAPSIS < estBurn / 2.

	UNTIL burnSegment = burnSettings:LENGTH {
		LOCK THROTTLE TO burnSettings[burnSegment][1].
		UNTIL APOAPSIS >= r * burnSettings[burnSegment][0] {
			burnStep(degFromNorth, burnSettings[burnSegment][1], autoStage).
		}
		set burnSegment to burnSegment + 1.
	}
	LOCK THROTTLE TO 0.0.		
}. 

// burns until target apoapsis is reached. Keeps burning if we surpass periapsis
function lowerApoapsis {
	parameter r.
	parameter degFromNorth.
	parameter autoStage is True.
	parameter burnSettings is list().
	
	if burnSettings:EMPTY {
		set burnSettings to list(
			list(1.20, 1.0),
			list(1.10, 0.5),
			list(1.05, 0.1),
			list(1.00, 0.05)	
		).
	}
	
	set burnSegment to 0.
	set currentHeight to PERIAPSIS.
	if r > APOAPSIS { set currentHeight to APOAPSIS. }
	UNTIL currentHeight > r * burnSettings[burnSegment][0] {
		set burnSegment to burnSegment + 1.
	}

	set estBurn to guesstimateHeightChangeBurnTime(r, PERIAPSIS, SHIP:BODY).
	WAIT UNTIL ETA:PERIAPSIS < estBurn / 2 + 10.
	LOCK STEERING TO HEADING(-degFromNorth, 0).	
	WAIT UNTIL ETA:PERIAPSIS < estBurn / 2.

	UNTIL burnSegment = burnSettings:LENGTH {
		LOCK THROTTLE TO burnSettings[burnSegment][1].
		if r < PERIAPSIS {
			UNTIL APOAPSIS <= r * burnSettings[burnSegment][0] {
				burnStep(-degFromNorth, burnSettings[burnSegment][1], autoStage).
			}
		} else {
			UNTIL APOAPSIS <= r * burnSettings[burnSegment][0] {
				burnStep(-degFromNorth, burnSettings[burnSegment][1], autoStage).
			}
		}
		set burnSegment to burnSegment + 1.
	}
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


