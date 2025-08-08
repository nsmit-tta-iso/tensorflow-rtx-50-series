ARG VERSION=latest

FROM nvidia/cuda:12.8.1-cudnn-devel-ubuntu24.04 AS builder

USER root

#####################################
# BUILD TENSORFLOW
#####################################

RUN apt-get install -y libpq-dev wget software-properties-common lsb-release git python3 python3-venv python3-pip 

RUN add-apt-repository ppa:deadsnakes/ppa -y

RUN apt update

RUN apt install python3.13 python3.13-dev -y

RUN mkdir /workspace

WORKDIR /workspace

RUN wget https://apt.llvm.org/llvm.sh && \
    chmod +x llvm.sh && \
    ./llvm.sh 20 all && \
    update-alternatives --install /usr/bin/clang clang /usr/bin/clang-20 100 && \
    rm llvm.sh

RUN git clone https://github.com/tensorflow/tensorflow.git
WORKDIR /workspace/tensorflow
RUN git checkout 1f4ee8bcd86b7333e9a98f666d70309fc7c8907a

RUN wget  https://github.com/bazelbuild/bazelisk/releases/download/v1.26.0/bazelisk-linux-amd64 -O /usr/bin/bazel && \
    chmod +x /usr/bin/bazel && \
    bazel version

COPY .tf_configure.bazelrc .

RUN bazel build //tensorflow/tools/pip_package:wheel --repo_env=USE_PYWRAP_RULES=1 --repo_env=WHEEL_NAME=tensorflow --config=cuda --config=cuda_wheel

WORKDIR /workspace
RUN cp tensorflow/bazel-bin/tensorflow/tools/pip_package/wheel_house/*.whl .

CMD ["bash"]
