FROM centos:7
LABEL maintainer faisalburhanudin@gmail.com

RUN yum update -y && yum install epel-release -y && yum install -y \
        python-devel \
        python-pip \
        git \
        cmake \
        make \
        wget \
        gcc-c++ \
        protobuf-devel \
        hdf5-devel \
        lmdb-devel \
        leveldb-devel \
        snappy-devel \
        opencv-devel \
        atlas-devel \
        doxygen \
        gflags-devel \
        openblas-devel \
        glog-devel

RUN wget https://dl.bintray.com/boostorg/release/1.68.0/source/boost_1_68_0.tar.gz && \
        tar -xf boost_1_68_0.tar.gz && \
        cd boost_1_68_0 && \
        ./bootstrap.sh --prefix=/usr/local/ && ./b2 install --prefix=/usr/local/ --with=all && \
        cd .. && rm -r boost_1_68_0.tar.gz

ENV CAFFE_ROOT=/opt/caffe
WORKDIR $CAFFE_ROOT

# FIXME: use ARG instead of ENV once DockerHub supports this
# https://github.com/docker/hub-feedback/issues/460
ENV CLONE_TAG=1.0

RUN git clone -b ${CLONE_TAG} --depth 1 https://github.com/BVLC/caffe.git . && \
    pip install --upgrade pip && \
    cd python && pip install -r requirements.txt && cd .. && \
    mkdir build && cd build && \
    cmake -DCPU_ONLY=1 -DBLAS=open -Wno-dev .. && \
    make -j"$(nproc)"

ENV PYCAFFE_ROOT $CAFFE_ROOT/python
ENV PYTHONPATH $PYCAFFE_ROOT:$PYTHONPATH
ENV PATH $CAFFE_ROOT/build/tools:$PYCAFFE_ROOT:$PATH
RUN echo "$CAFFE_ROOT/build/lib" >> /etc/ld.so.conf.d/caffe.conf && ldconfig

WORKDIR /workspace

