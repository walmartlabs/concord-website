#!/bin/bash

DATE=`date +%Y-%m-%d`
RELEASEMESSAGE="WMT Release $DATE"

rm -f wmt-release-*
echo $RELEASEMESSAGE > wmt-release-id.txt
zip -r wmt-release-$DATE.zip _includes/wmt _layouts/wmt assets/wmt wmt-release-id.txt

echo "$RELEASEMESSAGE created."
