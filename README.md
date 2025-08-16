# USB ISO mounting helper for GL-RM1

This script (`usbm.sh`) helps you mount a USB storage device on a GL.iNet GL-RM1 KVM and bind-mount any `.iso` files so they appear under `/userdata/media` for use in the KVM UI. The GL-RM1 has only ~5GB of eMMC, so this lets you keep large ISOs on external storage.

## What it does

- Mounts the USB partition you choose at `/mnt/usb`.
- Allows you to bind-mounts each `.iso` to `/userdata/media/<filename>.iso`, this will allow the Web UI and (I assume) the desktop apps to see them.
- And of course a cleanup feature to clear any externally mounted ISOs

Mount points used:

- USB mount: `/mnt/usb` (created automatically if missing)
- UI-visible media: `/userdata/media` (must exist before use)

## Installation

1. Download the script:

```
wget -O usbm.sh <RAW_URL_TO_usb/usbm.sh>
```

2. Move it to `/usr/bin/usbm`

```
mv usbm.sh /usr/bin/usbm
```

3. Make it executable

```
chmod +x /usr/bin/usbm
```

4. Run with `usbm`

## Usage

1. Plug in your USB drive.
2. Run the script:

```
usbm
```

Notes:

- The script creates placeholder files under `/userdata/media` otherwise we cannot create bind mounts. These files will be automatically deleted after unmounting using the script.
- The script never formats or writes to your USB; it only mounts/binds.

## Uninstall

- Optionally unbind and unmount first by running the script.
- Remove the script:
  - `rm /usr/bin/usbm`

## FAQ

1. The script outputs gibberish after installation:

- It is possible line endings screw up when you download the usbm.sh, in case it shows gibberish you can run this to fix it:

```
sed -i 's/\r//g' usbm.sh
```
