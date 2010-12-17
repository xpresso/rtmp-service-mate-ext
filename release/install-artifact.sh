#!/bin/bash

mvn install:install-file \
-Dfile=rtmp-service-1.3.0.swc \
-DgroupId=com.flashdevs.mateExt \
-DartifactId=rtmp-service \
-Dversion=1.3.0 \
-Dpackaging=swc \
-DgeneratePom=true
