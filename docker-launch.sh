#!/usr/bin/env sh
IMG=concord-website-builder:latest
docker run --rm --volume "$PWD:/build/repo" -p 4000:4000 $IMG
