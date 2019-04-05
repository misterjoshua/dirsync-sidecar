#!/bin/sh

set -ex

DOWNLOAD_OPTIONS="--no-progress"
UPLOAD_OPTIONS="--no-progress"

# Give the caller a chance to do their own intialization
if [ ! -z "$INITIALIZE_EXPRESSION" ]; then
    eval "$INITIALIZE_EXPRESSION"
fi

if [ "$UPLOAD_DELETE_UNKNOWN" = "yes" ]; then
    UPLOAD_OPTIONS="$UPLOAD_OPTIONS --delete"
fi

if [ "$DOWNLOAD_DELETE_UNKNOWN" = "yes" ]; then
    DOWNLOAD_OPTIONS="$DOWNLOAD_OPTIONS --delete"
fi

# Eval an expression from INITIAL_DOWNLOAD_CONDITION to determine if an initial
# download should occur.
if [ ! -z "$INITIAL_DOWNLOAD_CONDITION" ]; then
    INITIAL_DOWNLOAD=yes
    eval "$INITIAL_DOWNLOAD_CONDITION" || INITIAL_DOWNLOAD=no

    if [ "$INITIAL_DOWNLOAD" = "yes" ]; then
        echo "The INITIAL_DOWNLOAD_CONDITION condition was met"
    else
        echo "The INITIAL_DOWNLOAD_CONDITION condition was not met"
    fi
fi

# Perform the initial download.
if [ "$INITIAL_DOWNLOAD" = "yes" ]; then
    echo "Downloading from $S3_URL to $VOLUME_PATH"
    aws s3 sync $DOWNLOAD_OPTIONS "$S3_URL" "$VOLUME_PATH"
fi

# Periodically sync up/down
while true; do
    echo "Sleeping for $SYNC_INTERVAL_SECONDS seconds"
    sleep $SYNC_INTERVAL_SECONDS

    if [ "$SYNC_DOWN" = "yes" ]; then
        echo "Redownloading from $S3_URL to $VOLUME_PATH"
        aws s3 sync $DOWNLOAD_OPTIONS "$S3_URL" "$VOLUME_PATH"
    fi

    if [ "$SYNC_UP" = "yes" ]; then
        echo "Uploading from $VOLUME_PATH to $S3_URL"
        aws s3 sync $UPLOAD_OPTIONS "$VOLUME_PATH" "$S3_URL"
    fi

    if [ "$SYNC_ONCE" = "yes" ]; then
        echo "Finished synchronizing once."
        exit
    fi
done
