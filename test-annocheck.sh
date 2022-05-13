#!/bin/sh -eu
# Run the `tool/test-annocheck.sh [binary files]` to check security issues.
# E.g. `tool/test-annocheck.sh ruby libruby.so.3.2.0`.
#
# Use annocheck.
# https://sourceware.org/annobin/

set -x

DOCKER="$(command -v docker || command -v podman)"
VOLUME_OPTS=""
TAG=ruby-fedora-annocheck
TOOL_DIR=$(dirname "${0}")
# Set volume option if it is executed on local (non-CI) enviornment.
# In CI such as GitHub Actions, I couldn't find way to use the volume option.
if [ -z "${CI-}" ]; then
  VOLUME_OPTS="-v $(pwd):/work"
  COPY=false
  "${DOCKER}" build --rm -t "${TAG}" ${TOOL_DIR}
else
  COPY=true
  TAG="${TAG}-copy"
  "${DOCKER}" build --rm -t "${TAG}" --build-arg=FILES="${*}" -f ${TOOL_DIR}/Dockerfile-copy ${TOOL_DIR}
fi

"${DOCKER}" run --rm -t ${VOLUME_OPTS} "${TAG}" annocheck --verbose "${@}"
