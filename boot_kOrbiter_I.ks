// copying files for launch sequence
copy launchers from 0.
copy orbiting2 from 0.
RUN ONCE launchers.
RUN ONCE orbiting2.

ENABLE_DEBUG_MODE().

countdown(5).
stepped_gravity_launch(2, 80000, 0.66).
raisePeriapsis(90000, 90, True).
stabilizeOrbit(90000, 100000, 90, 0, True).
