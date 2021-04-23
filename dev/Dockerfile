# Copyright (c) 2020 Gitpod GmbH. All rights reserved.
# Licensed under the GNU Affero General Public License (AGPL).
# See License-AGPL.txt in the project root for license information.

FROM public.ecr.aws/g7f0f4s4/gitpod/full-vnc:latest

ENV TRIGGER_REBUILD 9

USER root
ARG AWS_ACCESS_KEY_ID
ARG AWS_SECRET_ACCESS_KEY
### cloud_sql_proxy ###
ARG CLOUD_SQL_PROXY=/usr/local/bin/cloud_sql_proxy
RUN curl -fsSL https://dl.google.com/cloudsql/cloud_sql_proxy.linux.arm64 > $CLOUD_SQL_PROXY \
    && chmod +x $CLOUD_SQL_PROXY

### Helm3 ###
RUN mkdir -p /tmp/helm/ \
    && curl -fsSL https://get.helm.sh/helm-v3.5.2-linux-arm64.tar.gz | tar -xzvC /tmp/helm/ --strip-components=1 \
    && cp /tmp/helm/helm /usr/local/bin/helm \
    && cp /tmp/helm/helm /usr/local/bin/helm3 \
    && rm -rf /tmp/helm/ \
    && helm completion bash > /usr/share/bash-completion/completions/helm

### kubernetes ###
RUN mkdir -p /usr/local/kubernetes/ && \
    curl -fsSL https://github.com/kubernetes/kubernetes/releases/download/v1.17.16/kubernetes.tar.gz \
    | tar -xzvC /usr/local/kubernetes/ --strip-components=1 \
    && KUBERNETES_SKIP_CONFIRM=true /usr/local/kubernetes/cluster/get-kube-binaries.sh \
    && chown gitpod:gitpod -R /usr/local/kubernetes

ENV PATH=$PATH:/usr/local/kubernetes/cluster/:/usr/local/kubernetes/client/bin/

### kubectl ###
RUN curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - \
    # really 'xenial'
    && add-apt-repository -yu "deb https://apt.kubernetes.io/ kubernetes-xenial main" \
    && install-packages kubectl=1.20.0-00 \
    && kubectl completion bash > /usr/share/bash-completion/completions/kubectl

RUN curl -fsSL -o /usr/bin/kubectx https://raw.githubusercontent.com/ahmetb/kubectx/master/kubectx && chmod +x /usr/bin/kubectx \
 && curl -fsSL -o /usr/bin/kubens  https://raw.githubusercontent.com/ahmetb/kubectx/master/kubens  && chmod +x /usr/bin/kubens

