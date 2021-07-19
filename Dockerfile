############################
# STEP 1 - Download the lastest cloudimg from ubuntu servers
############################
FROM ubuntu:focal AS builder

RUN apt-get update \
    && apt-get install -y --no-install-recommends gnupg apt-transport-https ca-certificates curl \
    && rm -rf /var/lib/apt/lists/* \
    set -eux; \
    ARCH="$(dpkg --print-architecture)"; \
    curl -SLfO https://partner-images.canonical.com/core/focal/current/ubuntu-focal-core-cloudimg-${ARCH}-root.tar.gz \
    && mkdir temp \
    && mv ubuntu-focal-core-cloudimg-${ARCH}-root.tar.gz /temp \
    && cd temp \
    && tar zxpvf ubuntu-focal-core-cloudimg-${ARCH}-root.tar.gz \
    && rm -rf ubuntu-focal-core-cloudimg-${ARCH}-root.tar.gz


############################
# STEP 2 build a image from scratch using the cloud image download from the previous step
############################
FROM scratch 

MAINTAINER Gabriel Knepper Mendes <gabriel666@gmail.com>


# Copy cloud image from previous step
COPY --from=builder /temp /


CMD ["/bin/bash"]


# First, make sure your package manager supports HTTPS and that the necessary crypto tools are installed:
RUN apt-get update \
    && apt-get install -y --no-install-recommends gnupg apt-transport-https ca-certificates curl \
    && rm -rf /var/lib/apt/lists/*


# Next, add the Fullstaq Ruby repository by creating /etc/apt/sources.list.d/fullstaq-ruby.list. 
RUN echo "deb https://apt.fullstaqruby.org ubuntu-20.04 main" > /etc/apt/sources.list.d/fullstaq-ruby.list


# Then run:
RUN curl -SLfO https://raw.githubusercontent.com/fullstaq-labs/fullstaq-ruby-server-edition/main/fullstaq-ruby.asc \ 
    && apt-key add fullstaq-ruby.asc \
    && apt update


# Then install fullstaq-ruby-common
RUN apt-get install -y --no-install-recommends fullstaq-ruby-common 


#Ruby packages are now available as fullstaq-ruby-<VERSION>:
# RUN apt search fullstaq-ruby


# Set the version
ENV RBENV_VERSION 3.0.2-jemalloc
# ENV RBENV_VERSION 3.0.2-malloctrim

# Install fullstaq ruby
RUN apt-get install -y --no-install-recommends fullstaq-ruby-${RBENV_VERSION}/ubuntu-20.04

# Test Ruby installation
RUN /usr/lib/fullstaq-ruby/versions/${RBENV_VERSION}/bin/ruby --version

# Test GEM
RUN /usr/lib/fullstaq-ruby/versions/${RBENV_VERSION}/bin/gem install --no-document nokogiri


