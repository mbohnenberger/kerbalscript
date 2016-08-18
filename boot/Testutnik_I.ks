// copying files for launch sequence
print "Copying scripts...".
copypath("0:/launchers.ks","1:/launchers.ks").
RUN ONCE "launchers.ks".

countdown(5).
straight_launch(3, 66000).
