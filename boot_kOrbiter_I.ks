// copying files for launch sequence
copy launchers from 0.
copy orbiting2 from 0.
RUN ONCE launchers.
RUN ONCE orbiting2.

ENABLE_DEBUG_MODE().

countdown(5).
stepped_gravity_launch(0, 90000, 0.66).
run orbiting2_raisePeriapsis(90000, 90, True).

LOG_INFO("Boot script complete.").