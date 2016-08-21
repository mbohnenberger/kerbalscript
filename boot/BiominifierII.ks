// copying files for launch sequence
copypath("0:/launchers.ks","1:/launchers.ks").
copypath("0:/common/common.ks","1:/common/common.ks").
//copypath("0:/orbiting/orbiting2base.ks","1:/orbiting/orbiting2base.ks").
copypath("0:/utils/deployParachutes.ks","1:/utils/deployParachutes.ks").
runpath("common/common.ks").
runpath("launchers.ks").

ENABLE_DEBUG_MODE().

countdown(5).
//stepped_gravity_launch(1, 900000, 90, 1.0, 0.0, 0.6).
TCGT_launch(1, 90000000, 90, 85, 2.2, 20.0, 99999999, 10000, 0.2).
stageUpTo(1).
LOCK STEERING TO RETROGRADE.
runpath("utils/deployParachutes.ks").
UNLOCK STEERING.

LOG_INFO("Boot script complete.").
