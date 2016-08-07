copy common from 0.
run once common.

function increasePeriapsis {
    parameter peri.
    parameter finalStage.
    PRINT_INFO("Increasing periapsis").

    if PERIAPSIS > peri { RETURN. }
    set errorPeri to peri - PERIAPSIS. // positive error
    set estimateBurnTime to errorPeri / 100000 * 5.
    set etaBurnStartApo to estimateBurnTime / 2. // heuristic for when to start burn 20s base times error

    LOCK STEERING TO PROGRADE.	
    WAIT UNTIL ETA:APOAPSIS < etaBurnStartApo.
    PRINT_INFO("Starting burn").
    LOCK THROTTLE TO 1.0. 
    UNTIL PERIAPSIS > peri OR STAGE:NUMBER < finalStage {
	safe_stage(MAXTHRUST = 0, 1.0).	
    }
    LOCK THROTTLE TO 0.0.
    PRINT_INFO("Burn complete").
    if PERIAPSIS < peri { PRINT_WARN("Periapsis not fully increased"). }
}

function decreasePeriapsis {
    parameter peri.
    parameter finalStage.
    PRINT_INFO("Decreasing periapsis").

    if PERIAPSIS < peri { RETURN. }
    set errorPeri to PERIAPSIS - peri. // positive error
    set estimateBurnTime to errorPeri / 100000 * 5.
    set etaBurnStartApo to estimateBurnTime / 2. // heuristic for when to start burn 20s base times error

    LOCK STEERING TO RETROGRADE.	
    WAIT UNTIL ETA:APOAPSIS < etaBurnStartApo.
    PRINT_INFO("Starting burn").
    LOCK THROTTLE TO 1.0. 
    UNTIL PERIAPSIS < peri OR STAGE:NUMBER < finalStage {
	safe_stage(MAXTHRUST = 0, 1.0).	
    }
    LOCK THROTTLE TO 0.0.
    PRINT_INFO("Burn complete").
    if PERIAPSIS > peri { PRINT_WARN("Periapsis not fully decreased"). }
}

function increaseApoapsis {
    parameter apo.
    parameter finalStage.
    PRINT_INFO("Increasing apoapsis").

    if APOAPSIS > apo { RETURN. }    
    set errorApo to apo - APOAPSIS. // positive error
    set estimateBurnTime to errorApo / 100000 * 5.
    set etaBurnStartPeri to estimateBurnTime / 2. // heuristic for when to start burn 20s base times error

    LOCK STEERING TO PROGRADE.	
    WAIT UNTIL ETA:PERIAPSIS < etaBurnStartPeri.
    PRINT_INFO("Starting burn").
    LOCK THROTTLE TO 1.0. 
    UNTIL APOAPSIS > apo OR STAGE:NUMBER < finalStage {
	safe_stage(MAXTHRUST = 0, 1.0).	
    }
    LOCK THROTTLE TO 0.0.
    PRINT_INFO("Burn complete").
    if APOAPSIS < apo { PRINT_WARN("Apoapsis not fully increased"). }
}

function decreaseApoapsis {
    parameter apo.
    parameter finalStage.
    PRINT_INFO("Decreasing apoapsis").

    if APOAPSIS < apo { RETURN. }    
    set errorApo to APOAPSIS - apo. // positive error
    set estimateBurnTime to errorApo / 100000 * 5.
    set etaBurnStartPeri to estimateBurnTime / 2. // heuristic for when to start burn 20s base times error

    LOCK STEERING TO RETROGRADE.	
    WAIT UNTIL ETA:PERIAPSIS < etaBurnStartPeri.
    PRINT_INFO("Starting burn").
    LOCK THROTTLE TO 1.0. 
    UNTIL APOAPSIS < apo OR STAGE:NUMBER < finalStage {
	safe_stage(MAXTHRUST = 0, 1.0).	
    }
    LOCK THROTTLE TO 0.0.
    PRINT_INFO("Burn complete").
    if APOAPSIS > apo { PRINT_WARN("Apoapsis not fully decreased"). }
}

function establishOrbit {
	parameter peri.
	parameter finalStage.

	if ETA:APOAPSIS > ETA:PERIAPSIS AND PERIAPSIS < SHIP:ORBIT:BODY:ATMOSPHERE:HEIGHT { 
		PRINT_ERROR("Missed apoapsis with periapsis below atmosphere. FIX MANUALLY!"). 
		RETURN.
	}
 
	increasePeriapsis(peri, finalStage).
}.

function stabilizeOrbit {
	parameter apo.
	parameter peri.
	parameter finalStage.
	parameter err is 0.01.

	if ETA:APOAPSIS > ETA:PERIAPSIS AND PERIAPSIS < SHIP:ORBIT:BODY:ATMOSPHERE:HEIGHT { 
		PRINT_ERROR("Missed apoapsis with periapsis below atmosphere. FIX MANUALLY!"). 
		RETURN.
	}
        
        set errorApo to APOAPSIS - apo.
	set errorPeri to PERIAPSIS - peri.

	UNTIL errorApo < err * APOAPSIS AND errorPeri < err * PERIAPSIS OR STAGE:NUMBER < finalStage {
		if ETA:APOAPSIS < ETA:PERIAPSIS {
			if APOAPSIS < apo {
				increaseApoapsis(apo, finalStage).
			} else { 
				decreaseApoapsis(apo, finalStage).
			}			
		}
		else {
			if PERIAPSIS < peri {
				increasePeriapsis(peri, finalStage).
			} else {
				decreasePeriapsis(peri, finalStage).
			}
		}
	}
}.
