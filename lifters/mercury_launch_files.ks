copypath("0:/common/common.ks","1:/common/common.ks").
copypath("0:/launchers.ks","1:/launchers.ks").
copypath("0:/orbiting/raisePeriapsis.ks","1:/orbiting/raisePeriapsis.ks").
copypath("0:/orbiting/raisePeriapsisNow.ks","1:/orbiting/raisePeriapsisNow.ks").
copypath("0:/lifters/mercury_launch.ks","1:/lifters/mercury_launch.ks").

run once "common/common.ks".
run once "launchers.ks".
