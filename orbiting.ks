copy common from 0.
run once common.

function insideBurnWindow {
	parameter etaDelegate.
	parameter windowLeft.
	parameter windowRight.

	// if we are outside the burn window, wait till we hit it again, unless we're close to target height
	// don't check for the right window if it's set to a negative number
	if windowLeft > 0 {
		// left window right of eta. 
		set insideLeftWindow to (ORBIT:PERIOD - etaDelegate:call()) > windowLeft.
	} else {
		set insideLeftWindow to etaDelegate:call() < -windowLeft.
	}
	if windowRight < 0 {
		// right window left of eta. 
		set insideRightWindow to etaDelegate:call() > -windowRight.
	} else {
		set insideRightWindow to (ORBIT:PERIOD - etaDelegate:call()) < windowRight.
	}

	set insideWindow to false.
	if windowLeft > 0 OR windowRight < 0 {
		// here checks DO overlap.
		set insideWindow to insideLeftWindow AND insideRightWindow.
	} else {
		// here checks don't overlap
		set insideWindow to insideLeftWindow OR insideRightWindow.
	}

	return insideWindow.
}.

function timedBurn {
	parameter deg. // a function returning the direction to burn in
	parameter pitch.
	parameter etaDelegate. // a function returning the time to the opposing point on the orbit
	parameter finalStage.
	parameter burnDuration.
	parameter autoStage is True.

	set timeBurned to 0.

	LOG_INFO("Starting burn sequence").
	LOG_DEBUG("Burn duration: " + burnDuration).
	WAIT UNTIL etaDelegate:call() < burnDuration / 2 + 10.
	//LOCK STEERING TO dirDelegate:call(). // have to do this inside the loop, otherwise we'll lock to a static value
	LOCK STEERING TO HEADING(deg, pitch).

	WAIT UNTIL etaDelegate:call() < burnDuration / 2.
	LOCK THROTTLE to 1.0.
	UNTIL timeBurned >= burnDuration OR STAGE:NUMBER < finalStage {
		LOCK STEERING TO HEADING(deg, pitch). // have to do this inside the loop, otherwise we'll lock to a static value
		if autoStage { safe_stage(MAXTHRUST = 0, 1.0). }	
		WAIT 1.
		set timeBurned to timeBurned + 1.
	}.
	LOCK THROTTLE TO 0.0.

	UNLOCK STEERING.
    LOG_INFO("Burn complete").
}.

function windowedBurn {
	parameter orbitDelegate. // a function returning the current state of the attribute to change 
	parameter target. // target of the attribute 
	parameter etaDelegate. // a function returning the time to the opposing point on the orbit
	parameter dirDelegate. // a function returning the direction to burn in
	parameter finalStage.
	parameter autoStage is True.
	parameter burnSequence is list(). // format list(list(throttle, stopCondition, windowLeft (negative), windowRight))

	if ALT:RADAR < 100 { LOG_ERROR("Ship is grounded. Can't change orbit."). RETURN. }

	set isIncrease to orbitDelegate:call() < target. // are we increasing something?

	LOG_INFO("Starting burn sequence").
	FROM { local i is 0. }
	UNTIL i >= burnSequence:LENGTH
	STEP { set i to i+1. } 
	DO {
		WAIT UNTIL insideBurnWindow(etaDelegate, burnSequence[i][2], burnSequence[i][3]). // if we don't wait here we'll wait until the middle of the burn window
		if isIncrease {
			// until we have surpassed the current stop condition or have finished with the final stage or have reached the target
			UNTIL orbitDelegate:call() > burnSequence[i][1] OR STAGE:NUMBER < finalStage OR orbitDelegate:call() > target { 
				LOCK STEERING TO dirDelegate:call(). // have to do this inside the loop, otherwise we'll lock to a static value
				if insideBurnWindow(etaDelegate, burnSequence[i][2], burnSequence[i][3]) { 
					// we are inside the burn window
					LOCK THROTTLE TO burnSequence[i][0]. 
					if autoStage { safe_stage(MAXTHRUST = 0, burnSequence[i][0]). }	
				} else {
					LOCK THROTTLE TO 0. 
					//WAIT (burnSequence[i][3] - burnSequence[i][2]) * 0.1. // wait a little bit to avoid on-off-on-off-on-off 
				}
			}
		} else {
			UNTIL orbitDelegate:call() < burnSequence[i][1] OR STAGE:NUMBER < finalStage OR orbitDelegate:call() < target { 
				LOCK STEERING TO dirDelegate:call(). // see above
				if insideBurnWindow(etaDelegate, burnSequence[i][2], burnSequence[i][3]) { 
					// we are inside the burn window
					LOCK THROTTLE TO burnSequence[i][0]. 
					if autoStage { safe_stage(MAXTHRUST = 0, burnSequence[i][0]). }	
				} else {
					LOCK THROTTLE TO 0. 
					//WAIT (burnSequence[i][3] - burnSequence[i][2]) * 0.1. // wait a little bit to avoid on-off-on-off-on-off 
				}
			}
		}
		LOCK THROTTLE TO 0.0. // lock to 0 between burn sequence segments
	}

	UNLOCK STEERING.
    LOCK THROTTLE TO 0.0.
    LOG_INFO("Burn complete").
    if isIncrease and orbitDelegate:call() < target { LOG_WARN("Orbit attribute not fully increased"). }
	else if isIncrease <> true and orbitDelegate:call() > target{ LOG_WARN("Orbit attribute not fully decreased"). }
}.

