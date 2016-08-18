// copying files for launch sequence
copypath("0:/launchers.ks","1:/launchers.ks").
copypath("0:/orbiting/orbiting2base.ks","1:/orbiting/orbiting2base.ks").
RUN ONCE "launchers.ks".
RUN ONCE "orbiting/orbiting2base.ks".

ENABLE_DEBUG_MODE().

countdown(5).
stepped_gravity_launch(2, 90000, 0, 1.0).
run orbiting2_raisePeriapsis(90000, 2, True).

LOG_INFO("Boot script complete.").
