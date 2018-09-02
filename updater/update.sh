#!/bin/bash
# And busybox-w64 ash


win=0
if echo "$OS" | grep -q Windows; then
    win=1
fi

if [ -d .git ]; then
    # don't update in a git repo
    exit 0
fi

if [ $win == 0 ]; then
    bundle=/tmp/Area_Of_Fire-updater-dependencies
    if [ "$1" != '--in-st' ]; then
        updater/exodus-bundle.sh $bundle
        $bundle/bin/st -e "$0" --in-st
    else
        if ! [ -x "$(command -v rsync)" ]; then
            rsync() { $bundle/bin/rsync "$@"; }
        fi
        rsync -rtv --info=progress2 --delete rsync://area-of-fire.baraniecki.eu/update_linux .
        rm -rv $bundle
    fi
fi

if [ $win == 1 ] && [ "$1" != --in-temp ]; then
    update_tools_dir="$TMP/aof-update.$RANDOM$RANDOM$RANDOM"
    mkdir -p "$update_tools_dir"
    cp -rv updater/* "$update_tools_dir/"
    cmd /c start "$update_tools_dir/busybox64.exe" ash "$update_tools_dir/update.sh" --in-temp "$update_tools_dir"
    exit $?
elif [ $win == 1 ] && [ "$1" == --in-temp ]; then
    update_tools_dir="$2"
    rsync() { "$update_tools_dir/rsync.exe" "$@"; }
    rsync -rtv --info=progress2 --delete rsync://area-of-fire.baraniecki.eu/update .
fi
