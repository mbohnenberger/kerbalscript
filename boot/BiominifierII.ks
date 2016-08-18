// copying files for launch sequence
copypath("0:/launchers.ks","1:/launchers.ks").
copypath("0:/orbiting/orbiting2base.ks","1:/orbiting/orbiting2base.ks").
copypath("0:/utils/deployParachutes.ks","1:/utils/deployParachutes.ks").
RUN ONCE "launchers.ks".

ENABLE_DEBUG_MODE().

countdown(5).
stepped_gravity_launch(2, 900000, 0, 1.0, 0.0, 0.6).
stageUpTo(1).
LOCK STEERING TO RETROGRADE.
run utils_deployParachutes.
UNLOCK STEERING.

LOG_INFO("Boot script complete.").
