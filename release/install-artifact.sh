#!/bin/bash

mvn install:install-file \
-Dfile=rtmp-service-1.2.0.swc \
-DgroupId=com.flashdevs.mateExt \
-DartifactId=rtmp-service \
-Dversion=1.2.0 \
-Dpackaging=swc \
-DgeneratePom=true
