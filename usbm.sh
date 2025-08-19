#!/bin/sh

MEDIA_DIR="/userdata/media"
USB_MOUNT="/mnt/usb"

is_usb_mounted() {
    mount | grep "on $USB_MOUNT " > /dev/null 2>&1
}

unbind_usb_binds() {
    echo "Unbinding ISOs in $MEDIA_DIR that point to $USB_MOUNT..."
    mount | grep "on $MEDIA_DIR" | while read -r line; do
        SRC=$(echo "$line" | awk '{print $1}')
        TGT=$(echo "$line" | awk '{print $3}')
        echo "$SRC" | grep -q "^$USB_MOUNT"
        if [ $? -eq 0 ]; then
            umount "$TGT" && echo "Unbound $TGT"
            # Remove zero byte placeholder files
            size=$(wc -c <"$TGT" 2>/dev/null || echo 1)
            if [ "$size" = "0" ]; then
                rm "$TGT" && echo "Removed empty placeholder $TGT"
            fi
        fi
    done
    clean_zero_byte_files
}

unbind_all_isos() {
    echo "Unbinding all ISO files in $MEDIA_DIR..."
    find "$MEDIA_DIR" -type f -name '*.iso' | while IFS= read -r tgt; do
        umount "$tgt" 2>/dev/null && echo "Unbound $tgt"
        # Remove zero byte placeholder files
        size=$(wc -c <"$tgt" 2>/dev/null || echo 1)
        if [ "$size" = "0" ]; then
            rm "$tgt" && echo "Removed empty placeholder $tgt"
        fi
    done
    clean_zero_byte_files
}

clean_zero_byte_files() {
    echo "Cleaning zero-byte files in /userdata..."
    CLEANED=0
    find "/userdata" -type f -size 0 2>/dev/null | while IFS= read -r file; do
        rm "$file" && echo "Removed zero-byte file: $file" && CLEANED=1
    done
    [ "$CLEANED" -eq 1 ] || echo "No zero-byte files found to clean."
}

mount_usb() {
    ls /dev/sd* 2>/dev/null
    printf "Which /dev/sdX device do you want to mount (e.g. sda1): "
    read DRIVE
    mkdir -p "$USB_MOUNT"
    mount "/dev/$DRIVE" "$USB_MOUNT" && echo "Mounted /dev/$DRIVE to $USB_MOUNT"
}

unbind_usb_and_exit() {
    unbind_usb_binds
    umount "$USB_MOUNT" && echo "USB unmounted."
    clean_zero_byte_files
    printf "Continue (main menu) or exit? [c/E]: "
    read CH
    [ "$CH" = "c" ] || [ "$CH" = "C" ] || exit 0
}

bind_found_isos() {
    echo "Searching for .iso files on USB (recursively)..."
    FOUND=0
    find "$USB_MOUNT" -type f -name '*.iso' 2>/dev/null | while IFS= read -r iso; do
        FOUND=1
        BN=$(basename "$iso")
        tgt="$MEDIA_DIR/$BN"
        [ -f "$tgt" ] || touch "$tgt"
        mount --bind "$iso" "$tgt" && echo "Bind-mounted '$iso' -> '$tgt'"
    done
    [ "$FOUND" -eq 1 ] || echo "No ISOs found to bind."
}

list_media_isos() {
    echo "ISOs in $MEDIA_DIR:"
    ls -l "$MEDIA_DIR"/*.iso 2>/dev/null
}

while true; do
    echo ""
    echo "=== USB ISO Manager ==="
    if is_usb_mounted; then
        echo "USB is currently mounted at $USB_MOUNT."
        echo "1. Bind all ISOs from USB (recursively) to $MEDIA_DIR"
        echo "2. Unmount USB drive and related ISO bind mounts"
        echo "3. Unbind all ISOs from $MEDIA_DIR"
        echo "4. List ISOs currently in $MEDIA_DIR"
        echo "5. Clean zero-byte files in /userdata"
        echo "6. Exit"
        printf "Choose an option [1-6]: "
        read ACTION
        case "$ACTION" in
            1) bind_found_isos;;
            2) unbind_usb_and_exit;;
            3) unbind_all_isos;;
            4) list_media_isos;;
            5) clean_zero_byte_files;;
            6|q|Q) echo "Bye!"; exit 0;;
            *) echo "Invalid selection!";;
        esac
    else
        echo "No USB is mounted."
        echo "1. Mount USB drive"
        echo "2. List ISOs currently in $MEDIA_DIR"
        echo "3. Clean zero-byte files in /userdata"
        echo "4. Exit"
        printf "Choose an option [1-4]: "
        read ACTION
        case "$ACTION" in
            1) mount_usb;;
            2) list_media_isos;;
            3) clean_zero_byte_files;;
            4|q|Q) echo "Bye!"; exit 0;;
            *) echo "Invalid selection!";;
        esac
    fi
done
