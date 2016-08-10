copy common from 0.
run once common.

function controlledBurn {
	parameter etaDelegate.
	parameter burnSettings. // format (throttle, stopCondition, windowLeft, windowRight, stopFactor (a scaling factor that stops the burn when reacing stopFactor*windowLeft/Right), restartFactor (same as stopFactor for restarting the burn))
	parameter autoStage is True.

	// if we are outside the burn window, wait till we hit it again, unless we're close to target height
	// don't check for the right window if it's set to a negative number
	if burnSettings[2] > 0 {
		// left window right of eta. TODO: Don't ignore stop factor
		set outsideLeftWindow to (ORBIT:PERIOD - etaDelegate:call()) < burnSettings[2].
	} else {
		set outsideLeftWindow to etaDelegate:call() > -burnSettings[2]*burnSettings[4].
	}
	if burnSettings[3] < 0 {
		// right window left of eta. TODO: Don't ignore stop factor
		set outsideRightWindow to etaDelegate:call() < -burnSettings[3].
	} else {
		set outsideRightWindow to (ORBIT:PERIOD - etaDelegate:call()) > burnSettings[4]*burnSettings[3].
	}
	if outsideLeftWindow OR outsideRightWindow { 
		LOG_DEBUG("Outside burn window. Waiting.").
		LOCK THROTTLE TO 0. 
		WAIT UNTIL (etaDelegate:call() < burnSettings[5] * burnSettings[2]) or ((ORBIT:PERIOD - etaDelegate:call()) < burnSettings[5] * burnSettings[3]). // wait a little longer (restartBurnFactor) to avoid constant turning off and on
		LOG_DEBUG("Continuing.").
	}
	// otherwise burn
	else {
		LOCK THROTTLE TO burnSettings[0]. 
		if autoStage { safe_stage(MAXTHRUST = 0, burnSettings[0]). }	
	}
}.

function orbitManeuver {
	parameter orbitDelegate. // a function returning the current state of the attribute to change 
	parameter target. // target of the attribute 
	parameter etaDelegate. // a function returning the time to the opposing point on the orbit
	parameter dirDelegate. // a function returning the direction to burn in
	parameter finalStage.
	parameter autoStage is True.
	parameter burnSequence is list(). // format list(list(throttle, stopCondition, windowLeft (negative), windowRight, stopFactor, restartFactor))

	if ALT:RADAR < 100 { LOG_ERROR("Ship is grounded. Can't change orbit."). RETURN. }

	set isIncrease to orbitDelegate:call() < target. // are we increasing something?

	LOG_INFO("Starting burn sequence").
	FROM { local i is 0. }
	UNTIL i >= burnSequence:LENGTH
	STEP { set i to i+1. } 
	DO {
		if isIncrease {
			// until we have surpassed the current stop condition or have finished with the final stage or have reached the target
			UNTIL orbitDelegate:call() > burnSequence[i][1] OR STAGE:NUMBER < finalStage OR orbitDelegate:call() > target { 
				LOCK STEERING TO dirDelegate:call(). // have to do this inside the loop, otherwise we'll lock to a static value
				controlledBurn(etaDelegate, burnSequence[i], autoStage).
			}
		} else {
			UNTIL orbitDelegate:call() < burnSequence[i][1] OR STAGE:NUMBER < finalStage OR orbitDelegate:call() < target { 
				LOCK STEERING TO dirDelegate:call(). // see above
				controlledBurn(etaDelegate, burnSequence[i], autoStage).
			}
		}
		
		LOCK THROTTLE TO 0.0.
	}

	UNLOCK STEERING.
    LOCK THROTTLE TO 0.0.
    LOG_INFO("Burn complete").
    if isIncrease and orbitDelegate:call() < target { LOG_WARN("Orbit attribute not fully increased"). }
	else if isIncrease <> true and orbitDelegate:call() > target{ LOG_WARN("Orbit attribute not fully decreased"). }
}.

function guesstimateHeightChangeBurn {
	parameter currentHeight.
	parameter targetHeight.
	set error to targetHeight - currentHeight.
	set est to error/100000 * 5.
	if est < 0 { set est to -est. }
	return est.
}.

