#!/usr/bin/env bash
set -e

# 1. YOUR EXPLICIT HARD DRIVE MAPPING
HDD_UUID="D28C7BCF8C7BAC9B"
HDD_MOUNT="/mnt/games_hdd"

SSD_UUID="0AC04E3FC04E316D"
SSD_MOUNT="/mnt/games_ssd"

# Get current user and group IDs for permissions
USER_ID=$(id -u)
GROUP_ID=$(id -g)

# Function to safely check and mount a specific drive using native ntfs3
mount_game_drive() {
  local UUID="$1"
  local MOUNT_POINT="$2"
  local DRIVE_TYPE="$3"

  # Safely find the current /dev/ path dynamically based on UUID
  local DEV_PATH
  DEV_PATH=$(blkid -U "$UUID" || true)

  if [ -z "$DEV_PATH" ]; then
    echo "ℹ️ $DRIVE_TYPE (UUID: $UUID) is not plugged in. Skipping."
    return 0
  fi

  echo "Found $DRIVE_TYPE at: $DEV_PATH"
  echo "Target Mount Point: $MOUNT_POINT"

  # Ensure the explicit mount directory exists
  if [ ! -d "$MOUNT_POINT" ]; then
    sudo mkdir -p "$MOUNT_POINT"
  fi

  # Unmount if it was auto-mounted poorly by the desktop environment
  if mountpoint -q "$MOUNT_POINT"; then
    echo "Drive was already mounted. Resetting safely..."
    sudo umount "$MOUNT_POINT"
  fi

  # 2. MOUNT WITH NATIVE KERNEL DRIVER (ntfs3)
  # prealloc: optimizes allocation for large game files
  # uid/gid/umask/fmask: sets permissions so Steam Proton can run binaries smoothly
  echo "🚀 Mounting via native kernel engine to $MOUNT_POINT..."
  sudo mount -t ntfs3 \
    -o force,uid="$USER_ID",gid="$GROUP_ID",nofail,prealloc,umask=000,fmask=111 \
    "$DEV_PATH" "$MOUNT_POINT"

  echo "✅ Successfully mounted $DRIVE_TYPE!"
  echo "--------------------------------------------------------"
}

echo "Starting explicit game drive mount sequence..."
echo "--------------------------------------------------------"

# Run the mount function for your HDD
mount_game_drive "$HDD_UUID" "$HDD_MOUNT" "Games HDD"

# Run the mount function for your SSD
mount_game_drive "$SSD_UUID" "$SSD_MOUNT" "Games SSD"

echo "🎉 All connected game drives are ready for Steam!"
