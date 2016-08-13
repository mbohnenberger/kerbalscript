// copying files for launch sequence
copy launchers from 0.
copy orbiting2base from 0.
RUN ONCE launchers.
RUN ONCE orbiting2base.

ENABLE_DEBUG_MODE().

countdown(5).
stepped_gravity_launch(2, 90000, 90, 1.0).
run orbiting2_raisePeriapsis(90000, 90, 2, True).

LOG_INFO("Boot script complete.").