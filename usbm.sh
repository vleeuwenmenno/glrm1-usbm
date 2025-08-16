#!/bin/sh

MEDIA_DIR="/userdata/media"
USB_MOUNT="/mnt/usb"

echo "== Available drives =="
ls /dev/sd* 2>/dev/null

echo
echo "Currently mounted:"
mount | grep "${USB_MOUNT}"

echo
read -p "Do you want to unmount all bind mounts from ${MEDIA_DIR} and the USB? [y/N]: " UNMOUNT
if [ "$UNMOUNT" = "y" ] || [ "$UNMOUNT" = "Y" ]; then
    echo "Unmounting bind mounts in ${MEDIA_DIR}..."
    for iso in ${MEDIA_DIR}/*.iso; do
        umount "$iso" 2>/dev/null
    done
    echo "Unmounting USB..."
    umount ${USB_MOUNT} 2>/dev/null
fi

echo
ls /dev/sd*
read -p "Which /dev/sdX device do you want to mount? (e.g. sda1): " DRIVE

mkdir -p ${USB_MOUNT}
mount "/dev/${DRIVE}" "${USB_MOUNT}"

echo
echo "Files on USB:"
ls "${USB_MOUNT}"/*.iso

echo
read -p "Do you want to bind-mount all .iso files from USB to ${MEDIA_DIR}? [y/N]: " BIND
if [ "$BIND" = "y" ] || [ "$BIND" = "Y" ]; then
    for iso in "${USB_MOUNT}"/*.iso; do
        BN=$(basename "$iso")
        tgt="${MEDIA_DIR}/${BN}"
        [ -f "$tgt" ] || touch "$tgt"
        mount --bind "$iso" "$tgt"
        echo "Bind-mounted $iso -> $tgt"
    done
    echo "Done."
else
    echo "No bind operations run."
fi

echo
echo "Contents of ${MEDIA_DIR}:"
ls -l "${MEDIA_DIR}"