RUN curl -fsSL https://go.kubebuilder.io/dl/2.3.2/linux/arm64 | tar -xz -C /tmp/ \
    && sudo mkdir -p /usr/local/kubebuilder \
    && sudo mv /tmp/kubebuilder_2.3.2_linux_arm64/* /usr/local/kubebuilder \
    && rm -rf /tmp/*

### MySQL client ###
RUN install-packages mysql-client

# golangci-lint
RUN cd /usr/local && wget https://golang.org/dl/go1.16.3.linux-arm64.tar.gz && rm -rf /usr/local/go && tar -C /usr/local -xzf go1.16.3.linux-arm64.tar.gz \
    && echo "export PATH=\$PATH:/usr/local/" >> /home/gitpod/.bashrc 

RUN cd /usr/local && curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s v1.34.0

# leeway
ENV LEEWAY_NESTED_WORKSPACE=true
RUN cd /usr/bin && aws s3 cp s3://arm-devspaces/leeway . && chmod +x leeway

# dazzle
RUN cd /usr/bin && aws s3 cp s3://arm-devspaces/dazzle . && chmod +x leeway

# werft CLI
ENV WERFT_K8S_NAMESPACE=werft
ENV WERFT_DIAL_MODE=kubernetes
RUN cd /usr/bin && aws s3 cp s3://arm-devspaces/werft . && chmod +x werft

# yq - jq for YAML files
# Note: we rely on version 3.x.x in various places, 4.x breaks this!
RUN cd /usr/bin && curl -fsSL https://github.com/mikefarah/yq/releases/download/3.4.1/yq_linux_arm64 > yq && chmod +x yq

# release helper
RUN cd /usr/bin && curl -fsSL https://github.com/c4milo/github-release/releases/download/v1.1.0/github-release_v1.1.0_linux_arm64.tar.gz | tar xz

### Protobuf
RUN set -ex \
    && tmpdir=$(mktemp -d) \
    && curl -fsSL -o $tmpdir/protoc.zip https://github.com/protocolbuffers/protobuf/releases/download/v3.15.5/protoc-3.15.5-linux-aarch_64.zip \
    && mkdir -p /usr/lib/protoc && cd /usr/lib/protoc && unzip $tmpdir/protoc.zip \
    && chmod -R o+r+x /usr/lib/protoc/include \
    && chmod -R +x /usr/lib/protoc/bin \
    && ln -s /usr/lib/protoc/bin/* /usr/bin \
    && rm -rf $tmpdir

# TODO
### Telepresence ###
# RUN curl -fsSL https://packagecloud.io/datawireio/telepresence/gpgkey | apt-key add - \
#     # 'cosmic' not supported
#     && add-apt-repository -yu "deb https://packagecloud.io/datawireio/telepresence/ubuntu/ bionic main" \
#     # 0.95 (current at the time of this commit) is broken
#     && sudo apt-get update \
#     && install-packages \
#         iproute2 \
#         iptables \
#         net-tools \
#         socat \
#         telepresence=0.109
# RUN uname -a
# RUN sudo apt-get update -y \
#     && sudo apt-get install -y iproute2 iptables net-tools socat
# RUN curl -s https://packagecloud.io/install/repositories/datawireio/telepresence/script.deb.sh | sudo bash && sudo apt-get update -y && sudo apt install --no-install-recommends telepresence

### Toxiproxy CLI
RUN aws s3 cp s3://arm-devspaces/toxiproxy-cli toxiproxy \
    && mv toxiproxy /usr/bin/ \
    && chmod +x /usr/bin/toxiproxy

### libseccomp > 2.5.0
RUN install-packages gperf \
    && cd $(mktemp -d) \
    && curl -fsSL https://github.com/seccomp/libseccomp/releases/download/v2.5.1/libseccomp-2.5.1.tar.gz | tar xz \
    && cd libseccomp-2.5.1 && ./configure && make && make install

USER gitpod

# Fix node version we develop against
ARG GITPOD_NODE_VERSION=12.18.3
RUN bash -c ". .nvm/nvm.sh \
        && nvm install $GITPOD_NODE_VERSION \
        && npm install -g typescript yarn"
ENV PATH=/home/gitpod/.nvm/versions/node/v${GITPOD_NODE_VERSION}/bin:$PATH

# Fix the Go version
ENV GOPATH=$HOME/go-packages
ENV GOROOT=$HOME/go
RUN go get golang.org/dl/go1.16 && \
    go1.16 download && \
    mv $(which go1.16) $(which go)
ENV GOPATH=/workspace/go \
    PATH=/workspace/go/bin:$PATH

## Register leeway autocompletion in bashrc
RUN bash -c "echo . \<\(leeway bash-completion\) >> ~/.bashrc"

# TODO
# Install pulumi
RUN curl -fsSL https://get.pulumi.com | sh \
    && mkdir -p /home/gitpod/.pulumi/bin \
    && echo "export PATH=\$PATH:/home/gitpod/.pulumi/bin" >> /home/gitpod/.bashrc 

# RUN curl -fsSL https://get.pulumi.com/releases/sdk/pulumi-v1.9.1-linux-x64.tar.gz | tar xvzC . \
#     && mkdir -p /home/gitpod/.pulumi/bin \
#     && mv pulumi/* /home/gitpod/.pulumi/bin \
#     && echo "export PATH=\$PATH:/home/gitpod/.pulumi/bin" >> /home/gitpod/.bashrc \
#     && rm -Rf ./pulumi

### Google Cloud ###
# not installed via repository as then 'docker-credential-gcr' is not available
ARG GCS_DIR=/opt/google-cloud-sdk
ENV PATH=$GCS_DIR/bin:$PATH
# Downloading gcloud package
RUN curl https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.tar.gz > /tmp/google-cloud-sdk.tar.gz

# Installing the package
RUN sudo mkdir -p /usr/local/gcloud \
  && sudo tar -C /usr/local/gcloud -xvf /tmp/google-cloud-sdk.tar.gz \
  && sudo /usr/local/gcloud/google-cloud-sdk/install.sh

# Adding the package path to local
ENV PATH $PATH:/usr/local/gcloud/google-cloud-sdk/bin

# RUN sudo apt-get update \
#     && sudo apt-get install apt-transport-https ca-certificates gnupg -y \
#     && echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list \
#     && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - \
#     && sudo apt-get update && sudo apt-get install google-cloud-sdk -y
#     # && gcloud init
RUN echo ${GOPATH}
RUN echo ${USER}
# TODO fix this
# RUN go get github.com/GoogleCloudPlatform/docker-credential-gcr
# RUN docker-credential-gcr configure-docker
# RUN sudo chown gitpod: /opt \
#     && mkdir $GCS_DIR \
#     && curl -fsSL https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-245.0.0-linux-aarch64.tar.gz \
#     | tar -xzvC /opt \
#     && /opt/google-cloud-sdk/install.sh --quiet --usage-reporting=false --bash-completion=true \
#     --additional-components docker-credential-gcr alpha beta \
#     # needed for access to our private registries
#     && docker-credential-gcr configure-docker

# Install tools for gsutil
RUN sudo install-packages \
        gcc \
        python-dev \
        python-setuptools

RUN bash -c "pip uninstall crcmod; pip install --no-cache-dir -U crcmod"

### gitpod-core specific gcloud/kubectl config
# Copy GCloud default config that points to gitpod-dev
ARG GCLOUD_CONFIG_DIR=/home/gitpod/.config/gcloud
COPY --chown=gitpod gcloud-default-config $GCLOUD_CONFIG_DIR/configurations/config_default

# Set kubeconfig file for dev cluster, using GCloud Application Default Credentials (ADC) as auth provider
ARG KUBE_CONFIG_PATH=/home/gitpod/.kube/config
COPY --chown=gitpod kubeconfig.yaml $KUBE_CONFIG_PATH

# Set Application Default Credentials (ADC) based on user-provided env var
RUN echo ". /workspace/gitpod/scripts/setup-google-adc.sh" >> ~/.bashrc

ENV DB_HOST=localhost

ENV LEEWAY_WORKSPACE_ROOT=~/code/
ENV LEEWAY_REMOTE_CACHE_BUCKET=gitpod-core-leeway-cache-branch

### AWS Cli ###
RUN pip install --no-cache-dir awscli

# Install aws-iam-authenticator
RUN sudo curl -fsSL -o aws-iam-authenticator "https://amazon-eks.s3-us-west-2.amazonaws.com/1.13.7/2019-06-11/bin/linux/arm64/aws-iam-authenticator" \
    && sudo chmod +x ./aws-iam-authenticator \
    && sudo mkdir -p $HOME/.aws-iam \
    && sudo mv ./aws-iam-authenticator $HOME/.aws-iam/aws-iam-authenticator \
    && sudo chown -R gitpod:gitpod $HOME/.aws-iam

# Install Terraform
ARG RELEASE_URL="https://releases.hashicorp.com/terraform/0.14.2/terraform_0.14.2_linux_arm64.zip"
RUN mkdir -p ~/.terraform \
    && cd ~/.terraform \
    && curl -fsSL -o terraform_linux_arm64.zip ${RELEASE_URL} \
    && unzip *.zip \
    && rm -f *.zip \
    && printf "terraform -install-autocomplete\n" >>~/.bashrc

# Install GraphViz to help debug terraform scripts
RUN sudo install-packages graphviz
RUN sudo chmod -R 777 /home/gitpod/
ENV PATH=$PATH:$HOME/.aws-iam:$HOME/.terraform
RUN echo ${GOPATH}
USER root
# RUN echo -e "#!/bin/bash\n node -v \$@" > entrypoint.sh
# RUN chmod +x entrypoint.sh
# RUN node -v
# ENTRYPOINT [ "/bin/bash" ]
# ENTRYPOINT ["./entrypoint.sh"]
# CMD [ "-v", "help" ]