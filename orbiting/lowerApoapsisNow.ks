declare parameter r.
declare parameter finalStage.
declare parameter autoStage is True.
declare parameter burnSettings is list().

if STAGE:NUMBER <= finalStage { LOG_WARN("Final stage reached. Not adjusting orbit."). }

// burns until target apoapsis is reached. Keeps burning if we surpass periapsis
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

if SHIP:ORBIT:ECCENTRICITY < 1 {
	UNTIL getOppositeHeight() > burnSettings[burnSegment][0] * r OR burnSegment >= burnSettings:LENGTH - 1 {
		set burnSegment to burnSegment + 1.
	}
}

LOCK horizontalRetrograde to -getHorizonPrograde().
LOCK STEERING TO horizontalRetrograde.
WAIT 5.

UNTIL burnSegment = burnSettings:LENGTH OR STAGE:NUMBER <= finalStage {
	set thrttl to burnSettings[burnSegment][1].
	LOCK THROTTLE TO thrttl.
	UNTIL getOppositeHeight() <= r * burnSettings[burnSegment][0] AND APOAPSIS > 0 { burnStep(burnSettings[burnSegment][1], autoStage). }
	set burnSegment to burnSegment + 1.
}
UNLOCK STEERING.
LOCK THROTTLE TO 0.0.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
