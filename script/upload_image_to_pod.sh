#!/bin/bash

set -euo pipefail
IMAGE_DIR="/home/ensemble"
DIR_PATH="/var/vnf_img"
echo " "
read -rp "Enter the One image file name at a time which available in /home/ensemble and move to /var/vnf_img/:" Image_name


if [[ ! -f "$IMAGE_DIR/$Image_name" ]]
then
        echo -e "\nError: $Image_name Image Not found in the /home/ensemble do copy inside this path then re-run again"
        exit 1
else
        echo -e "\n Moving Image to $DIR_PATH path..................."
        mv "$IMAGE_DIR"/"$Image_name" "$DIR_PATH"
fi

pod_mount_path_image="/mnt/eso-core/vnf_images/$Image_name"
single_pod_capture=$(kubectl get pods -A |awk '{if(NR>1)print}'| grep -i "running"| grep "orch-core-orchestrator-core" | awk '{print $2}'|awk '{if(NR==1) print}')

if [[ ! -z "$single_pod_capture" ]]
then
   Full_mount_path=$(kubectl exec -n orchestratorns "$single_pod_capture" -c orchestrator-core  -- sh -c 'df -k|grep -i vnf_images' 2>&1 )
   mount_status=$?
   echo -e "==================================="
   echo -e "$Full_mount_path"
   echo -e "==================================="
else
   echo -e "\nError: NO PODS RUNNING IN orchestrator NAMESPACE KINDLY CHECK MANUALLY........."
   exit 1
fi

if [[ "$mount_status" = 0 ]]
then
        echo -e "\nchecking the disk should space more than 2 GB........."
        available_space=$(echo "$Full_mount_path" | awk '{print $4}')
        thresholdvalue=$(( available_space / 1024 ))
else
        exit 1
fi

if [[ "$thresholdvalue" -lt 2000 ]]
then
        echo "Error: Pod disk space less than 2GB kindly increase the pod space and try to copy it"
        exit 1
else
        echo -e "\nPods have more than 2 GB start copying the image AVAILABLE_SIZE:$(( thresholdvalue / 1024 ))GB"

fi


if [[ ! -z "$single_pod_capture" ]]
then
    echo -e "Copying to the pod $DIR_PATH/$Image_name..................."
    kubectl cp "$DIR_PATH/$Image_name" orchestratorns/"$single_pod_capture":/mnt/eso-core/vnf_images/ -c orchestrator-core
    sleep 2
    echo -e "\n+++++++command to change permissions of files copied to Orchestrator pod & list the image++++++++++\n"
    kubectl exec -n orchestratorns $(kubectl get pods -A |awk '{print $2}'|awk '{if(NR>1)print}'| grep "orch-core-orchestrator-core-") -c orchestrator-core  -- sh -c "chmod 666  '$pod_mount_path_image' && ls -ll '$pod_mount_path_image'"
    available_file=$?
    echo -e "\n++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    

    if [[ "$available_file" = 0 ]]
    then
        echo -e "\nSuccessfully Copied to Pod Hence Removing the local image from the Launch pad server $DIR_PATH/$Image_name \n"
        rm -f "$DIR_PATH"/"$Image_name"
    else
        echo -e "Error: Seems the file not copied properly into the pod. hence file is not removing the image from $DIR_PATH"
    fi
fi
