// copying files for launch sequence
copy launchers from 0.
RUN ONCE launchers.

copy orbiting2_raisePeriapsis from 0.
copy orbiting2_raisePeriapsisNow from 0.
copy orbiting2_deorbit from 0.
copy utils_deployParachutes from 0.
copy orbiting2_deorbitAndLand from 0.

ENABLE_DEBUG_MODE().

countdown(5).
stepped_gravity_launch(1, 90000, 0.66).
run orbiting2_raisePeriapsis(90000, 90, 1, True).

LOG_INFO("Boot script complete.").