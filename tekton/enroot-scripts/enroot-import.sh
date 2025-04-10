#!/usr/bin/env bash
#
# Wrapper around "enroot import" to enroot a container image.
#

shopt -s inherit_errexit
set -eu -o pipefail

source "$(dirname ${BASH_SOURCE[0]})/common.sh"
source "$(dirname ${BASH_SOURCE[0]})/enroot-common.sh"

function _enroot() {
    enroot \
        ${*}
}

#
# Prepare
#

# making sure the required workspace "imagedir" is bounded, which means its volume is currently mounted
# and ready to use
phase "Inspecting source workspace '${WORKSPACES_IMAGEDIRECTORY_PATH}' (PWD='${PWD}')"
[[ "${WORKSPACES_IMAGEDIRECTORY_BOUND}" != "true" ]] &&
    fail "Workspace 'imagedir' is not bounded"

mkdir -p ${WORKSPACES_IMAGEDIRECTORY_PATH}/tmp
export ENROOT_TEMP_PATH="${WORKSPACES_IMAGEDIRECTORY_PATH}/tmp"

# Handle optional dockerconfig secret
if [[ "${WORKSPACES_DOCKERCONFIG_BOUND}" == "true" ]]; then

    # if config.json exists at workspace root, we use that
    if test -f "${WORKSPACES_DOCKERCONFIG_PATH}/config.json"; then
        export DOCKER_CONFIG="${WORKSPACES_DOCKERCONFIG_PATH}"

        # else we look for .dockerconfigjson at the root
    elif test -f "${WORKSPACES_DOCKERCONFIG_PATH}/.dockerconfigjson"; then
        # ensure .docker exist before the copying the content
        if [ ! -d "$HOME/.docker" ]; then
           mkdir -p "$HOME/.docker"
        fi
        cp "${WORKSPACES_DOCKERCONFIG_PATH}/.dockerconfigjson" "$HOME/.docker/config.json"
        export DOCKER_CONFIG="$HOME/.docker"

        # need to error out if neither files are present
    else
        echo "neither 'config.json' nor '.dockerconfigjson' found at workspace root"
        exit 1
    fi
fi


#
# Import
#

phase "Creating '${PARAMS_IMAGE_OUTPUT}' based on '${PARAMS_IMAGE}'"
#### hay que pasar de ${REGISTRY_NAME}:${REGISTRY_PORT}/${IMAGE_NAME}:${IMAGE_TAG} a ${REGISTRY_NAME}:${REGISTRY_PORT}#${IMAGE_NAME}:${IMAGE_TAG}
URI=`echo "${PARAMS_IMAGE}" | sed -e 's/\\//#/'`

_enroot import \
    --output "${PARAMS_IMAGE_OUTPUT}" \
    "docker://${URI}" \

