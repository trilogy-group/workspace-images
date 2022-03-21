FROM centos:7

# Update libstdc++.so.6 (required for vscode)
USER root
COPY libstdc\\+\\+.so.6.0.28.* /usr/lib64/
RUN /bin/bash -c 'ARCH=`uname -m` && \
    if [ "$ARCH" == "x86_64" ]; then \
        mv /usr/lib64/libstdc++.so.6.0.28.amd64 /usr/lib64/libstdc++.so.6.0.28 && \
        rm /usr/lib64/libstdc++.so.6.0.28.arm64; \
    else \
        mv /usr/lib64/libstdc++.so.6.0.28.arm64 /usr/lib64/libstdc++.so.6.0.28 && \
        rm /usr/lib64/libstdc++.so.6.0.28.amd64; \
    fi && \
    mv /usr/lib64/libstdc++.so.6 /usr/lib64/libstdc++.so.6.bkp && \
    ln -s libstdc++.so.6.0.28 /usr/lib64/libstdc++.so.6'

COPY libutil-2.31.so.* /usr/lib64/
RUN /bin/bash -c 'ARCH=`uname -m` && \
    if [ "$ARCH" == "x86_64" ]; then \
        mv /usr/lib64/libutil-2.31.so.amd64 /usr/lib64/libutil-2.31.so && \
        rm /usr/lib64/libutil-2.31.so.arm64; \
    else \
        mv /usr/lib64/libutil-2.31.so.arm64 /usr/lib64/libutil-2.31.so && \
        rm /usr/lib64/libutil-2.31.so.amd64; \
    fi && \
    mv /usr/lib64/libutil.so.1 /usr/lib64/libutil.so.1.bkp && \
    ln -s libutil-2.31.so /usr/lib64/libutil.so.1'


# Install core packages
USER root
RUN yum update -y && yum install -y \
  base-devel \
  bash-completion \
  wget \
  curl \
  sudo \

# Install git
USER root
ARG GIT_VERSION=2.32.0
RUN yum update -y && yum groupinstall -y "Development Tools" && \
    yum install -y gettext-devel openssl-devel perl-CPAN perl-devel zlib-devel && \
    wget https://github.com/git/git/archive/v${GIT_VERSION}.tar.gz -O git.tar.gz && \
    tar -zxf git.tar.gz && \
    rm git.tar.gz && \
    cd git-* && \
    make configure && \
    ./configure --prefix=/usr && \
    make install && \
    cd .. && rm -rf git-${GIT_VERSION}

# git-lfs
RUN /bin/bash -c 'ARCH=`uname -m` && \
    GITLFS_VERSION=v2.13.2 && \
    if [ "$ARCH" == "x86_64" ]; then \
        GITLFS_FILENAME=git-lfs-linux-amd64-${GITLFS_VERSION}.tar.gz; \
    else \
        GITLFS_FILENAME=git-lfs-linux-arm64-${GITLFS_VERSION}.tar.gz; \
    fi && \
    wget https://github.com/git-lfs/git-lfs/releases/download/${GITLFS_VERSION}/${GITLFS_FILENAME} && \
    TEMP_DIR=/tmp/git-lfs && \
    mkdir -p ${TEMP_DIR} && \
    tar -zxf ${GITLFS_FILENAME} -C ${TEMP_DIR} && \
    rm ${GITLFS_FILENAME} && \
    ${TEMP_DIR}/install.sh && \
    rm -rf ${TEMP_DIR}'
