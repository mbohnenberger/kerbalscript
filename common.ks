// some variables to abstract stuff away
GLOBAL HAS_PREDICTION TO Career():CANMAKENODES.
GLOBAL HAS_ACTION_GROUPS TO Career():CANDOACTIONS.
GLOBAL DEBUG_MODE TO false.

function ENABLE_DEBUG_MODE {
	set DEBUG_MODE TO true.
	LOG_DEBUG("Debug mode enabled.").
}.

// IO
function LOG_MSG {
	parameter message.
	parameter color.
	parameter writeToLog is False.
	HUDTEXT(message, 10, 1, 30, color, false).
	PRINT(message).
	if writeToLog {LOG message to lastLaunch.txt.}
}.

function HUD_HUGE_ALERT {
	parameter message.
	HUDTEXT(message, 10, 2, 60, red, false).
}.

function LOG_INFO {
	parameter message.
	parameter writeToLog is False.
	LOG_MSG("INFO: " + message, white, writeToLog).
}.

function LOG_DEBUG {
	parameter message.
	parameter writeToLog is False.
	if(DEBUG_MODE) {LOG_MSG("DEBUG: " + message, blue, writeToLog).}
}.

function LOG_WARN {
	parameter message.
	parameter writeToLog is False.
	LOG_MSG("WARNING: " + message, yellow, writeToLog).
}.

function LOG_ERROR {
	parameter message.
	parameter writeToLog is False.
	LOG_MSG("ERROR: " + message, red, writeToLog).
}.

// this should probably live somewhere else..
function safe_stage {
	parameter doStage is True.
	parameter thrttl is 1.0.
	IF doStage {
		LOCK THROTTLE TO 0.0.
		STAGE. WAIT 1.
		LOCK THROTTLE TO thrttl.
	}
}.

// common delegates
function apoD { return APOAPSIS. }.
function periD { return PERIAPSIS. }.
function etaApoD { return ETA:APOAPSIS. }. 
function etaPeriD { return ETA:PERIAPSIS. }. 
function progradeD { return PROGRADE. }.
function retrogradeD { return RETROGRADE. }.
GLOBAL dApo TO apoD@.
GLOBAL dPeri TO periD@.
GLOBAL dEtaApo TO etaApoD@.
GLOBAL dEtaPeri TO etaPeriD@.
GLOBAL dPrograde TO progradeD@.
GLOBAL dRetrograde TO retrogradeD@.
