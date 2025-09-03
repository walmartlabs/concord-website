# Concord Website

This is the source code of the website for the workflow and integration server Concord.

The site is available at
[https://concord.walmartlabs.com](https://concord.walmartlabs.com).

## Build Using Docker

Build the Docker image:

```shell
cd concord-website
docker build . -t concord-website-builder:latest
```

Run the script:

```shell
./docker-launch.sh
```

The website should be available at http://localhost:4000

## Build Locally

```shell
gem install bundler -v 1.17.3
bundle install
./native-launch.sh
```

## Contribute

Feel free to submit pull requests or file issues. More info is available on https://concord.walmartlabs.com/overview/contribute.html 
