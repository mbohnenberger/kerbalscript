// copying files for launch sequence
copy launchers from 0.
copy orbiting2 from 0.
RUN ONCE launchers.
RUN ONCE orbiting2.

ENABLE_DEBUG_MODE().

countdown(5).
stepped_gravity_launch(0, 80000, 0.66).
raisePeriapsis(80000, 90, True).
//stabilizeOrbit(90000, 100000, 90, 0, True).
increaseInclination(10, 0).
decreaseInclination( 0, 0).
