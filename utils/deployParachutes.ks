declare parameter deploymentHeight is 1000.
declare parameter nameTag is "".
declare parameter deploymentHeightDrogue is 10000.
declare parameter nameTagDrogue is "".

run once "common/common.ks".

//
// find drogue chutes and set altitude
//
set drogueChuteModuleName to "ModuleParachute".
set drogueChuteEventName to "Deploy Chute".
set drogueChuteAltitudeFieldName to "altitude".
set drogueChuteTitles to list().

set found_drogue_chutes to list().
if nameTagDrogue:LENGTH <= 0 {
	for drogueChuteTitle in drogueChuteTitles {
		for drogueChute in SHIP:PARTSTITLED(drogueChuteTitle) { found_drogue_chutes:ADD(drogueChute). }
	}
} else {
	set found_drogue_chutes to SHIP:PARTSTAGGED(nameTagDrogue).
}

if DEBUG_MODE { LOG_DEBUG("Drogue Parachutes found: " + found_drogue_chutes). }

for drogueChute in found_drogue_chutes {
	set drogueChuteModule to drogueChute:getmodule(drogueChuteModule).
	drogueChuteModule:setField(drogueChuteAltitudeFieldName, deploymentHeightDrogue).
}
LOG_INFO("Drogue chutes armed. Deploying at " + deploymentHeightDrogue + "m radar altitude.").

//
// find main chutes and set altitude
//
set chuteModuleName to "ModuleParachute".
set chuteEventName to "Deploy Chute".
set chuteAltitudeFieldName to "altitude".
set chuteTitles to list(RADIAL_PARACHUTE_NAME, TIP_PARACHUTE_NAME).

set found_chutes to list().
if nameTag:LENGTH <= 0 {
	for chuteTitle in chuteTitles {
		for chute in SHIP:PARTSTITLED(chuteTitle) { found_chutes:ADD(chute). }
	}
} else {
	set found_chutes to SHIP:PARTSTAGGED(nameTag).
}

if DEBUG_MODE { LOG_DEBUG("Parachutes found: " + found_chutes). }

for chute in found_chutes {
	set chuteModule to chute:getmodule(chuteModuleName).
	chuteModule:setField(chuteAltitudeFieldName, deploymentHeight).
}
LOG_INFO("Parachutes armed. Deploying at " + deploymentHeight + "m radar altitude.").

//
// deploy drogue chutes.
//
WAIT UNTIL ALT:RADAR < deploymentHeightDrogue.
LOG_INFO("Deploying drogue parachutes.").

for drogueChute in found_drogue_chutes {
	set drogueChuteModule to chute:getmodule(drogueChuteModuleName).
	if drogueChuteModule:HasEvent(drogueChuteEventName) {
		drogueChuteModule:DoEvent(drogueChuteEventName).
	}
}

//
// deploy main chutes.
//
WAIT UNTIL ALT:RADAR < deploymentHeight.
LOG_INFO("Deploying parachutes.").

for chute in found_chutes {
	set chuteModule to chute:getmodule(chuteModuleName).
	if chuteModule:HasEvent(chuteEventName) {
		chuteModule:DoEvent(chuteEventName).
	}
}
