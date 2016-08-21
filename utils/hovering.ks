declare parameter height.
declare parameter kp.
declare parameter ki.
declare parameter kd.

run once "common/common.ks".

set prevE to 0.
set E to height - ALT:RADAR.
set I to 0. 
set D to 0.
set dT to 1.

until false {
	set prevE to E.
	set E to height - ALT:RADAR.

	set P to kp * (height - ALT:RADAR).
	set I to ki * (I + (E + prevE) / 2 * dT).
	set D to kd * (E - prevE) / dT.

	LOG_DEBUG("P = " + P).
	LOG_DEBUG("I = " + I).
	LOG_DEBUG("D = " + D).
	LOG_DEBUG("Throttle = " + (P + I + D)).
	LOCK THROTTLE TO MIN(1.0, MAX(0.0, P + I + D)).
	WAIT dT.
}
