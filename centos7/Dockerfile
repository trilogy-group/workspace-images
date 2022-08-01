FROM centos:7

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
