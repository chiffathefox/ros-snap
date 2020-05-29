
ARG snap_arch="amd64"

FROM ros:melodic-ros-base-bionic as builder

ARG snap_arch
RUN apt-get update --yes
RUN apt-get install --yes curl jq squashfs-tools

RUN set -x \
    && sds='Snap-Device-Series: 16' \
    && uri=https://api.snapcraft.io/v2/snaps/info \
    && snap_install() { \
        link=`curl -H "$sds" "$uri/$1?architecture=$snap_arch&fields=download" \
            | jq '.["channel-map"][0].download.url' -r` \
        && curl -L "$link" --output "$1.snap" \
        && mkdir -pv "/snap/$1" \
        && unsquashfs -d "/snap/$1/current" "$1.snap"; \
    } \
    && snap_install core \
    && snap_install core18 \
    && snap_install snapcraft \
    && mkdir -p /snap/bin \
    && echo "#!/bin/sh" > /snap/bin/snapcraft \
    && yaml_path=/snap/snapcraft/current/meta/snap.yaml \
    && snap_version="$(awk '/^version:/{print $2}' $yaml_path)" \
    && echo "export SNAP_VERSION=\"$snap_version\"" >> /snap/bin/snapcraft \
    && echo 'exec "$SNAP/usr/bin/python3" "$SNAP/bin/snapcraft" "$@"' \
        >> /snap/bin/snapcraft \
    && chmod +x /snap/bin/snapcraft


FROM ros:melodic-ros-base-bionic

ARG snap_arch

COPY --from=builder /snap/core /snap/core
COPY --from=builder /snap/core18 /snap/core18
COPY --from=builder /snap/snapcraft /snap/snapcraft
COPY --from=builder /snap/bin/snapcraft /snap/bin/snapcraft

RUN apt-get update \
    && apt-get upgrade --yes \
    && apt-get install --yes sudo locales \
    && locale-gen en_US.UTF-8

ENV LANG="en_US.UTF-8"
ENV LANGUAGE="en_US:en"
ENV LC_ALL="en_US.UTF-8"
ENV PATH="/snap/bin:$PATH"
ENV SNAP_ARCH=$snap_arch
ENV SNAP="/snap/snapcraft/current"
ENV SNAP_NAME="snapcraft"

