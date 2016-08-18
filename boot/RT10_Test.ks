// copying files for launch sequence
copypath("0:/launchers.ks","1:/launchers.ks").
RUN ONCE "launchers.ks".

ENABLE_DEBUG_MODE().

countdown(5).
maxV_straight_launch(2, 10000, 140). 

UNTIL STAGE:NUMBER = 1 { safe_stage(true, 0.0). }

UNTIL false {
	if SHIP:ALTITUDE > 9000
		AND SHIP:ALTITUDE < 13000
		AND SHIP:VERTICALSPEED > 60
		AND SHIP:VERTICALSPEED < 160
	{
		LOG_INFO("Test conditions met! Staging.").
		STAGE.
		BREAK.
	}
}

WAIT UNTIL ALT:RADAR < 700.
STAGE.

LOG_INFO("Boot script complete.").