function guesstimateHeightChangeBurnTime { // assumes circular orbit
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

function getDefaultBurnSequence {
	parameter currentState.
	parameter targetState.
	parameter burnTime.

	if targetState > currentState {
		// we are increasing the state
		set d to targetState - currentState.
		set burnSequence to list(
			// throttle		stop condition		window left		window right
			// we'll always keep the burn pivot, e.g. apoapsis, in front of us by limiting the burn window. This avoids a "go-around" during the burn.
			list(1.00,	0.80 * d, 	-burnTime / 2, burnTime / 2),
			list(0.50,	0.90 * d, 	-burnTime / 2, burnTime / 2),
			list(0.10,	0.95 * d, 	-burnTime / 2, burnTime / 2),
			list(0.05,	1.00 * d, 	-burnTime / 2, burnTime / 2)
		).
		return burnSequence.
	} else {
		set d to currentState - targetState.
		set burnSequence to list(
			list(1.00,	1.20 * d, 	-burnTime / 2, burnTime / 2),
			list(0.50,	1.10 * d, 	-burnTime / 2, burnTime / 2),
			list(0.10,	1.05 * d, 	-burnTime / 2, burnTime / 2),
			list(0.05,	1.00 * d, 	-burnTime / 2, burnTime / 2)
		).
		return burnSequence.
	}
}.

function changePeriapsis {
	parameter height.
	parameter deg.
	parameter finalStage.
	parameter autoStage is True.
	parameter burnSequence is list().

	set burnTime to guesstimateHeightChangeBurnTime(height, PERIAPSIS, SHIP:BODY).
	if burnSequence:EMPTY {
		if height > PERIAPSIS {
			timedBurn(deg, 0, dEtaApo, finalStage, burnTime, autoStage).	
		} else {
			timedBurn(deg, 0, dEtaApo, finalStage, burnTime, autoStage).	
		}
	} else {
		set burnSequence to getDefaultBurnSequence(PERIAPSIS, height, burnTime).
		if height > PERIAPSIS {	
			windowedBurn(dPeri, height, dEtaApo, dPrograde, finalStage, autoStage, burnSequence).
		} else {
			windowedBurn(dPeri, height, dEtaApo, dRetrograde, finalStage, autoStage, burnSequence).
		}
	}
}.

function changeApoapsis {
	parameter height.
	parameter deg.
	parameter finalStage.
	parameter autoStage is True.
	parameter burnSequence is list().

	set planet to SHIP:BODY.

	set burnTime to guesstimateHeightChangeBurnTime(height, APOAPSIS, SHIP:BODY).
	if burnSequence:EMPTY {
		if height > APOAPSIS {
			timedBurn(deg, 0, dEtaPeri, finalStage, burnTime, autoStage).	
		} else {
			timedBurn(deg, 0, dEtaPeri, finalStage, burnTime, autoStage).	
		}
	} else {
		set burnSequence to getDefaultBurnSequence(APOAPSIS, height, burnTime).
		if height > PERIAPSIS {	
			windowedBurn(dApo, height, dEtaPeri, dPrograde, finalStage, autoStage, burnSequence).
		} else {
			windowedBurn(dApo, height, dEtaPeri, dRetrograde, finalStage, autoStage, burnSequence).
		}
	}
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
			if PERIAPSIS < peri { set d to deg. } else { set d to -deg. }
			changePeriapsis(peri, deg, finalStage, autoStage).
		}
		else {
			if APOAPSIS < apo { set d to deg. } else { set d to -deg. }
			changeApoapsis(apo, deg, finalStage, autoStage).
		}
    	set errorApo to ABS(APOAPSIS - apo).
		set errorPeri to ABS(PERIAPSIS - peri).
		set numBurns to numBurns + 1.
	}

	LOG_INFO("Orbit stabilized. ErrorA: " + errorApo + " ErrorP: " + errorPeri).
}.
