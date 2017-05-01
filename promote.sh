#!/bin/sh
dir=`pwd`
name=concord.prod.walmart.com
site="$dir/_site/"
target=/home/jvanzyl/webserver-0.0.7-SNAPSHOT/server/sites/${name}
rsync -avz --delete ${site} jvanzyl@devtools.walmart.com:${target}
