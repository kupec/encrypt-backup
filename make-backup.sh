#!/bin/bash

RETURN_DIR=$(pwd)

cd $1
BACKUP_DIR=$(pwd)
cd $RETURN_DIR

cd $2
BACKUP_BUILD=$(pwd)
cd $RETURN_DIR

DATE=$(date +"%Y-%m-%d")

if [ -z "$NOZIP" ]; then
    ZIP=z
    ZIP_SIFFIX=.gz
fi;

if [ -z "$STORE_BACKUP_COUNT" ]; then
    STORE_BACKUP_COUNT=1
fi;

FOLDER_NAME=$(basename $BACKUP_DIR)
ARCHIVE_EXTENSION=.tar${ZIP_SIFFIX}.gpg


function goToScriptFolder {
    cd $(dirname $0)
}

function removeOldBackups {
    mkdir -p $BACKUP_BUILD

    echo "Removing old backups"
    find $BACKUP_BUILD -name "$FOLDER_NAME*" | sort -rn | tail -n +$STORE_BACKUP_COUNT | xargs -i rm -f {}
}

function findArchiveSuffix {
    LAST_BACKUP=$(find $BACKUP_BUILD -name "$FOLDER_NAME*" | sort -rn | head -n 1)
    ARCHIVE_SUFFIX=$(echo $(basename "$LAST_BACKUP" $ARCHIVE_EXTENSION) | tr - "\n" | tail -n 1)

    if [ -z "$ARCHIVE_SUFFIX" ]; then
        ARCHIVE_SUFFIX=1
    else
        ARCHIVE_SUFFIX=$(echo "$ARCHIVE_SUFFIX + 1" | bc)
    fi;

    ARCHIVE_SUFFIX=$(printf %03d $ARCHIVE_SUFFIX)

    echo Determine archive suffix as $ARCHIVE_SUFFIX
}

function compressAndEncryptFolder {
    PIPE=/tmp/backup-pipe-$RANDOM
    ARCHIVE_NAME=$FOLDER_NAME-${DATE}-${ARCHIVE_SUFFIX}${ARCHIVE_EXTENSION}

    echo "Creating named pipe"
    mkfifo $PIPE

    echo "Running compress task"
    cd $(dirname $BACKUP_DIR)
    tar c${ZIP}f - $FOLDER_NAME > $PIPE &

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
. ./config.inc

removeOldBackups;
findArchiveSuffix;
compressAndEncryptFolder;

restoreCurrentFolder;
