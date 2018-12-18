#!/bin/bash
# Copyright (c) 2018, Silicon Laboratories
# See license terms contained in COPYING file

# DO NOT MOVE THIS SCRIPT OR MAKE IT EXECUTABLE
# this script is to be run by wfx_tools_install

set -ex

GITHUB_TOOLS_PATH="/home/pi/siliconlabs/wfx-linux-tools"
GITHUB_TOOLS_INTERNAL_PATH="$GITHUB_TOOLS_PATH/internal"

GIT="git -C $GITHUB_TOOLS_PATH"

if [ -z "$TOOLS_VERSION" ]; then
    echo "ERROR: version needed" >&2
    exit 1
fi

if [ $# -gt 0 ]; then
    STATUS=$($GIT status --porcelain --untracked-files=no)
    if ! [ -z "$STATUS" ]; then
	echo "ERROR: the following files where modified in the direcory $REPO_PATH"
	echo "$STATUS"
	echo "To DISCARD modifications, run \"git reset --hard\" in this directory"
	echo "To SAVE modifications, run \"git stash\" in this directory"
	exit 1
    fi

    # Fetch if version is unknown
    if ! $GIT rev-parse --verify $TOOLS_VERSION &>/dev/null; then
	$GIT fetch --all --tags --prune
    fi

    if ! $GIT checkout $TOOLS_VERSION; then
        echo "ERROR: cannot get version $TOOLS_VERSION" >&2
        echo "Possible tags:"
        $GIT tag | sed 's/^/  /'
        exit 1
    fi
fi

# Update internal tools (ignore if file does not exist)
STATUS=0
$GITHUB_TOOLS_INTERNAL_PATH/install_internal.sh || STATUS=$?
if [ $STATUS != 0 ] && [ $STATUS != 127 ]; then
    exit 1
fi

( cd "$GITHUB_TOOLS_PATH"; sudo ./install.sh )
