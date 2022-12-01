FROM hashicorp/terraform:1.3.6 AS terraform

FROM ubuntu:22.04 AS aws

RUN apt update && \
    apt install -y unzip curl && \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf awscliv2.zip

FROM ubuntu:22.04 AS base
RUN apt update && \
    apt install -y unzip curl && \
    curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash && \
    curl -Lso tfsec https://github.com/tfsec/tfsec/releases/download/v1.15.4/tfsec-linux-amd64 && \
    chmod +x tfsec && \
    mv tfsec /usr/local/bin/tfsec && \
    curl -1sLf 'https://dl.cloudsmith.io/public/evilmartians/lefthook/setup.deb.sh' | sudo -E bash && \
    apt install -y lefthook

FROM ubuntu:22.04

COPY --from=terraform /bin/terraform /bin/terraform
COPY --from=aws /usr/local/bin/aws /usr/local/bin/aws
COPY --from=base /usr/local/bin/tflint /usr/local/bin/tflint
COPY --from=base /usr/local/bin/tfsec /usr/local/bin/tfsec

CMD ["bash"]
