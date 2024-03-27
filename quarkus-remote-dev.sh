#!/bin/bash

for arg in "$@"; do
    case $arg in
        --ci)
            ci=true
            ;;
        --app-name=*)
            app_name="${1#*=}"
            ;;
        *)
            exit 1
            ;;
    esac
    shift
done

echo "Setting 'quarkus.package.type' to 'mutable-jar'."
sed -i 's/^quarkus\.package\.type=.*/quarkus.package.type=mutable-jar/' src/main/resources/application.properties

echo "Packaging application..."
mvn clean package -DskipTests

echo "Creating build with name: $app_name"
echo "Creating app with name: $app_name"
oc new-build registry.access.redhat.com/ubi8/openjdk-17 --binary --name=remotelivecode -l app=remotelivecode

echo "Starting build with name: $app_name"
oc start-build remotelivecode --from-dir=target/quarkus-app

echo "Creating new app with name: $app_name in devmode"
oc new-app remotelivecode -e QUARKUS_LAUNCH_DEVMODE=true

echo "Expose service with name: $app_name"
oc expose service/remotelivecode