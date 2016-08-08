copy common from 0.
run once common.

// more compact version of increase/decrease apoapsis/periapsis
function changeOrbit {
	parameter operation.
    parameter height.
    parameter finalStage.
	parameter autoStage is True.
	parameter burnSequence is list().

	if ALT:RADAR < 100 { LOG_ERROR("Ship is grounded. Can't change orbit."). RETURN. }

	set increaseApoapsis to false.
	set increasePeriapsis to false.
	set decreaseApoapsis to false.
	set decreasePeriapsis to false.	
	if operation = "A+" { LOG_INFO("Increasing apoapsis"). set increaseApoapsis to true. }
	else if operation = "P+" { LOG_INFO("Increasing periapsis"). set increasePeriapsis to true.} 
	else if operation = "A-" { LOG_INFO("Decreasing apoapsis"). set increasePeriapsis to true. } 
	else if operation = "P-" { LOG_INFO("Decreasing periapsis"). set increasePeriapsis to true.	} 
	else { LOG_ERROR("Unknown operation: " + operation). }
	
	if increaseApoapsis or increasePeriapsis { if burnSequence:EMPTY { set burnSequence to list(1.0, height * 0.9, 0.2, height). }} 
	else { if burnSequence:EMPTY { set burnSequence to list(1.0, height * 1.1, 0.2, height). }}

	if increaseApoapsis  and APOAPSIS  > height { RETURN. }
	if increasePeriapsis and PERIAPSIS > height { RETURN. }
	if decreaseApoapsis  and APOAPSIS  < height { RETURN. }
	if decreasePeriapsis and PERIAPSIS < height { RETURN. }

	set error to 0.
	if increaseApoapsis  { set error to height - APOAPSIS. }
	if increasePeriapsis { set error to height - PERIAPSIS. }
	if decreaseApoapsis  { set error to APOAPSIS - height. }
	if decreasePeriapsis { set error to PERIAPSIS - height. }
    set estimateBurnTime to error / 100000 * 5.
    set etaBurnStart to estimateBurnTime / 2. // heuristic for when to start burn: 5 seconds for 100km difference. 
	LOG_DEBUG("Estimated burn time: " + estimateBurnTime).
	LOG_DEBUG("Burn scheduled for: " + etaBurnStart + "s before Apo/Peri").

	// TODO: remove this block with kOS v1.0.0 and use the one below instead.
	if increasePeriapsis or decreasePeriapsis { WAIT UNTIL ETA:APOAPSIS < etaBurnStart + 60.} 
	else { WAIT UNTIL ETA:PERIAPSIS < etaBurnStart + 60. }
	HUD_HUGE_ALERT("!!! STOP WARPING !!!").

	if increasePeriapsis or decreasePeriapsis { WAIT UNTIL ETA:APOAPSIS < etaBurnStart + 10.} 
	else { WAIT UNTIL ETA:PERIAPSIS < etaBurnStart + 10. }
	//SET WARP TO 0. // doesn't work in current version. fixed for kOS 1.0.0 TODO: uncomment with v1.0.0

	if increaseApoapsis or increasePeriapsis { LOCK STEERING TO PROGRADE. } 
	else { LOCK STEERING TO RETROGRADE. }

	if increasePeriapsis or decreasePeriapsis { WAIT UNTIL ETA:APOAPSIS < etaBurnStart.}
	else { WAIT UNTIL ETA:PERIAPSIS < etaBurnStart. }
	
    LOG_INFO("Starting burn").
	FROM { local i is 0. }
	UNTIL i >= burnSequence:LENGTH
	STEP { set i to i+2. } 
	DO {
		LOG_DEBUG("Burn at " + burnSequence[i] + " until " + burnSequence[i+1]).
    	LOCK THROTTLE TO burnSequence[i]. 

		if increasePeriapsis {
			UNTIL PERIAPSIS > burnSequence[i+1] OR STAGE:NUMBER < finalStage { if autoStage { safe_stage(MAXTHRUST = 0, burnSequence[i]). }	}
		} else if increaseApoapsis {
			UNTIL APOAPSIS > burnSequence[i+1] OR STAGE:NUMBER < finalStage { if autoStage { safe_stage(MAXTHRUST = 0, burnSequence[i]). }	}
		} else if decreasePeriapsis { 
			UNTIL PERIAPSIS < burnSequence[i+1] OR STAGE:NUMBER < finalStage { if autoStage { safe_stage(MAXTHRUST = 0, burnSequence[i]). }	}
		} else if decreaseApoapsis {
			UNTIL APOAPSIS < burnSequence[i+1] OR STAGE:NUMBER < finalStage { if autoStage { safe_stage(MAXTHRUST = 0, burnSequence[i]). }	}
		} else { LOG_ERROR("Something has gone completely wrong. Should never happen...famous last words."). }
    	LOCK THROTTLE TO 0.0.
	}

	UNLOCK STEERING.
    LOCK THROTTLE TO 0.0.
    LOG_INFO("Burn complete").
    if increasePeriapsis and PERIAPSIS < height { LOG_WARN("Periapsis not fully increased"). }
	else if increaseApoapsis and APOAPSIS < height { LOG_WARN("Apoapsis not fully increased"). }
	else if decreasePeriapsis and PERIAPSIS > height { LOG_WARN("Periapsis not fully decreased"). }
	else if decreaseApoapsis and APOAPSIS > height { LOG_WARN("Apoapsis not fully decreased"). }
}