function getDefaultBurnSequence {
	parameter currentState.
	parameter targetState.
	parameter burnTime.

	if targetState > currentState {
		// we are increasing the state
		set d to targetState - currentState.
		set burnSequence to list(
			// throttle		stop condition		window left		window right		stop factor		restart factor
			// we'll always keep the burn pivot, e.g. apoapsis, in front of us by limiting the burn window. This avoids a "go-around" during the burn.
			// also set a wider burn window for the last part of the burn
			list(1.00,	0.80 * d, 	-burnTime / 2, -1,	1.5,	0.5),
			list(0.50,	0.90 * d, 	-burnTime / 2, -1,	1.5,	0.5),
			list(0.10,	0.95 * d, 	-burnTime / 2, -1,	2.0,	0.5),
			list(0.05,	1.00 * d, 	-burnTime / 2, -1,	5.0,	4.0)
		).
		return burnSequence.
	} else {
		set d to currentState - targetState.
		set burnSequence to list(
			list(1.00,	1.20 * d, 	-burnTime / 2, -1,	1.5,	0.5),
			list(0.50,	1.10 * d, 	-burnTime / 2, -1,	1.5,	0.5),
			list(0.10,	1.05 * d, 	-burnTime / 2, -1,	2.0,	0.5),
			list(0.05,	1.00 * d, 	-burnTime / 2, -1,	5.0,	4.0)
		).
		return burnSequence.
	}
}.

function changePeriapsis {
	parameter height.
	parameter finalStage.
	parameter autoStage is True.
	parameter burnSequence is list().
	
	if burnSequence:EMPTY {
		set burnTime to guesstimateHeightChangeBurn(PERIAPSIS, height).
		set burnSequence to getDefaultBurnSequence(PERIAPSIS, height, burnTime).
	}

	if height > PERIAPSIS {	
		orbitManeuver(dPeri, height, dEtaApo, dPrograde, finalStage, autoStage, burnSequence).
	} else {
		orbitManeuver(dPeri, height, dEtaApo, dRetrograde, finalStage, autoStage, burnSequence).
	}
}.

function changeApoapsis {
	parameter height.
	parameter finalStage.
	parameter autoStage is True.
	parameter burnSequence is list().

	if burnSequence:EMPTY {
		set burnTime to guesstimateHeightChangeBurn(PERIAPSIS, height).
		set burnSequence to getDefaultBurnSequence(PERIAPSIS, height, burnTime).
	}

	if height > APOAPSIS {	
		orbitManeuver(dApo, height, dEtaPeri, dPrograde, finalStage, autoStage, burnSequence).
	} else {
		orbitManeuver(dApo, height, dEtaPeri, dRetrograde, finalStage, autoStage, burnSequence).
	}
}.

function establishOrbit {
	parameter peri.
	parameter finalStage.
	parameter autoStage.

	LOG_INFO("Lifting periapsis to " + peri + "m").
	if ETA:APOAPSIS > ETA:PERIAPSIS AND PERIAPSIS < SHIP:ORBIT:BODY:ATMOSPHERE:HEIGHT { 
		LOG_ERROR("Missed apoapsis with periapsis below atmosphere. FIX MANUALLY!"). 
		RETURN.
	}
	changePeriapsis(peri, finalStage, autoStage).
}.

function stabilizeOrbit {
	parameter h1.
	parameter h2.
	parameter finalStage.
	parameter autoStage.
	parameter err is 0.01.

	set apo to 0. set peri to 0.
	if h1 > h2 {
		set apo to h1. set peri to h2.		
	} else {
		set apo to h2. set peri to h1.
	}

	LOG_INFO("Stabilizing orbit with apoapsis/periapis: (" + apo + " - " + peri + ")"). 
	if ETA:APOAPSIS > ETA:PERIAPSIS AND PERIAPSIS < SHIP:ORBIT:BODY:ATMOSPHERE:HEIGHT { 
		LOG_ERROR("Missed apoapsis with periapsis below atmosphere. FIX MANUALLY!"). 
		RETURN.
	}
        
    set errorApo to APOAPSIS - apo.
	set errorPeri to PERIAPSIS - peri.

	UNTIL (errorApo < err * APOAPSIS AND errorPeri < err * PERIAPSIS) OR STAGE:NUMBER < finalStage {
		if ETA:APOAPSIS < ETA:PERIAPSIS {
			changeApoapsis(apo, finalStage, autoStage).
		}
		else {
			changePeriapsis(peri, finalStage, autoStage).
		}
    	set errorApo to APOAPSIS - apo.
		set errorPeri to PERIAPSIS - peri.
	}

	LOG_INFO("Orbit stabilized. ErrorA: " + errorApo + " ErrorP: " + errorPeri).
}.
