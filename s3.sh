#!/bin/sh

set -ex

DOWNLOAD_OPTIONS=""
UPLOAD_OPTIONS=""

if [ "$S3_UPLOAD_DELETE" = "yes" ]; then
    UPLOAD_OPTIONS="$UPLOAD_OPTIONS --delete"
fi

if [ "$S3_DOWNLOAD_DELETE" = "yes" ]; then
    DOWNLOAD_OPTIONS="$DOWNLOAD_OPTIONS --delete"
fi

# Perform the initial download.
if [ "$S3_DOWNLOAD" = "yes" ]; then
    echo "Downloading from $S3_URL to $VOLUME_PATH"
    aws s3 sync $DOWNLOAD_OPTIONS "$S3_URL" "$VOLUME_PATH"
fi

# Periodically redownload, up to the sync limit if applicable.
while true; do
    if [ "$S3_REDOWNLOAD" = "yes" ]; then
        echo "Redownloading from $S3_URL to $VOLUME_PATH"
        aws s3 sync $DOWNLOAD_OPTIONS "$S3_URL" "$VOLUME_PATH"
    fi

    if [ "$S3_UPLOAD" = "yes" ]; then
        echo "Uploading from $VOLUME_PATH to $S3_URL"
        aws s3 sync $UPLOAD_OPTIONS "$VOLUME_PATH" "$S3_URL"
    fi

    if [ "$SYNC_ONCE" = "yes" ]; then
        echo "Finished synchronizing once."
        exit
    fi

    echo "Sleeping for $SYNC_INTERVAL_SECONDS seconds"
    sleep $SYNC_INTERVAL_SECONDS
done