function establishOrbit {
	parameter peri.
	parameter finalStage.
	parameter autoStage.

	if ETA:APOAPSIS > ETA:PERIAPSIS AND PERIAPSIS < SHIP:ORBIT:BODY:ATMOSPHERE:HEIGHT { 
		LOG_ERROR("Missed apoapsis with periapsis below atmosphere. FIX MANUALLY!"). 
		RETURN.
	}
 
	set burnSequence to list(
		1.0, 0.8 * peri,
		0.5, 0.9 * peri,
		0.1, peri	
	).
	changeOrbit("P+", peri, finalStage, autoStage, burnSequence).
}.

function stabilizeOrbit {
	parameter apo.
	parameter peri.
	parameter finalStage.
	parameter autoStage.
	parameter err is 0.01.

	if ETA:APOAPSIS > ETA:PERIAPSIS AND PERIAPSIS < SHIP:ORBIT:BODY:ATMOSPHERE:HEIGHT { 
		LOG_ERROR("Missed apoapsis with periapsis below atmosphere. FIX MANUALLY!"). 
		RETURN.
	}
        
    set errorApo to APOAPSIS - apo.
	set errorPeri to PERIAPSIS - peri.

	UNTIL errorApo < err * APOAPSIS AND errorPeri < err * PERIAPSIS OR STAGE:NUMBER < finalStage {
		if ETA:APOAPSIS < ETA:PERIAPSIS {
			if APOAPSIS < apo {
				set burnSequence to list(
					1.0, 0.8 * apo,
					0.5, 0.9 * apo,
					0.1, apo 
				).
				changeOrbit("A+", apo, finalStage, autoStage, burnSequence).
			} else { 
				set burnSequence to list(
					1.0, 1.2 * apo,
					0.5, 1.1 * apo,
					0.1, apo 
				).
				changeOrbit("A-", apo, finalStage, autoStage, burnSequence).
			}			
		}
		else {
			if PERIAPSIS < peri {
				set burnSequence to list(
					1.0, 0.8 * peri,
					0.5, 0.9 * peri,
					0.1, peri 
				).
				changeOrbit("P+", peri, finalStage, autoStage, burnSequence).
			} else {
				set burnSequence to list(
					1.0, 1.2 * peri,
					0.5, 1.1 * peri,
					0.1, peri 
				).
				changeOrbit("P-", peri, finalStage, autoStage, burnSequence).
			}
		}
	}
}.
