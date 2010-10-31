#!/bin/bash

mvn install:install-file \
-Dfile=wms-core.jar \
-DgroupId=wowza \
-DartifactId=wms-core \
-Dversion=2.1.1 \
-Dpackaging=jar \
-DgeneratePom=true

mvn install:install-file \
-Dfile=wms-server.jar \
-DgroupId=wowza \
-DartifactId=wms-server \
-Dversion=2.1.2 \
-Dpackaging=jar \
-DgeneratePom=true