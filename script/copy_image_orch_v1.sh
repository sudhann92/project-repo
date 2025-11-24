#!/bin/bash
set -euo pipefail

# ==========================================
# CONFIGURATION
# ==========================================
DIR_PATH="/var/vnf_img"
POD_DIR="/mnt/eso-core/vnf_images"
NAMESPACE="orchestratorns"
POD_FILTER="orch-core-orchestrator-core" 
LOG_FILE="/var/log/orch_image_copy.log"

# ==========================================
# COLOR CODES
# ==========================================
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
CYAN="\e[36m"
NC="\e[0m"

# ==========================================
# LOGGING FUNCTION
# ==========================================
log() {
    echo -e "$(date '+%F %T') | $*" | tee -a "$LOG_FILE"
}

# ==========================================
# Get orchestrator pod name
# ==========================================
get_pod() {
    pod=$(kubectl get pods -A |awk '{if(NR>1)print}'| grep -i "running"| grep "$POD_FILTER" | awk '{print $2}'|awk '{if(NR==1) print}')
#pod=$(kubectl get pods -n "$NAMESPACE" --field-selector=status.phase=Running | awk '/'"$POD_FILTER"'/ {print $1; exit}')
    if [[ -z "$pod" ]]; then
        log "${RED}ERROR: No running pod found using filter '$POD_FILTER'${NC}"
        exit 1
    fi

    log "${GREEN}Using pod: $pod${NC}"
}

# ==========================================
# Ask user for image list
# ==========================================
get_images() {
    read -p "Enter image names (comma-separated): " Image_input
    IFS=',' read -ra Image_ARRAY <<< "$Image_input"

    for img in "${Image_ARRAY[@]}"; do
        img_trimmed=$(echo "$img" | xargs)
        if [[ ! -f "$DIR_PATH/$img_trimmed" ]]; then
            log "${RED}Image '$img_trimmed' not found in $DIR_PATH${NC}"
            exit 1
        fi
    done
}

# ==========================================
# Get tenant name & resolve actual directory
# ==========================================
get_tenant_folder() {
    read -p "Enter exact tenant name (as per DNS which you created in Tenant page) Ex:henkel.singtel.com : " Tenant_name

    # Fuzzy match inside POD_DIR
    tenant_folder=$(kubectl exec -n "$NAMESPACE" "$pod" -c orchestrator-core  -- sh -c "ls -1 $POD_DIR | grep -ix \"${Tenant_name}\"" 2>&1)

    if [[ -z "$tenant_folder" ]]; then
        log "${RED}ERROR: Tenant folder not found. Manual check:${NC}"
        log "kubectl exec -n $NAMESPACE $pod -c orchestrator-core -- ls -1 $POD_DIR"
        exit 1
    fi

    if [[ ! -d "$POD_DIR/$tenant_folder" ]]; then
        log "${RED}ERROR: $tenant_folder This not a folder not found. Manual check:${NC}"
        exit 1
    fi

    log "${GREEN}Tenant folder resolved: $tenant_folder${NC}"
}

# ==========================================
# Check pod disk space
# ==========================================
check_disk_space() {
    mount_info=$(kubectl exec -n "$NAMESPACE" "$pod" -c orchestrator-core -- sh -c "df -k | grep -i vnf_images")

    available_kb=$(echo "$mount_info" | awk '{print $4}')
    available_mb=$(( available_kb / 1024 ))

    if (( available_mb < 2000 )); then
        log "${RED}ERROR: Less than 2GB free in pod${NC}"
        exit 1
    fi

    log "${CYAN}Disk OK: ${available_mb}MB available${NC}"
}

# ==========================================
# Copy image helper
# ==========================================
copy_image_to_path() {
    local image=$1
    local dst_path=$2

    log "${YELLOW}Copying $image → $dst_path${NC}"

    kubectl cp "$DIR_PATH/$image" "$NAMESPACE/$pod:$dst_path/" -c orchestrator-core

    kubectl exec -n "$NAMESPACE" "$pod" -c orchestrator-core -- sh -c "chmod 666 \"$dst_path/$image\""

    log "${GREEN}Copied & permission set: $dst_path/$image${NC}"
    kubectl exec -n "$NAMESPACE" "$pod" -c orchestrator-core -- sh -c "ls -ll \"$dst_path/$image\""
}

#================================
#Delete the Images inside in local directory
#=================================
delete_local_images() {

    echo -e "\nDo you want to delete the images from local folder ($DIR_PATH)?"
    read -p "Type yes or no: " answer

    case "$answer" in
        yes|YES|y|Y)
            for img in "${Image_ARRAY[@]}"; do
                img_trimmed=$(echo "$img" | xargs)

                if [[ -f "$DIR_PATH/$img_trimmed" ]]; then
                    rm -f "$DIR_PATH/$img_trimmed"
                    log "${GREEN}Deleted local image: $DIR_PATH/$img_trimmed${NC}"
                else
                    log "${YELLOW}Local image already removed or missing: $img_trimmed${NC}"
                fi
            done
            ;;
        no|NO|n|N)
            log "${YELLOW}Local images NOT deleted as per user choice.${NC}"
            ;;
        *)
            log "${YELLOW}Invalid choice. Skipping delete action.${NC}"
            ;;
    esac
}

# ==========================================
# 1) GLOBAL COPY
# ==========================================
copy_global() {
    get_images
    get_pod
    check_disk_space

    for image in "${Image_ARRAY[@]}"; do
        img_trimmed=$(echo "$image" | xargs)
        copy_image_to_path "$img_trimmed" "$POD_DIR"
    done

    delete_local_images
}

# ==========================================
# 2) TENANT COPY
# ==========================================
copy_tenant() {
    get_images
    get_pod
    get_tenant_folder
    check_disk_space

    tenant_path="$POD_DIR/$tenant_folder"

    for image in "${Image_ARRAY[@]}"; do
        img_trimmed=$(echo "$image" | xargs)
        copy_image_to_path "$img_trimmed" "$tenant_path"
    done

    delete_local_images
}

# ==========================================
# 3) BOTH COPY
# ==========================================
copy_both() {
    get_images
    get_pod
    get_tenant_folder
    check_disk_space

    tenant_path="$POD_DIR/$tenant_folder"

    for image in "${Image_ARRAY[@]}"; do
        img_trimmed=$(echo "$image" | xargs)
        copy_image_to_path "$img_trimmed" "$POD_DIR"
        copy_image_to_path "$img_trimmed" "$tenant_path"
    done

    delete_local_images
}





# ==========================================
# MENU
# ==========================================
echo -e "${CYAN}Select an option:${NC}"
echo "1) Copy to Global Path (/mnt/eso-core/vnf_images)"
echo "2) Copy to Tenant Path (/mnt/eso-core/vnf_images/<tenant_name>)"
echo "3) Copy to Both"
read -p "Enter choice: " choice

case "$choice" in
    1) copy_global ;;
    2) copy_tenant ;;
    3) copy_both ;;
    *) echo -e "${RED}Invalid option${NC}" ; exit 1 ;;
esac
