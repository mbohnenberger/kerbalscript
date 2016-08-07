// copying files for launch sequence
copy launchers from 0.
copy orbiting from 0.
RUN ONCE launchers.
RUN ONCE orbiting.

countdown(5).
stepped_gravity_launch(2, 80000, 0.66).
establishOrbit(80000, 1).
