FROM centos:7

COPY libstdc++.so.6.0.24.* /usr/lib64/
#USER root
RUN /bin/bash -c 'ARCH=`uname -m` && \
    if [ "$ARCH" == "x86_64" ]; then \
        mv /usr/lib64/libstdc++.so.6.0.24.amd64 /usr/lib64/libstdc++.so.6.0.24 && \
        rm /usr/lib64/libstdc++.so.6.0.24.arm64; \
    else \
        mv /usr/lib64/libstdc++.so.6.0.24.arm64 /usr/lib64/libstdc++.so.6.0.24 && \
        rm /usr/lib64/libstdc++.so.6.0.24.amd64; \
    fi && \
    mv /usr/lib64/libstdc++.so.6 /usr/lib64/libstdc++.so.6.bkp && \
    ln -s /usr/lib64/libstdc++.so.6.0.24 /usr/lib64/libstdc++.so.6'
