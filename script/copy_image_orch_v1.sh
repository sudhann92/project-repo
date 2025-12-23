#!/bin/bash
#Used for POPS Team
set -euo pipefail

# CONFIGURATION

DIR_PATH="/var/vnf_img"
POD_DIR="/mnt/eso-core/vnf_images"
NAMESPACE="orchestratorns"
POD_FILTER="orch-core-orchestrator-core" 
LOG_FILE="/tmp/orch_image_copy.log"

# Constants
readonly MIN_FREE_MB=500
readonly FILE_PERMISSIONS="666"
readonly CONTAINER_NAME="orchestrator-core"


# COLOR CODES

readonly GREEN="\e[32m"
readonly RED="\e[31m"
readonly YELLOW="\e[33m"
readonly CYAN="\e[36m"
readonly NC="\e[0m"


# LOGGING FUNCTION

log() {
    echo -e "$(date '+%F %T') | $*" | tee -a "$LOG_FILE"
}

log_error() {
    log "${RED}ERROR: $*${NC}"
}

log_success() {
    log "${GREEN}SUCCESS: $*${NC}"
}

log_info() {
    log "${CYAN}INFO: $*${NC}"
}


log_input() {
	log "${YELLOW}OPTIONS: $*${NC}"
}

# Get orchestrator pod name

get_pod() {

    log_info "Searching for running pod with filter: $POD_FILTER"

    pod=$(kubectl get pods -A |awk '{if(NR>1)print}'| grep -i "running"| grep "$POD_FILTER" | awk '{print $2}'|awk '{if(NR==1) print}')
#pod=$(kubectl get pods -n "$NAMESPACE" --field-selector=status.phase=Running | awk '/'"$POD_FILTER"'/ {print $1; exit}')
    if [[ -z "$pod" ]]; then
        log_error "No running pod found with filter '$POD_FILTER'"
        log_info "Available pods:"
        kubectl get pods -n "$NAMESPACE"
        exit 1
    fi

    log_success "Using pod: $pod"
}


# Ask user for image list

get_images() {
    read -rp "Enter image names (comma-separated): " Image_input
    
    if [[ -z "${Image_input// /}" ]]; then
        log_error "No image names provided. Input cannot be empty"
        exit 1
    fi
    IFS=',' read -ra Image_ARRAY <<< "$Image_input"

    log_info "Validating ${#Image_ARRAY[@]} image(s)..."
    
    if [[ ${#Image_ARRAY[@]} -eq 0 ]]; then
        log_error "No valid image names found after validation"
        exit 1
    fi

    for img in "${Image_ARRAY[@]}"; do
        img_trimmed=$(echo "$img" | xargs)
        
        if [[ ! -f "$DIR_PATH/$img_trimmed" ]]; then
            log_error "Image '$img_trimmed' not found in $DIR_PATH"
            exit 1
        fi
    done
    
    log_success "All images validated"
}



# Calculate total size of images

calculate_total_size() {
    local total_kb=0
    
    for img in "${Image_ARRAY[@]}"; do
        img_trimmed=$(echo "$img" | xargs)
        size_kb=$(du -k "$DIR_PATH/$img_trimmed" 2>/dev/null | awk '{print $1}')
        if [[ -z "$size_kb" ]]; then
            log_error "Failed to get size for $img_trimmed"
            exit 1
        fi
        
        total_kb=$((total_kb + size_kb))
    done
    
    echo $((total_kb / 1024)) # Return MB
}


list_tenant_folders() {
    log_info "Fetching available tenant folders..."
    
    # Get list of tenant directories
    local tenant_list=$(kubectl exec -n "$NAMESPACE" "$pod" -c "$CONTAINER_NAME" -- sh -c "ls -d1 $POD_DIR/*/ 2>/dev/null | xargs -n 1 basename" 2>&1)
    
    if [[ -z "$tenant_list" ]]; then
        log_error "No tenant folders found in $POD_DIR"
        exit 1
    fi
    
    log_input "BELOW ARE THE TENANT FOLDER AVAILABLE IN THE POD CHOOSE PROPER ONE FOR COPY THE IMAGE: \n$tenant_list"
}


# Get tenant name & resolve actual directory

get_tenant_folder() {
    echo ""
    read -rp "Enter exact tenant name from Above List (as per DNS which you created in Tenant page) Ex: henkel.singtel.com : " Tenant_name

    log_info "Searching for tenant folder: $Tenant_name"
    
    tenant_folder=$(kubectl exec -n "$NAMESPACE" "$pod" -c "$CONTAINER_NAME" -- sh -c "ls -1 $POD_DIR 2>/dev/null | grep -ix \"${Tenant_name}\" | head -n1" 2>&1)

    if [[ -z "$tenant_folder" ]]; then
        log_error "Tenant folder not found. Available tenants:"
        kubectl exec -n "$NAMESPACE" "$pod" -c "$CONTAINER_NAME" -- sh -c "ls -d1 $POD_DIR/*/ 2>/dev/null | xargs -n 1 basename" 2>&1
        exit 1
    fi

    if ! kubectl exec -n "$NAMESPACE" "$pod" -c "$CONTAINER_NAME" -- sh -c "test -d '$POD_DIR/$tenant_folder'"; then
        log_error "'$tenant_folder' exists but is not a directory"
        exit 1
    fi

    log_success "Tenant folder resolved: $tenant_folder"
}


# Check pod disk space

check_disk_space() {
    log_info "Checking available disk space..."
    
    mount_info=$(kubectl exec -n "$NAMESPACE" "$pod" -c "$CONTAINER_NAME" -- sh -c "df -k | grep -i vnf_images")

    available_kb=$(echo "$mount_info" | awk '{print $4}')
    available_mb=$(( available_kb / 1024 ))
    
    # Calculate required space
    total_size_mb=$(calculate_total_size)
    required_mb=$((total_size_mb + MIN_FREE_MB))

    log_info "Available: ${available_mb}MB | Required: ${required_mb}MB (${total_size_mb}MB files + ${MIN_FREE_MB}MB buffer)"

    if (( available_mb < required_mb )); then
        log_error "Insufficient space: need ${required_mb}MB but only ${available_mb}MB available"
        exit 1
    fi

    log_success "Disk space check passed"
}


# Copy image helper with verification

copy_image_to_path() {
    local image=$1
    local dst_path=$2
    local start_time=$(date +%s)

    log_info "Copying $image →  $dst_path"

    # Perform copy with error handling
    if ! kubectl cp "$DIR_PATH/$image" "$NAMESPACE/$pod:$dst_path/" -c "$CONTAINER_NAME"; then
        log_error "Copy failed for $image"
        exit 1
    fi

    # Verify file exists in destination
    if ! kubectl exec -n "$NAMESPACE" "$pod" -c "$CONTAINER_NAME" -- sh -c "test -f '$dst_path/$image'"; then
        log_error "Copy verification failed: $dst_path/$image not found"
        exit 1
    fi

    # Set permissions (read-write for owner, read-only for others)
    if ! kubectl exec -n "$NAMESPACE" "$pod" -c "$CONTAINER_NAME" -- sh -c "chmod $FILE_PERMISSIONS '$dst_path/$image'"; then
        log_error "Failed to set permissions for $dst_path/$image"
        exit 1
    fi

    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    log_success "Copied $image in ${duration}s"
    kubectl exec -n "$NAMESPACE" "$pod" -c "$CONTAINER_NAME" -- sh -c "ls -lh '$dst_path/$image'"
}


# Delete images from local directory

delete_local_images() {
    echo -e "\n${YELLOW}Do you want to delete the images from local folder ($DIR_PATH)?${NC}"
    read -rp "Type yes or no: " answer

    case "$answer" in
        yes|YES|y|Y)
            for img in "${Image_ARRAY[@]}"; do
                img_trimmed=$(echo "$img" | xargs)

                if [[ -f "$DIR_PATH/$img_trimmed" ]]; then
                    if rm -f "$DIR_PATH/$img_trimmed"; then
                        log_success "Deleted local image: $DIR_PATH/$img_trimmed"
                    else
                        log_error "Failed to delete: $DIR_PATH/$img_trimmed"
                    fi
                else
                    log_info "Local image already removed: $img_trimmed"
                fi
            done
            ;;
        no|NO|n|N)
            log_info "Local images NOT deleted as per user choice"
            ;;
        *)
            log_info "Invalid choice. Skipping delete action"
            ;;
    esac
}

