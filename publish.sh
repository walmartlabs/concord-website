#!/bin/bash

# Setup environment
. ${HOME}/.bashrc
export PATH=/mnt/jenkinspan/bin/:$PATH
echo "Path:"
echo $PATH

# Delete the Site build dir
rm -rf _site || true

# Install Gems from Gemfile (Jekyll)
gem sources --remove "http://rubygems.org"
gem sources --remove "https://rubygems.org"
gem sources --add "https://nexus.prod.walmart.com/nexus/content/repositories/rubygems/"
bundle clean --force || true
bundle install

# Build the Site - Zip it Up
bundle exec jekyll build
cd _site
zip -or site.zip *
cd ..

# Publish a WAR File to Nexus
mvn -e -V -B -fae deploy:deploy-file -DpomFile=pom.xml \
	-Dfile=_site/site.zip \
	-Durl="http://gec-maven-nexus.walmart.com/nexus/content/repositories/labs_snapshots" \
	-DrepositoryId="labs_snapshots"
