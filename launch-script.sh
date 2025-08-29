#!/usr/bin/env sh

bundle exec jekyll clean
bundle exec jekyll serve --source /build/repo --host 0.0.0.0 --incremental "$@"
