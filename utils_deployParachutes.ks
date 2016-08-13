declare parameter deploymentHeight is 1000.
declare parameter nameTag is "".

run once common.

set chuteModuleName to "ModuleParachute".
set chuteEventName to "Deploy Chute".
set chuteAltitudeFieldName to "altitude".

set found_chutes to list().
if nameTag:LENGTH <= 0 {
	for chute in SHIP:PARTSTITLED(RADIAL_PARACHUTE_NAME) { found_chutes:ADD(chute). }
	for chute in SHIP:PARTSTITLED(TIP_PARACHUTE_NAME) { found_chutes:ADD(chute). }
} else {
	set found_chutes to SHIP:PARTSTAGGED(nameTag).
}

if DEBUG_MODE { LOG_DEBUG("Parachutes found: " + found_chutes). }

for chute in found_chutes {
	set chuteModule to chute:getmodule(chuteModuleName).
	chuteModule:setField(chuteAltitudeFieldName, deploymentHeight).
	if chuteModule:HasEvent(chuteEventName) {
		chuteModule:DoEvent(chuteEventName).
	}
}

LOG_INFO("Parachutes armed. Deploying at " + deploymentHeight + "m radar altitude.").