#!/bin/bash
# Build the Debian packages for one upstream project, at the release pinned in versions.env,
# in a clean Debian 13 container on this host (arm64 for ustreamer; kvmd builds anywhere).
#   ./build.sh ustreamer|kvmd        packages land in ./out/
set -euo pipefail
cd "$(dirname "$0")"
. ./versions.env
pkg=${1:?usage: build.sh ustreamer|kvmd}
case $pkg in
  ustreamer) repo=https://github.com/pikvm/ustreamer tag=v$USTREAMER_VERSION commit=$USTREAMER_COMMIT ;;
  kvmd)      repo=https://github.com/pikvm/kvmd      tag=v$KVMD_VERSION      commit=$KVMD_COMMIT ;;
  *) echo "unknown package: $pkg" >&2; exit 2 ;;
esac
mkdir -p out
docker run --rm -v "$PWD:/repo:ro" -v "$PWD/out:/out" \
  -e PKG="$pkg" -e REPO="$repo" -e TAG="$tag" -e COMMIT="$commit" -e OWNER="$(id -u):$(id -g)" \
  debian:trixie bash -euo pipefail -c '
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -qq
    apt-get install -y -qq --no-install-recommends git ca-certificates devscripts equivs build-essential >/dev/null
    git clone -q --depth 1 --branch "$TAG" "$REPO" "/build/$PKG"
    got=$(git -C "/build/$PKG" rev-parse HEAD)
    [ "$got" = "$COMMIT" ] || { echo "tag $TAG is $got, expected $COMMIT" >&2; exit 1; }
    cp -r "/repo/packages/$PKG/debian" "/build/$PKG/"
    cd "/build/$PKG"
    mk-build-deps -i -r -t "apt-get -y -qq --no-install-recommends" debian/control >/dev/null
    dpkg-buildpackage -us -uc -b
    cp ../*.deb /out/
    chown "$OWNER" /out/*.deb
  '
ls -l out/
