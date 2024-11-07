#!/bin/bash

# Write the value "none" to the file /usr/iotc/local.backup/data/running_model
echo "none" > /usr/iotc/local/data/running-model
#pkill -f stai_mpu_S3_image_classification.py

echo "Starting stop_image_classification.sh script" >> /var/log/iotconnect.log
echo "Current user: $(whoami)" >> /var/log/iotconnect.log
echo "Running model set to none" >> /var/log/iotconnect.log
echo "none" > /usr/iotc/local/data/running-model

echo "Attempting to kill processes" >> /var/log/iotconnect.log
/bin/ps aux | /bin/grep 'python3 /usr/local/x-linux-ai/image-classification/stai_mpu_S3_image_classification.py' | /bin/grep -v 'grep' | /usr/bin/awk '{print $2}' | /usr/bin/xargs sudo /bin/kill -9 >> /var/log/iotconnect.log 2>&1


if [ $? -eq 0 ]; then
    echo "Successfully killed stai_mpu_image_classification.py processes." >> /var/log/iotconnect.log
else
    echo "Failed to kill the processes or no processes found." >> /var/log/iotconnect.log
fi
