#! /usr/bin/bash

## Macro for stdout color
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
LCYAN='\033[1;36m'
BRED='\033[1;91m'
NC='\033[0m' # No Color

CURRENT_DIR=$(pwd)
IMAGES_LIST=()
SELECTED_IMAGE=

if [[ "${1:-}" =~ ^[0-9]+$ ]]
then
    SELECTED_IMAGE=$1
    shift
else
    echo "Select which image to run with (enter number):"
fi

readarray -t IMAGES_LIST < <(docker image ls --filter dangling=false --format '{{.Repository}}:{{.Tag}}')
if [ "${#IMAGES_LIST[@]}" -eq 0 ]
then
    echo "No tagged Docker images found." >&2
    exit 1
fi

for (( i=0; i<${#IMAGES_LIST[@]}; i++ ))
do
    echo -e "$((i + 1)): ${LCYAN}${IMAGES_LIST[$i]}${NC}"
done

if [ -z "$SELECTED_IMAGE" ]
then
    read -r SELECTED_IMAGE
fi

if ! [[ "$SELECTED_IMAGE" =~ ^[0-9]+$ ]] || (( 10#$SELECTED_IMAGE < 1 || 10#$SELECTED_IMAGE > ${#IMAGES_LIST[@]} ))
then
    echo "Invalid image selection." >&2
    exit 1
fi

IMAGE=${IMAGES_LIST[$((10#$SELECTED_IMAGE - 1))]}
DOCKER_ARGS=(run --rm --device /dev/bus/usb "--workdir=${CURRENT_DIR}" -e PYTHONUNBUFFERED=1)
DOCKER_ARGS+=(--mount "type=bind,source=${HOME},target=${HOME}")
DOCKER_ARGS+=(--mount "type=bind,source=${HOME}/.ssh,target=/root/.ssh")
DOCKER_ARGS+=(--mount "type=bind,source=${CURRENT_DIR},target=${CURRENT_DIR}")

if [ -d "${HOME}/.gnupg" ]
then
    DOCKER_ARGS+=(--mount "type=bind,source=${HOME}/.gnupg,target=/root/.gnupg")
fi

if [ -n "${SSH_AUTH_SOCK:-}" ] && SSH_AUTH_SOCK_PATH=$(readlink -f -- "$SSH_AUTH_SOCK")
then
    DOCKER_ARGS+=(-v "${SSH_AUTH_SOCK_PATH}:/ssh-agent" -e SSH_AUTH_SOCK=/ssh-agent)
fi

printf 'Running:'
printf ' %q' docker "${DOCKER_ARGS[@]}" "$IMAGE" "$@"
printf '\n'

docker "${DOCKER_ARGS[@]}" "$IMAGE" "$@"