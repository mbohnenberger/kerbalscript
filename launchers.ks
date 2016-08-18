function init_launch {
    parameter thrttl.

	if ALT:RADAR > 100 { LOG_ERROR("Ship is not grounded. Aborting launch sequence."). RETURN. }
    LOG_INFO("Starting launch sequence...").
    LOCK THROTTLE TO thrttl.
    LOCK STEERING TO HEADING(90,90).
}.

function finish_launch {
    LOG_INFO("Launch sequence complete.").
    LOCK THROTTLE TO 0.
    SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
}.

function straight_launch {
    parameter finalStage.
    parameter apo.
    parameter thrttl is 1.0.

    init_launch(thrttl).

    LOG_INFO("Straight launch sequence active.").
    UNTIL APOAPSIS > apo OR STAGE:NUMBER <= finalStage {
        safe_stage(MAXTHRUST = 0, thrttl).
    }

    finish_launch().
}.

function maxV_straight_launch {
	parameter finalStage.
	parameter targetHeight.
	parameter maxV.

	set thrttl to 1.0.
	init_launch(thrttl).

	LOG_INFO("Straight launch sequence w max V of " + maxV + " active.").
	UNTIL SHIP:ALTITUDE >= targetHeight OR STAGE:NUMBER <= finalStage {
		if SHIP:VERTICALSPEED > maxV { set thrttl to 0.0. } else { set thrttl to 1.0. }		
		LOCK THROTTLE to thrttl.
		safe_stage(MAXTHRUST = 0, thrttl).
	}

	finish_launch().
}.

function stepped_gravity_launch {
    parameter finalStage.
    parameter apo.
	parameter degToNorth.
    parameter thrttl is 1.0.
	parameter minAngle is 0.0.
	parameter evenOutFactor is 0.7.

    init_launch(thrttl).

	set angle to 90.
    LOG_INFO("Stepped velocity gravity launch sequence active.").

    set atmosphereHeight to BODY("Kerbin"):ATM:HEIGHT.
    IF apo < atmosphereHeight {
	LOG_WARN("Target apoapsis is inside atmosphere.").
    }
    set horizontalHeight to MIN(evenOutFactor * apo, evenOutFactor * BODY("Kerbin"):ATM:HEIGHT). // horizontal at 70% atmosphere height
    set heightStep to horizontalHeight / 9.
    set hCheck to heightStep.

    //LOG_DEBUG("Horizontal at: " + ROUND(horizontalHeight)).
    //LOG_DEBUG("Height step: " + ROUND(heightStep)).
    LOG_INFO("Target apoapsis: " + ROUND(apo)).

    UNTIL APOAPSIS > apo OR STAGE:NUMBER <= finalStage + 1 {
	    IF ALTITUDE > hCheck {
		set angle to MAX(minAngle, angle - 10).
		set angle to MAX(angle, 0).
		set hCheck to hCheck + heightStep.
		LOG_INFO("Pitching to " + angle + " degrees").
		LOCK STEERING TO HEADING(degToNorth,angle).	
	    }
	    safe_stage(MAXTHRUST = 0, thrttl).
    }

    finish_launch().
}.
