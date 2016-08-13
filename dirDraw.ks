declare parameter d.
declare parameter label.

VECDRAW(V(0,0,0), d*V(1,0,0), RED, label + " X",5,true).
VECDRAW(V(0,0,0), d*V(0,1,0), GREEN, label + " Y",5,true).
VECDRAW(V(0,0,0), d*V(0,0,1), BLUE, label + " Z",5,true).
