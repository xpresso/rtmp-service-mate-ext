#!/bin/bash

mvn install:install-file \
-Dfile=red5.jar \
-DgroupId=org.red5 \
-DartifactId=red5 \
-Dversion=0.9.0 \
-Dpackaging=jar \
-DgeneratePom=true