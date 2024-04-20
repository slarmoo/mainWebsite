#!/bin/bash

while getopts k:h:s: flag
do
    case "${flag}" in
        k) key=${OPTARG};;
        h) hostname=${OPTARG};;
        s) service=${OPTARG};;
    esac
done

if [[ -z "$key" || -z "$hostname" || -z "$service" ]]; then
    printf "\nMissing required parameter.\n"
    printf "  syntax: deployFiles.sh -k <pem key file> -h <hostname> -s <service>\n\n"
    exit 1
fi

if [ "$service" = "main" ]; then
    printf "\n----> Clear out the previous distribution for main.\n"
    printf "\n----> Deploying files for main to $hostname with $key\n"
    ssh -i "$key" ubuntu@$hostname << ENDSSH 
    cd /usr/share
    rm -rf /caddy
    mkdir -p /caddy
ENDSSH

    printf "\n----> Copy the distribution package to main.\n"
    scp -r -i "$key" * ubuntu@$hostname:/usr/share/caddy
    exit 0
fi

printf "\n----> Deploying files for $service to $hostname with $key\n"

# Step 1
printf "\n----> Clear out the previous distribution on the target.\n"
ssh -i "$key" ubuntu@$hostname << ENDSSH
rm -rf services/${service}/public
mkdir -p services/${service}/public
ENDSSH

# Step 2
printf "\n----> Copy the distribution package to the target.\n"
scp -r -i "$key" * ubuntu@$hostname:services/$service/public
