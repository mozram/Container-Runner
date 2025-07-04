#! /usr/bin/bash

## Macro for stdout color
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
LCYAN='\033[1;36m'
BRED='\033[1;91m'
NC='\033[0m' # No Color

## Mount home. Map 1-1 so the log directly reflect the path
MOUNT_HOME="--mount type=bind,source=${HOME},target=${HOME}"
## Mount .ssh as container typically run as root
MOUNT_SSH="--mount type=bind,source=${HOME}/.ssh,target=/root/.ssh"
## Mount GPG keyring, if any
MOUNT_GPG=""
if [ -d "${HOME}/.gnupg" ] 
then
    MOUNT_GPG="--mount type=bind,source=${HOME}/.gnupg,target=/root/.gnupg"
fi
## Mount SSH Sock Agent
MOUNT_SSH_SOCK=""
readlink -f $SSH_AUTH_SOCK
if [ $? -eq 0 ]
then
    MOUNT_SSH_SOCK="-v $(readlink -f $SSH_AUTH_SOCK):/ssh-agent -e SSH_AUTH_SOCK=/ssh-agent"
fi

## Mount current directory with same path as host
CURRENT_DIR=$(pwd)
MOUNT_CURRENT_DIR="--mount type=bind,source=${CURRENT_DIR},target=${CURRENT_DIR}"

## Variable to store images name
IMAGES_LIST=()
TAG_LIST=()

echo "Select which image to run with (enter number):"

## Get the list of images
IMAGES_RAW=$((docker images) 2>&1 )

## Split each line into single
readarray -t <<<$IMAGES_RAW

for (( i=1; i<${#MAPFILE[@]}; i++ ))
do
    # echo "$i: ${MAPFILE[$i]}"
    TEMP=$(echo "${MAPFILE[$i]}" | tr -s " " | cut -d' ' -f1)
    TEMP2=$(echo "${MAPFILE[$i]}" | tr -s " " | cut -d' ' -f2)
    IMAGES_LIST+=("${TEMP}")
    TAG_LIST+=("${TEMP2}")
    ## Print selection to user
    echo -e "$i: ${LCYAN}${TEMP}${NC}:${BRED}${TEMP2}${NC}"
done

read SELECTED_IMAGE

((SELECTED_IMAGE=SELECTED_IMAGE-1))
# echo $SELECTED_IMAGE

# echo ${IMAGES_LIST[$SELECTED_IMAGE]}
# echo ${TAG_LIST[$SELECTED_IMAGE]}

## Get args
ARGS="PYTHONUNBUFFERED=1 $@"

CMD="docker run --rm --device /dev/bus/usb --workdir=${CURRENT_DIR} -e PYTHONUNBUFFERED=1 ${MOUNT_SSH_SOCK} ${MOUNT_GPG} ${MOUNT_HOME} ${MOUNT_SSH} ${MOUNT_CURRENT_DIR} ${IMAGES_LIST[$SELECTED_IMAGE]}:${TAG_LIST[$SELECTED_IMAGE]} \"${@}\""

echo "Running ${CMD}"

# eval $CMD

docker run \
--rm \
--device /dev/bus/usb \
--workdir=${CURRENT_DIR} \
-e PYTHONUNBUFFERED=1 \
${MOUNT_SSH_SOCK} \
${MOUNT_GPG} \
${MOUNT_HOME} \
${MOUNT_CURRENT_DIR} \
${MOUNT_SSH} \
${IMAGES_LIST[$SELECTED_IMAGE]}:${TAG_LIST[$SELECTED_IMAGE]} \
"${@}"