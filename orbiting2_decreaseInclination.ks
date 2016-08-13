declare parameter angle.
declare parameter lgtAscendingNode.
declare parameter finalStage.
declare parameter autoStage is True.
declare parameter burnSettings is list().

run once common.

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
UNTIL burnSegment = burnSettings:LENGTH OR STAGE:NUMBER < finalStage {
	if burnAtAsc {
		WAIT UNTIL ABS(SHIP:LONGITUDE - lgtAscendingNode) < 10.
		LOG_INFO("Closing in on ascending node. Locking steering.").
		if DEBUG_MODE { drawVec(-getOrbitNormal(), RED, "anti-normal"). }
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
		if DEBUG_MODE { drawVec(getOrbitNormal(), RED, "normal"). }
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
