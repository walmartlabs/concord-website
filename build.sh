#!/usr/bin/env bash
set -euo pipefail

ORIGINAL_DIR=$(pwd)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

return_to_original_dir() {
    cd "$ORIGINAL_DIR" || {
        echo "Warning: Could not return to original directory: $ORIGINAL_DIR" >&2
    }
}

trap return_to_original_dir EXIT

cd "$SCRIPT_DIR"

IMG="${CONCORD_WEBSITE_BUILDER_IMAGE:-concord-website-builder:latest}"
WORK_DIR="$SCRIPT_DIR/_build"
SITE_SOURCE_DIR="$WORK_DIR/site"
CLONE_DIR="$WORK_DIR/concord"
DOCS_REPO="${CONCORD_DOCS_REPO:-https://github.com/walmartlabs/concord.git}"
DOCS_REF="${CONCORD_DOCS_REF:-${GITHUB_HEAD_REF:-${GITHUB_REF_NAME:-master}}}"
DOCS_FALLBACK_REF="${CONCORD_DOCS_FALLBACK_REF:-master}"
DOCS_SRC="${CONCORD_DOCS_SRC:-}"
DOCS_DIR="${CONCORD_DOCS_DIR:-}"
DOCS_EDIT_BASE_URL="${CONCORD_DOCS_EDIT_BASE_URL:-https://github.com/walmartlabs/concord/tree/${DOCS_REF}/docs/src}"

resolve_docs_src() {
    if [[ -n "$DOCS_SRC" ]]; then
        cd "$DOCS_SRC"
        pwd
        return
    fi

    if [[ -n "$DOCS_DIR" ]]; then
        if [[ -d "$DOCS_DIR/docs/src" ]]; then
            cd "$DOCS_DIR/docs/src"
        else
            cd "$DOCS_DIR"
        fi
        pwd
        return
    fi

    rm -rf "$CLONE_DIR"

    if git clone --depth 1 --branch "$DOCS_REF" "$DOCS_REPO" "$CLONE_DIR"; then
        cd "$CLONE_DIR/docs/src"
        pwd
        return
    fi

    if [[ "$DOCS_REF" == "$DOCS_FALLBACK_REF" ]]; then
        echo "Error: could not clone $DOCS_REPO at $DOCS_REF" >&2
        exit 1
    fi

    echo "Warning: could not clone $DOCS_REPO at $DOCS_REF; falling back to $DOCS_FALLBACK_REF" >&2
    git clone --depth 1 --branch "$DOCS_FALLBACK_REF" "$DOCS_REPO" "$CLONE_DIR"
    cd "$CLONE_DIR/docs/src"
    pwd
}

copy_site_source() {
    rm -rf "$SITE_SOURCE_DIR"
    mkdir -p "$SITE_SOURCE_DIR"

    tar \
        --exclude="./.git" \
        --exclude="./_build" \
        --exclude="./_site" \
        --exclude="./_src" \
        --exclude="./docs/src" \
        --exclude="./vendor" \
        --exclude="./.bundle" \
        -cf - . | tar -xf - -C "$SITE_SOURCE_DIR"
}

DOCS_SRC="$(resolve_docs_src)"
cd "$SCRIPT_DIR"
DOCS_MOUNT_DIR="$(dirname "$DOCS_SRC")"
DOCS_CONTAINER_SRC="/build/concord-docs/$(basename "$DOCS_SRC")"

docker build -t "$IMG" .

copy_site_source

docker run --rm \
    --user "$(id -u):$(id -g)" \
    --env "CONCORD_DOCS_EDIT_BASE_URL=$DOCS_EDIT_BASE_URL" \
    --volume "$SITE_SOURCE_DIR:/build/site" \
    --volume "$DOCS_MOUNT_DIR:/build/concord-docs:ro" \
    --entrypoint ruby \
    "$IMG" \
    /build/site/tools/import-concord-docs.rb "$DOCS_CONTAINER_SRC" /build/site/docs

rm -rf "$SCRIPT_DIR/_site"
mkdir -p "$SCRIPT_DIR/_site"

docker run --rm \
    --user "$(id -u):$(id -g)" \
    --volume "$SITE_SOURCE_DIR:/build/site" \
    --volume "$SCRIPT_DIR/_site:/build/site-out" \
    --entrypoint bundle \
    "$IMG" \
    exec jekyll build --source /build/site --destination /build/site-out
