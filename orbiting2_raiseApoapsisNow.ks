declare parameter r.
declare parameter degFromNorth.
declare parameter finalStage.
declare parameter autoStage is True.
declare parameter burnSettings is list().

run once common.

// burns until target apoapsis is reached.
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

LOCK STEERING TO HEADING(degFromNorth, 0).	
WAIT 5.

UNTIL burnSegment = burnSettings:LENGTH OR STAGE:NUMBER < finalStage {
	LOCK THROTTLE TO burnSettings[burnSegment][1].
	UNTIL getOppositeHeight() >= r * burnSettings[burnSegment][0] { burnStep(degFromNorth, burnSettings[burnSegment][1], autoStage). }
	set burnSegment to burnSegment + 1.
}
UNLOCK STEERING.
LOCK THROTTLE TO 0.0.