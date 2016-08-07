function PRINT_MSG {
	parameter message.
	parameter color.
	HUDTEXT(message, 10, 1, 30, color, false).
}.

function PRINT_INFO {
	parameter message.
	PRINT_MSG("INFO: " + message, white).
}.

function PRINT_DEBUG {
	parameter message.
	PRINT_MSG("DEBUG: " + message, blue).
}.

function PRINT_WARN {
	parameter message.
	PRINT_MSG("WARNING: " + message, yellow).
}.

function PRINT_ERROR {
	parameter message.
	PRINT_MSG("ERROR: " + message, red).
}.

function safe_stage {
	parameter doStage is True.
	parameter thrttl is 1.0.
	IF doStage {
		LOCK THROTTLE TO 0.0.
		STAGE. WAIT 1.
		LOCK THROTTLE TO thrttl.
	}
}.

