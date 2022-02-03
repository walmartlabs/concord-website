#!/bin/bash
# requires Gem: html-proofer

if ! command -v htmlproofer &> /dev/null
then
  echo "This script requires 'html-proofer' gem"
  exit 1
fi

echo "Running htmlproofer on _site"

# every page generates an "Edit this page on GitHub" link. We can safely ignore
# those and avoid rate limiting errors due to too many calls
htmlproofer \
  --url-ignore '/.*github.com.*concord-website.*/' \
  --file-ignore '/.*assets/wmt/.*html/' \
  --log-level :debug ./_site > htmlproofer-results.log
cat htmlproofer-results.log
echo "Completed. Results also stored in htmlproofer-results.log"