# ==========================================
# 1) GLOBAL COPY
# ==========================================
copy_global() {
    log_info "=== GLOBAL COPY MODE ==="
    get_images
    get_pod
    check_disk_space

    for image in "${Image_ARRAY[@]}"; do
        img_trimmed=$(echo "$image" | xargs)
	copy_image_to_path "$img_trimmed" "$POD_DIR"
    done

    delete_local_images
    log_success "Global copy completed"
}

#copy_image_to_path "$img_trimmed" "$POD_DIR"
# ==========================================
# 2) TENANT COPY
# ==========================================
copy_tenant() {
    log_info "=== TENANT COPY MODE ==="
    get_images
    get_pod
    list_tenant_folders
    get_tenant_folder
    check_disk_space

    tenant_path="$POD_DIR/$tenant_folder"

    for image in "${Image_ARRAY[@]}"; do
        img_trimmed=$(echo "$image" | xargs)
        copy_image_to_path "$img_trimmed" "$tenant_path"
    done

    delete_local_images
    log_success "Tenant copy completed"
}

# ==========================================
# 3) BOTH COPY
# ==========================================
copy_both() {
    log_info "=== BOTH (GLOBAL + TENANT) COPY MODE ==="
    get_images
    get_pod
    list_tenant_folders
    get_tenant_folder
    check_disk_space

    tenant_path="$POD_DIR/$tenant_folder"

    # Verify both paths exist before copying
    if ! kubectl exec -n "$NAMESPACE" "$pod" -c "$CONTAINER_NAME" -- sh -c "test -d '$POD_DIR' && test -d '$tenant_path'"; then
        log_error "One or both destination paths don't exist"
        exit 1
    fi

    for image in "${Image_ARRAY[@]}"; do
        img_trimmed=$(echo "$image" | xargs)
        copy_image_to_path "$img_trimmed" "$POD_DIR"
        copy_image_to_path "$img_trimmed" "$tenant_path"
    done

    delete_local_images
    log_success "Both copy completed"
}


# MAIN MENU

main() {
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║  VNF Images Copy Utility Make sure Images in ($DIR_PATH)   ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "Select an option:"
    echo "  1) Copy to Global Path ($POD_DIR)"
    echo "  2) Copy to Tenant Path ($POD_DIR/<tenant_name>)"
    echo "  3) Copy to Both (Global + Tenant)"
    echo ""
    read -rp "Enter choice [1-3]: " choice

    case "$choice" in
        1) copy_global ;;
        2) copy_tenant ;;
        3) copy_both ;;
        *) 
            log_error "Invalid option: $choice"
            exit 1 
            ;;
    esac
}


# ENTRY POINT

main
