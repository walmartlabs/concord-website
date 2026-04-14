# Concord Website

This is the source code of the website for the workflow and integration server Concord.

The site is available at
[https://concord.walmartlabs.com](https://concord.walmartlabs.com).

## Build Using Docker

Build the site:

```shell
cd concord-website
./build.sh
```

The build imports docs from `walmartlabs/concord` before running Jekyll. By
default it uses the current GitHub ref in CI and `master` locally. To test with a
local Concord checkout, use:

```shell
CONCORD_DOCS_DIR=/path/to/concord ./build.sh
```

The static website is written to `_site`.

## Build Locally

```shell
gem install bundler -v 1.17.3
bundle install
./native-launch.sh
```

## Contribute

Feel free to submit pull requests or file issues. More info is available on https://concord.walmartlabs.com/overview/contribute.html 
