// some variables to abstract stuff away
GLOBAL HAS_PREDICTION TO Career():CANMAKENODES.
GLOBAL HAS_ACTION_GROUPS TO Career():CANDOACTIONS.
GLOBAL DEBUG_MODE TO true.

// part names
GLOBAL TIP_PARACHUTE_NAME to "Mk16 Parachute".
GLOBAL RADIAL_PARACHUTE_NAME to "Mk2-R Radial-Mount Parachute".
GLOBAL COMMUNOTRON_DTS_M1_NAME to "Communotron DTS-M1".

function ENABLE_DEBUG_MODE {
	set DEBUG_MODE TO true.
	LOG_DEBUG("Debug mode enabled.").
}.

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
		WAIT 0.5. STAGE. WAIT 0.5. // wait before stage, otherwise throttle might not be fully decreased yet.
		LOCK THROTTLE TO thrttl.
	}
}.

function stageUpTo {
	parameter finalStage.
	UNTIL STAGE:NUMBER = finalStage { safe_stage(true, 0.0). }
}.

function drawVec {
	parameter v.
	parameter c.
	parameter label.
	VECDRAW(V(0,0,0), v, c, label, 15, true, 0.05).
}.

// estimation based on v for circular orbit at target height
function guesstimateHeightChangeBurnTime { 
	parameter targetHeight.
	parameter currentHeight. // height at which we start the burn
	parameter planet.

	set vt to SQRT(planet:MU / (currentHeight + planet:RADIUS)).
	set vAtBurn to SQRT(planet:MU * (2 / (planet:RADIUS + currentHeight) - 1 / SHIP:ORBIT:SEMIMAJORAXIS)).
	set a to SHIP:MAXTHRUST / SHIP:MASS. // thrust is in kN and mass is in tons
	set dV to vt - vAtBurn.
	if dV < 0 { set dV to -dV. }
	return dV / a.	
}.

function burnStep {
	parameter thrttl.
	parameter autoStage.
	if autoStage { safe_stage(MAXTHRUST = 0, thrttl). }
}. 

function getOppositeHeight {
	// look at the current etas. The one closest to half the orbit period is the one opposite from us
	if ABS(ETA:APOAPSIS - SHIP:ORBIT:PERIOD / 2) > ABS(ETA:PERIAPSIS - SHIP:ORBIT:PERIOD / 2) { return PERIAPSIS. }
	else { return APOAPSIS. }
}.

function getOrbitNormal {
	set n to SHIP:NORTH:FOREVECTOR:NORMALIZED. set u to SHIP:UP:FOREVECTOR:NORMALIZED.
	set f to VCRS(u, n).
	return -f * sin(SHIP:ORBIT:INCLINATION) + n * cos(SHIP:ORBIT:INCLINATION).
}.

function getHorizonPrograde {
	set n to SHIP:NORTH:FOREVECTOR:NORMALIZED. set u to SHIP:UP:FOREVECTOR:NORMALIZED.
	set f to VCRS(u, n).
	return f * cos(SHIP:ORBIT:INCLINATION) + n * sin(SHIP:ORBIT:INCLINATION).
}.

function getMunarInterceptAngle {
	parameter burnHeight.

	set aMun to BODY("Mun"):ORBIT:SEMIMAJORAXIS.
	set aShip to aMun * 0.5 + BODY("Kerbin"):RADIUS + burnHeight. // elliptical orbit with periapsis at current height and apoapsis on munar height.
	return 180 * aShip * aShip / (aMun * aMun).
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
