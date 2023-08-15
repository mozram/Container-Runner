#! /usr/bin/bash

## Clean version of runner. Home folder will be simulated as empty workspace

CURRENT_DIR=$(pwd)
TEMP_DIR=${HOME}/.cache/container${CURRENT_DIR}

## Create temp dir
mkdir -p ${TEMP_DIR}

## Mount home with new namespace
MOUNT_HOME="--mount type=bind,source=${TEMP_DIR},target=${HOME}"
## Mount home. Map 1-1 so the log directly reflect the path
MOUNT_WORKSPACE="--mount type=bind,source=${CURRENT_DIR},target=${CURRENT_DIR}"
## Mount .ssh as container typically run as root
MOUNT_SSH="--mount type=bind,source=${HOME}/.ssh,target=/root/.ssh"
## Mount GPG keyring
MOUNT_GPG="--mount type=bind,source=${HOME}/.gnupg,target=/root/.gnupg"
## Mount SSH Sock Agent
MOUNT_SSH_SOCK="-v $(readlink -f $SSH_AUTH_SOCK):/ssh-agent -e SSH_AUTH_SOCK=/ssh-agent"

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
    echo "$i: ${TEMP}:${TEMP2}"
done

read SELECTED_IMAGE
((SELECTED_IMAGE=SELECTED_IMAGE-1))
# echo $SELECTED_IMAGE

# echo ${IMAGES_LIST[$SELECTED_IMAGE]}
# echo ${TAG_LIST[$SELECTED_IMAGE]}

CMD="docker run --rm -it -p 9999:9999 --device /dev/bus/usb --entrypoint \"/bin/bash\" ${MOUNT_SSH_SOCK} ${MOUNT_GPG} ${MOUNT_HOME} ${MOUNT_WORKSPACE} ${MOUNT_SSH} ${IMAGES_LIST[$SELECTED_IMAGE]}:${TAG_LIST[$SELECTED_IMAGE]} -c \"cd ${CURRENT_DIR} && bash\""
echo ${CMD}

eval $CMD
