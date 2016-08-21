copypath("0:/common/common.ks","1:/common/common.ks").
copypath("0:/utils/hovering.ks","1:/utils/hovering.ks").

runpath("common/common.ks").
ENABLE_DEBUG_MODE().
countdown(5).
LOCK STEERING TO HEADING(90,90).
STAGE.
runpath("utils/hovering.ks",500, 0.0015, 0.0, 0.002).
