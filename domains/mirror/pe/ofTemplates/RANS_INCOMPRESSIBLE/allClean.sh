#!/bin/sh

source /usr/local/stella/OpenFOAM-v1906-gcc/OpenFOAM-v1906/etc/bashrc

# Source tutorial clean functions
. $WM_PROJECT_DIR/bin/tools/CleanFunctions

# remove surface and features
\rm -rf constant/extendedFeatureEdgeMesh > /dev/null 2>&1
rm -rf 0 > /dev/null 2>&1

# remove old timings, execution signals, and results
rm *.timing
rm *.signal

rm postProcessing/forceCoeffs/0/coefficient.dat
rm result.dat

cleanCase
