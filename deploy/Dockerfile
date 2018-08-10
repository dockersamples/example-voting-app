FROM ruby:2.3

RUN apt-get update && apt-get install -y curl python3-pip

ARG AWS_CLI_VERSION="1.15.71"
ARG KUBECTL_VERSION="1.10.3"
ARG KUBECTL_BUILD_DATE="2018-07-26"

# install kubectl 
RUN curl -L https://amazon-eks.s3-us-west-2.amazonaws.com/${KUBECTL_VERSION}/${KUBECTL_BUILD_DATE}/bin/linux/amd64/kubectl > /usr/local/bin/kubectl \
    && chmod +x /usr/local/bin/kubectl

# install aws-iam-authenticator
RUN curl -L "https://amazon-eks.s3-us-west-2.amazonaws.com/${KUBECTL_VERSION}/${KUBECTL_BUILD_DATE}/bin/linux/amd64/aws-iam-authenticator" > /usr/local/bin/aws-iam-authenticator \
    && chmod +x /usr/local/bin/aws-iam-authenticator

# install aws cli
RUN which python
RUN which python3
RUN pip3 install awscli==${AWS_CLI_VERSION} && \
  mkdir -p "${HOME}/.aws"

RUN which aws

# copy helper scripts to set up kubeconfig

COPY . .
#COPY env_var_helper_client.sh ./deploy/env_var_helper_client.rb ./
RUN chmod +x env_var_helper_client.sh

ENTRYPOINT ["./env_var_helper_client.sh"]
