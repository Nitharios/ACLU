#!/bin/bash
set -x # echo bash commands before execution, useful for debugging
set -e # stop bash execution on on first error

# /etc/profile
# export ECR_REGION=$ECR_REGION
# export IMAGES_REPO_URL=$IMAGES_REPO_URL

# Upgrade aws cli to support --no-include-email for docker login (email was deprecated from docker)
pip install --upgrade awscli
#$(aws ecr get-login --region $ECR_REGION --no-include-email)
$(aws ecr get-login --region us-west-2 --no-include-email) # Ended up harcoding REGION here...if it ever changes we need to update the script

# Docker compose
cd /var/project-aclu/
# TODO this should probably go in APPLICATION_STOP step
docker-compose down
# force docker to fetch latest aclu image
docker-compose pull
docker-compose up -d

# Create the spatial index TODO - Not sure if it is ok to run this on every deploy...is it idempotent? TODO2 - What about import scripts?
docker exec $(docker ps -aqf "name=aclu-db") mongo aclu --eval "db.features.ensureIndex({'geojson.geometry': '2dsphere'})"
