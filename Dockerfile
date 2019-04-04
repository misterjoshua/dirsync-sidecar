FROM mesosphere/aws-cli

ENV VOLUME_PATH /data

# A place for the container user to perform custom initialization.
ENV INITIALIZE_EXPRESSION true

ENV UPLOAD_DELETE_UNKNOWN no
ENV DOWNLOAD_DELETE_UNKNOWN no

# Initial download settings.
ENV INITIAL_DOWNLOAD_CONDITION true

# Continuous sync settings.
ENV SYNC_INTERVAL_SECONDS 60
ENV SYNC_UP yes
ENV SYNC_DOWN no
ENV SYNC_ONCE no

ENV S3_URL s3://your-bucket-path

VOLUME /data

ADD s3.sh /s3.sh

ENTRYPOINT /bin/sh /s3.sh
