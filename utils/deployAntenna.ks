declare parameter commTarget is "Mission Control".
declare parameter nameTag is "".
declare parameter antennaParts is list().

run once "common/common.ks".

//
// find antennas 
//
if antennaParts:LENGTH <= 0 {
	set antennaTitles to list(COMMUNOTRON_DTS_M1_NAME, COMMUNOTRON_16_NAME).
} else {
	set antennaTitles to antennaParts.
}

set found_antennas to list().
if nameTag:LENGTH <= 0 {
	for antennaTitle in antennaTitles {
		for antenna in SHIP:PARTSTITLED(antennaTitle) { found_antennas:ADD(antenna). }
	}
} else {
	set found_antennas to SHIP:PARTSTAGGED(nameTag).
}


if DEBUG_MODE { LOG_DEBUG("Antennas found: " + found_antennas). }
if found_antennas:LENGTH <= 0 { LOG_WARN("No antennas found!"). }
else {
	set antenna to found_antennas[0]. // pick the first one
	
	if antenna:TITLE = COMMUNOTRON_DTS_M1_NAME { // antenna can set target
		set antennaModuleName to "ModuleRTAntenna".
		set antennaEventName to "activate".
		set antennaTargetFieldName to "target".

		LOG_INFO("Aiming antenna at " + commTarget).
		set antennaModule to antenna:getmodule(antennaModuleName).
		if antennaModule:HasEvent(antennaEventName) {
			antennaModule:SetField(antennaTargetFieldName, commTarget).
			antennaModule:DoEvent(antennaEventName).
			LOG_INFO("Antenna deployed and aiming at " + commTarget).
		} else {
			LOG_ERROR("Antenna has no event called " + antennaEventName).
		}
	}
	else if antenna:TITLE = COMMUNOTRON_16_NAME {
		set antennaModuleName to "ModuleRTAntenna".
		set antennaEventName to "activate".

		LOG_INFO("Extending antenna").
		set antennaModule to antenna:getmodule(antennaModuleName).
		if antennaModule:HasEvent(antennaEventName) {
			antennaModule:DoEvent(antennaEventName).
			LOG_INFO("Antenna extended").
		} else {
			LOG_ERROR("Antenna has no event called " + antennaEventName).
		}

	}
}
