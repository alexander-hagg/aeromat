#!/bin/bash

# Start caserunners in each directory
for d in ./case*/ ; do (cd "$d" && qsub submit.sh &); done

# for d in ./case*/ ; do (cd "$d" && ./caseRunner.sh &); done

