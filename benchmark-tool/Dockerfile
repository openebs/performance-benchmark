# Alpine Linux is used because of its small filesize. This works since we have
# few dependencies.
FROM alpine:3.9 AS base

# Install root CA certificates so HTTPS works.
RUN apk update
RUN apk add ca-certificates && rm -rf /var/cache/apk/*

# Install dumb-init (explained below) and Terraform.
RUN apk add dumb-init \
            terraform

# Install Python and other dependencies
RUN apk add py3-pip \
            python3-dev



RUN apk add openssh-client



# Install Helm
RUN wget -O /tmp/helm.tar.gz https://get.helm.sh/helm-v3.2.4-linux-amd64.tar.gz
RUN mkdir /tmp/helm
RUN tar -zxvf /tmp/helm.tar.gz -C /tmp/helm
RUN mv /tmp/helm/linux-amd64/helm /usr/local/bin


# # Install Helmfile
# RUN wget -O /usr/local/bin/helmfile https://github.com/roboll/helmfile/releases/download/v0.45.3/helmfile_linux_amd64
# RUN chmod +x /usr/local/bin/helmfile



# Install AWS CLI and dependencies
RUN apk add groff \
            less
RUN pip3 install awscli

# Install bash
RUN apk add bash

# Install jq for JSON parsing
RUN apk add jq

# Install curl
RUN apk add curl

RUN apk add git

RUN git clone https://github.com/openebs/Mayastor /mayastor
RUN cd /mayastor && git checkout v0.2.0


# # Install dig
# RUN wget https://github.com/sequenceiq/docker-alpine-dig/releases/download/v9.10.2/dig.tgz && tar -xf dig.tgz -C /usr/local/bin/ && rm -rf dig.tgz

# # NOTE without this the kubectl binary copied from Kubespray will not work. More
# # information about the issue can be found here:
# # https://stackoverflow.com/questions/34729748/installed-go-binary-not-found-in-path-on-alpine-linux-docker
# RUN mkdir /lib64 && ln -s /lib/libc.musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2

#-------------------------------------------------------------------------------
# This breaks the build into (at least) 2 stages to cut down on build time,
# isolating the more frequently-changing aspects into the later stages.
FROM alpine:3.9 AS infra
COPY --from=base / /

# Copy directories from repository.
COPY terraform /terraform

# # Install all the various Terraform plugins included in the AWS provider.
# RUN terraform init /terraform/eks


# Install kubectl
RUN wget -O /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/v1.16.0/bin/linux/amd64/kubectl
RUN chmod +x /usr/local/bin/kubectl





# Install eksctl
RUN curl --silent --location "https://github.com/weaveworks/eksctl/releases/download/latest_release/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
RUN mv /tmp/eksctl /usr/local/bin

# # Install aws-iam-authenticator
# RUN curl -o aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.13.7/2019-06-11/bin/linux/amd64/aws-iam-authenticator
# RUN chmod +x aws-iam-authenticator
# RUN mv aws-iam-authenticator bin/




COPY deploy /deploy
COPY io_profiles /io_profiles

# Copy and make all scripts executable.
COPY script /script
RUN find /script -type f -exec chmod +x {} \;

# COPY helm-charts /helm-charts


# # This allows us to use the plugins installed manually above.
# ENV TF_SKIP_PROVIDER_VERIFY 1



# Dumb-init, a simple process supervisor, is used as a wrapper for commands
# executed in the container. This allows signals to be passed from the host
# machine to processes running in the container. For example, without dumb-init,
# ctrl-C'ing out of `docker run` would leave Terraform or Ansible running inside
# a detached container (which is not what we want).
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
