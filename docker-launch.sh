#!/usr/bin/env sh
IMG=<WALMART_DOCKER_REGISTRY_URL>/walmartlabs-strati-sde/websites-container:1.0.0
docker run --rm --volume "$PWD:/build/repo" -p 4000:4000 $IMG
