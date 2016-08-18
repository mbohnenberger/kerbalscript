declare parameter r.
declare parameter finalStage.
declare parameter autoStage is True.
declare parameter burnSettings is list().

// burns until target periapsis is reached. If target periapsis is higher than apoapsis
// we will keep burning until apoapsis is target height

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
UNTIL MAX(0, getOppositeHeight()) < burnSettings[burnSegment][0] * r OR burnSegment >= burnSettings:LENGTH - 1 {
	set burnSegment to burnSegment + 1.
}

LOCK horizontalPrograde to getHorizonPrograde().
LOCK STEERING TO horizontalPrograde.	
WAIT 5.

UNTIL burnSegment >= burnSettings:LENGTH OR STAGE:NUMBER <= finalStage + 1 {
	set thrttl to burnSettings[burnSegment][1].
	LOCK THROTTLE TO thrttl.
	// burn until the opposing point is at the target height 
	UNTIL getOppositeHeight() >= r * burnSettings[burnSegment][0] { burnStep(burnSettings[burnSegment][1], autoStage). }
	set burnSegment to burnSegment + 1.
}
UNLOCK STEERING.
LOCK THROTTLE TO 0.0.
