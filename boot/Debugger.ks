// copying files for launch sequence
copypath("0:/launchers.ks","1:/launchers.ks").
copypath("0:/orbiting/orbiting2.ks","1:/orbiting/orbiting2.ks").
RUN ONCE "launchers.ks".
RUN ONCE "orbiting/orbiting2.ks".

ENABLE_DEBUG_MODE().

countdown(5).
stepped_gravity_launch(0, 90000, 0.66).
raisePeriapsis(90000, True).
increaseInclination(90, 0).
