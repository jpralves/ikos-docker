#------------------------------#
# BUILD Image
#------------------------------#

FROM fedora:41 AS base

ARG build_type=Release
ARG IKOS_VERSION=v3.4

WORKDIR /root/ikos

RUN dnf update -y
RUN dnf install -y gcc g++ cmake gmp-devel mpfr-devel ppl-devel apron-devel \
                   python3 python3-pygments sqlite-devel \
                   zlib-ng-devel libedit-devel tbb-devel git libffi-devel zlib-devel boost-devel

## Install packages from Fedora 36 repo
RUN dnf install -y \
 https://archives.fedoraproject.org/pub/archive/fedora/linux/updates/36/Everything/x86_64/Packages/c/clang-14.0.5-2.fc36.x86_64.rpm \
 https://archives.fedoraproject.org/pub/archive/fedora/linux/updates/36/Everything/x86_64/Packages/c/clang-devel-14.0.5-2.fc36.x86_64.rpm \
 https://archives.fedoraproject.org/pub/archive/fedora/linux/updates/36/Everything/x86_64/Packages/c/clang-tools-extra-14.0.5-2.fc36.x86_64.rpm \
 https://archives.fedoraproject.org/pub/archive/fedora/linux/updates/36/Everything/x86_64/Packages/c/clang-libs-14.0.5-2.fc36.x86_64.rpm \
 https://archives.fedoraproject.org/pub/archive/fedora/linux/updates/36/Everything/x86_64/Packages/c/clang-resource-filesystem-14.0.5-2.fc36.x86_64.rpm \
 https://archives.fedoraproject.org/pub/archive/fedora/linux/updates/36/Everything/x86_64/Packages/l/llvm-14.0.5-2.fc36.x86_64.rpm \
 https://archives.fedoraproject.org/pub/archive/fedora/linux/updates/36/Everything/x86_64/Packages/l/llvm-devel-14.0.5-2.fc36.x86_64.rpm \
 https://archives.fedoraproject.org/pub/archive/fedora/linux/updates/36/Everything/x86_64/Packages/l/llvm-static-14.0.5-2.fc36.x86_64.rpm \
 https://archives.fedoraproject.org/pub/archive/fedora/linux/updates/36/Everything/x86_64/Packages/l/llvm-libs-14.0.5-2.fc36.x86_64.rpm \
 https://archives.fedoraproject.org/pub/archive/fedora/linux/updates/36/Everything/x86_64/Packages/l/llvm-test-14.0.5-2.fc36.x86_64.rpm

## Clone the ikos github repo
RUN git clone --single-branch https://github.com/NASA-SW-VnV/ikos.git . \
 && git checkout tags/${IKOS_VERSION} \
# Patch for python 3.13:
 && curl https://github.com/NASA-SW-VnV/ikos/commit/b3ad5a6f0659c9307c9bea974aaeb17e217c6ded.patch | git apply

WORKDIR /root/ikos/build

ENV MAKEFLAGS="-j4"

RUN cmake \
        -DCMAKE_INSTALL_PREFIX="/opt/ikos" \
        -DCMAKE_BUILD_TYPE="$build_type" \
        -DLLVM_CONFIG_EXECUTABLE="/usr/bin/llvm-config" \
        ..

RUN make

RUN make install
# RUN make check

#------------------------------#
# MAIN Image
#------------------------------#

FROM fedora:41

RUN dnf update -y \
 && dnf install -y python3 boost-devel gmp-devel tbb \
 https://archives.fedoraproject.org/pub/archive/fedora/linux/updates/36/Everything/x86_64/Packages/c/clang-14.0.5-2.fc36.x86_64.rpm \
 https://archives.fedoraproject.org/pub/archive/fedora/linux/updates/36/Everything/x86_64/Packages/c/clang-libs-14.0.5-2.fc36.x86_64.rpm \
 https://archives.fedoraproject.org/pub/archive/fedora/linux/updates/36/Everything/x86_64/Packages/c/clang-resource-filesystem-14.0.5-2.fc36.x86_64.rpm \
 https://archives.fedoraproject.org/pub/archive/fedora/linux/updates/36/Everything/x86_64/Packages/l/llvm-14.0.5-2.fc36.x86_64.rpm \
 https://archives.fedoraproject.org/pub/archive/fedora/linux/updates/36/Everything/x86_64/Packages/l/llvm-libs-14.0.5-2.fc36.x86_64.rpm \
 && dnf clean all

COPY --from=base /opt/ikos /opt/ikos

ENV PATH="/opt/ikos/bin:$PATH"

WORKDIR /src
