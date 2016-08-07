// copying files for launch sequence
print "Copying scripts...".
copy launchers from 0.
RUN ONCE launchers.

countdown(5).
straight_launch(3, 66000).
