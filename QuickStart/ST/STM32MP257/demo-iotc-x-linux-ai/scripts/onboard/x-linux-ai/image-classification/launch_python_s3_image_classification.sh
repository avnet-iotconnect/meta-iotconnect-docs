#!/bin/sh
#
# Copyright (c) 2024 STMicroelectronics.
# All rights reserved.
#
# This software is licensed under terms that can be found in the LICENSE file
# in the root directory of this software component.
# If no LICENSE file comes with this software, it is provided AS-IS.
set -x
weston_user=$(ps aux | grep '/usr/bin/weston '|grep -v 'grep'|awk '{print $1}')
FRAMEWORK=$1
echo "stai wrapper used : "$FRAMEWORK
source /usr/local/x-linux-ai/resources/config_board.sh

# Ensure the variables are populated correctly
if [ -z "$IMAGE_CLASSIFICATION_MODEL" ] || [ -z "$IMAGE_CLASSIFICATION_LABEL" ]; then
    echo "Error: Model or label path not defined."
    exit 1
fi

# Build the complete command with the correct paths
cmd="python3 /usr/local/x-linux-ai/image-classification/stai_mpu_S3_image_classification.py -m /usr/local/x-linux-ai/image-classification/models/$IMAGE_CLASSIFICATION_MODEL -l /usr/local/x-linux-ai/image-classification/models/$IMAGE_CLASSIFICATION_LABEL --framerate 30 --frame_width $DWIDTH --frame_height $DHEIGHT $OPTIONS"

if [ "$weston_user" != "root" ]; then
    echo "user : "$weston_user
    script -qc "su -l $weston_user -c '$cmd'"
else
    $cmd
fi
