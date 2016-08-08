copy common from 0.
run once common.

function countdown {
    parameter t.
    
    LOG_INFO("Counting down...").

    FROM { local c is t. }
    UNTIL c = 0
    STEP { set c to c-1. }
    DO {
        LOG_INFO("..." + c + "...").
        WAIT 1.
    }
}.

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
    UNTIL APOAPSIS > apo OR STAGE:NUMBER < finalStage {
        safe_stage(MAXTHRUST = 0, thrttl).
    }

    finish_launch().
}.

function stepped_gravity_launch {
    parameter finalStage.
    parameter apo.
    parameter thrttl is 1.0.

    init_launch(thrttl).

    LOG_INFO("Stepped velocity gravity launch sequence active.").

    set angle to 90.
    set atmosphereHeight to BODY("Kerbin"):ATM:HEIGHT.
    IF apo < atmosphereHeight {
	LOG_WARN("Target apoapsis is inside atmosphere.").
    }
    set horizontalHeight to MIN(apo, 0.7 * BODY("Kerbin"):ATM:HEIGHT). // horizontal at 70% atmosphere height
    set heightStep to horizontalHeight / 9.
    set hCheck to heightStep.

    //LOG_DEBUG("Horizontal at: " + ROUND(horizontalHeight)).
    //LOG_DEBUG("Height step: " + ROUND(heightStep)).
    LOG_INFO("Target apoapsis: " + ROUND(apo)).

    UNTIL APOAPSIS > apo OR STAGE:NUMBER < finalStage {
	    IF ALTITUDE > hCheck {
		set angle to angle - 10.
		set hCheck to hCheck + heightStep.
		LOG_INFO("Pitching to " + angle + " degrees").
		LOCK STEERING TO HEADING(90,angle).	
	    }
	    safe_stage(MAXTHRUST = 0, thrttl).
    }

    finish_launch().
}.
