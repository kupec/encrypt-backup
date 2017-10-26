#!/bin/bash

. ./config.inc

DATE=$(date +"%Y-%m-%d")

function goToScriptFolder {
    set RETURN_DIR=$(pwd)
    cd $(dirname $0)
}

function compressAndEncryptFolder {
    rm -rf $BACKUP_BUILD
    mkdir -p $BACKUP_BUILD

    cd $(dirname $BACKUP_DIR)
    FOLDER_NAME=$(basename $BACKUP_DIR)
    PIPE=$BACKUP_BUILD/pipe
    ARCHIVE_NAME=$FOLDER_NAME-${DATE}.tgz.gpg

    echo "Creating named pipe"
    mkfifo $PIPE

    echo "Running compress task"
    tar czf - $FOLDER_NAME > $PIPE &

    cd $BACKUP_BUILD

    echo "Running encrypt task"
    echo $PASSPHRASE | gpg --batch --quiet --yes --passphrase-fd 0 --output $ARCHIVE_NAME --symmetric $PIPE

    echo "Tear down"
    rm $PIPE
}

function restoreCurrentFolder {
    cd $RETURN_DIR
}


##### MAIN ########

goToScriptFolder;

compressAndEncryptFolder;

restoreCurrentFolder;