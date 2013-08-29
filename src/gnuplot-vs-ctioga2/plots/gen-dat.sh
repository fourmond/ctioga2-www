#! /bin/sh

ctioga2 --math /xrange -20:19 /samples=40 \
	-L '2*atan(x)' -P /save=1.dat \
	-L '4*atan(x)' -P /save=2.dat \
	-L '6*atan(x)' -P /save=3.dat
