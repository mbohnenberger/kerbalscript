// copying files for launch sequence
copypath("0:/lifters/mercuryII_launch_files.ks","1:/lifters/mercuryII_launch_files.ks").
run once "lifters/mercuryII_launch_files.ks".

countdown(5).
run "lifters/mercuryII_launch.ks".
