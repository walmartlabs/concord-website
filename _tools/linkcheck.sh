#!/bin/bash

echo "Running linkchecker on http://localhost:4000"
linkchecker --anchors http://localhost:4000 > linkcheck-results.log
cat linkcheck-results.log
echo "Completed. Results also stored in linkcheck-results.log"