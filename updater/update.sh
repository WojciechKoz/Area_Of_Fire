#!/bin/bash
# And busybox-w64 ash

win=0
if echo "$OS" | grep -q Windows; then
    win=1
fi

if [ $win == 1 ] && [ "$1" != --in-temp ]; then
    update_tools_dir="$TMP/aof-update.$RANDOM$RANDOM$RANDOM"
    mkdir -p "$update_tools_dir"
    cp -rv update/* "$update_tools_dir/"
    cmd /c start "$update_tools_dir/busybox64.exe" ash "$update_tools_dir/update.sh" --in-temp "$update_tools_dir"
    exit $?
elif [ $win == 1 ] && [ "$1" == --in-temp ]; then
    update_tools_dir="$2"
    rsync() { "$update_tools_dir/rsync.exe" "$@"; }
fi

rsync -rtv rsync://area-of-fire.baraniecki.eu/update .
